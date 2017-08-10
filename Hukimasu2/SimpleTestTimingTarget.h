//
//  SimpleTestTimingTarget.h
//  Hukimasu
//
//  Created by William DeVore on 5/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "TimingTargetAdapter.h"

class SimpleTestTimingTarget : public TimingTargetAdapter {
    
public:
    SimpleTestTimingTarget();
    virtual ~SimpleTestTimingTarget();
    
    virtual void timingEvent(float fraction);
    
    virtual void begin();
    
    virtual void end();
    
    virtual void repeat();
    
};