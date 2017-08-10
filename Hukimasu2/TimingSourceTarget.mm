//
//  TimingSourceTarget.m
//  Hukimasu
//
//  Created by William DeVore on 5/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TimingSourceTarget.h"
#import "Animator.h"

TimingSourceTarget::TimingSourceTarget() {
    animator = NULL;
}

TimingSourceTarget::TimingSourceTarget(Animator* animator) {
    this->animator = animator;
}

TimingSourceTarget::~TimingSourceTarget() {
}

void TimingSourceTarget::timingSourceEvent(TimingSource* timingSource)
{
    // Make sure that we are being called by the current timer
    // and that the animation is actually running
//    if (animator->isRunning()) {
//        animator->timingEvent(animator->getTimingFraction());
//    }

}
