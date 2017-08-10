//
//  Emitter.m
//  Hukimasu2
//
//  Created by William DeVore on 10/28/11 A.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Emitter.h"
#import "ContactUserData.h"
#import "Model.h"
#import "Utilities.h"
#import "BoxCargo.h"
#import "TimerBase.h"

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

Emitter::Emitter() {
    interval = 0L;
    intervalCount = 0L;
    numberToEmit = 0L;
    paused = false;
    physicsWorld = NULL;
    waitingParticle = NULL;
    timerEmit = NULL;
    timerQueueDelay = NULL;
}

Emitter::~Emitter() {
}


void Emitter::setPosition(float x, float y)
{
    b2Vec2 pos(x, y);
    baseBody->SetTransform(pos, baseBody->GetAngle());
    
    pos.Set(x - .45f, y + 0.1f);
    leftWallBody->SetTransform(pos, leftWallBody->GetAngle());
    
    pos.Set(x + 0.45f, y + 0.1f);
    rightWallBody->SetTransform(pos, rightWallBody->GetAngle());
}

float Emitter::getAngle()
{
    return baseBody->GetAngle();
}

void Emitter::setAngle(float angle)
{
    baseBody->SetTransform(getPosition(), angle);
}

const b2Vec2& Emitter::getPosition()
{
    return baseBody->GetPosition();
}

void Emitter::setInterval(long microseconds)
{
    interval = microseconds;
}

void Emitter::setCount(int count)
{
    numberToEmit = count;
}

void Emitter::reset()
{
    intervalCount = 0L;

    b2World* world = Model::instance()->getPhysicsWorld();

    std::list<BoxCargo*>::iterator iter = particles.begin();
    while (iter != particles.end()) {
        BoxCargo* particle = *iter;
        particle->release(world);
        delete particle;
        ++iter;
    }
    
    /**
     *  Note that this function only erases
     *  the elements, and that if the elements themselves are
     *  pointers, the pointed-to memory is not touched in any way.
     *  Managing the pointer is the user's responsibilty which is done
     *  in the while loop by calling delete.
     */
    particles.clear();
    
    waitingParticle = NULL;
}

void Emitter::pause()
{
    paused = true;
}

void Emitter::resume()
{
    paused = false;
}

void Emitter::start()
{
    paused = false;
    reset();
    createParticle();
    timerEmit->reset();
    timerEmit->start();
    timerQueueDelay->reset();
}

bool Emitter::hasWaitingParticle()
{
    return waitingParticle != NULL;
}

bool Emitter::reachMaxEmission()
{
    return particles.size() == numberToEmit;
}

// This callback is called at the end of an interval from the TimerBase class.
void Emitter::action(int Id)
{
    switch (Id) {
        case 1:
            // Apply a force to the current waiting particle.
            if (hasWaitingParticle())
            {
                launchParticle();
                // We don't want to que another particle if we are stopping. By starting
                // the queue timer we are causing another particle to queue.
                if (!shouldStop(Id))
                    timerQueueDelay->start();
            }
            break;
        case 2:
                createParticle();
                timerQueueDelay->reset();
            break;
        default:
            break;
    }
}

// This callback is called at the end of an interval from the TimerBase class.
bool Emitter::shouldStop(int Id)
{
    switch (Id) {
        case 1:
            // Was the last waiting particle launched.
            if (reachMaxEmission())
            {
                //StringUtilities::log("Completed emitting. Paused.");
                return true;
            }
            else
            {
                return false;
            }
            break;
        case 2:
            // Once a particle has been queued the associated timer should stop.
            // It won't restart until commanded.
            return true;
            break;
        default:
            return false;
    }
}

void Emitter::update(long dt)
{
    if (paused)
        return;

    // The timer will call back to action() and shouldStop()
    timerEmit->update(dt);
    timerQueueDelay->update(dt);
}

