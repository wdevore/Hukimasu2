//
//  LandingPadTypeB.m
//  Hukimasu2
//
//  Created by William DeVore on 7/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StringUtilities.h"
#import "LandingPadTypeB.h"

LandingPadTypeB::LandingPadTypeB() {
    
}

LandingPadTypeB::~LandingPadTypeB() {
}

void LandingPadTypeB::message(int message) {
    StringUtilities::log("LandingPadTypeB::message ", message);
}
