//
//  Cup.h
//  Hukimasu2
//
//  Created by William DeVore on 10/16/11 A.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "IMessage.h"
#import "HuActor.h"
#import "IContactlistener.h"

class Cup : public HuActor {
    
private:
    b2Body* body;
    b2Fixture* fixture;
    
    b2Vec2* vertices;
    int vertexCount;
    b2Vec2* leftWallVertices;
    int leftWallVertexCount;
    b2Vec2* rightWallVertices;
    int rightWallVertexCount;
    
public:
    Cup();
    ~Cup();
    
    virtual void init(b2World* const world);

    virtual void release(b2World* world);
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
    bool isActive();

    virtual void zeroVelocities();

    b2Body* getBody();
    void attachToBody(b2Body* body);
    
};