//
//  BasicLane.m
//  Hukimasu2
//
//  Created by William DeVore on 7/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "Box2D.h"
#import "StringUtilities.h"

#import "BasicLane.h"

#import "ActorShip.h"
#import "CircleShip.h"
#import "ViewZone.h"
#import "Model.h"
#import "RotateControl.h"
#import "Box2dContactListener.h"

BasicLane::BasicLane() {
    viewZone = NULL;
    viewZone2 = NULL;
    viewZone3 = NULL;
    model = NULL;
    rotateControl = NULL;
    ground = NULL;
    ship = NULL;
}

BasicLane::~BasicLane() {
}

void BasicLane::init()
{
    model = Model::instance();
    
    model->resetMatrix();

    viewZone2 = ViewZone::createAsRectangle(1.0f, b2Vec2(10.0f, 10.0f), 8.0f, 8.0f);
    viewZone2->init();
    
    viewZone3 = ViewZone::createAsRectangle(1.0f, b2Vec2(-15.0f, 10.0f), 6.0f, 6.0f);
    viewZone3->init();
    
    viewZone = ViewZone::createAsCircle(1.0f, b2Vec2(0.0f, 2.0f), 4.0f);
    viewZone->init();
    
    maxNumberShipModels = 2;

    rotateControl = model->createRotateControl(0);
    rotateControl->init(model->getViewWidth(), model->getViewHeight());

    initialShipPosition.Set(5.0f, 5.0f);

    ship = model->buildCircleShip();
    ship->setPosition(5.0f, 5.0f);
    rotateControl->setAnglePower(ship->getRotatePower());

    ground = new ActorGround();
    std::list<edge> edges;
    buildBasicLand(edges);
    ground->init(model->getPhysicsWorld(), edges);

    model->setTranslation(0.0f, 0.0f);
    
    model->setVerticalGravity(-2.5f);
    model->enableClock(true);
    
    model->setScale(0.5f);

    // Now "bake" in the above transformations.
    model->transform();
}

void BasicLane::begin()
{
    
}

void BasicLane::beforeStep(long dt)
{
    b2Vec2 shipW = ship->getPosition();   // This value is in WORLD-space
    
    ship->update(dt);
    
    ground->update(dt);
    
    viewZone->check(shipW);
    viewZone2->check(shipW);
    viewZone3->check(shipW);

    ship->beforeStep(dt);

}

void BasicLane::afterStep(long dt)
{
    ship->afterStep(dt);

}

void BasicLane::draw()
{
    ship->draw();
    //world->DrawDebugData();
    
    ground->draw();

    viewZone->draw(PTM_RATIO);
    viewZone2->draw(PTM_RATIO);
    viewZone3->draw(PTM_RATIO);
}

void BasicLane::pause()
{
    
}

void BasicLane::resume()
{
    
}

void BasicLane::reset(b2World* const world)
{
    
}

void BasicLane::end()
{
    
}

void BasicLane::release(b2World* world)
{
    model->destroyCircleShip();
    
    ground->release(world);
    delete ground;

    delete rotateControl;

    delete viewZone;
    delete viewZone2;
    delete viewZone3;
}

HuActor* BasicLane::getActiveActor()
{
    return activeActor;
}

CircleShip* BasicLane::getShip()
{
    return ship;
}

RotateControl* BasicLane::getRotateControl()
{
    return rotateControl;
}

void BasicLane::touchBegin(float x, float y)
{
    if (model->isOverlayVisible()) {
        ship->rotating(false);
        
        return;
    }

    if (rotateControl->controlApplies(x, y))
    {
        // They touched in the turning region.
        ship->rotating(true);
        
        rotateControl->touchBegan(x, y);
    }
    else
    {
        float rowSize = model->getViewHeight() / 4.0f;
        float colSize = model->getViewWidth() / 5.0f;
        ship->thrusting(colSize, rowSize, x, y);
    }
}

void BasicLane::touchMove(float x, float y, float dx, float dy)
{
    if (rotateControl->controlApplies(x, y)) {
        rotateControl->touchMoved(x, y);
        
        if (rotateControl->triggered()) {
            ship->applyAngularImpulse(rotateControl->deltaAngle());
        }
    }
}

void BasicLane::touchEnd(float x, float y)
{
    if (!Model::instance()->isOverlayVisible()) {
        if (rotateControl->controlApplies(x, y)) {
            ship->rotating(false);
        }
        else {
            ship->thrusting(0, 0, -1, -1);
        }
    }
}

void BasicLane::buildBasicLand(std::list<edge> & edges)
{
    edge e04 = {b2Vec2(-35.0f, 2.5f), b2Vec2(-25.0f, 2.5f)};
    edges.push_back(e04);
    
    edge e03 = {b2Vec2(-25.0f, 2.5f), b2Vec2(-20.0f, 7.5f)};
    edges.push_back(e03);
    
    edge e02 = {b2Vec2(-20.0f, 7.5f), b2Vec2(-10.0f, 7.5f)};
    edges.push_back(e02);
    
    edge e01 = {b2Vec2(-10.0f, 7.5f), b2Vec2(-10.0f, 5.5f)};
    edges.push_back(e01);
    
    edge e0 = {b2Vec2(-10.0f, 5.5f), b2Vec2(-5.0f, 2.5f)};
    edges.push_back(e0);
    
    edge e1 = {b2Vec2(-5.0f, 2.5f), b2Vec2(1.0f, 2.5f)};
    edges.push_back(e1);
    
    edge e2 = {b2Vec2(1.0f, 2.5f), b2Vec2(1.5f, 1.0f)};
    edges.push_back(e2);
    
    edge e3 = {b2Vec2(1.5f, 1.0f), b2Vec2(7.0f, 1.0f)};
    edges.push_back(e3);
    
    edge e4 = {b2Vec2(7.0f, 1.0f), b2Vec2(7.5f, 0.0f)};
    edges.push_back(e4);
    
    edge e5 = {b2Vec2(7.5f, 0.0f), b2Vec2(10.5f, 0.0f)};
    edges.push_back(e5);
    
    edge e6 = {b2Vec2(10.5f, 0.0f), b2Vec2(11.0f, 2.0f)};
    edges.push_back(e6);
    
    edge e7 = {b2Vec2(11.0f, 2.0f), b2Vec2(11.0f, 5.0f)};
    edges.push_back(e7);
    
    edge e8 = {b2Vec2(11.0f, 5.0f), b2Vec2(15.0f, 10.0f)};
    edges.push_back(e8);
    
    edge e9 = {b2Vec2(15.0f, 10.0f), b2Vec2(20.0f, 10.0f)};
    edges.push_back(e9);
    
    edge e10 = {b2Vec2(20.0f, 10.0f), b2Vec2(40.0f, 10.0f)};
    edges.push_back(e10);
}

void BasicLane::debug()
{
    
}
