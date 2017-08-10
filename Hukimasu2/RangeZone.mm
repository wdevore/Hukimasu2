//
//  RangeZone.m
//  Hukimasu2
//
//  Created by William DeVore on 8/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RangeZone.h"

#import <sstream>
#import <iomanip>
#import <vector>

#import "Utilities.h"
#import "StringUtilities.h"
#import "floatAnimatedProperty.h"
#import "Animator.h"
#import "Model.h"

RangeZone::RangeZone() : Zone() {
    shape = NULL;
}

RangeZone::~RangeZone() {
    StringUtilities::log("RangeZone::~RangeZone deleting shape");
    delete shape;
}

void RangeZone::init()
{
    Zone::init();
    
}

void RangeZone::check(const b2Vec2& point)
{
    bool inside = pointInside(point);
    
    RangeZone::CROSSSTATE crossState = crossed(inside);
    
    if (crossState == Zone::ENTERED)
    {
        state = crossState;
    } else if (crossState == Zone::EXITED)
    {
        state = crossState;
    } else
    {
        if (inside)
            state = Zone::INSIDE;
        else
            state = Zone::OUTSIDE;
    }
    
}

bool RangeZone::pointInside(const b2Vec2& point)
{
    return shape->pointInside(point);
}

const b2Vec2& RangeZone::getCenter()
{
    return shape->getCenter();
}

void RangeZone::setPosition(const b2Vec2& point)
{
    shape->setPosition(point);
}

void RangeZone::draw(float ratio)
{
    shape->draw(ratio);
}

std::string RangeZone::toString()
{
    std::ostringstream oss;
    oss << std::setprecision(2);
    oss << std::fixed;
    oss << Zone::toString() << shape->toString();
    return oss.str();
}