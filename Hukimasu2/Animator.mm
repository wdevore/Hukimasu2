//
//  Animator.m
//  Hukimasu
//
//  Created by William DeVore on 5/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "StringUtilities.h"
#import "Utilities.h"

#import <math.h>
#import <algorithm>

#import "Animator.h"
#import "LinearInterpolator.h"
#import "TimingTarget.h"
#import "Cocos2dTimingSource.h"
#import "KeyValues.h"
#import "PropertySetterTimingTarget.h"

int Animator::INFINITE = -1;

Animator::Animator() {
    interpolator = NULL;
    initialize();
}

// NOTE: The Cocos2dTimingSource is created in the WorldLayer and bound
// to this animator.
Animator::Animator(int _duration) {
    // Default interpolator is Linear
    interpolator = NULL;

    initialize();

    duration = _duration;
    // The timer is set externally for this project.
}

Animator::Animator(int _duration, TimingTargetAdapter* target)
{
    // Default interpolator is Linear
    interpolator = NULL;
    
    initialize();
    
    duration = _duration;

    addTarget(target);
    // The timer is set externally for this project.
}

Animator::Animator(int duration, double repeatCount, RepeatBehavior repeatBehavior, TimingTargetAdapter* target)
{
    // Default interpolator is Linear
    interpolator = NULL;
    
    initialize();
    
    this->duration = duration;
    this->repeatCount = repeatCount;
    this->repeatBehavior = repeatBehavior;

    addTarget(target);

    // Set convenience variable: do we have an integer number of cycles?
	intRepeatCount = rint(repeatCount) == repeatCount;
    //StringUtilities::log("Animator::getTimingFraction intRepeatCount:", intRepeatCount);

    // The timer is set externally for this project.
}

Animator::Animator(int duration, double repeatCount, RepeatBehavior repeatBehavior, TimingTargetAdapter* target, Interpolator* interpolator)
{
    this->interpolator = interpolator;
    
    initialize();
    
    this->duration = duration;
    this->repeatCount = repeatCount;
    this->repeatBehavior = repeatBehavior;
    
    addTarget(target);
    
    // Set convenience variable: do we have an integer number of cycles?
	intRepeatCount = rint(repeatCount) == repeatCount;
    //StringUtilities::log("Animator::getTimingFraction intRepeatCount:", intRepeatCount);
    
    // The timer is set externally for this project.
}

Animator::~Animator() {
    // We despose of the targets as well.
    std::list<TimingTargetAdapter*>::iterator iter = targets.begin();
    
    while (iter != targets.end()) {
        // This target is more likely to be a PropertySetterTimingTarget type.
        TimingTargetAdapter* target = *iter;
        
        PropertySetterTimingTarget<float>* f = dynamic_cast<PropertySetterTimingTarget<float>* >(target);
        if (f != NULL)
        {
            KeyValues<float>* scaleKeyValues = f->getKeyValues();
            if (scaleKeyValues != NULL)
            {
                StringUtilities::log("ViewZone::~ViewZone deleting float keyvalues");
                scaleKeyValues->releaseAsFloats();
            }
        }
        else
        {
            PropertySetterTimingTarget<b2Vec2>* b = dynamic_cast<PropertySetterTimingTarget<b2Vec2>* >(target);
            if (b != NULL)
            {
                KeyValues<b2Vec2>* scaleKeyValues = b->getKeyValues();
                if (scaleKeyValues != NULL)
                {
                    StringUtilities::log("ViewZone::~ViewZone deleting b2Vec keyvalues");
                    scaleKeyValues->releaseAsb2Vectors();
                }
            }
        }
        StringUtilities::log("Animator::~Animator deleting associated target");
        delete target;
        ++iter;
    }
    
    targets.clear();

    // Note: the client should handle delete.
    //delete interpolator;
}

