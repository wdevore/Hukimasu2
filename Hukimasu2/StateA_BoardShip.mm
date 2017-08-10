//
//  StateA_BoardShip.m
//  Hukimasu2
//
//  Created by William DeVore on 7/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "StringUtilities.h"

#import "SampleLaneA.h"
#import "StateA_BoardShip.h"

#import "CircleShip.h"
#import "ActorGround.h"
#import "TriangleShip.h"

#import "ViewZone.h"
#import "LandingPadTypeC.h"
#import "RangeZone.h"

#import "ContactUserData.h"

StateA_BoardShip::StateA_BoardShip(SampleLaneA* lane) : BaseStateLaneA(lane) {
}

StateA_BoardShip::~StateA_BoardShip() {
}

void StateA_BoardShip::begin()
{
    StringUtilities::log("StateA_BoardShip::begin");
    Model* model = Model::instance();
    CircleShip* cShip = model->getCircleShip();
    cShip->attachPad();
    
    model->buildCatcherShip();
}

void StateA_BoardShip::beforeStep(long dt)
{
    BaseStateLaneA::beforeStep(dt);
    Model* model = Model::instance();
    model->getCircleShip()->beforeStep(dt);
    model->getSuit()->beforeStep(dt);
}

void StateA_BoardShip::afterStep(long dt)
{
    Model* model = Model::instance();
    CircleShip* cShip = model->getCircleShip();
    TriangleShip* suit = model->getSuit();
    
    cShip->update(dt);
    suit->update(dt);

    BaseStateLaneA::afterStep(dt);
    
    cShip->afterStep(dt);
    suit->afterStep(dt);

    b2Vec2 actorW = lane->getActiveActor()->getPosition();   // This value is in WORLD-space
    
    // Has suit entered the ship's space?
    RangeZone* rangeZone = lane->getRangeZone();
    rangeZone->check(actorW);

    if (rangeZone->getState() == Zone::ENTERED)
    {
        // Extend pad
        cShip->activatePad();
        cShip->extendPad();
    }
    else if (rangeZone->getState() == Zone::EXITED)
    {
        // Retract pad
        cShip->extractPad();
    }
    else if (rangeZone->getState() == Zone::INSIDE)
    {
        if (cShip->hasSomethingSuccessfullyLanded())
        {
            if (!cShip->isPadFullyRetracted())
            {
                cShip->extractPad();
            }
            else
            {
                // Pad has fully retracted. We can move to State B
                movetToNextState(lane->getStateB_ShipActivate());
                return;
            }
        }
        // Check to see if the pad has fully extended
        //if (cShip->isPadFullyExtended()) 
        //{
        //   //StringUtilities::log("fully extended");
        //}

        //if (cShip->isPadFullyRetracted())
        //{
        //    //StringUtilities::log("fully retracted");
        //}
    }
    else if (rangeZone->getState() == Zone::OUTSIDE)
    {
    }
    
    cShip->processContacts(dt);
    
    suit->processContacts(dt);

}

// This method is ultimately being called by the physics engine for each contact
// it finds during each step.
bool StateA_BoardShip::shouldCollide(const b2Fixture* const fixtureA, const b2Fixture* const fixtureB)
{
    ContactUserData* userDataA = (ContactUserData*)fixtureA->GetUserData();
    ContactUserData* userDataB = (ContactUserData*)fixtureB->GetUserData();
    
    bool m = (userDataA->getType() == ContactUserData::TriangleShip || userDataB->getType() == ContactUserData::LandingPadTypeC);
    m = m || (userDataA->getType() == ContactUserData::LandingPadTypeC || userDataB->getType() == ContactUserData::TriangleShip);
    
    if (m)
    {
        // The physics engine is asking about the triangle/suit and circleship.
        if (Model::instance()->getCircleShip()->hasSomethingSuccessfullyLanded())
        {
            // The suit landed. 
            // We now want to filter out the collision between the suit and the circleship.
            // This means we need to tell the physics engine to ignore the collision between them; otherwise
            // when the suit is being pulled inside the ship the suit will collide with the ship.
            // We return false indicating they should "NOT" collide.
            return false;
        }
    }
    
    return true;   // otherwise the fixtures should collide.
}

void StateA_BoardShip::draw()
{
    Model* model = Model::instance();
    CircleShip* cShip = model->getCircleShip();
    TriangleShip* suit = model->getSuit();

    cShip->draw();
    suit->draw();
    lane->getRangeZone()->draw(PTM_RATIO);
    BaseStateLaneA::draw();
}

void StateA_BoardShip::end()
{
    StringUtilities::log("StateA_BoardShip::end");
    Model* model = Model::instance();
    CircleShip* cShip = model->getCircleShip();
    cShip->releasePad(model->getPhysicsWorld());
    
    // Deactivate the suit and make it invisible.
    model->destroySuit();
}

void StateA_BoardShip::release(b2World* world)
{
}

void StateA_BoardShip::reset(b2World* world)
{
    Model* model = Model::instance();
    TriangleShip* suit = model->getSuit();
    
    // Move suit back to start position
    suit->setPosition(-14.0f, 7.75f);
    suit->setAngle(0.0f);
    suit->zeroVelocities();
    suit->activate(true);

    CircleShip* cShip = model->getCircleShip();
    // Reset state vars
    cShip->reset();
}

void StateA_BoardShip::movetToNextState(ILaneState* state)
{
    lane->setState(state);
}