//
//  ActorShip2.mm
//  Hukimasu
//
//  Created by William DeVore on 4/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <iostream>
#import <typeinfo>

#import "CircleShip.h"
#import "ActorGround.h"
#import "Utilities.h"
#import "StringUtilities.h"
#import "ContactUserData.h"
#import "LandingPadTypeC.h"
#import "Cup.h"
#import "Model.h"

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

CircleShip::CircleShip() {
    landpadC = NULL;
    cup = NULL;
    legVertices = NULL;
    axisVertices = NULL;
    contactUserDataBody = NULL;
    contactUserDataLeftLeg = NULL;
    contactUserDataRightLeg = NULL;
    padActive = false;
    fullyExtended = false;
    fullyRetracted = true;
    padJoint = NULL;
    thrustPower = 0;
    body = NULL;
    leftLegBody = NULL;
    rightLegBody = NULL;
}

CircleShip::~CircleShip()
{
    StringUtilities::log("CircleShip::~CircleShip");
}

void CircleShip::activate(bool state)
{
    body->SetActive(state);
    leftLegBody->SetActive(state);
    rightLegBody->SetActive(state);
}

void CircleShip::reset()
{
    padActive = false;
    fullyExtended = false;
    fullyRetracted = true;

    if (landpadC != NULL)
    {
        landpadC->reset();
        b2Vec2 pos = getPosition();
        landpadC->setPosition(pos.x, pos.y);
    }
}

void CircleShip::init(b2World* const world)
{
    setName("Circle Ship");
    
    // This ship is a circle plus to columns
    const float32 radius = 1.0f;

    thrustPower = 0;

    axisVertexCount = 2;
    axisVertices = new b2Vec2[axisVertexCount];
    axisVertices[0].Set(0.0f, 0.5f);
    axisVertices[1].Set(0.0f, 1.0f);

    // These vertices are for box2d. box2d limits the max amount
    // of vertices to 8 which is not good visually.
    float32 k_segments = 8.0f;
	float32 k_increment = 2.0f * b2_pi / k_segments;
	float32 theta = 0.0f;
    
    b2Vec2* circleVertices = new b2Vec2[8];
    for (int32 i = 0; i < k_segments; ++i)
	{
		b2Vec2 v = radius * b2Vec2(cosf(theta), sinf(theta));
		circleVertices[i].Set(v.x, v.y);
		theta += k_increment;
	}
    
    /////// ##############################
    /////// main circle body
    /////// ##############################
    b2PolygonShape polygon;
    polygon.Set(circleVertices, 8);
    
    delete [] circleVertices;
    
    b2FixtureDef shapeDef;
    shapeDef.shape = &polygon;
    shapeDef.density = 1.0f;
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.active = false;
    
    //bodyDef.userData = this;
    bodyDef.position.Set(0.0f, 0.0f);
    body = world->CreateBody(&bodyDef);
    
    bodyFixture = body->CreateFixture(&shapeDef);
    
    contactUserDataBody = new ContactUserData();
    contactUserDataBody->setObject(this, ContactUserData::CircleShip);
    contactUserDataBody->setData1(1);
    bodyFixture->SetUserData(contactUserDataBody);

    // Create left leg joint. It is a column box attached to the
    // circle body on the lower left.
    legVertexCount = 4;
    legVertices = new b2Vec2[legVertexCount];
    legVertices[0].Set(-0.25f, -0.5f);
    legVertices[1].Set(0.25f, -0.5f);
    legVertices[2].Set(0.25f, 0.5f);
    legVertices[3].Set(-0.25f, 0.5f);
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
    contactUserDataRightLeg->setObject(this, ContactUserData::CircleShipRightLeg);
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
    jointDef.localAnchorA.Set(0.75f, -0.75f);
    
    jointDef.bodyB = rightLegBody;
    // The local anchor point relative to body1's origin or anchor point? Answer: anchor.
    jointDef.localAnchorB.Set(0.0f, 0.0f);
    
	/// The upper translation limit, usually in meters.
    // Note: The numbers are a range relative to anchor point B.
    // This is a "range" of motion meaning the body will not move more than
    // abs(upper) + abs(lower).
    jointDef.upperTranslation = 0.5f;
    jointDef.lowerTranslation = -0.5f;

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
    //bodyDef.position.Set(x - 0.75f, y - 1.25f);
    leftLegBody = world->CreateBody(&bodyDef);
    fixture = leftLegBody->CreateFixture(&shapeDef);
    contactUserDataLeftLeg = new ContactUserData();
    contactUserDataLeftLeg->setObject(this, ContactUserData::CircleShipLeftLeg);
    contactUserDataLeftLeg->setData1(3);
    fixture->SetUserData(contactUserDataLeftLeg);

    jointDef.localAxis1.Set(0.0f, -1.0f);

    jointDef.bodyA = body;
    jointDef.localAnchorA.Set(-0.75f, -0.75f);
    
    jointDef.bodyB = leftLegBody;
    jointDef.localAnchorB.Set(0.0f, 0.0f);

    jointDef.upperTranslation = 0.5f;
    jointDef.lowerTranslation = -0.5f;
    
    jointDef.enableLimit = true;
    jointDef.maxMotorForce = 10.0f;
    jointDef.motorSpeed = 1.0f;
    jointDef.enableMotor = true;
    jointDef.collideConnected = false;
    
    world->CreateJoint(&jointDef);
    
}

