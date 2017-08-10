//
//  TimingTargetAdapter.m
//  Hukimasu
//
//  Created by William DeVore on 5/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TimingTargetAdapter.h"

/**
 * Implements the {@link TimingTarget} interface, providing stubs for all
 * TimingTarget methods.  Subclasses may extend this adapter rather than
 * implementing the TimingTarget interface if they only care about a 
 * subset of the events that TimingTarget provides.  For example, 
 * sequencing animations may only require monitoring the 
 * {@link TimingTarget#end} method, so subclasses of this adapter
 * may ignore the other methods such as timingEvent.
 *
 */

TimingTargetAdapter::TimingTargetAdapter() {
    
}

TimingTargetAdapter::~TimingTargetAdapter() {
}


void TimingTargetAdapter::timingEvent(float fraction)
{
    
}

void TimingTargetAdapter::begin()
{
    
}

void TimingTargetAdapter::end()
{
    
}

void TimingTargetAdapter::repeat()
{
    
}
