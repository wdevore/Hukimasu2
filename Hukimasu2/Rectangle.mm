//
//  Rectangle.m
//  Hukimasu
//
//  Created by William DeVore on 6/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <sstream>
#import <iomanip>

#import "Utilities.h"
#import "StringUtilities.h"
#import "Rectangle.h"

Rectangle::Rectangle() {
    
}

Rectangle::~Rectangle() {
    StringUtilities::log("Rectangle::~Rectangle");
}

Rectangle::Rectangle(float cx, float cy, float minx, float miny, float maxx, float maxy) {
    position.x = cx;
    position.y = cy;
    
    min.x = minx;
    min.y = miny;
    
    max.x = maxx;
    max.y = maxy;
    
    width = fabsf(max.x - min.x);
    height = fabsf(max.y - min.y);
}

Rectangle::Rectangle(float width, float height) {
    position.x = width / 2.0f;
    position.y = height / 2.0f;

    this->width = width;
    this->height = height;

    min.x = 0.0f;
    min.y = 0.0f;
    
    max.x = width;
    max.y = height;
}

Rectangle::Rectangle(const b2Vec2& position, float width, float height) {
    this->position.x = position.x;
    this->position.y = position.y;
    
    this->width = width;
    this->height = height;
    
    min.x = position.x - (width / 2.0f);
    min.y = position.y - (height / 2.0f);
    
    max.x = position.x + (width / 2.0f);
    max.y = position.y + (height / 2.0f);
}

const b2Vec2& Rectangle::getCenter()
{
    return position;
}

void Rectangle::setPosition(const b2Vec2& point)
{
    position.Set(point.x, point.y);
}

void Rectangle::setColor(const Vector4f& color)
{
    this->color = color;
}

void Rectangle::setColor(float r, float g, float b, float a)
{
    color.x = r;
    color.y = g;
    color.z = b;
    color.w = a;
}

float Rectangle::getWidth()
{
    return width;
}

float Rectangle::getHeight()
{
    return height;
}

bool Rectangle::pointInside(const b2Vec2& point)
{
    bool inside = false;
    if (point.x > min.x) {
        if (point.y > min.y) {
            if (point.x < max.x) {
                if (point.y < max.y) {
                    inside = true;
                }
            }
        }
    }
    return inside;
}

void Rectangle::draw(float ratio)
{
    //glColor4f(0.2f, 0.2f, 1.0f, 1.0f);
    glColor4f(color.x, color.y, color.z, color.w);

    glVertexPointer(2, GL_FLOAT, 0, Utilities::getNormalizedVertexRectangle());
    glPushMatrix();
    
    // We need to translate and center the default rectangle.
    float width = getWidth();
    float height = getHeight();
    b2Vec2 center = getCenter();
    center.x = center.x - (width / 2.0f);
    center.y = center.y - (height / 2.0f);
    
    glTranslatef(center.x*ratio, center.y*ratio, 0.0f);
    glScalef(width*ratio, height*ratio, 0.0f);
    
	glDrawArrays(GL_LINE_LOOP, 0, Utilities::rectangleVertexCount);
    
    glPopMatrix();
}

std::string Rectangle::toString()
{
    std::ostringstream oss;
    oss << std::setprecision(2);
    oss << std::fixed;
    oss << "[Rectangle Center: " << StringUtilities::toString(position);
    oss << ", "<< "Width: " << width << ", Height: " << height;
    oss << ", "<< "Min: " << StringUtilities::toString(min);
    oss << ", "<< "Max: " << StringUtilities::toString(max);
    oss << "]";
    return oss.str();
}