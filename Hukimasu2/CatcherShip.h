//
//  CatcherShip.h
//  Hukimasu2
//
//  Created by William DeVore on 10/27/11 A.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ActorShip.h"

class ContactUserData;

class CatcherShip : public ActorShip {
private:
    b2Vec2* axisVertices;
    int axisVertexCount;
    
    // The leg are simetrical.
    b2Vec2* legVertices;
    int legVertexCount;

    b2Vec2* bodyVertices;
    int bodyVertexCount;

    b2Vec2* leftWallVertices;
    int leftWallVertexCount;
    b2Vec2* rightWallVertices;
    int rightWallVertexCount;

    b2Body* body;
    b2Body* leftWallBody;
    b2Body* rightWallBody;
    b2Body* leftLegBody;
    b2Body* rightLegBody;
    
    // These should be one ContactUserData object for each object
    // you want identified. Generally either a fixture or body is associated.
    ContactUserData* contactUserDataBody;
    ContactUserData* contactUserDataLeftLeg;
    ContactUserData* contactUserDataRightLeg;
    ContactUserData* contactUserDataLeftWall;
    ContactUserData* contactUserDataRightWall;
    
public:
    CatcherShip();
    ~CatcherShip();
    
    void debug();
    
    virtual void init(b2World* const world);
    virtual void release(b2World* const world);
    virtual void reset();
    virtual void zeroVelocities();

    virtual void setPosition(float x, float y);
    virtual const b2Vec2& getPosition();
    
    virtual float getAngle();
    virtual void setAngle(float angle);

    virtual void draw();
    virtual void update(long dt);
    
    virtual void applyForceAlongHeading();
    virtual void applyAngularImpulse(float angle);
    virtual void applyLinearImpulse(const b2Vec2& direction, const b2Vec2& position);
    
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
    
    virtual void subscribeAsContactListener(Box2dContactListener* contactTransmitter);
    
    virtual void activate(bool state);

};
