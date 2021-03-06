//
//  CatcherShip.m
//  Hukimasu2
//
//  Created by William DeVore on 10/27/11 A.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CatcherShip.h"
#import <iostream>
#import <typeinfo>

#import "ActorGround.h"
#import "Utilities.h"
#import "StringUtilities.h"
#import "ContactUserData.h"
#import "Model.h"

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

CatcherShip::CatcherShip() {
    legVertices = NULL;
    axisVertices = NULL;
    leftWallVertices = NULL;
    rightWallVertices = NULL;
    contactUserDataBody = NULL;
    contactUserDataLeftLeg = NULL;
    contactUserDataRightLeg = NULL;
    contactUserDataLeftWall = NULL;
    contactUserDataRightWall = NULL;
    thrustPower = 0;
}

CatcherShip::~CatcherShip() {
}

void CatcherShip::activate(bool state)
{
    body->SetActive(state);
    leftWallBody->SetActive(state);
    rightWallBody->SetActive(state);
    leftLegBody->SetActive(state);
    rightLegBody->SetActive(state);
}

void CatcherShip::init(b2World* const world)
{
    setName("Catcher Ship");
    
    thrustPower = 0;
    
    axisVertexCount = 2;
    axisVertices = new b2Vec2[axisVertexCount];
    axisVertices[0].Set(0.0f, 0.5f);
    axisVertices[1].Set(0.0f, 1.0f);
        
    /////// ##############################
    /////// main box body
    /////// ##############################
    bodyVertexCount = 4;
    bodyVertices = new b2Vec2[bodyVertexCount];
    bodyVertices[0].Set(-1.5f, -0.1f);
    bodyVertices[1].Set(1.5f, -0.1f);
    bodyVertices[2].Set(1.5f, 0.1f);
    bodyVertices[3].Set(-1.5f, 0.1f);
    
    b2PolygonShape polygon;
    polygon.Set(bodyVertices, bodyVertexCount);
    
    b2FixtureDef shapeDef;
    shapeDef.shape = &polygon;
    shapeDef.density = 1.0f;
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.active = false;
    
    // Technically a meaningless position as it will changed at a later time.
    bodyDef.position.Set(0.0f, 0.0f);
    body = world->CreateBody(&bodyDef);
    
    b2Fixture* bodyFixture = body->CreateFixture(&shapeDef);
    
    contactUserDataBody = new ContactUserData();
    contactUserDataBody->setObject(this, ContactUserData::CatcherShip);
    contactUserDataBody->setData1(1);
    bodyFixture->SetUserData(contactUserDataBody);

    // The legs are simetrical so we use the same vertices for both.
    legVertexCount = 4;
    legVertices = new b2Vec2[legVertexCount];
    legVertices[0].Set(-0.25f, -0.25f);
    legVertices[1].Set(0.25f, -0.25f);
    legVertices[2].Set(0.25f, 0.25f);
    legVertices[3].Set(-0.25f, 0.25f);
    polygon.Set(legVertices, legVertexCount);
    
    b2Fixture* fixture = NULL;
    
    /////// ##############################
    ////// RIGHT LEG -------white
    /////// ##############################
    // The world position of the body.
    // Note: the positions and limits should be defined in world-space with means +Y is going
    // upward:
    //  ^  +Y
    //  |
    //  |
    //  |
    //  .----------> X
    // Typically you want to position bodyB at the resting position of the range of motion so that
    // the motor isn't forced to move bodyB into the resting position on the first few time steps.
    // So we need to calc the resting position based on the anchor points AND the range of
    // motion.
    // Because the motion is along the Y axis, the X position simply needs to match anchor A's
    // X position.
    //
    // The Y position is a bit more difficult in that we need to consider the resting position
    // that the motor will "force" upon bodyB (aka the leg). The range of motion is limited
    // to abs(upper)+abs(lower)  = 0.5 + 0.5 = 1.0 meters.
    //
    // Because anchor A is at -.75 Y axis, the range of motion is:
    // [(-.75 + 0.5) -> (-0.75 - 0.5)] = [-0.25 -> -1.25].
    // And because the local prismatic axis is the -Y axis, the motor will always want to move
    // bodyB (the leg) in the -Y direction where its resting local position will be -1.25. Hence we
    // set the Y position to -1.25f.
    //
    // If we place the leg body somewhere else the physics engine will abruptly force the body
    // into the resting position and this will introduce torgues and forces on the entire structure
    // which include (legs + circle). The ship will then begin to move and rotate because of a
    // sudden mass movement. You may want this but this game doesn't.
    //bodyDef.position.Set(x + 0.75f, y - 1.25f);
    
    rightLegBody = world->CreateBody(&bodyDef);
    fixture = rightLegBody->CreateFixture(&shapeDef);
    
    contactUserDataRightLeg = new ContactUserData();
    contactUserDataRightLeg->setObject(this, ContactUserData::CatcherShipRightLeg);
    contactUserDataRightLeg->setData1(2);
    fixture->SetUserData(contactUserDataRightLeg);
    
    // Now the joint of type Prismatic
    b2PrismaticJointDef jointDef;
    
    // Notes: The motor wants to move bodyB along localAxis's direction.
    // The motor (if enabled) will attempt to continuously move the body in this direction
    // until the body has reached its limit defined by the upper and lowers.
    jointDef.localAxis1.Set(0.0f, -1.0f);
    
    jointDef.bodyA = body;
    // The local anchor point relative to body1's (aka circle) origin.
    jointDef.localAnchorA.Set(1.25f, -0.1f);
    
    jointDef.bodyB = rightLegBody;
    // The local anchor point relative to body1's origin or anchor point? Answer: anchor.
    jointDef.localAnchorB.Set(0.0f, 0.0f);
    
	/// The upper translation limit, usually in meters.
    // Note: The numbers are a range relative to anchor point B.
    // This is a "range" of motion meaning the body will not move more than
    // abs(upper) + abs(lower).
    jointDef.upperTranslation = 0.25f;
    jointDef.lowerTranslation = -0.25f;
    
    jointDef.enableLimit = true;
    // This is the max force allowed before the motor starts a "breaking" effect.
    // Almost like damping to keep the motor speed limited.
    jointDef.maxMotorForce = 10.0f;
    // This is the motor's functioning speed. The motion of the body could be higher
    // if something is hit but a max is enforced by the maxMotorForce.
    jointDef.motorSpeed = 1.0f;
    jointDef.enableMotor = true;
    // We don't want the circle and legs to collide with each other.
    jointDef.collideConnected = false;
    
    world->CreateJoint(&jointDef);
    
    /////// ##############################
    ////// LEFT LEG -------purple
    /////// ##############################
    leftLegBody = world->CreateBody(&bodyDef);
    fixture = leftLegBody->CreateFixture(&shapeDef);
    contactUserDataLeftLeg = new ContactUserData();
    contactUserDataLeftLeg->setObject(this, ContactUserData::CatcherShipLeftLeg);
    contactUserDataLeftLeg->setData1(3);
    fixture->SetUserData(contactUserDataLeftLeg);
    
    jointDef.localAxis1.Set(0.0f, -1.0f);
    
    jointDef.bodyA = body;
    jointDef.localAnchorA.Set(-1.25f, -0.1f);
    
    jointDef.bodyB = leftLegBody;
    jointDef.localAnchorB.Set(0.0f, 0.0f);
    
    jointDef.upperTranslation = 0.25f;
    jointDef.lowerTranslation = -0.25f;
    
    jointDef.enableLimit = true;
    jointDef.maxMotorForce = 10.0f;
    jointDef.motorSpeed = 1.0f;
    jointDef.enableMotor = true;
    jointDef.collideConnected = false;
    
    world->CreateJoint(&jointDef);
    
    /////// ##############################
    ////// Left -- WALL -- using a weld joint GREEN
    /////// ##############################
    leftWallVertexCount = 5;
    leftWallVertices = new b2Vec2[leftWallVertexCount];
    leftWallVertices[0].Set(-0.25f, -0.25f);
    leftWallVertices[1].Set(0.25f, -0.25f);
    leftWallVertices[2].Set(0.25f, 0.20f);
    leftWallVertices[3].Set(0.1f, 0.20f);
    leftWallVertices[4].Set(-0.25f, -0.05f);
    polygon.Set(leftWallVertices, leftWallVertexCount);

    leftWallBody = world->CreateBody(&bodyDef);
    fixture = leftWallBody->CreateFixture(&shapeDef);
    
    contactUserDataLeftWall = new ContactUserData();
    contactUserDataLeftWall->setObject(this, ContactUserData::CatcherShipLeftWall);
    contactUserDataLeftWall->setData1(10);
    fixture->SetUserData(contactUserDataLeftWall);

    b2WeldJointDef weldJointDef;
    weldJointDef.bodyA = body;
    weldJointDef.bodyB = leftWallBody;
    weldJointDef.localAnchorA.Set(-1.25f, 0.1f);      // relative to A's origin
    // We want the anchor for B to be at the bottom of its shape so we place
    // it -.25 downwards from its local origin.
    weldJointDef.localAnchorB.Set(0.0f, -0.25f);    // relative to B's origin
    // We don't want the wall colliding with the body.
    weldJointDef.collideConnected = false;
    world->CreateJoint(&weldJointDef);

    /////// ##############################
    ////// Right -- WALL -- using a weld joint BLUE
    /////// ##############################
    rightWallVertexCount = 5;
    rightWallVertices = new b2Vec2[rightWallVertexCount];
    rightWallVertices[0].Set(-0.25f, -0.25f);
    rightWallVertices[1].Set(0.25f, -0.25f);
    rightWallVertices[2].Set(0.25f, -0.05f);
    rightWallVertices[3].Set(-0.1f, 0.25f);
    rightWallVertices[4].Set(-0.25f, 0.25f);
    polygon.Set(rightWallVertices, rightWallVertexCount);

    rightWallBody = world->CreateBody(&bodyDef);
    fixture = rightWallBody->CreateFixture(&shapeDef);
    
    contactUserDataRightWall = new ContactUserData();
    contactUserDataRightWall->setObject(this, ContactUserData::CatcherShipRightWall);
    contactUserDataRightWall->setData1(11);
    fixture->SetUserData(contactUserDataRightWall);
    
    weldJointDef.bodyA = body;
    weldJointDef.bodyB = rightWallBody;
    weldJointDef.localAnchorA.Set(1.25f, 0.1f);// relative to A's origin
    weldJointDef.localAnchorB.Set(0.0f, -0.25f);// relative to B's origin
    // We don't want the wall colliding with the body.
    weldJointDef.collideConnected = false;
    world->CreateJoint(&weldJointDef);
    
}

