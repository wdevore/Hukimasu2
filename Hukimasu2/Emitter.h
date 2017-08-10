//
//  Emitter.h
//  Hukimasu2
//
//  Created by William DeVore on 10/28/11 A.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
//
// This emitter fires a box into the air on a recurring interval. It will keep firing until stopped.
// Parameters:
// - interval in microseconds to pause before next firing.
// - how many boxes.
//
// Note: An emitter can have a force field in order to keep anything from getting to close
// and jamming the emitter. It is more to keep the physic engine stable than anything.
#import <list>
#import "HuActor.h"
#import "IEmitter.h"
#import "ITimerTarget.h"

class ContactUserData;
class BoxCargo;
class TimerBase;

class Emitter : public HuActor, public IEmitter, public ITimerTarget {
private:
    
    b2Vec2* baseVertices;
    int baseVertexCount;

    b2Vec2* leftWallVertices;
    int leftWallVertexCount;
    b2Vec2* rightWallVertices;
    int rightWallVertexCount;

    b2Body* baseBody;
    b2Body* leftWallBody;
    b2Body* rightWallBody;

    ContactUserData* contactUserDataBase;
    ContactUserData* contactUserDataLeftWall;
    ContactUserData* contactUserDataRightWall;

    std::list<BoxCargo*> particles;
    BoxCargo* waitingParticle;
    
    b2World * physicsWorld;
    
    long interval;
    long intervalCount;
    long numberToEmit;
    bool paused;
    
    // These timers will callback to this ITimerTarget. They use an
    // Id to identify themselves. A better approach would be to have
    // seperate classes.
    TimerBase* timerEmit;
    TimerBase* timerQueueDelay;

public:
    Emitter();
    ~Emitter();
    
    virtual void init(b2World* const world);
    virtual void release(b2World* const world);

    virtual void processContacts(long dt);
    
    virtual void update(long dt);
    virtual void draw();

    virtual void beforeStep(long dt);
    virtual void afterStep(long dt);

    void setPosition(float x, float y);
    virtual const b2Vec2& getPosition();
    
    virtual float getAngle();
    virtual void setAngle(float angle);

    virtual void setInterval(long microseconds);
    virtual void setCount(int count);
    virtual void reset();
    virtual void pause();
    virtual void resume();
    virtual void start();
    
    // ITimerTarget methods
    virtual void action(int Id);
    virtual bool shouldStop(int Id);
    
    bool hasWaitingParticle();
    bool reachMaxEmission();

    virtual void activate(bool state);
    
private:
    void createParticle();
    void launchParticle();
    
};
