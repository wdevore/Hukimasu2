//
//  ContactUserData.m
//  Hukimasu2
//
//  Created by William DeVore on 7/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <sstream>
#import <iomanip>

#import "StringUtilities.h"
#import "ContactUserData.h"

ContactUserData::ContactUserData() {
    
}

ContactUserData::~ContactUserData()
{
    StringUtilities::log("ContactUserData::~ContactUserData ", toString() );
}

void ContactUserData::setObject(void *object, DataTypes type)
{
    this->object = object;
    this->objectType = type;
}

void* ContactUserData::getObject()
{
    return object;
}

ContactUserData::DataTypes ContactUserData::getType()
{
    return objectType;
}

void ContactUserData::setData1(int value)
{
    data1 = value;
}

int ContactUserData::getData1()
{
    return data1;
}

std::string ContactUserData::toString()
{
    std::ostringstream oss;

    if (getType() == ContactUserData::ActorGround) {
        oss << "[ActorGround]";
    }
    else if (getType() == ContactUserData::TriangleShip) {
        oss << "[TriangleShip]";
    }
    else if (getType() == ContactUserData::LandingPadTypeA) {
        oss << "[LandingPadTypeA]";
    }
    else if (getType() == ContactUserData::LandingPadTypeB) {
        oss << "[LandingPadTypeB]";
    }
    else if (getType() == ContactUserData::LandingPadTypeC) {
        oss << "[LandingPadTypeC]";
    }
    else if (getType() == ContactUserData::CircleShip) {
        oss << "[CircleShip]";
    }
    else if (getType() == ContactUserData::CircleShipLeftLeg) {
        oss << "[CircleShipLeftLeg]";
    }
    else if (getType() == ContactUserData::CircleShipRightLeg) {
        oss << "[CircleShipRightLeg]";
    }
    else if (getType() == ContactUserData::EmitterBase) {
        oss << "[EmitterBase]";
    }
    else if (getType() == ContactUserData::EmitterLeftWall) {
        oss << "[EmitterLeftWall]";
    }
    else if (getType() == ContactUserData::EmitterRightWall) {
        oss << "[EmitterRightWall]";
    }
    else if (getType() == ContactUserData::BoxCargo) {
        oss << "[BoxCargo]";
    }
    else if (getType() == ContactUserData::CatcherShip) {
        oss << "[CatcherShip]";
    }
    else if (getType() == ContactUserData::CatcherShipLeftLeg) {
        oss << "[CatcherShipLeftLeg]";
    }
    else if (getType() == ContactUserData::CatcherShipRightLeg) {
        oss << "[CatcherShipRightLeg]";
    }
    else if (getType() == ContactUserData::CatcherShipLeftWall) {
        oss << "[CatcherShipLeftWall]";
    }
    else if (getType() == ContactUserData::CatcherShipRightWall) {
        oss << "[CatcherShipRightWall]";
    }
    else if (getType() == ContactUserData::Cup) {
        oss << "[Cup]";
    }
    else {
        oss << "[ContactUserData::UNKNOWN]";
    }

    return oss.str();
}