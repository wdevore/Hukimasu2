//
//  TriangleShip.h
//  Hukimasu
//
//  Created by William DeVore on 4/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ActorShip.h"

class ContactUserData;

class TriangleShip : public ActorShip {
private:
    b2Vec2* vertices;
    int vertexCount;
    
    b2Body* body;
    ContactUserData* contactUserDataBody;

public:
    TriangleShip();
    ~TriangleShip();
    
    virtual void init(b2World* const world);
    virtual void release(b2World* const world);
    virtual void reset();

    virtual void setPosition(float x, float y);
    virtual const b2Vec2& getPosition();

    virtual float getAngle();
    virtual void setAngle(float angle);

    virtual void draw();
    virtual void update(long dt);
    
    virtual void applyForceAlongHeading();
    virtual void applyAngularImpulse(float angle);

    virtual void beforeStep(long dt);
    virtual void afterStep(long dt);
    
    virtual void processContacts(long dt);

    virtual float getRotatePower();
    virtual float getThrustPower();
    
    virtual void thrusting(float screenWidth, float screenHeight, float x, float y);

    // Box2D contact listener methods
    virtual void beginContact(b2Contact* contact);
    virtual void endContact(b2Contact* contact);
    virtual void preSolve(b2Contact* contact, const b2Manifold* oldManifold);
    virtual void postSolve(b2Contact* contact, const b2ContactImpulse* impulse);
    
    virtual void activate(bool state);

    virtual void zeroVelocities();
    
};
