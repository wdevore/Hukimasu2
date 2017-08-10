//
//  TriangleShip.m
//  Hukimasu
//
//  Created by William DeVore on 4/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "StringUtilities.h"
#import "TriangleShip.h"
#import "ContactUserData.h"
#import "Model.h"
#import "Utilities.h"

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

TriangleShip::TriangleShip() {
    thrustPower = 0;
}

TriangleShip::~TriangleShip()
{
    StringUtilities::log("TriangleShip::~TriangleShip");
}

void TriangleShip::activate(bool state)
{
    body->SetActive(state);
}

void TriangleShip::init(b2World* const world)
{
    vertexCount = 3;
    vertices = new b2Vec2[vertexCount];
    
    vertices[0].Set(-0.25f, 0.0f);
    vertices[1].Set(0.25f, 0.0f);
    vertices[2].Set(0.0f, 0.75f);
    
    // Small triangle
    b2PolygonShape polygon;
    polygon.Set(vertices, vertexCount);
    
    b2FixtureDef triangleShapeDef;
    triangleShapeDef.shape = &polygon;
    triangleShapeDef.density = 1.0f;
    
    b2BodyDef triangleBodyDef;
    triangleBodyDef.type = b2_dynamicBody;
    triangleBodyDef.position.Set(0.0f, 0.0f);       // Default to the origin

    body = world->CreateBody(&triangleBodyDef);
    b2Fixture* fixture = body->CreateFixture(&triangleShapeDef);
    fixture->SetFriction(1.0f);
    
    contactUserDataBody = new ContactUserData();
    contactUserDataBody->setObject(this, ContactUserData::TriangleShip);
    contactUserDataBody->setData1(1);
    fixture->SetUserData(contactUserDataBody);

    thrustPower = 0;
}

void TriangleShip::release(b2World* const world)
{
    world->DestroyBody(body);
    body = NULL;
    delete [] vertices;
    delete contactUserDataBody;
}

void TriangleShip::reset()
{
    
}

void TriangleShip::setPosition(float x, float y)
{
    //ActorShip::setPosition(x, y);
    // Note: setting this property will cause the physics engine to
    // "probe" all bodys for information like collision.
    b2Vec2 pos(x, y);
    body->SetTransform(pos, body->GetAngle());
}

float TriangleShip::getAngle()
{
    return body->GetAngle();
}

void TriangleShip::setAngle(float angle)
{
    body->SetTransform(getPosition(), angle);
}

void TriangleShip::update(long dt)
{
}

const b2Vec2& TriangleShip::getPosition()
{
    return body->GetPosition();
}

void TriangleShip::draw()
{
    b2Vec2 pos = getPosition();
    float a = body->GetAngle();
    
    glColor4f(1.0f, 0.5f, 0.5f, 1.0f);
    
    glPushMatrix();
    glTranslatef(pos.x*PTM_RATIO, pos.y*PTM_RATIO, 0.0f);
    glScalef(PTM_RATIO, PTM_RATIO, 0.0f);
    glRotatef(a * 180.0f / b2_pi, 0.0f, 0.0f, 1.0f);
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glColor4f(Utilities::Color_Blue[0], Utilities::Color_Blue[1], Utilities::Color_Blue[2], 0.2f);
    glVertexPointer(2, GL_FLOAT, 0, vertices);
    glDrawArrays(GL_TRIANGLES, 0, vertexCount);
    
    glColor4f(Utilities::Color_Blue[0], Utilities::Color_Blue[1], Utilities::Color_Blue[2], 1.0f);
	glDrawArrays(GL_LINE_LOOP, 0, vertexCount);

    glPopMatrix();
    
}

void TriangleShip::applyForceAlongHeading()
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
    body->ApplyLinearImpulse(vector, b2Pos);
    
    // or
    //                        vector *= 10.0f;
    //                        b->ApplyForce(vector, b2Pos);
}

void TriangleShip::applyAngularImpulse(float angle)
{
    body->ApplyAngularImpulse(angle);
}

void TriangleShip::beforeStep(long dt)
{
    if (!_thrusting)
        return;
    
    applyForceAlongHeading();
}

void TriangleShip::afterStep(long dt)
{
    if (!_rotating)
        return;
    
    // TODO should probably use damping instead.
    body->SetAngularVelocity(0.0f);
}

float TriangleShip::getRotatePower()
{
    return 100.0f;
}

float TriangleShip::getThrustPower()
{
    return thrustPower;//1.0f/75.0f;
}

