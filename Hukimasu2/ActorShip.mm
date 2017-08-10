//
//  ActorShip.mm
//  Hukimasu
//
//  Created by William DeVore on 4/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ActorShip.h"

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

ActorShip::ActorShip() {
    thrustLocation = new b2Vec2(0.0f, 0.0f);
}

ActorShip::~ActorShip() {
    delete thrustLocation;
}

//void ActorShip::setPosition(float x, float y)
//{
//    position.Set(x, y);
//}
//
//const b2Vec2& ActorShip::getPosition()
//{
//    return position;
//}
//
void ActorShip::rotating(bool onOff)
{
    _rotating = onOff;
}

bool ActorShip::isThrusting()
{
    return _thrusting;
}

bool ActorShip::isRotating()
{
    return _rotating;
}

b2Vec2* ActorShip::getThrustTouchLocation()
{
    return thrustLocation;
}

void ActorShip::setThrustTouchLocation(float x, float y)
{
    thrustLocation->Set(x, y);
}

void ActorShip::applyLinearImpulse(const b2Vec2& direction, const b2Vec2& position)
{
    
}


