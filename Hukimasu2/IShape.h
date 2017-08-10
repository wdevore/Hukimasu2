//
//  IShape.h
//  Hukimasu2
//
//  Created by William DeVore on 6/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "Box2D.h"
#import "vmath.h"

class IShape {
protected:
    // The rectangle's center position.
    b2Vec2 position;
    Vector4f color;
    
public:
    virtual void setPosition(const b2Vec2& point) = 0;
    virtual void setColor(const Vector4f& color) = 0;
    virtual void setColor(float r, float g, float b, float a) = 0;
    
    // Return true if point inside circle
    virtual bool pointInside(const b2Vec2& point) = 0;
    
    virtual const b2Vec2& getCenter() = 0;

    virtual void draw(float ratio) = 0;
    
    virtual std::string toString() = 0;
};
