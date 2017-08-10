//
//  StateB_ShipActivate.h
//  Hukimasu2
//
//  Created by William DeVore on 10/8/11 A.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
//
// This state sets up for State C.
// It pulses the ship and moves to State C.
// -- Done --

#import "BaseStateLaneA.h"

class SampleLaneA;

class StateB_ShipActivate : public BaseStateLaneA {
private:
    
public:
    StateB_ShipActivate(SampleLaneA* lane);
    ~StateB_ShipActivate();
    
    virtual void begin();
    
    virtual void beforeStep(long dt);
    virtual void afterStep(long dt);
    
    virtual bool shouldCollide(const b2Fixture* const fixtureA, const b2Fixture* const fixtureB);
    
    virtual void draw();
    
    virtual void end();
    virtual void release(b2World* const world);
    
    virtual void movetToNextState(ILaneState* state);

};