void CircleShip::release(b2World* const world)
{
    b2World* _world = world;
    Model* model = Model::instance();
    if (_world == NULL)
        _world = model->getPhysicsWorld();
    
    _world->DestroyBody(body);
    body = NULL;
    _world->DestroyBody(leftLegBody);
    leftLegBody = NULL;
    _world->DestroyBody(rightLegBody);
    rightLegBody = NULL;
    
    Box2dContactListener* contactTransmitter = model->getWorldContactListener();
    unSubscribeAsContactListener(contactTransmitter);

    delete [] legVertices;
    delete [] axisVertices;
    delete contactUserDataBody;
    delete contactUserDataLeftLeg;
    delete contactUserDataRightLeg;
    
    legVertices = NULL;
    axisVertices = NULL;
    contactUserDataBody = NULL;
    contactUserDataLeftLeg = NULL;
    contactUserDataRightLeg = NULL;

    releasePad(_world);
    releaseCup(_world);
}

void CircleShip::setPosition(float x, float y)
{
    b2Vec2 pos(x, y);
    body->SetTransform(pos, body->GetAngle());

    b2Vec2 lpos(x - 0.75f, y - 1.25f);
    leftLegBody->SetTransform(lpos, leftLegBody->GetAngle());
    
    b2Vec2 rpos(x + 0.75f, y - 1.25f);
    rightLegBody->SetTransform(rpos, rightLegBody->GetAngle());

    if (landpadC != NULL)
    {
        b2Vec2 lPpos(x, y);
        b2Body* padBody = landpadC->getBody();
        padBody->SetTransform(lPpos, padBody->GetAngle());
    }
    
    if (cup != NULL)
    {
        b2Vec2 cPos(x, y);
        b2Body* cupBody = cup->getBody();
        cupBody->SetTransform(cPos, cupBody->GetAngle());
    }
}

float CircleShip::getAngle()
{
    return body->GetAngle();
}

void CircleShip::setAngle(float angle)
{
    body->SetTransform(getPosition(), angle);
}

