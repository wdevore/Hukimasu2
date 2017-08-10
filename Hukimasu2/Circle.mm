//
//  Circle.m
//  Hukimasu
//
//  Created by William DeVore on 6/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <sstream>
#import <iomanip>

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "Utilities.h"
#import "StringUtilities.h"

#import "Circle.h"

Circle::Circle() {
    
}

Circle::~Circle() {
    StringUtilities::log("Circle::~Circle");
}

Circle::Circle(float cx, float cy, float radius) {
    position.x = cx;
    position.y = cy;
    
    this->radius = radius;
}

bool Circle::pointInside(const b2Vec2& point)
{
    float distance = distanceFromCenter(point);
    if (distance < radius)
        return true;
    else
        return false;
}

float Circle::distanceFromCenter(const b2Vec2& point)
{
    float dx = position.x - point.x;
    float dy = position.y - point.y;
    return sqrtf(dx*dx + dy*dy);
}

float Circle::distanceFromEdge(const b2Vec2& point)
{
    float dx = position.x - point.x;
    float dy = position.y - point.y;
    float distance = sqrtf(dx*dx + dy*dy);
    return distance - radius;
}

const b2Vec2& Circle::getCenter()
{
    return position;
}

float Circle::getRadius()
{
    return radius;
}

void Circle::setPosition(const b2Vec2& point)
{
    position.Set(point.x, point.y);
}

void Circle::setColor(const Vector4f& color)
{
    this->color = color;
}

void Circle::setColor(float r, float g, float b, float a)
{
    color.x = r;
    color.y = g;
    color.z = b;
    color.w = a;
}

void Circle::draw(float ratio)
{
    //glColor4f(1.0f, 1.0f, 0.2f, 1.0f);
    glColor4f(color.x, color.y, color.z, color.w);
    glVertexPointer(2, GL_FLOAT, 0, Utilities::getNormalizedVertexCircle());

    glPushMatrix();
    
    glTranslatef(position.x*ratio, position.y*ratio, 0.0f);
    glScalef(radius*ratio, radius*ratio, 0.0f);
    
	glDrawArrays(GL_LINE_LOOP, 0, Utilities::circleVertexCount);
    
    glPopMatrix();
}

std::string Circle::toString()
{
    std::ostringstream oss;
    oss << std::setprecision(2);
    oss << std::fixed;
    oss << "[Circle Center: " << StringUtilities::toString(position);
    oss << ", "<< "Radius: " << radius;
    oss << "]";
    return oss.str();
}