void Animator::initialize()
{
    timingSourceTarget =NULL;
    timer = NULL;
    ticks = 0;
    
    intRepeatCount = true;  // for typical cases of repeated cycles
    timeToStop = false;     // This gets triggered during fraction calculation
    hasBegun = false;
    pauseBeginTime = 0;        // Used for pause/resume
    running = false;        // Used for isRunning()
    
    // Private variables to hold the internal "envelope" values that control
    // how the cycle is started, ended, and repeated.
    repeatCount = 1.0;
    
    repeatBehavior = Animator::REVERSE;
    endBehavior = Animator::HOLD;
    
    acceleration = 0;
    deceleration = 0.0f;
    startFraction = 0.0f;
    startDirection = Animator::FORWARD; // Direction of each cycle
    startDelay = 0;
    accumTime = cycleAccumTime = 0;
    
    if (interpolator == NULL)
        interpolator = new LinearInterpolator();
    
    previousTime = 0;

    // This timing source will fire events that will eventually
    // effect the timing target via the Animator.
    // This source is actually driven by the tick() method of the Layer.
    Cocos2dTimingSource* timerSource = new Cocos2dTimingSource();
    Utilities::addTimingSource(timerSource);
    timerSource->attachAnimator(this);

}

Animator::Direction Animator::getStartDirection()
{
    return startDirection;
}

void Animator::setStartDirection(Direction startDirection)
{
    this->startDirection = startDirection;
}

Interpolator* Animator::getInterpolator()
{
    return interpolator;
}

void Animator::setInterpolator(Interpolator* interpolator)
{
    if (this->interpolator != NULL)
        delete interpolator;
    this->interpolator = interpolator;
}

void Animator::setAcceleration(float acceleration)
{
    if (acceleration < 0 || acceleration > 1.0f) {
        StringUtilities::dump("Acceleration value cannot lie outside [0,1] range");
    }
    
    if (acceleration > (1.0f - deceleration)) {
        StringUtilities::dump("Acceleration value cannot be greater than (1 - deceleration)");
    }
    
    this->acceleration = acceleration;
}

void Animator::setDeceleration(float deceleration)
{
    if (deceleration < 0 || deceleration > 1.0f) {
       StringUtilities::dump("Deceleration value cannot lie outside [0,1] range");
    }
    
    if (deceleration > (1.0f - acceleration)) {
        StringUtilities::dump("Deceleration value cannot be greater than (1 - acceleration)");
    }
    
    this->deceleration = deceleration;
}

float Animator::getAcceleration()
{
    return acceleration;
}

float Animator::getDeceleration()
{
    return deceleration;
}

void Animator::addTarget(TimingTargetAdapter* targetAdapter)
{
    std::list<TimingTargetAdapter*>::iterator iter = targets.begin();
    
    bool found = false;
    
    while (iter != targets.end()) {
        TimingTargetAdapter* target = *iter;
        if (target->getId() == targetAdapter->getId()) {
            found = true;
            break;
        }
        ++iter;
    }
    
    if (!found) {
        targets.push_back(targetAdapter);
    }

}

void Animator::removeTarget(TimingTargetAdapter* target)
{
    targets.remove(target);
}

int Animator::getDuration()
{
	return duration;
}

void Animator::setDuration(int duration)
{
    this->duration = duration;
}

double Animator::getRepeatCount()
{
	return repeatCount;
}

void Animator::setRepeatCount(double repeatCount)
{
    validateRepeatCount(repeatCount);
    this->repeatCount = repeatCount;
}

int Animator::getStartDelay()
{
	return startDelay;
}

void Animator::setStartDelay(long startDelay)
{
    if (startDelay < 0) {
        std::string msg;
        msg += "startDelay (";
        msg += StringUtilities::toString(startDelay);
        msg += ") cannot be < 0";
        StringUtilities::dump(msg);
    }
    
    this->startDelay = startDelay;
    
    //timer->setStartDelay(startDelay);
}

Animator::RepeatBehavior Animator::getRepeatBehavior()
{
	return repeatBehavior;
}

void Animator::setRepeatBehavior(RepeatBehavior repeatBehavior)
{
    this->repeatBehavior = repeatBehavior;
}

Animator::EndBehavior Animator::getEndBehavior() {
	return endBehavior;
}

void Animator::setEndBehavior(EndBehavior endBehavior)
{
    this->endBehavior = endBehavior;
}

float Animator::getStartFraction()
{
    return startFraction;
}

void Animator::setStartFraction(float startFraction)
{
    if (startFraction < 0 || startFraction > 1.0f) {
        StringUtilities::dump("initialFraction must be between 0 and 1");
    }
    
    this->startFraction = startFraction;
}