void CircleShip::update(long dt)
{
    if (landpadC != NULL)
    {
        b2Body* padBody = landpadC->getBody();
        if (padBody != NULL)
        {
            // We get the hull position and pad position to find
            // the distance between them.
            b2Vec2 hullPos = getPosition();
            b2Vec2 padPos = padBody->GetPosition();
            padPos = padPos - hullPos;
            
            // We are only concerned about the X position because
            // the pad only moves along the local X axis.
            float x = fabsf(padPos.x);
            // Floating point differences have limited precision during
            // subtraction like operations, for example, the >= comparison.
            float epsilon = 0.005;
            
            if (x >= (2.0f - epsilon)) {
                fullyExtended = true;
            }
            else {
                fullyExtended = false;
            }
            
            if (x <= epsilon) {
                fullyRetracted = true;
            }
            else {
                fullyRetracted = false;
            }
            
            if (x > epsilon && x < (2.0f - epsilon)) {
                padActive = true;
            }
            else {
                padActive = false;
            }
        }
    }
}

const b2Vec2& CircleShip::getPosition()
{
    return body->GetPosition();
}

void CircleShip::draw()
{
    b2Vec2 bodyPos = getPosition();
    float bodyAngle = body->GetAngle();

    glVertexPointer(2, GL_FLOAT, 0, Utilities::getNormalizedVertexCircle());
    glPushMatrix();

    glTranslatef(bodyPos.x*PTM_RATIO, bodyPos.y*PTM_RATIO, 0.0f);
    glScalef(PTM_RATIO, PTM_RATIO, 0.0f);
    glRotatef(bodyAngle * 180.0f / b2_pi, 0.0f, 0.0f, 1.0f);
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glColor4f(Utilities::Color_Green[0], Utilities::Color_Green[1], Utilities::Color_Green[2], 0.2f);
	glDrawArrays(GL_TRIANGLE_FAN, 0, Utilities::circleVertexCount);

    glColor4f(Utilities::Color_Green[0], Utilities::Color_Green[1], Utilities::Color_Green[2], 1.0f);
	glDrawArrays(GL_LINE_LOOP, 0, Utilities::circleVertexCount);
    
    // Draw the axis line
	glVertexPointer(2, GL_FLOAT, 0, axisVertices);
    glColor4f(Utilities::Color_StealBlue[0], Utilities::Color_StealBlue[1], Utilities::Color_StealBlue[2], 1.0f);
	glDrawArrays(GL_LINES, 0, axisVertexCount);

    glPopMatrix();

    // Draw legs
    b2Vec2 legPos = leftLegBody->GetPosition();
    float legAngle = leftLegBody->GetAngle();

	glVertexPointer(2, GL_FLOAT, 0, legVertices);
    glPushMatrix();

    glTranslatef(legPos.x*PTM_RATIO, legPos.y*PTM_RATIO, 0.0f);
    glScalef(PTM_RATIO, PTM_RATIO, 0.0f);
    glRotatef(legAngle * 180.0f / b2_pi, 0.0f, 0.0f, 1.0f);

    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glColor4f(Utilities::Color_Orchid[0], Utilities::Color_Orchid[1], Utilities::Color_Orchid[2], 0.2f);
	glDrawArrays(GL_TRIANGLE_FAN, 0, legVertexCount);
    
    glColor4f(Utilities::Color_Orchid[0], Utilities::Color_Orchid[1], Utilities::Color_Orchid[2], 1.0f);
	glDrawArrays(GL_LINE_LOOP, 0, legVertexCount);

    glPopMatrix();
    
    legPos = rightLegBody->GetPosition();
    legAngle = rightLegBody->GetAngle();
    glPushMatrix();
    
    glTranslatef(legPos.x*PTM_RATIO, legPos.y*PTM_RATIO, 0.0f);
    glScalef(PTM_RATIO, PTM_RATIO, 0.0f);
    glRotatef(legAngle * 180.0f / b2_pi, 0.0f, 0.0f, 1.0f);
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glColor4f(Utilities::Color_White[0], Utilities::Color_White[1], Utilities::Color_White[2], 0.2f);
	glDrawArrays(GL_TRIANGLE_FAN, 0, legVertexCount);
    
    glColor4f(Utilities::Color_White[0], Utilities::Color_White[1], Utilities::Color_White[2], 1.0f);
	glDrawArrays(GL_LINE_LOOP, 0, legVertexCount);
    
    glPopMatrix();
    
    if (!fullyRetracted && landpadC != NULL)
        landpadC->draw();

    if (cup != NULL)
        cup->draw();
}

