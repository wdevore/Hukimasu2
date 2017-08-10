//
//  Cup.cpp
//  Hukimasu2
//
//  Created by William DeVore on 10/16/11 A.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "StringUtilities.h"
#import "Utilities.h"
#import "Cup.h"
#import "Model.h"
#import "Edge.h"
#import "ContactUserData.h"

Cup::Cup()
{
    body = NULL;
    vertices = NULL;
    leftWallVertices = NULL;
    rightWallVertices = NULL;
}

Cup::~Cup()
{
    StringUtilities::log("Cup::~Cup()");
}

void Cup::activate(bool state)
{
    body->SetActive(state);
}

void Cup::init(b2World* const world)
{
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position.Set(0.0f, 0.0f);
    body = world->CreateBody(&bodyDef);
    
    //body->SetAwake(false);
    body->SetActive(false);
    
    // For each edge there are 2 vertices.
    vertexCount = 4;
    vertices = new b2Vec2[vertexCount];
    vertices[0].Set(-0.5f, -0.25f);
    vertices[1].Set(0.5f, -0.25f);
    vertices[2].Set(0.45f, -0.15f);
    vertices[3].Set(-0.45f, -0.15f);
    
    b2PolygonShape polygon;
    polygon.Set(vertices, vertexCount);
    
    // The density of 1.0f has an effect on any motors attempt to act
    // on this body. The smaller the density the stronger the motor is
    // acting on the body.
    fixture = body->CreateFixture(&polygon, 0.1f);
    fixture->SetFriction(1.0f);
    
    ContactUserData* userData = new ContactUserData();
    userData->setObject(this, ContactUserData::Cup);
    userData->setData1(1);
    fixture->SetUserData(userData);
    
    leftWallVertexCount = 4;
    leftWallVertices = new b2Vec2[leftWallVertexCount];
    leftWallVertices[0].Set(0.5f, -0.25f);
    leftWallVertices[1].Set(0.75f, 0.25f);
    leftWallVertices[2].Set(0.65f, 0.25f);
    leftWallVertices[3].Set(0.45f, -0.15f);
    polygon.Set(leftWallVertices, leftWallVertexCount);
    
    fixture = body->CreateFixture(&polygon, 0.1f);
    fixture->SetFriction(1.0f);
    
    userData = new ContactUserData();
    userData->setObject(this, ContactUserData::Cup);
    userData->setData1(1);
    fixture->SetUserData(userData);
    
    rightWallVertexCount = 4;
    rightWallVertices = new b2Vec2[rightWallVertexCount];
    rightWallVertices[0].Set(-0.5f, -0.25f);
    rightWallVertices[1].Set(-0.45f, -0.15f);
    rightWallVertices[2].Set(-0.65f, 0.25f);
    rightWallVertices[3].Set(-0.75f, 0.25f);
    polygon.Set(rightWallVertices, rightWallVertexCount);
    
    fixture = body->CreateFixture(&polygon, 0.1f);
    fixture->SetFriction(1.0f);
    
    userData = new ContactUserData();
    userData->setObject(this, ContactUserData::Cup);
    userData->setData1(1);
    fixture->SetUserData(userData);
    
}

void Cup::reset()
{
}

void Cup::release(b2World* const world)
{
    Model* model = Model::instance();
    Box2dContactListener* contactTransmitter = model->getWorldContactListener();
    unSubscribeAsContactListener(contactTransmitter);

    ContactUserData* userData = (ContactUserData*)fixture->GetUserData();
    if (userData != NULL)
        delete userData;
    userData = NULL;

    world->DestroyBody(body);
    body = NULL;

    delete [] vertices;
    delete [] leftWallVertices;
    delete [] rightWallVertices;
    vertices = NULL;
    leftWallVertices = NULL;
    rightWallVertices = NULL;
    
    fixture = NULL;
}

void Cup::update(long dt)
{
    
}

void Cup::attachToBody(b2Body* parentBody)
{
    // Attach the cup using a simple weld joint.
    b2WeldJointDef weldJointDef;
    weldJointDef.bodyA = parentBody;
    weldJointDef.bodyB = body;
    // We don't want the cup colliding with the body.
    weldJointDef.collideConnected = false;
    
    Model* model = Model::instance();
    model->getPhysicsWorld()->CreateJoint(&weldJointDef);
}