void CatcherShip::reset()
{
    
}

void CatcherShip::zeroVelocities()
{
    body->SetAngularVelocity(0.0f);
    body->SetLinearVelocity(b2Vec2(0.0f, 0.0f));
    rightLegBody->SetAngularVelocity(0.0f);
    rightLegBody->SetLinearVelocity(b2Vec2(0.0f, 0.0f));
    leftLegBody->SetAngularVelocity(0.0f);
    leftLegBody->SetLinearVelocity(b2Vec2(0.0f, 0.0f));
    leftWallBody->SetAngularVelocity(0.0f);
    leftWallBody->SetLinearVelocity(b2Vec2(0.0f, 0.0f));
    rightWallBody->SetAngularVelocity(0.0f);
    rightWallBody->SetLinearVelocity(b2Vec2(0.0f, 0.0f));
}

void CatcherShip::release(b2World* const world)
{
    world->DestroyBody(body);
    body = NULL;
    world->DestroyBody(leftLegBody);
    leftLegBody = NULL;
    world->DestroyBody(rightLegBody);
    rightLegBody = NULL;
    world->DestroyBody(leftWallBody);
    leftWallBody = NULL;
    world->DestroyBody(rightWallBody);
    rightWallBody = NULL;

    delete [] legVertices;
    delete [] axisVertices;
    delete [] leftWallVertices;
    delete [] rightWallVertices;
    delete contactUserDataBody;
    delete contactUserDataLeftLeg;
    delete contactUserDataRightLeg;
    delete contactUserDataLeftWall;
    delete contactUserDataRightWall;
}

