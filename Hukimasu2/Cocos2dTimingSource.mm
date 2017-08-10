//
//  Cocos2dTimingSource.m
//  Hukimasu
//
//  Created by William DeVore on 5/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "Cocos2dTimingSource.h"
#import "Animator.h"

#import "StringUtilities.h"
#import "Utilities.h"

// This class doesn't have a timer thread. Instead it is driven
// by an external entity that feeds time deltas to it. Hence it
// needs to be linked to an external source.
Cocos2dTimingSource::Cocos2dTimingSource() : TimingSource() {
    tid = Utilities::genId();
}

Cocos2dTimingSource::~Cocos2dTimingSource() {
}

void Cocos2dTimingSource::start()
{
    running = true;
    accumTime = 0;
    previousTimeDelta = 0;
    timeDelta = 0;
    if (delay > 0)
        delayEnabled = true;
}

void Cocos2dTimingSource::stop()
{
    running = false;
}

void Cocos2dTimingSource::setResolution(int resolution)
{
    this->resolution = resolution;
}

void Cocos2dTimingSource::setStartDelay(long delay)
{
    this->delay = delay;
    if (delay > 0)
        delayEnabled = true;
}