void CircleShip::applyForceAlongHeading()
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

void CircleShip::applyLinearImpulse(const b2Vec2& direction, const b2Vec2& position)
{
    body->ApplyLinearImpulse(direction, position);
}

void CircleShip::applyAngularImpulse(float angle)
{
    body->ApplyAngularImpulse(angle);
}

void CircleShip::zeroVelocities()
{
    body->SetAngularVelocity(0.0f);
    body->SetLinearVelocity(b2Vec2(0.0f, 0.0f));
    rightLegBody->SetAngularVelocity(0.0f);
    rightLegBody->SetLinearVelocity(b2Vec2(0.0f, 0.0f));
    leftLegBody->SetAngularVelocity(0.0f);
    leftLegBody->SetLinearVelocity(b2Vec2(0.0f, 0.0f));
    if (cup != NULL)
        cup->zeroVelocities();
}

void CircleShip::beforeStep(long dt)
{
    if (!_thrusting)
        return;
    
    applyForceAlongHeading();
}

void CircleShip::afterStep(long dt)
{
    if (!_rotating)
        return;
    
    // TODO should probably use damping instead.
    body->SetAngularVelocity(0.0f);
}

void CircleShip::thrusting(float colSize, float rowSize, float x, float y)
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
            //StringUtilities::log("CircleShip::thrusting thrustPower ", thrustPower);
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

float CircleShip::getRotatePower()
{
    return 1.0f;
}

float CircleShip::getThrustPower()
{
    return thrustPower;//1.0f/3.0f;
}

//########################################################
// ## Physics callbacks for IContactFilterListener interface.
//########################################################
bool CircleShip::shouldCollide(const b2Fixture* const fixtureA, const b2Fixture* const fixtureB)
{
    ContactUserData* userDataA = static_cast<ContactUserData*>(fixtureA->GetUserData());
    ContactUserData* userDataB = static_cast<ContactUserData*>(fixtureB->GetUserData());
    
    bool m = (userDataA->getType() == ContactUserData::BoxCargo && userDataB->getType() == ContactUserData::CircleShip);
    m = m || (userDataA->getType() == ContactUserData::CircleShip && userDataB->getType() == ContactUserData::BoxCargo);
    // Technically I don't need to filter the circleship/landingpad combination because when the pad is connected to the
    // ship using a joint the joint's definition has the collideConnected set to false which means this method won't even be
    // be called for this combination.
    //m = m || (userDataA->getType() == ContactUserData::CircleShip && userDataB->getType() == ContactUserData::LandingPadTypeC);
    //m = m || (userDataA->getType() == ContactUserData::LandingPadTypeC && userDataB->getType() == ContactUserData::CircleShip);
    
    if (m)
    {
        // The box cargo needs to penetrate the ship's hull in order to be caught by the ship's cup.
        //StringUtilities::log("CircleShip::shouldCollide passing through uA " + userDataA->toString() + " and uB " + userDataB->toString());
        return false;
    }
    else
    {
        //StringUtilities::log("CircleShip::shouldCollide collide uA " + userDataA->toString() + " and uB " + userDataB->toString());
        return true;   // otherwise the fixtures should collide.
    }
    
}