//void Emitter::update(long dt)
//{
//    timerEmit->update(dt);
//    
//    if (paused)
//        return;
//    
//    if (intervalCount > interval)
//    {
//        // Collect overshoot for next pass.
//        intervalCount = intervalCount - interval;
//        
//        // Apply a force to the current waiting particle.
//        if (waitingParticle != NULL)
//        {
//            launchParticle();
//            queParticle = true;
//            queDelayCount = 0L;
//            
//            // Was the last waiting particle launched.
//            if (particles.size() == numberToEmit)
//            {
//                //StringUtilities::log("Completed emitting. Paused.");
//                pause();
//                return;
//            }
//        }
//        
//    }
//    
//    // Create another particle to sit on the emitter until emit time.
//    if (queParticle && (queDelayCount > queDelay))
//    {
//        createParticle(dt);
//        queParticle = false;
//    }
//    
//    // Accumulate current delta which may include an overshoot.
//    intervalCount += dt;
//    queDelayCount += dt;
//}

void Emitter::createParticle()
{
    //StringUtilities::log("Creating new particle to wait: ", position);
    waitingParticle = new BoxCargo();
    waitingParticle->init(physicsWorld);
    
    waitingParticle->activate(true);
    b2Vec2 position = baseBody->GetPosition();

    waitingParticle->setPosition(position.x, position.y + 0.2f);
    particles.push_back(waitingParticle);
    waitingParticle->setName(StringUtilities::toString((int)particles.size()));
    //StringUtilities::log("particles: ", (int)particles.size());
}

void Emitter::launchParticle()
{
    //StringUtilities::log("apply force to: ", waitingParticle->getName());
    waitingParticle->applyForce();
    // The particle has been launched.
    waitingParticle = NULL;
}

//########################################################
// ## Physics stepping
//########################################################
void Emitter::beforeStep(long dt)
{
}

void Emitter::afterStep(long dt)
{
}

//########################################################
// ## Physics callbacks
//########################################################

void Emitter::processContacts(long dt)
{
    
}

//########################################################
// ## Misc
//########################################################
void Emitter::activate(bool state)
{
    baseBody->SetActive(state);
    leftWallBody->SetActive(state);
    rightWallBody->SetActive(state);
}

void Emitter::init(b2World *const world)
{
    physicsWorld = world;
    
    /////// ##############################
    /////// main base body
    /////// ##############################
    baseVertexCount = 4;
    baseVertices = new b2Vec2[baseVertexCount];
    baseVertices[0].Set(-0.7f, -0.1f);
    baseVertices[1].Set(0.7f, -0.1f);
    baseVertices[2].Set(0.7f, 0.1f);
    baseVertices[3].Set(-0.7f, 0.1f);
    
    b2PolygonShape polygon;
    polygon.Set(baseVertices, baseVertexCount);
    
    b2FixtureDef shapeDef;
    shapeDef.shape = &polygon;
    shapeDef.density = 1.0f;
    
    b2BodyDef bodyDef;
    // The base needs to be static such that the whole emitter doesn't move.
    bodyDef.type = b2_staticBody;
    // The app must activate manually.
    bodyDef.active = false;

    // Technically a meaningless position as it will changed at a later time.
    bodyDef.position.Set(0.0f, 0.0f);
    baseBody = world->CreateBody(&bodyDef);
    
    b2Fixture* bodyFixture = baseBody->CreateFixture(&shapeDef);
    
    contactUserDataBase = new ContactUserData();
    contactUserDataBase->setObject(this, ContactUserData::EmitterBase);
    contactUserDataBase->setData1(1);
    bodyFixture->SetUserData(contactUserDataBase);

    b2Fixture* fixture = NULL;

    // The two wall needs to be dynamic so that they can be placed according
    // the joint parameters.
    bodyDef.type = b2_dynamicBody;

    /////// ##############################
    ////// Left -- WALL -- using a weld joint GREEN
    /////// ##############################
    leftWallVertexCount = 5;
    leftWallVertices = new b2Vec2[leftWallVertexCount];
    leftWallVertices[0].Set(-0.25f, -0.25f);
    leftWallVertices[1].Set(0.25f, -0.25f);
    leftWallVertices[2].Set(0.25f, 0.25f);
    leftWallVertices[3].Set(0.125f, 0.25f);
    leftWallVertices[4].Set(-0.25f, -0.15f);
    polygon.Set(leftWallVertices, leftWallVertexCount);
    
    leftWallBody = world->CreateBody(&bodyDef);
    fixture = leftWallBody->CreateFixture(&shapeDef);
    
    contactUserDataLeftWall = new ContactUserData();
    contactUserDataLeftWall->setObject(this, ContactUserData::EmitterLeftWall);
    contactUserDataLeftWall->setData1(10);
    fixture->SetUserData(contactUserDataLeftWall);
    
    b2WeldJointDef weldJointDef;
    weldJointDef.bodyA = baseBody;
    weldJointDef.bodyB = leftWallBody;
    weldJointDef.localAnchorA.Set(-0.45f, 0.1f);      // relative to A's origin
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
    rightWallVertices[2].Set(0.25f, -0.15f);
    rightWallVertices[3].Set(-0.1f, 0.25f);
    rightWallVertices[4].Set(-0.25f, 0.25f);
    polygon.Set(rightWallVertices, rightWallVertexCount);
    
    rightWallBody = world->CreateBody(&bodyDef);
    fixture = rightWallBody->CreateFixture(&shapeDef);
    
    contactUserDataRightWall = new ContactUserData();
    contactUserDataRightWall->setObject(this, ContactUserData::EmitterRightWall);
    contactUserDataRightWall->setData1(11);
    fixture->SetUserData(contactUserDataRightWall);
    
    weldJointDef.bodyA = baseBody;
    weldJointDef.bodyB = rightWallBody;
    weldJointDef.localAnchorA.Set(0.45f, 0.1f);// relative to A's origin
    weldJointDef.localAnchorB.Set(0.0f, -0.25f);// relative to B's origin
    // We don't want the wall colliding with the body.
    weldJointDef.collideConnected = false;
    world->CreateJoint(&weldJointDef);
    
    timerEmit = new TimerBase(this, 1);
    timerEmit->setInterval(3000000L);
    
    timerQueueDelay = new TimerBase(this, 2);
    timerQueueDelay->setInterval(500000L);
    
}

