//
//  ActorGround.m
//  Hukimasu
//
//  Created by William DeVore on 5/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "StringUtilities.h"
#import "ActorGround.h"
#import "Model.h"
#import "ContactUserData.h"
#import "Utilities.h"

ActorGround::ActorGround() {
    setName("Ground");
}

ActorGround::~ActorGround()
{
    StringUtilities::log("ActorGround::~ActorGround");
}

void ActorGround::activate(bool state)
{
    body->SetActive(state);
}

void ActorGround::init(b2World* const world)
{
    buildBasicBox(world);
}

void ActorGround::init(b2World* const world, std::list<edge>& edges)
{
    attachToWorld(world, edges);
}

void ActorGround::release(b2World* const world)
{
    delete [] vertices;

    world->DestroyBody(body);
    body = NULL;

    userDatas.clear();
}

void ActorGround::reset()
{
}

void ActorGround::buildBasicBox(b2World* const world)
{
    Model* model = Model::instance();
    
    edge bottom = {b2Vec2(0.0f, 0.0f), b2Vec2(model->getWorldWidth(), 0.0f)};
    edges.push_back(bottom);
    
    edge top = {b2Vec2(0.0f, model->getWorldHeight()), b2Vec2(model->getWorldWidth(), model->getWorldHeight())};
    edges.push_back(top);
    
    edge left = {b2Vec2(0.0f, model->getWorldHeight()), b2Vec2(0.0f, 0.0f)};
    edges.push_back(left);
    
    edge right = {b2Vec2(model->getWorldWidth(), model->getWorldHeight()), b2Vec2(model->getWorldWidth(), 0.0f)};
    edges.push_back(right);
    
    attachToWorld(world, edges);
}

void ActorGround::attachToWorld(b2World* const world, std::list<edge>& edges)
{
    // Define the ground body.
    b2BodyDef groundBodyDef;
    groundBodyDef.active = false;
    
    // Call the body factory which allocates memory for the ground body
    // from a pool and creates the ground box shape (also from a pool).
    // The body is also added to the world.
    body = world->CreateBody(&groundBodyDef);
    
    // Define the ground box shape.
    b2PolygonShape groundBox;		
    
    // For each edge there are 2 vertices.
    vertexCount = edges.size() * 2;
    vertices = new b2Vec2[vertexCount];
    
    int id = 0;
    std::list<edge>::iterator iter = edges.begin();
    int edgeIndex = 0;
    
    while (iter != edges.end()) {
        edge e = *iter;
        
        groundBox.SetAsEdge(e.start, e.end);
        b2Fixture* fixture = body->CreateFixture(&groundBox, 0);
        
        // TODO This user data needs to be deleted!!!!!
        ContactUserData* userData = new ContactUserData();
        userData->setObject(this, ContactUserData::ActorGround);
        userData->setData1(edgeIndex++);
        userDatas.push_back(userData);
        fixture->SetUserData(userData);

        vertices[id].Set(e.start.x, e.start.y);
        vertices[id+1].Set(e.end.x, e.end.y);
        
        ++iter;
        id += 2;
    }
    
    edges.clear();
}

//########################################################
// ## Physics stepping
//########################################################
void ActorGround::beforeStep(long dt)
{
    
}

void ActorGround::afterStep(long dt)
{
    
}

void ActorGround::update(long dt)
{
    
}

void ActorGround::draw()
{
    Model* model = Model::instance();
    float p2m = model->getPixelsToMetersRatio();
    
    b2Vec2 bodyPos = body->GetPosition();
    float bodyAngle = body->GetAngle();
    
    glVertexPointer(2, GL_FLOAT, 0, vertices);
    glPushMatrix();
    
    glTranslatef(bodyPos.x * p2m, bodyPos.y * p2m, 0.0f);
    glScalef(p2m, p2m, 0.0f);
    glRotatef(bodyAngle * 180.0f / b2_pi, 0.0f, 0.0f, 1.0f);
    
    glColor4f(Utilities::Color_Brown[0], Utilities::Color_Brown[1], Utilities::Color_Brown[2], 1.0f);
	glDrawArrays(GL_LINES, 0, vertexCount);
    
    glPopMatrix();
}
