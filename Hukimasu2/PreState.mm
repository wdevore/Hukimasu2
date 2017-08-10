//
//  PreState.m
//  Hukimasu2
//
//  Created by William DeVore on 7/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "StringUtilities.h"
#import "SampleLaneA.h"
#import "PreState.h"
#import "StateA_BoardShip.h"
#import "RotateControl.h"
#import "ActorShip.h"
#import "TriangleShip.h"
#import "CircleShip.h"
#import "ActorGround.h"

#import "Model.h"
#import "LandingPadTypeC.h"
#import "RangeZone.h"

PreState::PreState(SampleLaneA* lane)  : BaseStateLaneA(lane) {
    this->lane = lane;
}

PreState::~PreState() {
}

void PreState::begin()
{
    StringUtilities::log("PreState::begin");

    BaseStateLaneA::begin();
    Model* model = Model::instance();
    
    ActorGround* ground = model->getGround();
    ground->activate(true);
    
    
    CircleShip* cShip = model->getCircleShip();
    TriangleShip* suit = model->getSuit();
    
    // To change active ship switch the lines below along with
    /// the rotate control a few lines down.
    lane->setActiveActor(suit);
    //lane->setActiveActor(cShip);  
    
    b2Vec2 initialSuitPosition(-14.0f, 7.75f);
    suit->setPosition(initialSuitPosition.x, initialSuitPosition.y);
    suit->activate(true);
    
    b2Vec2 initialShipPosition(-8.0f, 3.75f);
    // debug version
    //b2Vec2 initialShipPosition(5.0f, 3.75f);
    cShip->setPosition(initialShipPosition.x, initialShipPosition.y);
    cShip->activate(true);
    
    // NOTE switch active actor above too.
    lane->getRotateControl()->setAnglePower(suit->getRotatePower());
    //lane->getRotateControl()->setAnglePower(cShip->getRotatePower());
    
    lane->getRangeZone()->setPosition(initialShipPosition);
    
    model = Model::instance();
    
    // Set the view position. This position should be in view-space coords not local-space ship coords.
    //model->setTranslation(initialShipPosition.x, initialShipPosition.y);
    
    model->setVerticalGravity(-2.5f);
    model->enableClock(true);
    
    model->setScale(0.5f);
    
    // Now bake in the initial transformation.
    model->transform();

    movetToNextState(lane->getStateA_BoardShip());
    // Debug skip to State B first.
    //movetToNextState(lane->getStateB_ShipActivate());
    //movetToNextState(lane->getStateC_Gather());
}

void PreState::movetToNextState(ILaneState* state)
{
    lane->setState(state);
}
