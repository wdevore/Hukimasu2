//
//  SplineInterpolatorTest.h
//  Hukimasu
//
//  Created by William DeVore on 5/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "TimingTargetAdapter.h"

class SplineInterpolatorTest : public TimingTargetAdapter {
private:
    long startTime;
    static int DURATION;
    long previousTimeDelta;
    long accumTime;
    
public:
    SplineInterpolatorTest();
    virtual ~SplineInterpolatorTest();
   
    virtual void timingEvent(float fraction);
    
    virtual void begin();
    
};