void CatcherShip::setPosition(float x, float y)
{
    b2Vec2 pos(x, y);
    body->SetTransform(pos, body->GetAngle());
    
    pos.Set(x - 1.25f, y - 0.1f);
    leftLegBody->SetTransform(pos, leftLegBody->GetAngle());
    
    pos.Set(x + 1.25f, y - 0.1f);
    rightLegBody->SetTransform(pos, rightLegBody->GetAngle());
    
    pos.Set(x - 1.25f, y + 0.1f);
    leftWallBody->SetTransform(pos, leftWallBody->GetAngle());

    pos.Set(x + 1.25f, y + 0.1f);
    rightWallBody->SetTransform(pos, rightWallBody->GetAngle());
}

float CatcherShip::getAngle()
{
    return body->GetAngle();
}

void CatcherShip::setAngle(float angle)
{
    body->SetTransform(getPosition(), angle);
}

void CatcherShip::update(long dt)
{
}

const b2Vec2& CatcherShip::getPosition()
{
    return body->GetPosition();
}

void CatcherShip::draw()
{
    b2Vec2 pos = getPosition();
    float angle = body->GetAngle();
    
    // ------------------------------------------------------------
    // Draw main box body
    // ------------------------------------------------------------
    glVertexPointer(2, GL_FLOAT, 0, bodyVertices);
    glPushMatrix();
    
    glTranslatef(pos.x*PTM_RATIO, pos.y*PTM_RATIO, 0.0f);
    glScalef(PTM_RATIO, PTM_RATIO, 0.0f);
    glRotatef(angle * 180.0f / b2_pi, 0.0f, 0.0f, 1.0f);
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glColor4f(Utilities::Color_Yellow[0], Utilities::Color_Yellow[1], Utilities::Color_Yellow[2], 0.2f);
	glDrawArrays(GL_TRIANGLE_FAN, 0, bodyVertexCount);
    
    glColor4f(Utilities::Color_Yellow[0], Utilities::Color_Yellow[1], Utilities::Color_Yellow[2], 1.0f);
	glDrawArrays(GL_LINE_LOOP, 0, bodyVertexCount);
    
    // ------------------------------------------------------------
    // Draw the axis line
    // ------------------------------------------------------------
	glVertexPointer(2, GL_FLOAT, 0, axisVertices);
    glColor4f(Utilities::Color_StealBlue[0], Utilities::Color_StealBlue[1], Utilities::Color_StealBlue[2], 1.0f);
	glDrawArrays(GL_LINES, 0, axisVertexCount);
    
    glPopMatrix();
    
    // ------------------------------------------------------------
    // Draw legs
    // ------------------------------------------------------------
    pos = leftLegBody->GetPosition();
    angle = leftLegBody->GetAngle();
    
	glVertexPointer(2, GL_FLOAT, 0, legVertices);
    glPushMatrix();
    
    glTranslatef(pos.x*PTM_RATIO, pos.y*PTM_RATIO, 0.0f);
    glScalef(PTM_RATIO, PTM_RATIO, 0.0f);
    glRotatef(angle * 180.0f / b2_pi, 0.0f, 0.0f, 1.0f);
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glColor4f(Utilities::Color_Orchid[0], Utilities::Color_Orchid[1], Utilities::Color_Orchid[2], 0.2f);
	glDrawArrays(GL_TRIANGLE_FAN, 0, legVertexCount);
    
    glColor4f(Utilities::Color_Orchid[0], Utilities::Color_Orchid[1], Utilities::Color_Orchid[2], 1.0f);
	glDrawArrays(GL_LINE_LOOP, 0, legVertexCount);
    
    glPopMatrix();
    
    pos = rightLegBody->GetPosition();
    angle = rightLegBody->GetAngle();
    glPushMatrix();
    
    glTranslatef(pos.x*PTM_RATIO, pos.y*PTM_RATIO, 0.0f);
    glScalef(PTM_RATIO, PTM_RATIO, 0.0f);
    glRotatef(angle * 180.0f / b2_pi, 0.0f, 0.0f, 1.0f);
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glColor4f(Utilities::Color_Orchid[0], Utilities::Color_Orchid[1], Utilities::Color_Orchid[2], 0.2f);
	glDrawArrays(GL_TRIANGLE_FAN, 0, legVertexCount);
    
    glColor4f(Utilities::Color_Orchid[0], Utilities::Color_Orchid[1], Utilities::Color_Orchid[2], 1.0f);
	glDrawArrays(GL_LINE_LOOP, 0, legVertexCount);
    
    glPopMatrix();
    
    // ------------------------------------------------------------
    // Draw upper walls: left is GREEN
    // ------------------------------------------------------------
    pos = leftWallBody->GetPosition();
    angle = leftWallBody->GetAngle();
    
	glVertexPointer(2, GL_FLOAT, 0, leftWallVertices);
    glPushMatrix();
    
    glTranslatef(pos.x*PTM_RATIO, pos.y*PTM_RATIO, 0.0f);
    glScalef(PTM_RATIO, PTM_RATIO, 0.0f);
    glRotatef(angle * 180.0f / b2_pi, 0.0f, 0.0f, 1.0f);
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glColor4f(Utilities::Color_Green[0], Utilities::Color_Green[1], Utilities::Color_Green[2], 0.2f);
	glDrawArrays(GL_TRIANGLE_FAN, 0, leftWallVertexCount);
    
    glColor4f(Utilities::Color_Green[0], Utilities::Color_Green[1], Utilities::Color_Green[2], 1.0f);
	glDrawArrays(GL_LINE_LOOP, 0, leftWallVertexCount);
    
    glPopMatrix();
    
    pos = rightWallBody->GetPosition();
    angle = rightWallBody->GetAngle();
    
	glVertexPointer(2, GL_FLOAT, 0, rightWallVertices);
    glPushMatrix();
    
    glTranslatef(pos.x*PTM_RATIO, pos.y*PTM_RATIO, 0.0f);
    glScalef(PTM_RATIO, PTM_RATIO, 0.0f);
    glRotatef(angle * 180.0f / b2_pi, 0.0f, 0.0f, 1.0f);
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glColor4f(Utilities::Color_Green[0], Utilities::Color_Green[1], Utilities::Color_Green[2], 0.2f);
	glDrawArrays(GL_TRIANGLE_FAN, 0, rightWallVertexCount);
    
    glColor4f(Utilities::Color_Green[0], Utilities::Color_Green[1], Utilities::Color_Green[2], 1.0f);
	glDrawArrays(GL_LINE_LOOP, 0, rightWallVertexCount);
    
    glPopMatrix();
    
}

