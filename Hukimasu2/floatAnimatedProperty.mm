//
//  floatAnimatedProperty.m
//  Hukimasu
//
//  Created by William DeVore on 6/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "StringUtilities.h"

#import "floatAnimatedProperty.h"

floatAnimatedProperty::floatAnimatedProperty()
{
    value = 0.0f;
    propertyAction = NULL;
}

floatAnimatedProperty::~floatAnimatedProperty()
{
    StringUtilities::log("floatAnimatedProperty::~floatAnimatedProperty");
}

void floatAnimatedProperty::setValue(float value)
{
    //StringUtilities::log("floatAnimatedProperty::setValue : ", value);
    this->value = value;
    
    if (propertyAction != NULL)
        propertyAction->action(value);
}

float floatAnimatedProperty::getValue()
{
    return value;
}

void floatAnimatedProperty::setAction(IPropertyAction<float> *action)
{
    propertyAction = action;
}