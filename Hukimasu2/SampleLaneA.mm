//
//  SampleLaneA.m
//  Hukimasu2
//
//  Created by William DeVore on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "Box2D.h"
#import "StringUtilities.h"

#import "SampleLaneA.h"

#import "PreState.h"
#import "StateA_BoardShip.h"
#import "StateB_ShipActivate.h"
#import "StateC_Gather.h"

#import "ActorShip.h"
#import "CircleShip.h"
#import "ActorGround.h"
#import "Emitter.h"
#import "ViewZone.h"
#import "RangeZone.h"
#import "Model.h"
#import "RotateControl.h"
#import "Box2dContactFilterListener.h"
#import "ContactUserData.h"

#import "LandingPadTypeC.h"

SampleLaneA::SampleLaneA() {
    viewZone = NULL;
    model = NULL;
    rotateControl = NULL;
    
    currentState = NULL;
    defaultState = NULL;
    normalStateA = NULL;
    stateB_ShipActivate = NULL;
    
    activeActor = NULL;
}

SampleLaneA::~SampleLaneA() {
    delete currentState;
    delete defaultState;
    delete normalStateA;
    delete stateB_ShipActivate;
    delete stateC_Gather;
}

void SampleLaneA::init()
{
    StringUtilities::log("SampleLaneA::init");
    
    model = Model::instance();
    
    // We want shouldCollide() queries from the physics engine.
    Box2dContactFilterListener* filterListener = model->getWorldContactFilterListener();
    filterListener->subscribeListener(this);
    
    model->resetMatrix();

    viewZone = ViewZone::createAsCircle(1.0f, b2Vec2(-8.0f, 4.0f), 6.0f);
    viewZone->init();
    
    maxNumberShipModels = 2;
    
    rotateControl = model->createRotateControl(0);
    rotateControl->init(model->getViewWidth(), model->getViewHeight());

    model->buildSuit();
    model->buildCircleShip();
    std::list<edge> edges;
    buildBasicLand(edges);
    model->buildGround(edges);
    
    rangeZone = RangeZone::createAsCircle(b2Vec2(0.0f, 0.0f), 3.0f);
    
    currentState = getPreState();
    currentState->begin();
}

//########################################################
// ## State managment
//########################################################
void SampleLaneA::setState(ILaneState* state)
{
    currentState->end();
    currentState = state;
    currentState->begin();
}

ILaneState* SampleLaneA::getPreState()
{
    if (defaultState == NULL)
    {
        defaultState = new PreState(this);
    }
    return defaultState;
}

ILaneState* SampleLaneA::getStateA_BoardShip()
{
    if (normalStateA == NULL)
    {
        normalStateA = new StateA_BoardShip(this);
    }
    return normalStateA;
}

ILaneState* SampleLaneA::getStateB_ShipActivate()
{
    if (stateB_ShipActivate == NULL)
    {
        stateB_ShipActivate = new StateB_ShipActivate(this);
    }
    return stateB_ShipActivate;
}

ILaneState* SampleLaneA::getStateC_Gather()
{
    if (stateC_Gather == NULL)
    {
        stateC_Gather = new StateB_Gather(this);
    }
    return stateC_Gather;
}

//########################################################
// ## Lane flow
//########################################################
void SampleLaneA::begin()
{
    currentState->begin();
}

void SampleLaneA::beforeStep(long dt)
{
    currentState->beforeStep(dt);
}

void SampleLaneA::afterStep(long dt)
{
    currentState->afterStep(dt);
}

void SampleLaneA::draw()
{
    currentState->draw();
}

void SampleLaneA::pause()
{
    
}

void SampleLaneA::resume()
{
    
}

void SampleLaneA::reset(b2World* const world)
{
    currentState->reset(world);
}

void SampleLaneA::end()
{
    
}

void SampleLaneA::release(b2World* world)
{
    model->destroySuit();
    model->destroyCircleShip();
    model->destroyGround();
    
    delete rotateControl;
    
    delete viewZone;
    delete rangeZone;
}