void CatcherShip::applyForceAlongHeading()
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
    // The angle of the ship/body is given relative to the
    // +Y axis. So our reference axis matches that.
    refAxis.Set(0.0f, 1.0f);
    
    // Angle relative to +Y axis
    float angle = body->GetAngle();
    
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
    vector *= getThrustPower();
    
    // Now apply an impulse along the vector and aimed
    // directly at the body's position. The impulse is much
    // stronger than force because Mass comes into play.
    applyLinearImpulse(vector, b2Pos);
    
    // or
    //                        vector *= 10.0f;
    //                        b->ApplyForce(vector, b2Pos);
}

void CatcherShip::applyLinearImpulse(const b2Vec2& direction, const b2Vec2& position)
{
    body->ApplyLinearImpulse(direction, position);
}

void CatcherShip::applyAngularImpulse(float angle)
{
    body->ApplyAngularImpulse(angle);
}

void CatcherShip::beforeStep(long dt)
{
    if (!_thrusting)
        return;
    
    applyForceAlongHeading();
}

void CatcherShip::afterStep(long dt)
{
    if (!_rotating)
        return;
    
    // TODO should probably use damping instead.
    body->SetAngularVelocity(0.0f);
}

void CatcherShip::thrusting(float colSize, float rowSize, float x, float y)
{
    if (x == -1 && y == -1) {
        _thrusting = false;
        setThrustTouchLocation(-1, -1);
    }
    else {
        //if ((x < colSize) && (y > 3 * rowSize)) {
        if ((x < colSize)) {
            _thrusting = true;
            // Typical mid range power for this ship is 1.0/3.0. So from
            // Y = 0 to Y = max we want 1/3 to be in the middle.
            Model* model = Model::instance();
            thrustPower = 0.75f / (float)model->getViewHeight() * y;
            StringUtilities::log("CatcherShip::thrusting thrustPower ", thrustPower);
            setThrustTouchLocation(x, y);
        }
        else
        {
            _thrusting = false;
            setThrustTouchLocation(-1, -1);
        }
    }
    
}

