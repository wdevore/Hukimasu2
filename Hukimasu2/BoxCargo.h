//
//  BoxCargo.h
//  Hukimasu2
//
//  Created by William DeVore on 10/30/11 A.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import "HuActor.h"

class ContactUserData;

class BoxCargo : public HuActor {
private:
    
    b2Vec2* baseVertices;
    int baseVertexCount;
    
    b2Body* baseBody;
    
    ContactUserData* contactUserDataBase;
    
public:
    BoxCargo();
    ~BoxCargo();
    
    virtual void init(b2World* const world);
    virtual void release(b2World* const world);
    virtual void reset();

    virtual void processContacts(long dt);
    
    virtual void update(long dt);
    virtual void draw();
    
    virtual void beforeStep(long dt);
    virtual void afterStep(long dt);

    void setPosition(float x, float y);
    virtual const b2Vec2& getPosition();
    
    virtual float getAngle();
    virtual void setAngle(float angle);

    void applyForce();

    virtual void activate(bool state);

};
