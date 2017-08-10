//
//  b2Vec2AnimatedProperty.m
//  Hukimasu
//
//  Created by William DeVore on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "StringUtilities.h"
#import "b2Vec2AnimatedProperty.h"

b2Vec2AnimatedProperty::b2Vec2AnimatedProperty()
{
    value.x = 0.0f;
    value.y = 0.0f;
    propertyAction = NULL;
}

b2Vec2AnimatedProperty::~b2Vec2AnimatedProperty()
{
    StringUtilities::log("b2Vec2AnimatedProperty::~b2Vec2AnimatedProperty");
}

void b2Vec2AnimatedProperty::setValue(b2Vec2 value)
{
    //StringUtilities::log("b2Vec2AnimatedProperty::setValue : ", value);
    this->value.x = value.x;
    this->value.y = value.y;
    if (propertyAction != NULL)
        propertyAction->action(value);
}

b2Vec2 b2Vec2AnimatedProperty::getValue()
{
    return value;
}

void b2Vec2AnimatedProperty::setAction(IPropertyAction<b2Vec2> *action)
{
    propertyAction = action;
}