//########################################################
// ## Getters/Setters
//########################################################

float CatcherShip::getRotatePower()
{
    return 1.0f;
}

float CatcherShip::getThrustPower()
{
    return thrustPower;//1.0f/3.0f;
}

//########################################################
// ## Physics callbacks
//########################################################

// This event only occurs within the time step.
void CatcherShip::beginContact(b2Contact* contact)
{
    //StringUtilities::log("CatcherShip::beginContact");
    if (contact->IsEnabled()) {
        // We only want contacts that are between this ship and something
        // else. One of the fixtures must be the ship.
        b2Fixture* A = contact->GetFixtureA();
        b2Fixture* B = contact->GetFixtureB();
        
        ContactUserData* userDataA = (ContactUserData*)A->GetUserData();
        ContactUserData* userDataB = (ContactUserData*)B->GetUserData();
        
        if (userDataA->getType() == ContactUserData::CatcherShip || userDataB->getType() == ContactUserData::CatcherShip) {
            //StringUtilities::log("CatcherShip::beginContact collected contact between uA " + userDataA->toString() + " and uB " + userDataB->toString());
            AContact aContact = { A, B };
            contacts.push_back(aContact);
        } else {
            //StringUtilities::log("CatcherShip::beginContact discarded contact between uA " + userDataA->toString() + " and uB " + userDataB->toString());
        }
    }
    
}