void Animator::start()
{
    hasBegun = false;
    
    running = true;
    
    // Initialize start time variables
    direction = startDirection;
    cycleAccumTime = 0;
    
    // We want to delay some milliseconds after the start time.
    //int delay = getStartDelay();
    //StringUtilities::log("Animator::start delay: ", delay);
    
    // NOTE we may need to use = -delay because we are accumulating
    //startTime = microTime() + delay;
    //startTime = - delay;
    startTime = 0;
    //StringUtilities::log("Animator::start startTime: ", startTime);
    
    if (duration != INFINITE && ((direction == FORWARD && startFraction > 0.0f) || (direction == BACKWARD && startFraction < 1.0f))) {
            float offsetFraction = (direction == FORWARD) ? startFraction : (1.0f - startFraction);
            StringUtilities::log("Animator::start offsetFraction: ", offsetFraction);
            long startDelta = (long)(duration * offsetFraction);
            StringUtilities::log("Animator::start startDelta: ", startDelta);
            startTime -= startDelta;
        }
    
	currentStartTime = startTime;
    
    accumTime = startTime;
    
    // Preset previous time so that a proper delta can be calculated.
    //Utilities::previousTime = Utilities::FRAME_TIME + Utilities::WINDOW_DRIFT;
    //previousTime = 18000;
    //previousTimeDelta = Utilities::FRAME_TIME + Utilities::WINDOW_DRIFT;
    
	timer->start();
}

bool Animator::isRunning()
{
	return running;
}

void Animator::stop()
{
    //StringUtilities::dump("Animator::stop");

	timer->stop();
    end();
    timeToStop = false;
    running = false;
    pauseBeginTime = 0;
}

void Animator::cancel()
{
    //StringUtilities::dump("Animator::cancel");

    timer->stop();
    timeToStop = false;
    running = false;
    pauseBeginTime = 0;
}

void Animator::pause()
{
    //StringUtilities::dump("Animator::pause");

    if (isRunning()) {
        //pauseBeginTime = microTime();
        //pauseBeginTime = Utilities::microTimeDelta(&previousTimeDelta);
        pauseBeginTime = Utilities::getTimeDelta();//timer->microTimeDelta();
        running = false;
        timer->stop();
    }
}

void Animator::resume()
{
    //StringUtilities::dump("Animator::resume");

    if (pauseBeginTime > 0) {
        //long pauseDelta = (microTime() - pauseBeginTime);
        //long pauseDelta = (Utilities::microTimeDelta(&previousTimeDelta) - pauseBeginTime);
        long pauseDelta = (Utilities::getTimeDelta() - pauseBeginTime);//(timer->microTimeDelta() - pauseBeginTime);
        startTime += pauseDelta;
        currentStartTime += pauseDelta;
        timer->start();
        pauseBeginTime = 0;
        running = true;
    }
}

void Animator::timingEvent(float fraction)
{
    std::list<TimingTargetAdapter*>::iterator iter = targets.begin();
    
    while (iter != targets.end()) {
        TimingTargetAdapter* target = *iter;
        target->timingEvent(fraction);
        ++iter;
    }

    if (timeToStop) {
        stop();
    }
}

void Animator::begin()
{
    //StringUtilities::dump("Animator::begin");

    std::list<TimingTargetAdapter*>::iterator iter = targets.begin();
    
    while (iter != targets.end()) {
        TimingTargetAdapter* target = *iter;
        target->begin();
        ++iter;
    }
}

void Animator::end()
{
    //StringUtilities::dump("Animator::end");
    std::list<TimingTargetAdapter*>::iterator iter = targets.begin();
    
    while (iter != targets.end()) {
        TimingTargetAdapter* target = *iter;
        target->end();
        ++iter;
    }
}

/**
 * Internal repeat event that sends out the event to all targets
 */
void Animator::repeat()
{
    //StringUtilities::dump("Animator::repeat");

    std::list<TimingTargetAdapter*>::iterator iter = targets.begin();
    
    while (iter != targets.end()) {
        TimingTargetAdapter* target = *iter;
        target->repeat();
        ++iter;
    }
}

