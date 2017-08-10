//
//  BaseStateLaneA.m
//  Hukimasu2
//
//  Created by William DeVore on 7/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "StringUtilities.h"

#import "Model.h"
#import "BaseStateLaneA.h"
#import "SampleLaneA.h"
#import "ActorShip.h"
#import "ActorGround.h"
#import "ViewZone.h"
#import "RangeZone.h"

BaseStateLaneA::BaseStateLaneA(SampleLaneA* lane) {
    this->lane = lane;
}

BaseStateLaneA::~BaseStateLaneA() {
}

void BaseStateLaneA::begin()
{
    StringUtilities::log("BaseStateLaneA::begin");
}

void BaseStateLaneA::beforeStep(long dt)
{
}

void BaseStateLaneA::afterStep(long dt)
{
    Model* model = Model::instance();

    model->getGround()->update(dt);
    
    b2Vec2 actorW = lane->getActiveActor()->getPosition();   // This value is in WORLD-space
    lane->getViewZone()->check(actorW);
}

bool BaseStateLaneA::shouldCollide(const b2Fixture* const fixtureA, const b2Fixture* const fixtureB)
{
    return true;   // default is always collide.
}

void BaseStateLaneA::draw()
{
    //world->DrawDebugData();
    Model* model = Model::instance();
    
    model->getGround()->draw();
    
    lane->getViewZone()->draw(PTM_RATIO);
}

void BaseStateLaneA::end()
{
    StringUtilities::log("BaseStateLaneA::end");
}

void BaseStateLaneA::reset(b2World* const world)
{
    StringUtilities::log("BaseStateLaneA::reset");
}

void BaseStateLaneA::movetToNextState(ILaneState* state)
{
}