// This event can occur outside the time step
void CatcherShip::endContact(b2Contact* contact)
{
    //StringUtilities::log("CatcherShip::endContact");
    b2Fixture* A = contact->GetFixtureA();
    b2Fixture* B = contact->GetFixtureB();
    
    ContactUserData* userDataA = (ContactUserData*)A->GetUserData();
    ContactUserData* userDataB = (ContactUserData*)B->GetUserData();
    
    if (userDataA->getType() == ContactUserData::CatcherShip || userDataB->getType() == ContactUserData::CatcherShip) {
        AContact aContact = { A, B };
        
        std::list<AContact>::iterator pos;
        
        pos = std::find(contacts.begin(), contacts.end(), aContact);
        if (pos != contacts.end()) {
            contacts.erase(pos);
            //StringUtilities::log("CatcherShip::endContact erased contact between uA " + userDataA->toString() + " and uB " + userDataB->toString());
        }
    }
}

// This is called after collision detection, but before collision resolution.
// This gives you a chance to disable the contact based on the current configuration.
// For example, you can implement a one-­‐sided platform using this callback
// and calling b2Contact::SetEnabled(false). The contact will be re-­‐enabled each time
// through collision processing, so you will need to disable the contact every time-­‐step.
// The pre-­‐solve event may be fired multiple times per time step per contact due to continuous collision detection.
void CatcherShip::preSolve(b2Contact* contact, const b2Manifold* oldManifold)
{
    //StringUtilities::log("CatcherShip::preSolve");
    b2Fixture* A = contact->GetFixtureA();
    b2Fixture* B = contact->GetFixtureB();
    
    ContactUserData* userDataA = (ContactUserData*)A->GetUserData();
    ContactUserData* userDataB = (ContactUserData*)B->GetUserData();
    
    if (userDataA->getType() != ContactUserData::CatcherShip && userDataB->getType() != ContactUserData::CatcherShip) {
        //StringUtilities::log("CatcherShip::preSolve this event isn't related to this object");
        return;
    }
    
    // Use this to get Approach velocity to determine how hard the collision was. We will
    // want to update the Actor accordingly. We don't destroy bodies because this is
    // a callback during the physics' time stepping.
    b2WorldManifold worldManifold;
    
    contact->GetWorldManifold(&worldManifold);
    
    //std::cout << "PreSolve worldmanifold: (" << worldManifold.normal.x << "," << worldManifold.normal.y << ")" << std::endl;
    
    b2PointState state1[2], state2[2];
    
    /// Compute the point states given two manifolds. The states pertain to the transition from oldManifold
    /// to GetManifold. So state1 is either persist or remove while state2 is either add or persist.
    b2GetPointStates(state1, state2, oldManifold, contact->GetManifold());
    //0 b2_nullState,		///< point does not exist
    //1 b2_addState,		///< point was added in the update
    //2 b2_persistState,	///< point persisted across the update
    //3 b2_removeState		///< point was removed in the update
    
    //std::string s_s10 = mapPointState(state1[0]);
    //std::string s_s11 = mapPointState(state1[1]);
    
    //std::string s_s20 = mapPointState(state2[0]);
    //std::string s_s21 = mapPointState(state2[1]);
    
    //std::cout << "PreSolve state1,state2: {" << s_s10 << " : " <<s_s11<< " , " << s_s20 << " : " << s_s21 << "}" << std::endl;
    
    //if (worldManifold.normal.x == 1.0f || worldManifold.normal.x == -1.0f)
    //    contact->SetEnabled(false);  // The object will now go right through each other.
    
    // b2_addState = point was added in the update
    if (state2[0] == b2_addState) {
        b2Fixture* fixtureA = contact->GetFixtureA();
        b2Fixture* fixtureB = contact->GetFixtureB();
        
        const b2Body* bodyA = fixtureA->GetBody();
        const b2Body* bodyB = fixtureB->GetBody();
        
        b2Vec2 point = worldManifold.points[0];
        
        b2Vec2 vA = bodyA->GetLinearVelocityFromWorldPoint(point);
        b2Vec2 vB = bodyB->GetLinearVelocityFromWorldPoint(point);
        
        b2Vec2 vector;
        vector.Set(vB.x - vA.x, vB.y - vA.y);
        
        float32 approachVelocity = b2Dot(vector, worldManifold.normal);
        
        ContactUserData* userDataA = (ContactUserData*)fixtureA->GetUserData();
        ContactUserData* userDataB = (ContactUserData*)fixtureB->GetUserData();
        if (userDataA->getType() != ContactUserData::CatcherShip) {
            userDataB = (ContactUserData*)fixtureB->GetUserData();
            if (userDataB->getType() == ContactUserData::CatcherShip) {
                //StringUtilities::log("CatcherShip::preSolve fixture B " + userDataB->toString());
                //StringUtilities::log("CatcherShip::preSolve fixture A " + userDataA->toString());
                //StringUtilities::log("CatcherShip::preSolve approachVelocity: ", approachVelocity);
            }
        }
        else
        {
            //StringUtilities::log("CatcherShip::preSolve fixture A " + userDataA->toString());
            //StringUtilities::log("CatcherShip::preSolve fixture B " + userDataB->toString());
            //StringUtilities::log("CatcherShip::preSolve approachVelocity: ", approachVelocity);
        }
        
    }
    
}

