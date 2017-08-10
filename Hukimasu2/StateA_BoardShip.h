//
//  StateA_BoardShip.h
//  Hukimasu2
//
//  Created by William DeVore on 7/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "BaseStateLaneA.h"

//----------------------------------------------------------
// This state is the second state.
// The goal is to navigate the triangle (aka space suit) close to
// circleship for switching. When the triangle get close to the ship
// a landing strip extends (LandingPadTypeC). The triangle has to land softly otherwise
// it crashes. Once the suit lands safely it is deactivated such that thrust not longer works
// and the suit no longer collides with the ship so that it can enter when
// the pad pulls the suit into the ship.
// Then we switch to State B.
//
// When the switch occurs circleship drops a little to indicate it is
// manned and ready (This happens in state B).
// The padA will also sink giving a clue about
// padA's functionality relative to padB.
//
// When padA sinks far enough padB activates. padB applies
// a pulse force to the object above it.
//
// ---------------------------------------------------------
class SampleLaneA;

class StateA_BoardShip : public BaseStateLaneA {
private:
    
public:
    StateA_BoardShip(SampleLaneA* lane);
    ~StateA_BoardShip();

    virtual void begin();

    virtual void beforeStep(long dt);
    virtual void afterStep(long dt);
    
    virtual bool shouldCollide(const b2Fixture* const fixtureA, const b2Fixture* const fixtureB);

    virtual void draw();

    virtual void end();
    virtual void release(b2World* const world);
    
    virtual void reset(b2World* const world);

    virtual void movetToNextState(ILaneState* state);
};