float Animator::timingEventPreprocessor(float fraction)
{
    // First, take care of acceleration/deceleration factors
    if (acceleration != 0.0f || deceleration != 0.0f) {
        // See the SMIL 2.0 specification for details on this calculation
        float runRate = 1.0f / (1.0f - acceleration/2.0f - deceleration/2.0f);
        
        if (fraction < acceleration) {
            float averageRunRate = runRate * (fraction / acceleration) / 2.0f;
            fraction *= averageRunRate;
        } else if (fraction > (1.0f - deceleration)) {
            // time spent in deceleration portion
            float tdec = fraction - (1.0f - deceleration);
            // proportion of tdec to total deceleration time
            float pdec  = tdec / deceleration;
            fraction = runRate * (1.0f - ( acceleration / 2.0f) - deceleration + tdec * (2.0f - pdec) / 2.0f);
        } else {
            fraction = runRate * (fraction - (acceleration / 2.0f));
        }
        
        // clamp fraction to [0,1] since above calculations may
        // cause rounding errors
        if (fraction < 0.0f) {
            fraction = 0.0f;
        } else if (fraction > 1.0f) {
            fraction = 1.0f;
        }
    }
    
    // run the result through the current interpolator
    float inf = interpolator->interpolate(fraction);

    return inf;
}

long Animator::getTotalElapsedTime(long delta)
{
    // We need to detect wrap around.
    // 000050 = start time
    // 999950 = current time
    // 999950 - 000050 = 999900, but the linear diff = 100 usec
    accumTime += delta;
    return accumTime;
}

long Animator::getTotalElapsedTime()
{
    long currentTime = Utilities::getTimeDelta();//timer->microTimeDelta();//Utilities::microTimeDelta(&previousTimeDelta);//microTime();
    return getTotalElapsedTime(currentTime);
}

long Animator::getCycleElapsedTime(long delta)
{
    cycleAccumTime += delta;
    return cycleAccumTime;
}

long Animator::getCycleElapsedTime()
{
    long currentTime = Utilities::getTimeDelta();//timer->microTimeDelta();//Utilities::microTimeDelta(&previousTimeDelta);//microTime();
    return getCycleElapsedTime(currentTime);
}

