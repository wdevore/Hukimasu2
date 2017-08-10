//
//  TimerBase.m
//  Hukimasu2
//
//  Created by William DeVore on 10/30/11 A.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TimerBase.h"

TimerBase::TimerBase(ITimerTarget* target, int Id) {
    _target = target;
    _id = Id;
    reset();
}

TimerBase::~TimerBase() {
}

void TimerBase::stop()
{
    paused = true;
}

void TimerBase::start()
{
    paused = false;
}

void TimerBase::pause()
{
    paused = true;
}

bool TimerBase::isPaused()
{
    return paused;
}

void TimerBase::resume()
{
    paused = false;
}

void TimerBase::reset()
{
    _duration = 0L;
    _interval = _originalInterval;
    intervalCount = 0L;
    paused = true;
}

void TimerBase::update(long dt)
{
    if (paused)
        return;
    
    if (intervalCount > _interval)
    {
        // Collect overshoot for next pass.
        intervalCount = intervalCount - _interval;
        _target->action(_id);
        paused = _target->shouldStop(_id);
    }
    
    // Accumulate current delta which may include an overshoot.
    intervalCount += dt;
}

void TimerBase::setDuration(long duration)
{
    _duration = duration;
}

void TimerBase::setInterval(long interval)
{
    _interval = interval;
    _originalInterval = interval;
}