void Emitter::release(b2World* const world)
{
    world->DestroyBody(baseBody);
    baseBody = NULL;
    world->DestroyBody(leftWallBody);
    leftWallBody = NULL;
    world->DestroyBody(rightWallBody);
    rightWallBody = NULL;
    
    reset();
    
    delete [] leftWallVertices;
    delete [] rightWallVertices;
    delete [] baseVertices;
    delete timerEmit;
    delete timerQueueDelay;
}

void Emitter::draw()
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
    glColor4f(Utilities::Color_Orange[0], Utilities::Color_Orange[1], Utilities::Color_Orange[2], 0.2f);
	glDrawArrays(GL_TRIANGLE_FAN, 0, baseVertexCount);
    
    glColor4f(Utilities::Color_Orange[0], Utilities::Color_Orange[1], Utilities::Color_Orange[2], 1.0f);
	glDrawArrays(GL_LINE_LOOP, 0, baseVertexCount);
    
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
    glColor4f(Utilities::Color_Orange[0], Utilities::Color_Orange[1], Utilities::Color_Orange[2], 0.2f);
	glDrawArrays(GL_TRIANGLE_FAN, 0, leftWallVertexCount);
    
    glColor4f(Utilities::Color_Orange[0], Utilities::Color_Orange[1], Utilities::Color_Orange[2], 1.0f);
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
    glColor4f(Utilities::Color_Orange[0], Utilities::Color_Orange[1], Utilities::Color_Orange[2], 0.2f);
	glDrawArrays(GL_TRIANGLE_FAN, 0, rightWallVertexCount);
    
    glColor4f(Utilities::Color_Orange[0], Utilities::Color_Orange[1], Utilities::Color_Orange[2], 1.0f);
	glDrawArrays(GL_LINE_LOOP, 0, rightWallVertexCount);
    
    glPopMatrix();
    
    std::list<BoxCargo*>::iterator iter = particles.begin();
    
    while (iter != particles.end()) {
        BoxCargo* particle = *iter;
        particle->draw();
        ++iter;
    }

}
