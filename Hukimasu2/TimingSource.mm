//
//  TimingSource.m
//  Hukimasu
//
//  Created by William DeVore on 5/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "TimingSource.h"
#import "TimingEventListener.h"
#import "TimingSourceTarget.h"
#import "Animator.h"
#import "StringUtilities.h"
#import "Utilities.h"

#import <algorithm>

TimingSource::TimingSource() {
    animator = NULL;
    running = false;
    timeDelta = 0;
    previousTimeDelta = 0;
    resolution = -1;
    delayEnabled = false;
    delay = 0;
}

TimingSource::~TimingSource() {
    listeners.clear();
}

int TimingSource::getId()
{
    return tid;
}

void TimingSource::attachAnimator(Animator* animator)
{
    this->animator = animator;
    this->animator->setTimer(this);
}

// This method is typically called by the Cocos2d tick() method.
// But it could be called by a timing thread.
void TimingSource::tick(long dt)
{
    if (!running)
        return;
    
    //timeDelta = microTimeDelta();
    
    if (accumTime < delay && delayEnabled) {
        //accumTime += timeDelta;
        accumTime += dt;
        return;
    }
    
    //StringUtilities::log("TimingSource::tick accumTime delay: ", delay);
    //StringUtilities::log("TimingSource::tick accumTime accumTime: ", accumTime);
    //StringUtilities::log("TimingSource::tick accumTime timeDelta: ", timeDelta);
    delayEnabled = false; // disable delay now that it has ended.
    
    // We only want to send an event if enough time has passed between
    // the previous event. This is the resolution of the timer. By
    // default the resolution is equal to the frame rate; typically 1/60sec or 16666usecs.
    if (resolution > 0) {
        if (accumTime >= resolution) {
            animator->timingEvent(animator->getTimingFraction(resolution));
            accumTime = accumTime - resolution;
        }
    } else {
        animator->timingEvent(animator->getTimingFraction(dt));
        //animator->timingEvent(animator->getTimingFraction(timeDelta));
    }
    
    //accumTime += timeDelta;
    accumTime += dt;
}

//long TimingSource::microTimeDelta()
//{
//    return Utilities::microTimeDelta(&previousTimeDelta);
//}

void TimingSource::addEventListener(TimingSourceTarget* listener)
{
    
    std::list<TimingSourceTarget*>::iterator iter = listeners.begin();

    bool found = false;

    while (iter != listeners.end()) {
        TimingSourceTarget* target = *iter;
        if (target->getId() == listener->getId()) {
            found = true;
            break;
        }
        ++iter;
    }
    
    if (!found) {
        listeners.push_back(listener);
    }

}

void TimingSource::removeEventListener(TimingSourceTarget* listener)
{
    // Note: we don't delete listener. We just remove it; and because
    // it is a pointer the container will not delete it.
    listeners.remove(listener);
    // delete listener;
}


void TimingSource::timingEvent()
{
    std::list<TimingSourceTarget*>::iterator iter = listeners.begin();
    
    while (iter != listeners.end()) {
        TimingSourceTarget* target = *iter;
        
        target->timingSourceEvent(this);
        ++iter;
    }
}