//########################################################
// ## Physics callbacks for IContactlistener interface.
//########################################################
// This event only occurs within the time step.
void CircleShip::beginContact(b2Contact* contact)
{
    //StringUtilities::log("CircleShip::beginContact");
    if (contact->IsEnabled()) {
        // We only want contacts that are between this ship and something
        // else. One of the fixtures must be the ship.
        b2Fixture* fixtureA = contact->GetFixtureA();
        b2Fixture* fixtureB = contact->GetFixtureB();
        
        ContactUserData* userDataA = static_cast<ContactUserData*>(fixtureA->GetUserData());
        ContactUserData* userDataB = static_cast<ContactUserData*>(fixtureB->GetUserData());
        
        bool m = (userDataA->getType() == ContactUserData::CircleShip || userDataB->getType() == ContactUserData::CircleShip);
        m = m || (userDataA->getType() == ContactUserData::CircleShipLeftLeg || userDataB->getType() == ContactUserData::CircleShipLeftLeg);
        m = m || (userDataA->getType() == ContactUserData::CircleShipRightLeg || userDataB->getType() == ContactUserData::CircleShipRightLeg);
        
        if (m) {
            //StringUtilities::log("CircleShip::beginContact collected contact between uA " + userDataA->toString() + " and uB " + userDataB->toString());
            b2WorldManifold worldManifold;
            
            contact->GetWorldManifold(&worldManifold);

            AContact aContact = { fixtureA, fixtureB, worldManifold };
            contacts.push_back(aContact);
        } else {
            //StringUtilities::log("CircleShip::beginContact discarded contact between uA " + userDataA->toString() + " and uB " + userDataB->toString());
        }
    }
    
}

// This event can occur outside the time step
void CircleShip::endContact(b2Contact* contact)
{
    //StringUtilities::log("CircleShip::endContact");
    b2Fixture* fixtureA = contact->GetFixtureA();
    b2Fixture* fixtureB = contact->GetFixtureB();

    ContactUserData* userDataA = static_cast<ContactUserData*>(fixtureA->GetUserData());
    ContactUserData* userDataB = static_cast<ContactUserData*>(fixtureB->GetUserData());
    
    bool m = (userDataA->getType() == ContactUserData::CircleShip || userDataB->getType() == ContactUserData::CircleShip);
    m = m || (userDataA->getType() == ContactUserData::CircleShipLeftLeg || userDataB->getType() == ContactUserData::CircleShipLeftLeg);
    m = m || (userDataA->getType() == ContactUserData::CircleShipRightLeg || userDataB->getType() == ContactUserData::CircleShipRightLeg);
    
    if (m) {
        AContact aContact = { fixtureA, fixtureB };
        
        std::list<AContact>::iterator pos;
        
        pos = std::find(contacts.begin(), contacts.end(), aContact);
        if (pos != contacts.end()) {
            contacts.erase(pos);
            //StringUtilities::log("CircleShip::endContact erased contact between uA " + userDataA->toString() + " and uB " + userDataB->toString());
        }
    }
}

