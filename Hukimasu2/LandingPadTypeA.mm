//
//  LandingPadTypeA.m
//  Hukimasu2
//
//  Created by William DeVore on 7/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "StringUtilities.h"
#import "LandingPadTypeA.h"

LandingPadTypeA::LandingPadTypeA() {
    
}

LandingPadTypeA::~LandingPadTypeA() {
}

void LandingPadTypeA::message(int message) {
    StringUtilities::log("LandingPadTypeA::message ", message);
}