//########################################################
// ## Getter/Setters
//########################################################
//CircleShip* SampleLaneA::getShip()
//{
//    return ship;
//}

RotateControl* SampleLaneA::getRotateControl()
{
    return rotateControl;
}

ViewZone* SampleLaneA::getViewZone()
{
    return viewZone;
}

HuActor* SampleLaneA::getActiveActor()
{
    return activeActor;
}

void SampleLaneA::setActiveActor(ActorShip* actor)
{
    activeActor = actor;
}

RangeZone* SampleLaneA::getRangeZone()
{
    return rangeZone;
}

//########################################################
// ## Touch
//########################################################

void SampleLaneA::touchBegin(float x, float y)
{
    if (model->isOverlayVisible()) {
        activeActor->rotating(false);
        
        return;
    }
    
    if (rotateControl->controlApplies(x, y)) {
        // They touched in the turning region.
        activeActor->rotating(true);
        
        rotateControl->touchBegan(x, y);
    }
    else
    {
        float rowSize = model->getViewHeight() / 4.0f;
        float colSize = model->getViewWidth() / 5.0f;
        activeActor->thrusting(colSize, rowSize, x, y);
    }
}

void SampleLaneA::touchMove(float x, float y, float dx, float dy)
{
    if (rotateControl->controlApplies(x, y))
    {
        rotateControl->touchMoved(x, y);
        
        if (rotateControl->triggered())
        {
            activeActor->applyAngularImpulse(rotateControl->deltaAngle());
        }
    }
    else
    {
        float rowSize = model->getViewHeight() / 4.0f;
        float colSize = model->getViewWidth() / 5.0f;
        activeActor->thrusting(colSize, rowSize, x, y);
    }
}

void SampleLaneA::touchEnd(float x, float y)
{
    if (!Model::instance()->isOverlayVisible())
    {
        if (rotateControl->controlApplies(x, y))
        {
            activeActor->rotating(false);
        }
        else {
            activeActor->thrusting(0, 0, -1, -1);
        }
    }
}

//########################################################
// ## Contact handling
//########################################################
bool SampleLaneA::shouldCollide(const b2Fixture* const fixtureA, const b2Fixture* const fixtureB)
{
    if (currentState != NULL)
        return currentState->shouldCollide(fixtureA, fixtureB);
    else
        return true; // Default to "true" in that they should collide.
}

//########################################################
// ## builders
//########################################################

void SampleLaneA::buildBasicLand(std::list<edge>& edges)
{
    edge e04 = {b2Vec2(-18.0f, 6.0f), b2Vec2(-12.0f, 6.0f)};
    edges.push_back(e04);
    
    edge e03 = {b2Vec2(-12.0f, 6.0f), b2Vec2(-12.0f, 2.0f)};
    edges.push_back(e03);
    
    edge e02 = {b2Vec2(-12.0f, 2.0f), b2Vec2(-6.0f, 2.0f)};
    edges.push_back(e02);
    
    edge e01 = {b2Vec2(-6.0f, 2.0f), b2Vec2(-6.0f, 0.0f)};
    edges.push_back(e01);
    
    edge e0 = {b2Vec2(-6.0f, 0.0f), b2Vec2(0.0f, 0.0f)};
    edges.push_back(e0);
    
    edge e1 = {b2Vec2(0.0f, 0.0f), b2Vec2(0.0f, -2.0f)};
    edges.push_back(e1);
    
    edge e2 = {b2Vec2(0.0f, -2.0f), b2Vec2(8.0f, -2.0f)};
    edges.push_back(e2);
    
    edge e3 = {b2Vec2(8.0f, -2.0f), b2Vec2(8.0f, 6.0f)};
    edges.push_back(e3);
    
    edge e4 = {b2Vec2(8.0f, 6.0f), b2Vec2(12.0f, 6.0f)};
    edges.push_back(e4);
    
    edge e5 = {b2Vec2(12.0f, 6.0f), b2Vec2(12.0f, 12.0f)};
    edges.push_back(e5);
    
}

void SampleLaneA::debug()
{
}