// This is called after collision detection, but before collision resolution.
// This gives you a chance to disable the contact based on the current configuration.
// For example, you can implement a one-­‐sided platform using this callback
// and calling b2Contact::SetEnabled(false). The contact will be re-­‐enabled each time
// through collision processing, so you will need to disable the contact every time-­‐step.
// The pre-­‐solve event may be fired multiple times per time step per contact due to continuous collision detection.
void CircleShip::preSolve(b2Contact* contact, const b2Manifold* oldManifold)
{
//    //StringUtilities::log("CircleShip::preSolve");
//    b2Fixture* fixtureA = contact->GetFixtureA();
//    b2Fixture* fixtureB = contact->GetFixtureB();
//    
//    ContactUserData* userDataA = static_cast<ContactUserData*>(fixtureA->GetUserData());
//    ContactUserData* userDataB = static_cast<ContactUserData*>(fixtureB->GetUserData());
//    
//    // We only want to process the circle and legs; everything else this method doesn't care about.
//    bool m = (userDataA->getType() == ContactUserData::CircleShip);
//    m = m || (userDataA->getType() == ContactUserData::CircleShipLeftLeg);
//    m = m || (userDataA->getType() == ContactUserData::CircleShipRightLeg);
//    m = m || (userDataB->getType() == ContactUserData::CircleShip);
//    m = m || (userDataB->getType() == ContactUserData::CircleShipRightLeg);
//    m = m || (userDataB->getType() == ContactUserData::CircleShipLeftLeg);
//    
//    if (!m)
//    {
//        //StringUtilities::log("CircleShip::preSolve this event isn't related to this object");
//        //StringUtilities::log("CircleShip::preSolve discarded between uA " + userDataA->toString() + " and uB " + userDataB->toString());
//        return;
//    }
//
//    // We don't care if a ship part collided with the cup.
//    if (userDataA->getType() == ContactUserData::Cup || userDataB->getType() == ContactUserData::Cup)
//        return;
//    
//    // Use this to get Approach velocity to determine how hard the collision was. We will
//    // want to update the Actor accordingly. We don't destroy bodies because this is
//    // a callback during the physics' time stepping.
//    b2WorldManifold worldManifold;
//    
//    contact->GetWorldManifold(&worldManifold);
//    
//    //std::cout << "PreSolve worldmanifold: (" << worldManifold.normal.x << "," << worldManifold.normal.y << ")" << std::endl;
//    
//    b2PointState state1[2], state2[2];
//    
//    /// Compute the point states given two manifolds. The states pertain to the transition from oldManifold
//    /// to GetManifold. So state1 is either persist or remove while state2 is either add or persist.
//    b2GetPointStates(state1, state2, oldManifold, contact->GetManifold());
//    //0 b2_nullState,		///< point does not exist
//    //1 b2_addState,		///< point was added in the update
//    //2 b2_persistState,	///< point persisted across the update
//    //3 b2_removeState		///< point was removed in the update
//    
//    //std::string s_s10 = mapPointState(state1[0]);
//    //std::string s_s11 = mapPointState(state1[1]);
//    
//    //std::string s_s20 = mapPointState(state2[0]);
//    //std::string s_s21 = mapPointState(state2[1]);
//    
//    //std::cout << "PreSolve state1,state2: {" << s_s10 << " : " <<s_s11<< " , " << s_s20 << " : " << s_s21 << "}" << std::endl;
////    std::string state;
////    if (state2[0] == b2_addState)
////        state = "b2_addState";
////    else if (state2[0] == b2_nullState)
////        state = "b2_nullState";
////    else if (state2[0] == b2_persistState)
////        state = "b2_persistState";
////    else if (state2[0] == b2_removeState)
////        state = "b2_removeState";
////        
////    StringUtilities::log("CircleShip::preSolve between uA " + userDataA->toString() + " and uB " + userDataB->toString() + " state: " + state);
//
//    //if (worldManifold.normal.x == 1.0f || worldManifold.normal.x == -1.0f)
//    //    contact->SetEnabled(false);  // The object will now go right through each other.
//    
//    // b2_addState = point was added in the update. Most of the time this state is b2_persistState.
//    if (state2[0] == b2_addState)
//    {
//        const b2Body* bodyA = fixtureA->GetBody();
//        const b2Body* bodyB = fixtureB->GetBody();
//        
//        b2Vec2 point = worldManifold.points[0];
//        
//        b2Vec2 vA = bodyA->GetLinearVelocityFromWorldPoint(point);
//        b2Vec2 vB = bodyB->GetLinearVelocityFromWorldPoint(point);
//        
//        b2Vec2 vector;
//        vector.Set(vB.x - vA.x, vB.y - vA.y);
//        
//        float32 approachVelocity = b2Dot(vector, worldManifold.normal);
//        
//        //StringUtilities::log("CircleShip::preSolve approachVelocity: ", approachVelocity);
//    }

}

