//
//  StateC_Gather.h
//  Hukimasu2
//
//  Created by William DeVore on 10/28/11 A.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
// In this state the user must gather the boxes and drop them into the
// the Gather ship.
// An emitter ejects a box every set interval.
//
// Sequence of events:
// catch box(s)
// deliver to ship B
// safely land ship A
// ship A's landing pad extracts with suit
// suit activates and ship A deactivates
// suit land on ship B's pad thus activating ship B
// --Done--
//
#import "BaseStateLaneA.h"

class SampleLaneA;

class StateB_Gather : public BaseStateLaneA {
private:
    
public:
    StateB_Gather(SampleLaneA* lane);
    ~StateB_Gather();
    
    virtual void begin();
    
    virtual void beforeStep(long dt);
    virtual void afterStep(long dt);
    
    virtual bool shouldCollide(const b2Fixture* const fixtureA, const b2Fixture* const fixtureB);
    
    virtual void draw();
    
    virtual void end();
    virtual void release(b2World* const world);
    
    virtual void reset(b2World* const world);

};