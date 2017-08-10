//
//  KeyInterpolators.h
//  Hukimasu
//
//  Created by William DeVore on 5/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <vector>
#import "Interpolator.h"

class KeyInterpolators {
private:
    std::vector<Interpolator*> interpolators;
    
public:
    KeyInterpolators();
    ~KeyInterpolators();
    
    KeyInterpolators(int numIntervals, std::vector<Interpolator*>* interpolators);
    
    void addInterpolator(Interpolator* interpolator);
    
    float interpolate(int interval, float fraction);
};