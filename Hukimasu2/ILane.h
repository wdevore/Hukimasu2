//
//  ILane.h
//  Hukimasu2
//
//  Created by William DeVore on 7/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

// A lane is like a map. The play must complete the lane by doing something.
// For example, deliver something from A to B, complete a timed event etc.
//
// Lanes contain all the "elements", they track the state of the lane/game. A
// lane is pretty much the game layer in action. It is not the menus and such.
//
// 
// Interface
class b2World;
class HuActor;
class ActorShip;
class RotateControl;
class ILaneState;
class CircleShip;

class ILane {
public:
    virtual void debug() = 0;
    
    // This is called to allocate resources and bind and/or subscribe to system
    // resources.
    virtual void init() = 0;

    // This starts the actual lane.
    virtual void begin() = 0;

    // Work done before physics engine does its thing. Called for every tick()
    virtual void beforeStep(long dt) = 0;
    
    // Work done after the physics engine does its thing.  Called for every tick()
    virtual void afterStep(long dt) = 0;
    
    virtual void draw() = 0;
    
    // When the game is paused. Use to save state perhaps.
    virtual void pause() = 0;
    
    // When the game is resumed. This is where resouces should be
    // re-acquired.
    virtual void resume() = 0;
    
    virtual void reset(b2World* const world) = 0;
    
    // Called when the game is quiting.
    virtual void end() = 0;
    
    // The last call and is where all resouces should be released.
    virtual void release(b2World* const world) = 0;
    
    virtual void touchBegin(float x, float y) = 0;
    virtual void touchMove(float x, float y, float dx, float dy) = 0;
    virtual void touchEnd(float x, float y) = 0;
    
    virtual HuActor* getActiveActor() = 0;
//    virtual CircleShip* getShip() = 0;
    virtual RotateControl* getRotateControl() = 0;
    
};
