//
//  LandingPadTypeC.m
//  Hukimasu2
//
//  Created by William DeVore on 7/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "StringUtilities.h"
#import "Utilities.h"
#import "LandingPadTypeC.h"
#import "Model.h"
#import "Edge.h"
#import "ContactUserData.h"

LandingPadTypeC::LandingPadTypeC() {
    body = NULL;
    vertices = NULL;
    contactDuration = 0;
    successfulLanding = false;
    approachVelocity = 0;
    landed = false;
    requiredRestCount = 0L;
}

LandingPadTypeC::~LandingPadTypeC()
{
    StringUtilities::log("LandingPadTypeC::~LandingPadTypeC");
}

void LandingPadTypeC::activate(bool state)
{
    body->SetActive(state);
}

void LandingPadTypeC::init(b2World* const world)
{
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.active = false;
    bodyDef.position.Set(0.0f, 0.0f);
    body = world->CreateBody(&bodyDef);
    
    // For each edge there are 2 vertices.
    vertexCount = 4;
    vertices = new b2Vec2[vertexCount];
    vertices[0].Set(-1.0f, -1.0f/25.0f);
    vertices[1].Set(1.0f, -1.0f/25.0f);
    vertices[2].Set(1.0f, 1.0f/25.0f);
    vertices[3].Set(-1.0f, 1.0f/25.0f);
    
    b2PolygonShape polygon;
    polygon.Set(vertices, vertexCount);
    
    // The density of 1.0f has an effect on any motors' attempt to act
    // on this body. The smaller the density the stronger the motor is
    // acting on the body.
    fixture = body->CreateFixture(&polygon, 0.1f);
    fixture->SetFriction(1.0f);
    
    ContactUserData* userData = new ContactUserData();
    userData->setObject(this, ContactUserData::LandingPadTypeC);
    userData->setData1(1);
    fixture->SetUserData(userData);
    
    // 300ms = 300000us
    requiredRestCount = 1000000L;
    
    approachVelocity = 0;
    landed = false;
    contactDuration = 0;
}

void LandingPadTypeC::reset()
{
    contactDuration = 0;
    successfulLanding = false;
    approachVelocity = 0;
    landed = false;
    requiredRestCount = 1000000L;
}

void LandingPadTypeC::release(b2World* const world) {
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
    vertices = NULL;

    fixture = NULL;
}

void LandingPadTypeC::update(long dt)
{
    
}

//=============================================
// Properties
//=============================================

//=============================================
// Messaging
//=============================================

void LandingPadTypeC::message(int message) {
    StringUtilities::log("LandingPadTypeC::message ", message);
}

void LandingPadTypeC::subscribeListener(IMessage* listener) {
}

void LandingPadTypeC::unSubscribeListener(IMessage* listener) {
}

//=============================================
// Statuses
//=============================================
bool LandingPadTypeC::hasSomethingSuccessfullyLanded()
{
    return successfulLanding;
}

//=============================================
// Rendering
//=============================================

void LandingPadTypeC::draw() {
    Model* model = Model::instance();
    float p2m = model->getPixelsToMetersRatio();
    
    b2Vec2 bodyPos = body->GetPosition();
    float bodyAngle = body->GetAngle();
    
    glVertexPointer(2, GL_FLOAT, 0, vertices);
    glPushMatrix();
    
    glTranslatef(bodyPos.x * p2m, bodyPos.y * p2m, 0.0f);
    glScalef(p2m, p2m, 0.0f);
    glRotatef(bodyAngle * 180.0f / b2_pi, 0.0f, 0.0f, 1.0f);
    
    glColor4f(Utilities::Color_Red[0], Utilities::Color_Red[1], Utilities::Color_Red[2], 1.0f);
	glDrawArrays(GL_LINE_LOOP, 0, vertexCount);
    
    glPopMatrix();
}

//=============================================
// Getters/Setters
//=============================================
void LandingPadTypeC::setPosition(float x, float y)
{
    body->SetTransform(b2Vec2(x, y), body->GetAngle());
}

const b2Vec2& LandingPadTypeC::getPosition()
{
    return body->GetPosition();
}

b2Body* LandingPadTypeC::getBody()
{
    return body;
}

float LandingPadTypeC::getAngle()
{
    return body->GetAngle();
}

void LandingPadTypeC::setAngle(float angle)
{
    body->SetTransform(getPosition(), angle);
}


//########################################################
// ## Physics stepping
//########################################################
void LandingPadTypeC::beforeStep(long dt)
{
    
}

void LandingPadTypeC::afterStep(long dt)
{
    
}

//########################################################
// ## Physics callbacks
//########################################################

// This event only occurs within the time step.
void LandingPadTypeC::beginContact(b2Contact* contact)
{
    // Only process is PadC is enabled.
    if (contact->IsEnabled()) {
        // We want contacts that are between this Pad and the suit.
        b2Fixture* fixtureA = contact->GetFixtureA();
        b2Fixture* fixtureB = contact->GetFixtureB();
        
        ContactUserData* userDataA = static_cast<ContactUserData*>(fixtureA->GetUserData());
        ContactUserData* userDataB = static_cast<ContactUserData*>(fixtureB->GetUserData());
        
        bool m = (userDataA->getType() == ContactUserData::TriangleShip || userDataB->getType() == ContactUserData::LandingPadTypeC);
        m =m || (userDataA->getType() == ContactUserData::LandingPadTypeC || userDataB->getType() == ContactUserData::TriangleShip);
        
        // The triangle is the Space suit.
        if (m)
        {
            //StringUtilities::log("LandingPadTypeC::beginContact collected contact between uA " + userDataA->toString() + " and uB " + userDataB->toString());
            b2WorldManifold worldManifold;
            
            contact->GetWorldManifold(&worldManifold);
            
            AContact aContact = { fixtureA, fixtureB, worldManifold };
            contacts.push_back(aContact);
            landed = true;
            approachVelocity = 0;
        }
        else
        {
            //StringUtilities::log("LandingPadTypeC::beginContact discarded contact between uA " + userDataA->toString() + " and uB " + userDataB->toString());
        }
    }
    
}

