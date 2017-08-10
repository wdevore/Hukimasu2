//
//  Box2dContactFilterListener.m
//  Hukimasu2
//
//  Created by William DeVore on 7/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "StringUtilities.h"
#import "Box2dContactFilterListener.h"

Box2dContactFilterListener::Box2dContactFilterListener() {
}

Box2dContactFilterListener::~Box2dContactFilterListener() {
    StringUtilities::log("Box2dContactFilterListener::~Box2dContactFilterListener");
}

bool Box2dContactFilterListener::ShouldCollide(b2Fixture* fixtureA, b2Fixture* fixtureB)
{
    if (listener != NULL)
        return listener->shouldCollide(fixtureA, fixtureB);
    else
        return true;       // Default is they should collide.
}

void Box2dContactFilterListener::subscribeListener(IContactFilterListener *listener)
{
    this->listener = listener;
}

void Box2dContactFilterListener::unSubscribeListener()
{
    listener = NULL;
}