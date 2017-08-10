//
//  RotateControl.h
//  Hukimasu
//
//  Created by William DeVore on 4/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

class RotateControl {
    
protected:
    float _deltaAngle;
    float _screenWidth;
    float _screenHeight;
    float _anglePower;
    
public:
    RotateControl();
    virtual ~RotateControl();
    
    virtual void init(float screenWidth, float screenHeight) = 0;
    virtual void release() = 0;
    
    virtual bool controlApplies(float x, float y) = 0;

    virtual void draw() = 0;

    virtual bool triggered() = 0;

    virtual void touchUpdate(float x, float y) = 0;
    virtual void touchBegan(float x, float y) = 0;
    virtual void touchMoved(float currentX, float currentY) = 0;
    
    virtual float deltaAngle() = 0;
    
    virtual void setAnglePower(float power) = 0;
};