// The post solve event is where you can gather collision impulse results.
// If you don’t care about the impulses, you should probably just implement the pre-­‐solve event. 
void CatcherShip::postSolve(b2Contact* contact, const b2ContactImpulse* impulse)
{
    //StringUtilities::log("CatcherShip::postSolve");
}

// The recommended practice for processing contact points is to buffer all contact
// data that you care about and process it after the time step. You should always
// process the contact points immediately after the time step; otherwise some other
// client code might alter the physics world, invalidating the contact buffer.
// This method is called after the physics time step.
// This will continue to be processed until there is no more contacting (aka end-contact has occurred)
void CatcherShip::processContacts(long dt)
{
    std::list<AContact>::iterator pos;
    
    //StringUtilities::log("CatcherShip::processContacts dt ", dt);
    for(pos = contacts.begin(); pos != contacts.end(); ++pos) {
        AContact contact = *pos;
        
        b2Fixture* fixtureA = contact.fixtureA;
        b2Fixture* fixtureB = contact.fixtureB;
        
        // One of the fixtures is part of the ship, the other is something else.
        if (fixtureA->GetUserData() != NULL) {
            b2Body *bodyA = fixtureA->GetBody();
            //ContactUserData* userData = (ContactUserData*)fixtureA->GetUserData();
            //StringUtilities::log("CatcherShip::processContacts fixture A " + userData->toString());
            
            if (bodyA->GetUserData() != NULL) {
                //int* aId = (int*) bodyA->GetUserData();
                //CCLOG(@"collide: bA:%d", *aId);
            }
        }
        
        if (fixtureB->GetUserData() != NULL) {
            b2Body *bodyB = fixtureB->GetBody();
            //ContactUserData* userData = (ContactUserData*)fixtureB->GetUserData();
            //StringUtilities::log("CatcherShip::processContacts fixture B " + userData->toString());
            
            if (bodyB->GetUserData() != NULL) {
                //int* bId = (int*) bodyB->GetUserData();
                //CCLOG(@"collide: bB:%d", *bId);
            }
        }
        
    }
    
}

void CatcherShip::subscribeAsContactListener(Box2dContactListener* contactTransmitter)
{
    HuActor::subscribeAsContactListener(contactTransmitter);
}

//=============================================
// Statuses
//=============================================

//########################################################
// ## 
//########################################################

void CatcherShip::debug()
{
    debugToggle = !debugToggle;
}
