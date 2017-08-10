//
//  HuActor.mm
//  Hukimasu
//
//  Created by William DeVore on 4/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HuActor.h"
#import "Box2dContactListener.h"

HuActor::HuActor() {
    debugToggle = false;
}

HuActor::~HuActor() {
}

void HuActor::setName(std::string name)
{
    _name = name;
}

std::string HuActor::getName()
{
    return _name;
}

void HuActor::subscribeListener(IMessage* const listener)
{
    
}

void HuActor::unSubscribeListener(IMessage* const listener)
{
    
}

void HuActor::message(int message)
{
    
}

void HuActor::message(int message, IMessage *sender)
{
    
}

void HuActor::beginContact(b2Contact* contact)
{
    
}

void HuActor::endContact(b2Contact* contact)
{
    
}
void HuActor::preSolve(b2Contact* contact, const b2Manifold* oldManifold)
{
    
}

void HuActor::postSolve(b2Contact* contact, const b2ContactImpulse* impulse)
{
    
}

void HuActor::subscribeAsContactListener(Box2dContactListener* contactTransmitter)
{
    contactTransmitter->subscribeListener(this);
}

void HuActor::unSubscribeAsContactListener(Box2dContactListener* contactTransmitter)
{
    contactTransmitter->unSubscribeListener(this);
}

bool HuActor::shouldCollide(const b2Fixture *const fixtureA, const b2Fixture *const fixtureB)
{
    // The default behaviour is to allow both fixtures to collide.
    return true;
}

void HuActor::zeroVelocities()
{
    
}

void HuActor::activate(bool state)
{
    
}

void HuActor::reset()
{
    
}

void HuActor::debug()
{
    // do nothing
}