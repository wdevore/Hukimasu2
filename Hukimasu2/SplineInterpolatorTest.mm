//
//  SplineInterpolatorTest.m
//  Hukimasu
//
//  Created by William DeVore on 5/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "StringUtilities.h"
#import "Utilities.h"

#import "SplineInterpolatorTest.h"

int SplineInterpolatorTest::DURATION = 2000000;

SplineInterpolatorTest::SplineInterpolatorTest() {
    previousTimeDelta = 0;
    accumTime = 0;
}

SplineInterpolatorTest::~SplineInterpolatorTest() {
}


/**
 * TimingTarget implementation: Calculate the real fraction elapsed and
 * output that along with the fraction parameter, which has been 
 * non-linearly interpolated.
 */
void SplineInterpolatorTest::timingEvent(float fraction)
{
    long currentTimeDelta = Utilities::getTimeDelta();//Utilities::microTimeDelta(&previousTimeDelta);
    StringUtilities::log("SplineInterpolatorTest::timingEvent currentTimeDelta: ", currentTimeDelta);
    accumTime += currentTimeDelta;
    StringUtilities::log("SplineInterpolatorTest::timingEvent accumTime: ", accumTime);
    long elapsedTime = abs(accumTime - startTime);
    StringUtilities::log("SplineInterpolatorTest::timingEvent elapsedTime: ", elapsedTime);
    float realFraction = (float)elapsedTime / DURATION;
    StringUtilities::log("SplineInterpolatorTest::timingEvent DURATION: ", DURATION);
    std::cout << realFraction << "\t" << fraction << std::endl;
}

void SplineInterpolatorTest::begin()
{
    startTime = 0;//Utilities::microTimeDelta();
    StringUtilities::log("SplineInterpolatorTest::begin startTime: ", startTime);
    StringUtilities::log("Real\tInterpolated");
    StringUtilities::log("----\t------------");
}

//--------------------------------
//-- Animator test for spline
//--------------------------------
//simpleTimingTarget = new SplineInterpolatorTest();
//simpleTimingTarget->setId(11);
//Interpolator* interpolator = new SplineInterpolator(1.0f, 0.0f, 0.0f, 1.0f);
//animator = new Animator(2000000, Animator::INFINITE, Animator::LOOP, simpleTimingTarget, interpolator);  // 1s = 1000ms = 1,000,000us
//animator->setRepeatCount(1.0);

