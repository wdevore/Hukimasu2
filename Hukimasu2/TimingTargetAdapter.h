//
//  TimingTargetAdapter.h
//  Hukimasu
//
//  Created by William DeVore on 5/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "TimingTarget.h"

class TimingTargetAdapter : public TimingTarget {
    
public:
    TimingTargetAdapter();
    ~TimingTargetAdapter();
    
    virtual void timingEvent(float fraction);
    
    virtual void begin();
    
    virtual void end();
    
    virtual void repeat();
    
};