void TriangleShip::zeroVelocities()
{
    body->SetAngularVelocity(0.0f);
    body->SetLinearVelocity(b2Vec2(0.0f, 0.0f));
}

void TriangleShip::thrusting(float colSize, float rowSize, float x, float y)
{
    if (x == -1 && y == -1) {
        _thrusting = false;
        setThrustTouchLocation(-1, -1);
    }
    else {
        //if ((x < colSize) && (y > 3 * rowSize)) {
        if ((x < colSize)) {
            _thrusting = true;
            // Typical mid range power for this ship is 0 to 1/75.
            Model* model = Model::instance();
            thrustPower = 0.025f / (float)model->getViewHeight() * y;
            //StringUtilities::log("TriangleShip::thrusting thrustPower ", thrustPower);
            setThrustTouchLocation(x, y);
        }
        else
        {
            _thrusting = false;
            setThrustTouchLocation(-1, -1);
        }
    }
}

void TriangleShip::beginContact(b2Contact* contact)
{
    //StringUtilities::log("TriangleShip::beginContact");
    if (contact->IsEnabled()) {
        // We only want contacts that are between this ship and something
        // else. One of the fixtures must be the ship.
        b2Fixture* A = contact->GetFixtureA();
        b2Fixture* B = contact->GetFixtureB();
        
        ContactUserData* userDataA = (ContactUserData*)A->GetUserData();
        ContactUserData* userDataB = (ContactUserData*)B->GetUserData();
        
        bool m = (userDataA->getType() == ContactUserData::TriangleShip || userDataB->getType() == ContactUserData::TriangleShip);
        
        if (m) {
            //StringUtilities::log("TriangleShip::beginContact collected contact between uA " + userDataA->toString() + " and uB " + userDataB->toString());
            b2WorldManifold worldManifold;
            
            contact->GetWorldManifold(&worldManifold);
            
            AContact aContact = { A, B, worldManifold };
            contacts.push_back(aContact);
        } else {
            //StringUtilities::log("TriangleShip::beginContact discarded contact between uA " + userDataA->toString() + " and uB " + userDataB->toString());
        }
    }
}

void TriangleShip::endContact(b2Contact* contact)
{
    //StringUtilities::log("TriangleShip::endContact");
    b2Fixture* A = contact->GetFixtureA();
    b2Fixture* B = contact->GetFixtureB();
    
    ContactUserData* userDataA = (ContactUserData*)A->GetUserData();
    ContactUserData* userDataB = (ContactUserData*)B->GetUserData();
    
    bool m = (userDataA->getType() == ContactUserData::TriangleShip || userDataB->getType() == ContactUserData::TriangleShip);
    
    if (m) {
        AContact aContact = { A, B };
        
        std::list<AContact>::iterator pos;
        
        pos = std::find(contacts.begin(), contacts.end(), aContact);
        if (pos != contacts.end()) {
            contacts.erase(pos);
            //StringUtilities::log("TriangleShip::endContact erased contact between uA " + userDataA->toString() + " and uB " + userDataB->toString());
        }
    }
}

void TriangleShip::preSolve(b2Contact* contact, const b2Manifold* oldManifold)
{
    //StringUtilities::log("TriangleShip::preSolve");
}

void TriangleShip::postSolve(b2Contact* contact, const b2ContactImpulse* impulse)
{
    //StringUtilities::log("TriangleShip::postSolve");
}

void TriangleShip::processContacts(long dt)
{
//    std::list<AContact>::iterator pos;
//    //int i = 0;
//    //StringUtilities::log("TriangleShip::processContacts dt ", dt);
//    for(pos = contacts.begin(); pos != contacts.end(); ++pos) {
//        //StringUtilities::log("TriangleShip::processContacts contact: ", i++);
//        AContact contact = *pos;
//        
//        b2Fixture* fixtureA = contact.fixtureA;
//        b2Fixture* fixtureB = contact.fixtureB;
//        
//        // Use this to get Approach velocity to determine how hard the collision was. We will
//        // want to update the Actor accordingly. We don't destroy bodies because this is
//        // a callback during the physics' time stepping.
//        b2WorldManifold worldManifold = contact.worldManifold;
//        
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
//        if (fabs(approachVelocity) > Utilities::epsilon)
//        {
////            if (approachVelocity <= 0.0f)
////                StringUtilities::log("TriangleShip::processContacts approach Velocity: ", approachVelocity);
////            else
////                StringUtilities::log("TriangleShip::processContacts exit Velocity: ", approachVelocity);
//        }
//    }
}

