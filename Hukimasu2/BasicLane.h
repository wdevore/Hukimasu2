//
//  BasicLane.h
//  Hukimasu2
//
//  Created by William DeVore on 7/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "ILane.h"
#import <list>
#import "ActorGround.h"
#import "Model.h"

class ActorShip;
class ActorGround;
class ViewZone;
class RotateControl;
class CircleShip;

class BasicLane : public ILane {
    
private:
    int maxNumberShipModels;

    b2Vec2 initialShipPosition;
    ActorShip* activeActor;

    CircleShip* ship;
    ActorGround* ground;
    RotateControl* rotateControl;

    Model* model;

    ViewZone* viewZone;
    ViewZone* viewZone2;
    ViewZone* viewZone3;

public:
    BasicLane();
    virtual ~BasicLane();
   
    // States
    virtual void setState(ILaneState* state) {};

    virtual void debug();

    virtual void init();
    virtual void begin();

    virtual void beforeStep(long dt);
    virtual void afterStep(long dt);

    virtual void draw();

    virtual void pause();
    virtual void resume();
    virtual void end();
    virtual void release(b2World* world);
    virtual void reset(b2World* const world);

    virtual void touchBegin(float x, float y);
    virtual void touchMove(float x, float y, float dx, float dy);
    virtual void touchEnd(float x, float y);

    virtual HuActor* getActiveActor();
    virtual CircleShip* getShip();
    virtual RotateControl* getRotateControl();
    
private:
    void buildBasicLand(std::list<edge> & edges);
};
