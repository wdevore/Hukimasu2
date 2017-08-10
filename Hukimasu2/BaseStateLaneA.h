//
//  BaseStateLaneA.h
//  Hukimasu2
//
//  Created by William DeVore on 7/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
//----------------------------------------------------------
// This is the common functionality between the states
//
// ---------------------------------------------------------

#import "ILaneState.h"

class SampleLaneA;
class ActorShip;

class BaseStateLaneA : public ILaneState {
protected:
    SampleLaneA* lane;

public:
    BaseStateLaneA(SampleLaneA* lane);
    virtual ~BaseStateLaneA();
    
    virtual void begin();
    
    virtual void beforeStep(long dt);
    virtual void afterStep(long dt);
    
    virtual bool shouldCollide(const b2Fixture* const fixtureA, const b2Fixture* const fixtureB);

    virtual void draw();
    
    virtual void end();
    
    virtual void reset(b2World* const world);

    virtual void movetToNextState(ILaneState* state);

};