// The post solve event is where you can gather collision impulse results.
// If you don’t care about the impulses, you should probably just implement the pre-­‐solve event. 
void CircleShip::postSolve(b2Contact* contact, const b2ContactImpulse* impulse)
{
    //StringUtilities::log("CircleShip::postSolve");
}

// The recommended practice for processing contact points is to buffer all contact
// data that you care about and process it after the time step. You should always
// process the contact points immediately after the time step; otherwise some other
// client code might alter the physics world, invalidating the contact buffer.
// This method is called after the physics time step.
// This will continue to be processed until there is no more contacting (aka end-contact has occurred)
void CircleShip::processContacts(long dt)
{
    std::list<AContact>::iterator pos;
    //int i = 0;
    //StringUtilities::log("CircleShip::processContacts dt ", dt);
    for(pos = contacts.begin(); pos != contacts.end(); ++pos)
    {
        //StringUtilities::log("CircleShip::processContacts contact: ", i++);
        AContact contact = *pos;
        
        b2Fixture* fixtureA = contact.fixtureA;
        b2Fixture* fixtureB = contact.fixtureB;
        
        // Use this to get Approach velocity to determine how hard the collision was. We will
        // want to update the Actor accordingly. We don't destroy bodies because this is
        // a callback during the physics' time stepping.
        b2WorldManifold worldManifold = contact.worldManifold;
        
        const b2Body* bodyA = fixtureA->GetBody();
        const b2Body* bodyB = fixtureB->GetBody();
        
        b2Vec2 point = worldManifold.points[0];
        
        b2Vec2 vA = bodyA->GetLinearVelocityFromWorldPoint(point);
        b2Vec2 vB = bodyB->GetLinearVelocityFromWorldPoint(point);
        
        b2Vec2 vector;
        vector.Set(vB.x - vA.x, vB.y - vA.y);
        
        float32 approachVelocity = b2Dot(vector, worldManifold.normal);
        
        if (fabs(approachVelocity) > Utilities::epsilon)
        {
            if (approachVelocity <= 0.0f)
                StringUtilities::log("CircleShip::processContacts approach Velocity: ", approachVelocity);
            else
                StringUtilities::log("CircleShip::processContacts exit Velocity: ", approachVelocity);
        }
    }
    
    if (landpadC != NULL)
        landpadC->processContacts(dt);
    
}

//=============================================
// Statuses
//=============================================
bool CircleShip::hasSomethingSuccessfullyLanded()
{
    return landpadC->hasSomethingSuccessfullyLanded();
}

bool CircleShip::isPadFullyExtended()
{
    return fullyExtended;
}

bool CircleShip::isPadFullyRetracted()
{
    return fullyRetracted;
}

void CircleShip::extendPad()
{
    if (landpadC == NULL)
        attachPad();
    else
        detachPad();
    
    b2World* world = Model::instance()->getPhysicsWorld();
    
    b2Body* padBody = landpadC->getBody();
    
    b2PrismaticJointDef jointDef;

    // We want the motor force to continuously push the pad into
    // the ship. We then use a stronger force to push the pad out/extend it outward.
    jointDef.localAxis1.Set(-1.0f, 0.0f);
    
    jointDef.bodyA = body;
    // This anchor sets the relative position of the bodyB
    jointDef.localAnchorA.Set(-1.0f, 0.0f);
    
    jointDef.bodyB = padBody;
    jointDef.localAnchorB.Set(0.0f, 0.0f);
    
    jointDef.upperTranslation = 1.0f;
    jointDef.lowerTranslation = -1.0f;
    
    jointDef.enableLimit = true;
    jointDef.enableMotor = true;
    jointDef.maxMotorForce = 1.0f;
    jointDef.motorSpeed = 1.0f;
    
    // We don't want the pad to collide with the ship or its legs.
    jointDef.collideConnected = false;

    padJoint = world->CreateJoint(&jointDef);
    
    // The position of the pad depends on if the pad is in motion or just has
    // just started or ended (aka the upper or lower translation limits)
    // We need to detect if the pad has reached a limit.
    b2Vec2 b2Pos;
    if (fullyRetracted)
        b2Pos = getPosition();
    else
        b2Pos = padBody->GetPosition();

    padBody->SetTransform(b2Pos, padBody->GetAngle());

}

