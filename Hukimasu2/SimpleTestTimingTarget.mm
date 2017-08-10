//
//  SimpleTestTimingTarget.m
//  Hukimasu
//
//  Created by William DeVore on 5/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <iostream>

#import "SimpleTestTimingTarget.h"

SimpleTestTimingTarget::SimpleTestTimingTarget() {
    
}

SimpleTestTimingTarget::~SimpleTestTimingTarget() {
}


void SimpleTestTimingTarget::timingEvent(float fraction)
{
    //std::cout << "SimpleTestTimingTarget::timingEvent fraction: " << fraction << std::endl;
}

void SimpleTestTimingTarget::begin()
{
    //std::cout << "SimpleTestTimingTarget::begin :" << std::endl;
}

void SimpleTestTimingTarget::end()
{
    //std::cout << "SimpleTestTimingTarget::end :" << std::endl;
}

void SimpleTestTimingTarget::repeat()
{
    //std::cout << "SimpleTestTimingTarget::repeat :" << std::endl;
}
