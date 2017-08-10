//
//  TimingEventListener.m
//  Hukimasu
//
//  Created by William DeVore on 5/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TimingEventListener.h"

TimingEventListener::TimingEventListener() {
    id = -1;
}

TimingEventListener::~TimingEventListener() {
}

//void TimingEventListener::timingSourceEvent(TimingSource* timingSource)
//{
//    
//}

void TimingEventListener::setId(int _id)
{
    id = _id;
}

int TimingEventListener::getId()
{
    return id;
}

