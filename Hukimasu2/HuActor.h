//
//  HuActor.h
//  Hukimasu
//
//  Created by William DeVore on 4/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "Box2D.h"
#import "cocos2d.h"
#import <string>
#import <list>
#import "IMessage.h"
#import "AContact.h"
#import "IContactlistener.h"
#import "IContactFilterListener.h"

class Box2dContactListener;

class HuActor : public IMessage, public IContactlistener, public IContactFilterListener {
protected:
    std::string _name;
    
    bool debugToggle;
    
    // These are contacts that occurred after the physics engine has completed
    // a step()
    std::list<AContact> contacts;

public:
    HuActor();
    virtual ~HuActor();
    
    virtual void init(b2World* const world) = 0;
    
    virtual void draw() = 0;
    virtual void update(long dt) = 0;
    virtual void release(b2World* const world) = 0;
    virtual void reset() = 0;
    
    virtual const b2Vec2& getPosition() = 0;
    virtual void setPosition(float x, float y) = 0;

    virtual float getAngle() = 0;
    virtual void setAngle(float angle) = 0;
    
    virtual void zeroVelocities();
    
    virtual void setName(std::string name);
    virtual std::string getName();

    ////// IMessage interface
    virtual void subscribeListener(IMessage* const listener);
    virtual void unSubscribeListener(IMessage* const listener);
    virtual void message(int message);
    virtual void message(int message, IMessage* sender);

    ////// Box2dContactListener
    virtual void subscribeAsContactListener(Box2dContactListener* contactTransmitter);
    virtual void unSubscribeAsContactListener(Box2dContactListener* contactTransmitter);
    
    ////// IContactFilterListener methods
    virtual bool shouldCollide(const b2Fixture* const fixtureA, const b2Fixture* const fixtureB);

    // Box2D contact listener methods
    virtual void beginContact(b2Contact* contact);
    virtual void endContact(b2Contact* contact);
    virtual void preSolve(b2Contact* contact, const b2Manifold* oldManifold);
    virtual void postSolve(b2Contact* contact, const b2ContactImpulse* impulse);
    virtual void processContacts(long dt) = 0;

    virtual void beforeStep(long dt) = 0;
    virtual void afterStep(long dt) = 0;

    virtual void activate(bool state) = 0;
    
    virtual void debug();
};