void CircleShip::extractPad()
{
    if (landpadC == NULL)
        attachPad();
    else
        detachPad();
        
    b2World* world = Model::instance()->getPhysicsWorld();
    
    
    b2Body* padBody = landpadC->getBody();
    
    b2PrismaticJointDef jointDef;
    
    // We want the motor force to continuously push the pad into
    // the ship.
    jointDef.localAxis1.Set(1.0f, 0.0f);
    
    jointDef.bodyA = body;
    // This anchor sets the relative position of the bodyB
    jointDef.localAnchorA.Set(-1.0f, 0.0f);
    
    jointDef.bodyB = padBody;
    jointDef.localAnchorB.Set(0.0f, 0.0f);
    
    jointDef.upperTranslation = 1.0f;
    jointDef.lowerTranslation = -1.0f;
    
    jointDef.enableLimit = true;
    jointDef.enableMotor = true;
    jointDef.maxMotorForce = 1.0f;
    jointDef.motorSpeed = 1.0f;
    
    // We don't want the pad to collide with the ship or its legs.
    jointDef.collideConnected = false;
    
    padJoint = world->CreateJoint(&jointDef);
    
    // The position of the pad depends on if the pad is in motion or has
    // just started or ended (aka the upper or lower translation limits)
    // We need to detect if the pad has reached a limit.
    b2Vec2 b2Pos;
    if (fullyRetracted) {
        b2Pos = getPosition();
        b2Pos.x = b2Pos.x - 2.0f;
    }
    else
        b2Pos = padBody->GetPosition();
    
    padBody->SetTransform(b2Pos, padBody->GetAngle());

}

void CircleShip::detachPad()
{
    b2World* world = Model::instance()->getPhysicsWorld();

    if (padJoint != NULL)
    {
        world->DestroyJoint(padJoint);
        padJoint = NULL;
    }
}

void CircleShip::attachPad()
{
    Model* model = Model::instance();
    b2World* world = model->getPhysicsWorld();
    
    landpadC = new LandingPadTypeC();
    landpadC->init(world);
    
    b2Vec2 pos = body->GetPosition();
    landpadC->setPosition(pos.x, pos.y);

    Box2dContactListener* contactTransmitter = model->getWorldContactListener();
    landpadC->subscribeAsContactListener(contactTransmitter);
}

void CircleShip::activatePad()
{
    landpadC->activate(true);
}

void CircleShip::releasePad(b2World* const world)
{
    if (landpadC != NULL)
    {
        landpadC->activate(false);
        landpadC->release(world);
        delete landpadC;
        landpadC = NULL;
    }
}

//########################################################
// ## Cup
//########################################################
void CircleShip::attachCup()
{
    if (cup == NULL)
    {
        b2World* world = Model::instance()->getPhysicsWorld();

        cup = new Cup();
        cup->init(world);
        b2Vec2 pos = getPosition();
        cup->setPosition(pos.x, pos.y);
        cup->attachToBody(body);
        cup->activate(true);
    }
}

void CircleShip::releaseCup(b2World* const world)
{
    if (cup != NULL)
    {
        cup->release(world);
        delete cup;
        cup = NULL;
    }
}

void CircleShip::debug()
{
    //    landpadC->getBody()->SetLinearVelocity(b2Vec2(0.0f, 0.0f));
    //    b2Vec2 force(-0.1f, 0.0);
    //    landpadC->getBody()->ApplyLinearImpulse(force, b2Pos);

    if (debugToggle)
        extractPad();
    else
        extendPad();
    
    debugToggle = !debugToggle;
}
