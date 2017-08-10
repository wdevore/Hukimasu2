//
//  LinerRotateControl.m
//  Hukimasu
//
//  Created by William DeVore on 4/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <iostream>
#import "LinearRotateControl.h"
#import "StringUtilities.h"

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>


LinearRotateControl::LinearRotateControl() {
    
}

LinearRotateControl::~LinearRotateControl()
{
    StringUtilities::log("LinearRotateControl::~LinearRotateControl");
}

void LinearRotateControl::init(float screenWidth, float screenHeight)
{
    _screenWidth = screenWidth;
    _screenHeight = screenHeight;
    
    lineColor.Set(0.3f, 0.8f, 0.3f);
    line = new b2Vec2[2];
    
    _anglePower = 1.0f;
    averageIndex = 0;
}

void LinearRotateControl::release()
{
    delete [] line;
}

void LinearRotateControl::draw()
{
    glColor4f(lineColor.r, lineColor.g, lineColor.b, 1.0f);
    glVertexPointer(2, GL_FLOAT, 0, line);
    glDrawArrays(GL_LINES, 0, 2);
}

bool LinearRotateControl::controlApplies(float x, float y)
{
    return x > (_screenWidth - (_screenWidth / 5.0f));
}

void LinearRotateControl::touchUpdate(float x, float y)
{
}

bool LinearRotateControl::triggered()
{
    return true;
}

void LinearRotateControl::touchBegan(float x, float y)
{
    line[0].Set(x, y);
    line[1].Set(x, y);
    prevVector.Set(x, y);
    averageAngle[0] = 0.0f;
    averageAngle[1] = 0.0f;
    averageAngle[2] = 0.0f;
    averageIndex = 0;
    _deltaAngle = 0.0f;
}

// This is a simple vertical control
void LinearRotateControl::touchMoved(float currentX, float currentY)
{
    // Capture end point to rendering of line.
    line[1].Set(currentX, currentY);
    
    b2Vec2 vector;
    vector.Set(line[1].x - prevVector.x, line[1].y - prevVector.y);
    
    _deltaAngle = vector.y / _anglePower;
    
    // Even with the averaging there can still be enough touch
    // noise that the delta can spike, so we clamp it as a failsafe.
//    if (fabsf(_deltaAngle) > 0.05f) {
//        if (_deltaAngle < 0.0f)
//            _deltaAngle = -0.05;
//        else
//            _deltaAngle = 0.05f;
//    }

    // We average the deltas to minimize the noise that the touch
    // surface can produce.
    averageAngle[averageIndex] = _deltaAngle;
    _deltaAngle = averageAngle[0];
    _deltaAngle += averageAngle[1];
    _deltaAngle += averageAngle[2];
    _deltaAngle /= 3.0f;
    
    averageIndex  = (averageIndex + 1) % 3;
    
    prevVector.Set(line[1].x, line[1].y);
}

float LinearRotateControl::deltaAngle()
{
    //StringUtilities::log("LinearRotateControl::deltaAngle ",_deltaAngle);
    return (_deltaAngle);
}

void LinearRotateControl::setAnglePower(float power)
{
    _anglePower = power;
}
