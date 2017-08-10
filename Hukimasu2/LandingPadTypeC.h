//
//  LandingPadTypeC.h
//  Hukimasu2
//
//  Created by William DeVore on 7/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IMessage.h"
#import "HuActor.h"
#import "IContactlistener.h"

// This pad move horizontally. It is a primatic joint with a small force
// That moves it left or right.
// We don't want this pad to actually collide with the Circle ship.
// 
// TriangleShip can collide with PadC or CircleShip. PadC can only collide
// with TriangleShip.
class LandingPadTypeC : public HuActor {
    
private:
    b2Body* body;
    b2Fixture* fixture;
    
    b2Vec2* vertices;
    int vertexCount;

    // Track how long the triangle/suit has been in constant contact.
    // If it has contacted long enough AND the touch down velocity is below
    // the max then consider it a successful landing.
    long contactDuration;
    bool successfulLanding;
    bool landed;
    
    // How long the suit must be in contact.
    long requiredRestCount;
    float approachVelocity;
    
public:
    LandingPadTypeC();
    ~LandingPadTypeC();
    
    virtual void init(b2World* const world);

    virtual void release(b2World* const world);
    virtual void update(long dt);
    virtual void reset();

    ////// IMessage interface
    virtual void subscribeListener(IMessage* listener);
    virtual void unSubscribeListener(IMessage* listener);
    virtual void message(int message);

    virtual void beforeStep(long dt);
    virtual void afterStep(long dt);

    // Box2D contact listener methods
    virtual void beginContact(b2Contact* contact);
    virtual void endContact(b2Contact* contact);
    virtual void preSolve(b2Contact* contact, const b2Manifold* oldManifold);
    virtual void postSolve(b2Contact* contact, const b2ContactImpulse* impulse);
    virtual void processContacts(long dt);
    
    virtual void draw();

    void setPosition(float x, float y);
    virtual const b2Vec2& getPosition();

    virtual float getAngle();
    virtual void setAngle(float angle);

    virtual void activate(bool state);

    b2Body* getBody();
    
    bool hasSomethingSuccessfullyLanded();
    
};
