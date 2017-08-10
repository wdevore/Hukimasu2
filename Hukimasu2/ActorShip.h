//
//  ActorShip.h
//  Hukimasu
//
//  Created by William DeVore on 4/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "HuActor.h"
#import "IContactlistener.h"

class ActorShip : public HuActor {
protected:
    bool _rotating;
    bool _thrusting;
    
    float thrustPower;
    b2Vec2* thrustLocation;
    
public:
    ActorShip();
    ~ActorShip();
    
    virtual void applyForceAlongHeading() = 0;
    virtual void applyAngularImpulse(float angle) = 0;
    virtual void applyLinearImpulse(const b2Vec2& direction, const b2Vec2& position);

    virtual float getRotatePower() = 0;
    virtual float getThrustPower() = 0;
    
    void rotating(bool onOff);
    bool isRotating();
    virtual void thrusting(float screenWidth, float screenHeight, float x, float y) = 0;
    bool isThrusting();
    
    b2Vec2* getThrustTouchLocation();
    void setThrustTouchLocation(float x, float y);
    
};
