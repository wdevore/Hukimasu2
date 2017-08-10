//
//  SampleLaneA.h
//  Hukimasu2
//
//  Created by William DeVore on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <list>
#import "ILane.h"
#import "ILaneState.h"
#import "Edge.h"
#import "IContactFilterListener.h"
#import "Model.h"

class ActorShip;
class ActorGround;
class ViewZone;
class RotateControl;
class RangeZone;
class CircleShip;
class TriangleShip;
class CatcherShip;
class Emitter;

//
// The lane is responsible for allocating resources for the States.
//
class SampleLaneA : public ILane, public IContactFilterListener {
    
private:
    int maxNumberShipModels;
    int shipIndex;
    
    ActorShip* activeActor;
    
    RotateControl* rotateControl;
    
    Model* model;
    
    ViewZone* viewZone;
    
    // State machine vars
    ILaneState* currentState;
    ILaneState* defaultState;
    ILaneState* normalStateA;
    ILaneState* stateB_ShipActivate;
    ILaneState* stateC_Gather;
    
    // Zones
    RangeZone* rangeZone;
    
public:
    SampleLaneA();
    virtual ~SampleLaneA();
    
    virtual void debug();
    
    virtual void init();
    virtual void begin();
    
    virtual void beforeStep(long dt);
    virtual void afterStep(long dt);
    
    virtual void draw();
    
    virtual void pause();
    virtual void resume();
    virtual void end();
    virtual void release(b2World* const world);
    virtual void reset(b2World* const world);

    virtual void touchBegin(float x, float y);
    virtual void touchMove(float x, float y, float dx, float dy);
    virtual void touchEnd(float x, float y);
    
    virtual bool shouldCollide(const b2Fixture* const fixtureA, const b2Fixture* const fixtureB);
    
    virtual HuActor* getActiveActor();
    void setActiveActor(ActorShip* actor);
    
    virtual RotateControl* getRotateControl();

    ViewZone* getViewZone();
    
    RangeZone* getRangeZone();
    
    // States
    void setState(ILaneState* state);
    ILaneState* getStateA_BoardShip();
    ILaneState* getPreState();
    ILaneState* getStateB_ShipActivate();
    ILaneState* getStateC_Gather();

private:
    void buildBasicLand(std::list<edge>& edges);

};