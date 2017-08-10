//
//  Circle.h
//  Hukimasu
//
//  Created by William DeVore on 6/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "IShape.h"

class Circle : public IShape {
    
private:
    float radius;
    
public:
    Circle();
    virtual ~Circle();
    
    Circle(float cx, float cy, float radius);
    
    virtual void draw(float ratio);
    
    virtual void setPosition(const b2Vec2& point);
    virtual void setColor(const Vector4f& color);
    virtual void setColor(float r, float g, float b, float a);

    // Return true if point inside circle
    virtual bool pointInside(const b2Vec2& point);
    
    float distanceFromCenter(const b2Vec2& point);
    float distanceFromEdge(const b2Vec2& point);
    
    virtual const b2Vec2& getCenter();
    float getRadius();
    
    virtual std::string toString();
    
};
