//
//  LinearInterpolator.m
//  Hukimasu
//
//  Created by William DeVore on 5/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LinearInterpolator.h"

LinearInterpolator* LinearInterpolator::_instance = NULL;

LinearInterpolator::LinearInterpolator() {
    
}

LinearInterpolator::~LinearInterpolator() {
}

float LinearInterpolator::interpolate(float fraction)
{
    return fraction;
}

//--------------------------------
//-- Animator test for basic linear
//--------------------------------
//simpleTimingTarget = new SimpleTestTimingTarget();
//simpleTimingTarget->setId(11);
//Interpolator* interpolator = new LinearInterpolator();
//animator = new Animator(2000000, Animator::INFINITE, Animator::LOOP, simpleTimingTarget, interpolator);  // 1s = 1000ms = 1,000,000us
//animator->setStartFraction(1.0f);
//animator->setStartFraction(0.0f);
//animator->setStartDirection(Animator::FORWARD);
//animator->setRepeatCount(1.0);
//animator->setAcceleration(0.2f);

