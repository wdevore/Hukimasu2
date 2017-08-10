//
//  ContactUserData.h
//  Hukimasu2
//
//  Created by William DeVore on 7/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <string>

class ContactUserData {
public:
    /**
     * The types of Data that fixtures and bodies can hold
     */
    enum DataTypes {
        CircleShip,
        CircleShipLeftLeg,
        CircleShipRightLeg,
        TriangleShip,
        ActorGround,
        LandingPadTypeA,
        LandingPadTypeB,
        LandingPadTypeC,
        Cup,
        CatcherShip,
        CatcherShipLeftLeg,
        CatcherShipRightLeg,
        CatcherShipLeftWall,
        CatcherShipRightWall,
        EmitterBase,
        EmitterLeftWall,
        EmitterRightWall,
        BoxCargo
    };

private:
    void* object;
    DataTypes objectType;
    int data1;
    
public:
    ContactUserData();
    virtual ~ContactUserData();
    
    void setObject(void* object, DataTypes type);
    void* getObject();
    
    void setData1(int value);
    int getData1();
    
    DataTypes getType();
    
    std::string toString();
};