float Animator::getTimingFraction(long timeDelta)
{
//    StringUtilities::log("Animator::getTimingFraction ticks:", ticks);
    ticks++;
    long cycleElapsedTime = getCycleElapsedTime(timeDelta);
    long totalElapsedTime = getTotalElapsedTime(timeDelta);
    float currentCycle = (float)totalElapsedTime / duration;
//    StringUtilities::log("Animator::getTimingFraction delta:", delta);
//    StringUtilities::log("Animator::getTimingFraction cycleElapsedTime:", cycleElapsedTime);
//    StringUtilities::log("Animator::getTimingFraction totalElapsedTime:", totalElapsedTime);
//    StringUtilities::log("Animator::getTimingFraction currentCycle:", currentCycle);
//    StringUtilities::log("Animator::getTimingFraction repeatCount:", repeatCount);
//    StringUtilities::log("Animator::getTimingFraction duration:", duration);

    float fraction;
    
    if (!hasBegun) {
        // Call begin() first time after calling start()
        begin();
        hasBegun = true;
    }
    
    if ((duration != INFINITE) && (repeatCount != INFINITE) && (currentCycle >= repeatCount)) {
        // Envelope done: stop based on end behavior
        //StringUtilities::log("Animator::getTimingFraction Envelope done: stop based on end behavior");

        switch (endBehavior) {
            case HOLD:
                //StringUtilities::dump("Animator::getTimingFraction HOLD");
                // Make sure we send a final end value
                if (intRepeatCount) {
                    // If supposed to run integer number of cycles, hold
                    // on integer boundary
                    if (direction == BACKWARD) {
                        // If we were traveling backward, hold on 0
                        //StringUtilities::log("Animator::getTimingFraction direction == BACKWARD");
                        fraction = 0.0f;
                    } else {
                        //StringUtilities::log("Animator::getTimingFraction direction == FORWARD");
                        fraction = 1.0f;
                    }
                } else {
                    // hold on final value instead
                    fraction = std::min(1.0f, ((float)cycleElapsedTime / duration));
                }
                break;
            case RESET:
                //StringUtilities::log("Animator::getTimingFraction RESET");
                // RESET requires setting the final value to the start value
                // NOTE: shouldn't this be the startFraction???
                fraction = 0.0f;
                break;
            default:
                //StringUtilities::log("Animator::getTimingFraction DEFAULT!!!!!!!!!!!");
                fraction = 0.0f;
                // should not reach here
                break;
        }
        
        timeToStop = true;
    } else if ((duration != INFINITE) && (cycleElapsedTime > duration)) {
        //StringUtilities::log("Animator::getTimingFraction Cycle end: Time to stop or change the behavior of the timer");
        // Cycle end: Time to stop or change the behavior of the timer
        long actualCycleTime = cycleElapsedTime % duration;
        //StringUtilities::log("Animator::getTimingFraction actualCycleTime : ", actualCycleTime);
        
        fraction = (float)actualCycleTime / duration;
        //StringUtilities::log("Animator::getTimingFraction fraction : ", fraction);
        
        // Set new start time for this cycle
        // We use delta because this implementation is accumulating time instead of
        // using time deltas.
        currentStartTime = timeDelta - actualCycleTime;
        //StringUtilities::log("Animator::getTimingFraction currentStartTime : ", currentStartTime);
        
        if (repeatBehavior == REVERSE) {
            bool oddCycles = ((int)(cycleElapsedTime / duration) % 2) > 0;
            //StringUtilities::log("Animator::getTimingFraction REVERSE oddCycles : ", oddCycles);
            if (oddCycles) {
                // reverse the direction
                direction = (direction == FORWARD) ? BACKWARD : FORWARD;
            }
            if (direction == BACKWARD) {
                fraction = 1.0f - fraction;
            }
            //StringUtilities::log("Animator::getTimingFraction direction : ", direction);
        } else if (repeatBehavior == LOOP) {
            //StringUtilities::log("Animator::getTimingFraction LOOP startFraction : ", startFraction);
            // To loop we want to reset the fraction back to the starting fraction.
            fraction = startFraction;
        }
        
        // The cycle has ended. Reset the accumulation for the next cycle.
        cycleAccumTime = 0;
        
        repeat();
    } else {
        //StringUtilities::log("Animator::getTimingFraction mid-stream: calculate fraction of animation between");
        // mid-stream: calculate fraction of animation between
        // start and end times and send fraction to target
        fraction = 0.0f;
        if (duration != INFINITE) {
            // Only limited duration animations need a fraction
            fraction = (float)cycleElapsedTime / duration;

            if (direction == BACKWARD) {
                // If this is a reversing cycle, want to know inverse
                // fraction; how much from start to finish, not 
                // finish to start
                fraction = (1.0f - fraction);
            }
            // Clamp fraction in case timing mechanism caused out of 
            // bounds value
            fraction = std::min(fraction, 1.0f);
            fraction = std::max(fraction, 0.0f);
            //StringUtilities::log("Animator::getTimingFraction mid-stream: fraction : ", fraction);
        }
    }
    
    float f = timingEventPreprocessor(fraction);
    //StringUtilities::log("Animator::getTimingFraction timingEventPreprocessor: fraction : ", f);
    return f;
}

void Animator::setTimer(TimingSource* _timer)
{
    timer = _timer;
    
    // Remove this Animator from any previously-set external timer
    timer->removeEventListener(timingSourceTarget);
    
    if (timingSourceTarget == NULL) {
        timingSourceTarget = new TimingSourceTarget(this);
        timingSourceTarget->setId(33);
    }
    
    // Configure the timer to send timing events to our target.
    // For this project the timer source Cocos2dTimingSource
    timer->addEventListener(timingSourceTarget);
    
    // sync this new timer with existing timer properties
    //timer->setResolution(resolution);
    timer->setStartDelay(startDelay);
}

void Animator::validateRepeatCount(double repeatCount)
{
    if (repeatCount < 1 && repeatCount != INFINITE) {
        std::string msg;
        msg += "repeatCount (";
        msg += StringUtilities::toString(repeatCount);
        msg += ") cannot be <= 0";
        StringUtilities::dump(msg);
    }
}

//-(void) calculateDeltaTime
//{
//	struct timeval now;
//	
//	if( gettimeofday( &now, NULL) != 0 ) {
//		CCLOG(@"cocos2d: error in gettimeofday");
//		dt = 0;
//		return;
//	}
//	
//	// new delta time
//	if( nextDeltaTimeZero_ ) {
//		dt = 0;
//		nextDeltaTimeZero_ = NO;
//	} else {
//		dt = (now.tv_sec - lastUpdate_.tv_sec) + (now.tv_usec - lastUpdate_.tv_usec) / 1000000.0f;
//		dt = MAX(0,dt);
//	}
//	
//	lastUpdate_ = now;	
//}

