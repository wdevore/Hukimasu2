//
//  ViewZone.h
//  Hukimasu
//
//  Created by William DeVore on 6/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//
// A ViewZone is a region where the view is centered and zoomed in.
// The region is defined by a rectangle
// Entering a zone: causes a zoom at the zone's center (aka anchor) and
// the zone's center is scrolled to the view's center.
// Exiting a zone: cause the zoom to restore to the current world zoom value and
// the current view to be scrolled to the ship's position thus centering the
// view on the ship.
//
// This zone has one animated property for animating the scale.
#import <iostream>

#import "Box2D.h"
#import "Rectangle.h"
#import "Circle.h"
#import "PropertySetterTimingTarget.h"
#import "Zone.h"

class IShape;

class ViewZone : public Zone {
private:
    IShape* shape;
    float scale;

    PropertySetterTimingTarget<float>* scaleTarget;
    // An animator to animate the world's scale property
    Animator* scaleAnimator;

public:
    ViewZone();
    virtual ~ViewZone();
   
    static ViewZone* createAsRectangle(float scale, const b2Vec2& center, const b2Vec2& min, const b2Vec2& max)
    {
        ViewZone* zone = new ViewZone();
        zone->shape = new Rectangle(center.x, center.y, min.x, min.y, max.x, max.y);
        zone->init();
        zone->scale = scale;
        zone->shape->setColor(Vector4f(0.2f, 0.2f, 1.0f, 1.0f));
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
    static ViewZone* createAsRectangle(float scale, const b2Vec2& center, float width, float height)
    {
        ViewZone* zone = new ViewZone();
        zone->shape = new Rectangle(center, width, height);
        zone->init();
        zone->scale = scale;
        zone->shape->setColor(Vector4f(0.2f, 0.2f, 1.0f, 1.0f));
        return zone;
    }
    
    static ViewZone* createAsCircle(float scale, const b2Vec2& center, float radius)
    {
        ViewZone* zone = new ViewZone();
        zone->shape = new Circle(center.x, center.y, radius);
        zone->init();
        zone->scale = scale;
        zone->shape->setColor(Vector4f(0.2f, 0.2f, 1.0f, 1.0f));
        return zone;
    }
    
    void init();
    
    virtual const b2Vec2& getCenter();
    float getScale();
    
    virtual void check(const b2Vec2& point);
    
    virtual bool pointInside(const b2Vec2& point);
    
    virtual void draw(float ratio);

    std::string toString();
};