//=============================================
// Properties
//=============================================
bool Cup::isActive()
{
    return body->IsActive();
}

//=============================================
// Messaging
//=============================================

void Cup::message(int message) {
    StringUtilities::log("Cup::message ", message);
}

void Cup::subscribeListener(IMessage* listener) {
}

void Cup::unSubscribeListener(IMessage* listener) {
}

//=============================================
// Statuses
//=============================================

//=============================================
// Rendering
//=============================================

void Cup::draw() {
    if (!isActive())
        return;
    
    Model* model = Model::instance();
    float p2m = model->getPixelsToMetersRatio();
    
    b2Vec2 pos = body->GetPosition();
    float angle = body->GetAngle();
    
    glVertexPointer(2, GL_FLOAT, 0, vertices);
    glPushMatrix();
    
    glTranslatef(pos.x * p2m, pos.y * p2m, 0.0f);
    glScalef(p2m, p2m, 0.0f);
    glRotatef(angle * 180.0f / b2_pi, 0.0f, 0.0f, 1.0f);
    
    glColor4f(Utilities::Color_Blue[0], Utilities::Color_Blue[1], Utilities::Color_Blue[2], 1.0f);
	glDrawArrays(GL_LINE_LOOP, 0, vertexCount);
    
    glVertexPointer(2, GL_FLOAT, 0, leftWallVertices);
    
    glColor4f(Utilities::Color_Blue[0], Utilities::Color_Blue[1], Utilities::Color_Blue[2], 1.0f);
	glDrawArrays(GL_LINE_LOOP, 0, leftWallVertexCount);
    
    glVertexPointer(2, GL_FLOAT, 0, rightWallVertices);
     
    glColor4f(Utilities::Color_Blue[0], Utilities::Color_Blue[1], Utilities::Color_Blue[2], 1.0f);
	glDrawArrays(GL_LINE_LOOP, 0, rightWallVertexCount);
    glPopMatrix();

}

//============================================= 
// Getters/Setters
//=============================================
void Cup::setPosition(float x, float y)
{
    body->SetTransform(b2Vec2(x, y), body->GetAngle());
}

const b2Vec2& Cup::getPosition()
{
    return body->GetPosition();
}

b2Body* Cup::getBody()
{
    return body;
}

float Cup::getAngle()
{
    return body->GetAngle();
}

void Cup::setAngle(float angle)
{
    body->SetTransform(getPosition(), angle);
}

void Cup::zeroVelocities()
{
    body->SetAngularVelocity(0.0f);
    body->SetLinearVelocity(b2Vec2(0.0f, 0.0f));
}

//########################################################
// ## Physics stepping
//########################################################
void Cup::beforeStep(long dt)
{
    
}

void Cup::afterStep(long dt)
{
    
}

//########################################################
// ## Physics callbacks
//########################################################

// This event only occurs within the time step.
void Cup::beginContact(b2Contact* contact)
{
}

// This event can occur outside the time step
void Cup::endContact(b2Contact* contact)
{
}

// This is called after collision detection, but before collision resolution.
// This gives you a chance to disable the contact based on the current configuration.
// For example, you can implement a one-­‐sided platform using this callback
// and calling b2Contact::SetEnabled(false). The contact will be re-­‐enabled each time
// through collision processing, so you will need to disable the contact every time-­‐step.
// The pre-­‐solve event may be fired multiple times per time step per contact due to continuous collision detection.
void Cup::preSolve(b2Contact* contact, const b2Manifold* oldManifold)
{
}

// The post solve event is where you can gather collision impulse results.
// If you don’t care about the impulses, you should probably just implement the pre-­‐solve event. 
void Cup::postSolve(b2Contact* contact, const b2ContactImpulse* impulse)
{
    //StringUtilities::log("CircleShip::postSolve");
}

// The recommended practice for processing contact points is to buffer all contact
// data that you care about and process it after the time step. You should always
// process the contact points immediately after the time step; otherwise some other
// client code might alter the physics world, invalidating the contact buffer.
// This method is called after the physics time step.
// Note:
// This is a good place to track time on a contact to see how long the contact has been
// in-contact.
void Cup::processContacts(long dt)
{
}