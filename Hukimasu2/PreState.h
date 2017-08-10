//
//  PreState.h
//  Hukimasu2
//
//  Created by William DeVore on 7/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "BaseStateLaneA.h"

//----------------------------------------------------------
// This is the bootstrap state for the lane.
//
// ---------------------------------------------------------

class SampleLaneA;
class ActorShip;

class PreState : public BaseStateLaneA {
private:

public:
    PreState(SampleLaneA* lane);
    ~PreState();
    
    virtual void begin();
    
    virtual void movetToNextState(ILaneState* state);

};