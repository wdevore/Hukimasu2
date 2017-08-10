//
//  AngleRotateControl.m
//  Hukimasu
//
//  Created by William DeVore on 4/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <iostream>
#import "AngleRotateControl.h"
#import "StringUtilities.h"

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

AngleRotateControl::AngleRotateControl() {
    
}

AngleRotateControl::~AngleRotateControl()
{
    StringUtilities::log("AngleRotateControl::~AngleRotateControl");
}

void AngleRotateControl::init(float screenWidth, float screenHeight)
{
    _screenWidth = screenWidth;
    _screenHeight = screenHeight;
    
    ringLineColor.Set(0.3f, 0.8f, 0.3f);
    ringLine = new b2Vec2[2];
    
    ringInnerRimColor.Set(0.1f, 0.5f, 1.0f);
    
    ringOuterRimColor.Set(1.0f, 0.5f, 0.1f);
    ringOuterRim = new b2Vec2[40];       // 36/4 = 9 degree per step = 360/9 = 40 steps
    
    int rc = 0;
    for (int i = 0; i < 360; i += 9) {
        float rads = i * b2_pi / 180.0f;
        ringOuterRim[rc].x = cosf(rads);
        ringOuterRim[rc].y = sinf(rads);
        rc++;
    }
}

void AngleRotateControl::release()
{
    delete [] ringLine;
    delete [] ringOuterRim;
}

void AngleRotateControl::draw()
{
    // Draw radial line.
    glColor4f(ringLineColor.r, ringLineColor.g, ringLineColor.b, 1.0f);
    glVertexPointer(2, GL_FLOAT, 0, ringLine);
    glDrawArrays(GL_LINES, 0, 2);

    glVertexPointer(2, GL_FLOAT, 0, ringOuterRim);

    // Draw rotation circle.
    //glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    glColor4f(ringOuterRimColor.r, ringOuterRimColor.g, ringOuterRimColor.b, 1.0f);
    glPushMatrix();
    glTranslatef(ringLine[0].x, ringLine[0].y, 0.0f);
    glScalef(ringOuterRadius, ringOuterRadius, 0.0f);
    glDrawArrays(GL_LINE_LOOP, 0, 40);
    glPopMatrix();
    
    glColor4f(ringInnerRimColor.r, ringInnerRimColor.g, ringInnerRimColor.b, 1.0f);
    glPushMatrix();
    glTranslatef(ringLine[0].x, ringLine[0].y, 1.0f);
    glScalef(25.0f, 25.0f, 0.0f);
    glDrawArrays(GL_LINE_LOOP, 0, 40);
    glPopMatrix();
}

bool AngleRotateControl::controlApplies(float x, float y)
{
    return y < (_screenHeight / 2.0f);
}

bool AngleRotateControl::triggered()
{
    return ringOuterRadius > 25.0f;
}

void AngleRotateControl::touchBegan(float x, float y)
{
    ringLine[0].Set(x, y);
    ringLine[1].Set(x, y);
    ringOuterRadius = 0.0f;
    prevAngle = 0.0f;
    prevVector.Set(0.0f, 0.0f);
    sign = 1.0f;
    averageAngle[0] = 0.0f;
    averageAngle[1] = 0.0f;
    averageAngle[2] = 0.0f;
    averageIndex = 0;
    motionState = 0;
    _deltaAngle = 0.0f;
}

void AngleRotateControl::touchUpdate(float currentX, float currentY)
{
    // Capture end point to rendering of line.
    ringLine[1].Set(currentX, currentY);
    
    vector.Set(ringLine[1].x - ringLine[0].x, ringLine[1].y - ringLine[0].y);
    ringOuterRadius = vector.Length();

    vector.Normalize();

    if ((prevVector.y < 0.0f && vector.y > 0.0f) || (prevVector.y > 0.0f && vector.y < 0.0f) || (prevVector.y == 0.0f && vector.y != 0.0f)) {
        // The sign has changed since the last movement which means they
        // have passed the half plane.
        // If it was increasing before the crossover then we continue to increase.
        // If it was decreasing then we continue to decrease.
        sign *= -1.0f;

    }

    prevVector.Set(vector.x, vector.y);

    if (vector.y >= 0.0f)
        sign = -1.0f;
    else
        sign = 1.0f;

    prevAngle = calcAngle();

    if (triggered()) {
        motionState = 1;
    }
}

float AngleRotateControl::calcAngle()
{
    b2Vec2 refAxis;
    refAxis.Set(1.0f, 0.0f);
    
    // Get the angle between the reference axis and the current
    // drag vector.
    float dot = b2Dot(vector, refAxis);

    return acosf(dot);
}

void AngleRotateControl::touchMoved(float currentX, float currentY)
{
    switch (motionState) {
        case 0:
            touchUpdate(currentX, currentY);
            break;
            
        default:
            // Capture end point to rendering of line.
            ringLine[1].Set(currentX, currentY);
            
            //
            //       .-------> X
            //        \ theta
            //         \
            //          \
            //           
            // Form vector from location to location2
            vector.Set(ringLine[1].x - ringLine[0].x, ringLine[1].y - ringLine[0].y);
            ringOuterRadius = vector.Length();
            
            vector.Normalize();
            
            if ((prevVector.y < 0.0f && vector.y > 0.0f) || (prevVector.y > 0.0f && vector.y < 0.0f) || (prevVector.y == 0.0f && vector.y != 0.0f)) {
                // The sign has changed since the last movement which means they
                // have passed the half plane.
                // We need to track the angle.
                // If it was increasing before the crossover then we continue to increase.
                // If it was decreasing then we continue to decrease.
                sign *= -1.0f;
            }
            
            float currentAngle = calcAngle();
            //std::cout << "currentAngle: " << currentAngle << std::endl;
            
            _deltaAngle = (prevAngle - currentAngle);
            
            // We average the deltas to minimize the noise that the touch
            // surface can produce.
            averageAngle[averageIndex] = _deltaAngle;
            _deltaAngle = averageAngle[0];
            _deltaAngle += averageAngle[1];
            _deltaAngle += averageAngle[2];
            _deltaAngle /= 3.0f;
            
            averageIndex  = (averageIndex + 1) % 3;
            
            // Tone down the radius a bit.
            _deltaAngle *=  ringOuterRadius / 80.0f;
            
            // Even with the averaging there can still be enough touch
            // noise that the delta can spike, so we clamp it as a failsafe.
            if (fabsf(_deltaAngle) > 0.1f) {
                if (_deltaAngle < 0.0f)
                    _deltaAngle = -0.1f;
                else
                    _deltaAngle = 0.1f;
            }

            prevVector.Set(vector.x, vector.y);
            prevAngle = currentAngle;
            break;
    }
}

float AngleRotateControl::deltaAngle()
{
    return (_deltaAngle * sign);
}

void AngleRotateControl::setAnglePower(float power)
{
    _anglePower = power;
}
