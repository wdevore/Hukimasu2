//
//  ActorGround.h
//  Hukimasu
//
//  Created by William DeVore on 5/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <list>
#import "ActorImmovable.h"
#import "Edge.h"

class ContactUserData;

class ActorGround : public ActorImmovable {
private:
    std::list<edge> edges;
    std::list<ContactUserData*> userDatas;
    
    b2Body* body;

    b2Vec2* vertices;
    int vertexCount;

public:
    ActorGround();
    ~ActorGround();
    
    virtual void init(b2World* const world);
    virtual void init(b2World* const world, std::list<edge>& edges);
    virtual void release(b2World* const world);
    virtual void reset();

    virtual void draw();
    virtual void update(long dt);
    
    virtual void beforeStep(long dt);
    virtual void afterStep(long dt);

    virtual void activate(bool state);

private:
    void buildBasicBox(b2World* const world);
    void attachToWorld(b2World* const world, std::list<edge>& edges);
};
