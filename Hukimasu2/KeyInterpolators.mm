//
//  KeyInterpolators.m
//  Hukimasu
//
//  Created by William DeVore on 5/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "StringUtilities.h"

#import "KeyInterpolators.h"
#import "LinearInterpolator.h"

KeyInterpolators::KeyInterpolators() {
}

KeyInterpolators::~KeyInterpolators() {
}

KeyInterpolators::KeyInterpolators(int numIntervals, std::vector<Interpolator*>* interpolators)
{
    if (interpolators == NULL) {
        for (int i = 0; i < numIntervals; ++i) {
            LinearInterpolator* li = LinearInterpolator::instance();
            this->interpolators.push_back(li);
        }
    } else if (this->interpolators.size() < numIntervals) {
        for (int i = 0; i < numIntervals; ++i) {
            Interpolator* li = (*interpolators)[0];
            this->interpolators.push_back(li);
        }
    } else {
        for (int i = 0; i < numIntervals; ++i) {
            Interpolator* li = (*interpolators)[0];
            this->interpolators.push_back(li);
        }
    }
}

void KeyInterpolators::addInterpolator(Interpolator *interpolator)
{
    interpolators.push_back(interpolator);
}

float KeyInterpolators::interpolate(int interval, float fraction)
{
    //StringUtilities::log("KeyInterpolators::interpolate : interval ", interval);
    //StringUtilities::log("KeyInterpolators::interpolate : fraction ", fraction);
    Interpolator *interpolator = interpolators[interval];
    return interpolator->interpolate(fraction);
}
