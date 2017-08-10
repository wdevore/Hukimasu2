//
//  ActorShip2.h
//  Hukimasu
//
//  Created by William DeVore on 4/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "ActorShip.h"

class ContactUserData;
class LandingPadTypeC;
class Cup;

class CircleShip : public ActorShip {
private:
    b2Vec2* axisVertices;
    int axisVertexCount;

    b2Vec2* legVertices;
    int legVertexCount;

    b2Fixture* bodyFixture;

    b2Body* body;
    b2Body* leftLegBody;
    b2Body* rightLegBody;

    // These should be one ContactUserData object for each object
    // you want identified. Generally either a fixture or body is associated.
    ContactUserData* contactUserDataBody;
    ContactUserData* contactUserDataLeftLeg;
    ContactUserData* contactUserDataRightLeg;
    
    // #################################
    // ## Landing Pad C
    // #################################
    bool padActive;
    // This is the pad that extends from the main ship.
    LandingPadTypeC* landpadC;
    // This is true when the pad has fully extended. It isn't reset until
    // the pad is actually retracting.
    bool fullyExtended;
    bool fullyRetracted;
    b2Joint* padJoint;
    
    // #################################
    // ## Cup for catching boxes.
    // #################################
    Cup* cup;
    
public:
    CircleShip();
    ~CircleShip();
    
    void debug();
    
    virtual void init(b2World* const world);
    virtual void release(b2World* const world);
    virtual void reset();
    
    virtual void setPosition(float x, float y);
    virtual const b2Vec2& getPosition();

    virtual float getAngle();
    virtual void setAngle(float angle);

    virtual void zeroVelocities();

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

    // IContactFilterListener methods
    virtual bool shouldCollide(const b2Fixture* const fixtureA, const b2Fixture* const fixtureB);
    
    virtual void activate(bool state);

    // #################################
    // ## Landing Pad C
    // #################################
    void extendPad();
    void extractPad();
    void detachPad();
    void attachPad();
    void activatePad();
    
    void releasePad(b2World* const world);
    bool isPadFullyExtended();
    bool isPadFullyRetracted();
    bool hasSomethingSuccessfullyLanded();
    
    // #################################
    // ## Cup for catching boxes.
    // #################################
    void attachCup();
    void releaseCup(b2World* const world);
};
