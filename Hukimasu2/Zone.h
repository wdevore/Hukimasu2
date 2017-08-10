//
//  Zone.h
//  Hukimasu2
//
//  Created by William DeVore on 8/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "Box2D.h"

class Zone {
public:
    enum CROSSSTATE {
        // Object has remained in the side since the last check.
        NONE,
        // Object has entered zone.
        ENTERED,
        // Object has exited zone.
        EXITED,
        INSIDE,
        OUTSIDE
    };
    
protected:
    // Between frames we need to check if the object has enter or exited
    // true = inside zone, false = outside zone.
    int prevEnterExit;
    
    float enterScale;
    
    CROSSSTATE state;

public:
    Zone();
    virtual ~Zone();
    
    void init();
    
    virtual const b2Vec2& getCenter() = 0;
    virtual void draw(float ratio) = 0;
    virtual void check(const b2Vec2& point) = 0;
    
    CROSSSTATE crossed(bool enterExit);
    CROSSSTATE getState();
    
    virtual bool pointInside(const b2Vec2& point) = 0;
    
    std::string toString();
};