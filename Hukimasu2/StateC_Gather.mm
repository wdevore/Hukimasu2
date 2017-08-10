//
//  StateC_Gather.m
//  Hukimasu2
//
//  Created by William DeVore on 10/28/11 A.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "StateC_Gather.h"

#import "StringUtilities.h"
#import "SampleLaneA.h"

#import "CircleShip.h"
#import "CatcherShip.h"
#import "IEmitter.h"
#import "Emitter.h"
#import "RotateControl.h"

#import "ContactUserData.h"

StateB_Gather::StateB_Gather(SampleLaneA* lane) : BaseStateLaneA(lane) {
}

StateB_Gather::~StateB_Gather() {
}

void StateB_Gather::begin()
{
    StringUtilities::log("StateB_Gather::begin");
    Model* model = Model::instance();
    CatcherShip* catShip = model->buildCatcherShip();
    // Prep the Catcher ship
    catShip->setPosition(10.0f, 7.0f);
    catShip->activate(true);
    
    model->buildEmitter();

    // Place the Emitter
    Emitter* emitter = model->getEmitter();
    emitter->activate(true);
    emitter->setPosition(2.5f, -2.0f + 0.1f);
    // Configure Emitter
    IEmitter* iEmitter = static_cast<IEmitter*>(emitter);
    iEmitter->setInterval(3000000L);
    iEmitter->setCount(5);
    iEmitter->start();
}

void StateB_Gather::beforeStep(long dt)
{
    BaseStateLaneA::beforeStep(dt);
    
    Model* model = Model::instance();
    CircleShip* cShip = model->getCircleShip();

    cShip->beforeStep(dt);

    model->getEmitter()->update(dt);
    model->getEmitter()->beforeStep(dt);
}

void StateB_Gather::afterStep(long dt)
{
    Model* model = Model::instance();
    CircleShip* cShip = model->getCircleShip();
    
    cShip->update(dt);
    BaseStateLaneA::afterStep(dt);
    cShip->afterStep(dt);
    
    model->getEmitter()->afterStep(dt);
}

// This method is ultimately being called by the physics engine for each contact
// it finds during each step.
// Note: if the joint was created with collideConnected = false then this method is pointless
// for that joint and won't be called by the physic engine.
bool StateB_Gather::shouldCollide(const b2Fixture* const fixtureA, const b2Fixture* const fixtureB)
{
    Model* model = Model::instance();
    CircleShip* cShip = model->getCircleShip();
//    bool collide = true;
//    
//    collide = collide && lane->getShip()->shouldCollide(fixtureA, fixtureB);
//    
//    return collide;
    return cShip->shouldCollide(fixtureA, fixtureB);
}

void StateB_Gather::draw()
{
    Model* model = Model::instance();
    CircleShip* cShip = model->getCircleShip();
    CatcherShip* catShip = model->getCatcherShip();

    cShip->draw();
    catShip->draw();
    
    model->getEmitter()->draw();
    
    BaseStateLaneA::draw();
}

void StateB_Gather::end()
{
    Model* model = Model::instance();
    model->destroyEmitter();
}

void StateB_Gather::release(b2World* world)
{
}

void StateB_Gather::reset(b2World* world)
{
    Model* model = Model::instance();
    CircleShip* cShip = model->getCircleShip();
    // debug version
    //cShip->setPosition(5.0f, 3.75f);
    
    // Typical version
    cShip->release(world);
    // Note: get rid of the position requirement on position
    cShip->init(world);
    cShip->setPosition(-8.0f, 3.75f);
    cShip->setAngle(0.0f);
    //cShip->zeroVelocities();
    
    // re-attach cup
    cShip->attachCup();
    
    // Now activate ship
    cShip->activate(true);

    Emitter* emitter = model->getEmitter();
    emitter->pause();
    emitter->reset();
    emitter->start();
    
    // It is better to destroy and rebuild than to attempt
    // to clear velocities and such.
    //    CatcherShip* catShip = model->getCatcherShip();
    model->destroyCatcherShip();
    CatcherShip* catShip = model->buildCatcherShip();
    catShip->setPosition(10.0f, 7.0f);
    catShip->activate(true);
    //    catShip->setAngle(0.0f);
    //    catShip->zeroVelocities();

}