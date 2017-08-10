//
//  RangeZone.h
//  Hukimasu2
//
//  Created by William DeVore on 8/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <iostream>

#import "Box2D.h"
#import "Rectangle.h"
#import "Circle.h"
#import "PropertySetterTimingTarget.h"
#import "Zone.h"

class IShape;

class RangeZone : public Zone {
private:
    IShape* shape;
    
public:
    RangeZone();
    ~RangeZone();
    
    static RangeZone* createAsRectangle(const b2Vec2& center, const b2Vec2& min, const b2Vec2& max)
    {
        RangeZone* zone = new RangeZone();
        zone->shape = new Rectangle(center.x, center.y, min.x, min.y, max.x, max.y);
        zone->init();
        zone->shape->setColor(Vector4f(1.0f, 1.0f, 0.5f, 1.0f));
        return zone;
    }
    
    // This zone is defined as:
    //           width
    //  .-----------------.
    //  |                    |
    //  |                    |
    //  |     center       |  height
    //  |                    |
    //  |                    |
    //  .-----------------.
    // 0,0
    //
    static RangeZone* createAsRectangle(const b2Vec2& center, float width, float height)
    {
        RangeZone* zone = new RangeZone();
        zone->shape = new Rectangle(center, width, height);
        zone->init();
        zone->shape->setColor(Vector4f(1.0f, 1.0f, 0.5f, 1.0f));
        return zone;
    }
    
    static RangeZone* createAsCircle(b2Vec2 center, float radius)
    {
        RangeZone* zone = new RangeZone();
        zone->shape = new Circle(center.x, center.y, radius);
        zone->init();
        zone->shape->setColor(Vector4f(1.0f, 1.0f, 0.5f, 1.0f));
        return zone;
    }
    
    void init();
    
    virtual const b2Vec2& getCenter();
    
    virtual void check(const b2Vec2& point);
    
    virtual bool pointInside(const b2Vec2& point);
    
    virtual void draw(float ratio);
    
    void setPosition(const b2Vec2& point);
    
    std::string toString();
};