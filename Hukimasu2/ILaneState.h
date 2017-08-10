//
//  ILaneState.h
//  Hukimasu2
//
//  Created by William DeVore on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "Box2D.h"

// Interface
class ILaneState {
public:
    virtual void begin() = 0;
    
    virtual void beforeStep(long dt) = 0;
    virtual void afterStep(long dt) = 0;
    
    virtual bool shouldCollide(const b2Fixture* const fixtureA, const b2Fixture* const fixtureB) = 0;
    
    virtual void draw() = 0;
    
    virtual void end() = 0;
    
    virtual void reset(b2World* const world) = 0;
};