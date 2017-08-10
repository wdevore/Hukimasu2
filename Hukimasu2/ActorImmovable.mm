//
//  ActorLand.m
//  Hukimasu
//
//  Created by William DeVore on 5/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "ActorImmovable.h"

ActorImmovable::ActorImmovable() {
    
}

ActorImmovable::~ActorImmovable() {
}


void ActorImmovable::setPosition(float x, float y)
{
    position.Set(x, y);
}

const b2Vec2& ActorImmovable::getPosition()
{
    return position;
}

void ActorImmovable::processContacts(long dt)
{
    
}

void ActorImmovable::setAngle(float angle)
{
    _angle = angle;
}

float ActorImmovable::getAngle()
{
    return _angle;
}