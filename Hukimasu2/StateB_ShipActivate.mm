//
//  StateB_ShipActivate.m
//  Hukimasu2
//
//  Created by William DeVore on 10/8/11 A.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "StringUtilities.h"
#import "SampleLaneA.h"

#import "StateB_ShipActivate.h"
#import "TriangleShip.h"
#import "CircleShip.h"
#import "RotateControl.h"
#import "Emitter.h"

#import "ContactUserData.h"

StateB_ShipActivate::StateB_ShipActivate(SampleLaneA* lane) : BaseStateLaneA(lane) {
}

StateB_ShipActivate::~StateB_ShipActivate() {
}

void StateB_ShipActivate::begin()
{
    Model* model = Model::instance();
    
    StringUtilities::log("StateB_ShipActivate::begin");
    
    // Deactivate the landing pad as well.
    CircleShip* cShip = model->getCircleShip();

    cShip->attachCup();
    
    // Activate the ship.
    lane->setActiveActor(cShip);
    lane->getRotateControl()->setAnglePower(cShip->getRotatePower());

    // Apply a downward force on the ship to show that the ship has
    // been boarded.
    b2Vec2 position = cShip->getPosition();
    b2Vec2 downward(0.0f, -5.0f);
    cShip->applyLinearImpulse(downward, position);
}

void StateB_ShipActivate::beforeStep(long dt)
{
    BaseStateLaneA::beforeStep(dt);
    Model* model = Model::instance();
    CircleShip* cShip = model->getCircleShip();

    cShip->beforeStep(dt);
}

void StateB_ShipActivate::afterStep(long dt)
{
    Model* model = Model::instance();
    CircleShip* cShip = model->getCircleShip();

    cShip->update(dt);
    BaseStateLaneA::afterStep(dt);
    cShip->afterStep(dt);

    movetToNextState(lane->getStateC_Gather());
}

// This method is ultimately being called by the physics engine for each contact
// it finds during each step.
// Note: if the joint was created with collideConnected = false then this method is pointless
// for that joint and won't be called by the physic engine.
bool StateB_ShipActivate::shouldCollide(const b2Fixture* const fixtureA, const b2Fixture* const fixtureB)
{
//    ContactUserData* userDataA = (ContactUserData*)fixtureA->GetUserData();
//    ContactUserData* userDataB = (ContactUserData*)fixtureB->GetUserData();
//    
//    if ((userDataA->getType() == ContactUserData::BoxCargo && userDataB->getType() == ContactUserData::CircleShip)
//        || (userDataA->getType() == ContactUserData::CircleShip && userDataB->getType() == ContactUserData::BoxCargo))
//    {
//        // The box cargo needs to penetrate the ship's hull into to be caught by the ship's cup.
//        return false;
//    }
//    
    return true;   // otherwise the fixtures should collide.
}

void StateB_ShipActivate::draw()
{
    Model* model = Model::instance();
    CircleShip* cShip = model->getCircleShip();
    cShip->draw();
    BaseStateLaneA::draw();
}

void StateB_ShipActivate::end()
{
}

void StateB_ShipActivate::release(b2World* world)
{
}

void StateB_ShipActivate::movetToNextState(ILaneState* state)
{
    lane->setState(state);
}