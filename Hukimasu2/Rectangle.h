//
//  Rectangle.h
//  Hukimasu
//
//  Created by William DeVore on 6/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "Box2D.h"
#import "IShape.h"

#import <iostream>

class Rectangle : public IShape {
    
private:
    // The rectangle's center position.
    b2Vec2 position;
    
    // the lower left corner
    b2Vec2 min;
    
    // upper right
    b2Vec2 max;

    float width;
    float height;
    
public:
    Rectangle();
    virtual ~Rectangle();
    
    Rectangle(float cx, float cy, float minx, float miny, float maxx, float maxy);

    // This constructor creates:
    //           width
    //  .-----------------.
    //  |                    |
    //  |                    |
    //  |                    |  height
    //  |                    |
    //  |                    |
    //  .-----------------.
    // 0,0
    //
    Rectangle(float width, float height);

    // This constructor creates:
    //           width
    //  .-----------------.
    //  |                    |
    //  |                    |
    //  |     position    |  height
    //  |                    |
    //  |                    |
    //  .-----------------.
    // 0,0
    //
    Rectangle(const b2Vec2& position, float width, float height);

    virtual void draw(float ratio);

    virtual bool pointInside(const b2Vec2& point);
    
    virtual void setPosition(const b2Vec2& point);
    virtual void setColor(const Vector4f& color);
    virtual void setColor(float r, float g, float b, float a);

    virtual const b2Vec2& getCenter();
    float getWidth();
    float getHeight();
    
    virtual std::string toString();

};
