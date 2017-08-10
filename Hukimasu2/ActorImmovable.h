//
//  ActorImmovable.h
//  Hukimasu
//
//  Created by William DeVore on 5/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HuActor.h"

class ActorImmovable : public HuActor {
protected:
    b2Vec2 position;
    float _angle;
    
public:
    ActorImmovable();
    ~ActorImmovable();
    
    virtual void init(b2World* const world) = 0;
    
    virtual void processContacts(long dt);

    virtual void setPosition(float x, float y);
    virtual const b2Vec2& getPosition();
    
    virtual float getAngle();
    virtual void setAngle(float angle);

};
