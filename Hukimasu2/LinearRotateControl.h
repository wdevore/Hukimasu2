//
//  LinerRotateControl.h
//  Hukimasu
//
//  Created by William DeVore on 4/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Box2D.h"

#import "RotateControl.h"

class LinearRotateControl : public RotateControl {
    
private:
    int averageIndex;
    float averageAngle[3];
    
    b2Color lineColor;
    b2Vec2* line;
    b2Vec2 prevVector;

public:
    
    LinearRotateControl();
    ~LinearRotateControl();
    
    virtual void init(float screenWidth, float screenHeight);
    virtual void release();

    virtual void touchUpdate(float x, float y);

    virtual bool controlApplies(float x, float y);

    virtual void draw();

    virtual bool triggered();
    virtual void touchBegan(float x, float y);
    virtual void touchMoved(float currentX, float currentY);
    
    virtual float deltaAngle();
    
    virtual void setAnglePower(float power);

};
