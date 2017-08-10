//
//  TimingSourceTarget.h
//  Hukimasu
//
//  Created by William DeVore on 5/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "TimingEventListener.h"

class Animator;

/**
 * This class will be called by TimingSource.timingEvent()
 * when a timer sends in timing events to the Animator.
 */
class TimingSourceTarget : public TimingEventListener {
private:
    Animator* animator;
    
public:
    TimingSourceTarget();
    TimingSourceTarget(Animator* animator);
    virtual ~TimingSourceTarget();
    
    virtual void timingSourceEvent(TimingSource* timingSource);

};