// This event can occur outside the time step
void LandingPadTypeC::endContact(b2Contact* contact)
{
    b2Fixture* fixtureA = contact->GetFixtureA();
    b2Fixture* fixtureB = contact->GetFixtureB();
    
    ContactUserData* userDataA = static_cast<ContactUserData*>(fixtureA->GetUserData());
    ContactUserData* userDataB = static_cast<ContactUserData*>(fixtureB->GetUserData());
    
    if (userDataA->getType() == ContactUserData::TriangleShip || userDataB->getType() == ContactUserData::LandingPadTypeC)
    {
        AContact aContact = { fixtureA, fixtureB };
        
        std::list<AContact>::iterator pos;
        
        pos = std::find(contacts.begin(), contacts.end(), aContact);
        if (pos != contacts.end())
        {
            contacts.erase(pos);
            landed =false;
            contactDuration = 0;
            successfulLanding = false;
            //StringUtilities::log("LandingPadTypeC::endContact erased contact between uA " + userDataA->toString() + " and uB " + userDataB->toString());
        }
    }
}

// This is called after collision detection, but before collision resolution.
// This gives you a chance to disable the contact based on the current configuration.
// For example, you can implement a one-­‐sided platform using this callback
// and calling b2Contact::SetEnabled(false). The contact will be re-­‐enabled each time
// through collision processing, so you will need to disable the contact every time-­‐step.
// The pre-­‐solve event may be fired multiple times per time step per contact due to continuous collision detection.
void LandingPadTypeC::preSolve(b2Contact* contact, const b2Manifold* oldManifold)
{
    //StringUtilities::log("CircleShip::preSolve");
    b2Fixture* fixtureA = contact->GetFixtureA();
    b2Fixture* fixtureB = contact->GetFixtureB();
    
    ContactUserData* userDataA = static_cast<ContactUserData*>(fixtureA->GetUserData());
    ContactUserData* userDataB = static_cast<ContactUserData*>(fixtureB->GetUserData());
    
    bool m = (userDataA->getType() == ContactUserData::TriangleShip && userDataB->getType() == ContactUserData::LandingPadTypeC);
    m = m || (userDataA->getType() == ContactUserData::LandingPadTypeC && userDataB->getType() == ContactUserData::TriangleShip);
    if (m)
    {
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
        if (state2[0] == b2_addState)
        {
            const b2Body* bodyA = fixtureA->GetBody();
            const b2Body* bodyB = fixtureB->GetBody();
            
            b2Vec2 point = worldManifold.points[0];
            
            b2Vec2 vA = bodyA->GetLinearVelocityFromWorldPoint(point);
            b2Vec2 vB = bodyB->GetLinearVelocityFromWorldPoint(point);
            
            b2Vec2 vector;
            vector.Set(vB.x - vA.x, vB.y - vA.y);
            
            float currentVelocity = b2Dot(vector, worldManifold.normal);
            
            // There may be several "preSolve" events between beginContacts()
            // and the time processContacts() is called; we try to find the largest one (in magnitude).
            if (currentVelocity < approachVelocity)
                approachVelocity = currentVelocity;
            
            //StringUtilities::log("LandingPadTypeC::preSolve fixture B " + userDataB->toString());
            //StringUtilities::log("LandingPadTypeC::preSolve fixture A " + userDataA->toString());
            //StringUtilities::log("LandingPadTypeC::preSolve approachVelocity: ", approachVelocity);
        }
    }
    
}

// The post solve event is where you can gather collision impulse results.
// If you don’t care about the impulses, you should probably just implement the pre-­‐solve event. 
void LandingPadTypeC::postSolve(b2Contact* contact, const b2ContactImpulse* impulse)
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
void LandingPadTypeC::processContacts(long dt)
{
    std::list<AContact>::iterator pos;
    
    //StringUtilities::log("LandingPadTypeC::processContacts dt ", dt);

    for(pos = contacts.begin(); pos != contacts.end(); ++pos)
    {
        AContact contact = *pos;
        
        b2Fixture* fixtureA = contact.fixtureA;
        b2Fixture* fixtureB = contact.fixtureB;
        
        ContactUserData* userDataA = static_cast<ContactUserData*>(fixtureA->GetUserData());
        ContactUserData* userDataB = static_cast<ContactUserData*>(fixtureB->GetUserData());
        
        bool m = (userDataA->getType() == ContactUserData::TriangleShip && userDataB->getType() == ContactUserData::LandingPadTypeC);
        m = m || (userDataA->getType() == ContactUserData::LandingPadTypeC && userDataB->getType() == ContactUserData::TriangleShip);
        
        if (m)
        {
            // Accumulate time while contacted.
            contactDuration += dt;
            if (!successfulLanding && landed)
            {
                if (contactDuration > requiredRestCount)
                {
                    // The suit has steadied. How hard did it land?
                    if (approachVelocity >= -1.0)
                    {
                        //StringUtilities::log("LandingPadTypeC::processContacts suit has steadied approachVelocity ", approachVelocity);
                        successfulLanding = true;
                    }
                }
                
                if (approachVelocity < -1.0)
                {
                    //StringUtilities::log("LandingPadTypeC::processContacts suit landed to hard approachVelocity ", approachVelocity);
                    successfulLanding = false;
                }
            }
        }
    }
}