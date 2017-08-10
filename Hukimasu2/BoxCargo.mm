//
//  BoxCargo.m
//  Hukimasu2
//
//  Created by William DeVore on 10/30/11 A.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import "BoxCargo.h"

#import "ContactUserData.h"
#import "Model.h"
#import "Utilities.h"

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

BoxCargo::BoxCargo() {
}

BoxCargo::~BoxCargo() {
    StringUtilities::log("BoxCargo::~BoxCargo");
}


void BoxCargo::setPosition(float x, float y)
{
    b2Vec2 pos(x, y);
    baseBody->SetTransform(pos, baseBody->GetAngle());
}

const b2Vec2& BoxCargo::getPosition()
{
    return baseBody->GetPosition();
}

float BoxCargo::getAngle()
{
    return baseBody->GetAngle();
}

void BoxCargo::setAngle(float angle)
{
    baseBody->SetTransform(getPosition(), angle);
}

void BoxCargo::update(long dt)
{
}

//########################################################
// ## Physics stepping
//########################################################
void BoxCargo::beforeStep(long dt)
{
    
}

void BoxCargo::afterStep(long dt)
{
    
}

void BoxCargo::processContacts(long dt)
{
    
}

void BoxCargo::activate(bool state)
{
    baseBody->SetActive(state);
}

void BoxCargo::init(b2World *const world)
{
    /////// ##############################
    /////// main base body
    /////// ##############################
    baseVertexCount = 4;
    baseVertices = new b2Vec2[baseVertexCount];
    baseVertices[0].Set(-0.1f, -0.1f);
    baseVertices[1].Set(0.1f, -0.1f);
    baseVertices[2].Set(0.1f, 0.1f);
    baseVertices[3].Set(-0.1f, 0.1f);
    
    b2PolygonShape polygon;
    polygon.Set(baseVertices, baseVertexCount);
    
    b2FixtureDef shapeDef;
    shapeDef.shape = &polygon;
    shapeDef.density = 1.0f;
    
    b2BodyDef bodyDef;
    // The base needs to be static such that the whole BoxCargo doesn't move.
    bodyDef.type = b2_dynamicBody;
    bodyDef.active = false;
    
    // Technically a meaningless position as it will changed at a later time.
    bodyDef.position.Set(0.0f, 0.0f);
    baseBody = world->CreateBody(&bodyDef);
    
    b2Fixture* bodyFixture = baseBody->CreateFixture(&shapeDef);
    
    contactUserDataBase = new ContactUserData();
    contactUserDataBase->setObject(this, ContactUserData::BoxCargo);
    contactUserDataBase->setData1(1);
    bodyFixture->SetUserData(contactUserDataBase);
    
    srand(time(NULL));
}

void BoxCargo::applyForce()
{
    b2Vec2 refAxis;
    // Between OpenGL and Cocos2d the coord system ends up
    // being
    //
    //     ^ Y
    //     |
    //     |
    //     .-----> X
    // 0,0
    //
    refAxis.Set(0.0f, 1.0f);
    
    // Angle relative to +Y axis
    long number = random() % 99;
    //StringUtilities::log("number ", number);
    double angle;
    if (number < 49)
        angle = DEG2RAD(1.0);   // CCW rotation. aka to the left.
    else
        angle = DEG2RAD(-1.0);
    
    b2Mat22 rotate;
    rotate.Set(angle);
    
    // Now rotate the reference axis according to the angle
    // embedded in the rotate matrix.
    b2Vec2 vector = b2Mul(rotate, refAxis);

    // We need the position such that the force/impulse is
    // applied at the location of the body. Any where else and a
    // torque would occur.
    b2Vec2 b2Pos = getPosition();
    
    // Scale the direction vector accordingly because the
    // vector carries both direction and magnitude.
    vector *= 0.3f;
    
    // Now apply an impulse along the vector and aimed
    // directly at the body's position. The impulse is much
    // stronger than force because Mass comes into play.
    baseBody->ApplyLinearImpulse(vector, b2Pos);

    float torque = 0.1;
    
    if (number < 49)
        torque = -1.0f;
    else
        angle = 1.0f;

    baseBody->ApplyTorque(torque);
}

void BoxCargo::reset()
{
    
}

void BoxCargo::release(b2World* const world)
{
    delete [] baseVertices;
    baseVertices = NULL;
    world->DestroyBody(baseBody);
    baseBody = NULL;
    
    delete contactUserDataBase;
    contactUserDataBase = NULL;
}

void BoxCargo::draw()
{
    b2Vec2 pos = getPosition();
    float angle = baseBody->GetAngle();
    
    // ------------------------------------------------------------
    // Draw main box body
    // ------------------------------------------------------------
    glVertexPointer(2, GL_FLOAT, 0, baseVertices);
    glPushMatrix();
    
    glTranslatef(pos.x*PTM_RATIO, pos.y*PTM_RATIO, 0.0f);
    glScalef(PTM_RATIO, PTM_RATIO, 0.0f);
    glRotatef(angle * 180.0f / b2_pi, 0.0f, 0.0f, 1.0f);
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glColor4f(Utilities::Color_Yellow[0], Utilities::Color_Yellow[1], Utilities::Color_Yellow[2], 0.3f);
	glDrawArrays(GL_TRIANGLE_FAN, 0, baseVertexCount);
    
    glColor4f(Utilities::Color_White[0], Utilities::Color_White[1], Utilities::Color_White[2], 1.0f);
	glDrawArrays(GL_LINE_LOOP, 0, baseVertexCount);
    
    glPopMatrix();
}
