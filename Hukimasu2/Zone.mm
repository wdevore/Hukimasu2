//
//  Zone.m
//  Hukimasu2
//
//  Created by William DeVore on 8/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Zone.h"

#import <sstream>
#import <iomanip>
#import <vector>

#import "Utilities.h"
#import "StringUtilities.h"
#import "Model.h"

Zone::Zone() {
    enterScale = 0.0f;
    state = NONE;
}

Zone::~Zone() {
}

void Zone::init()
{
    prevEnterExit = false;
}


Zone::CROSSSTATE Zone::crossed(bool enterExit)
{
    state = NONE;
    // If previously the object was outside and now it is inside
    // then the object has entered.
    if (enterExit == true && prevEnterExit == false) {
        // Entered
        state = ENTERED;
    }
    
    if (enterExit == false && prevEnterExit == true) {
        // Exited
        state = EXITED;
    }
    
    prevEnterExit = enterExit;
    return state;
}

Zone::CROSSSTATE Zone::getState()
{
    return state;    
}

std::string Zone::toString()
{
    std::ostringstream oss;
    oss << std::setprecision(2);
    oss << std::fixed;
    oss << "Zone:" << std::endl;
    return oss.str();
}