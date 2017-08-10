//
//  MyContactListener.m
//  Box2DPong
//
//
#import "StringUtilities.h"
#import <iostream>
#import "Box2dContactListener.h"

Box2dContactListener::Box2dContactListener() {
}

Box2dContactListener::~Box2dContactListener()
{
    StringUtilities::log("Box2dContactListener::~Box2dContactListener");
}

// The; sequence is:
// BeginContact
// Presolve
// Postsolve
// ... repeat Pre/Post
// EndContact

void Box2dContactListener::BeginContact(b2Contact* contact) {
    // We need to copy out the data because the b2Contact passed in
    // is reused.
    
    std::list<IContactlistener*>::iterator iter = listeners.begin();
    
    while (iter != listeners.end()) {
        IContactlistener* listener = *iter;
        
        listener->beginContact(contact);
        ++iter;
    }
}

void Box2dContactListener::EndContact(b2Contact* contact) {
    std::list<IContactlistener*>::iterator iter = listeners.begin();
    
    while (iter != listeners.end()) {
        IContactlistener* listener = *iter;
        
        listener->endContact(contact);
        ++iter;
    }
}

void Box2dContactListener::PreSolve(b2Contact* contact, const b2Manifold* oldManifold) {
    std::list<IContactlistener*>::iterator iter = listeners.begin();
    
    while (iter != listeners.end()) {
        IContactlistener* listener = *iter;
        
        listener->preSolve(contact, oldManifold);
        ++iter;
    }
}

void Box2dContactListener::PostSolve(b2Contact* contact, const b2ContactImpulse* impulse) {
    std::list<IContactlistener*>::iterator iter = listeners.begin();
    
    while (iter != listeners.end()) {
        IContactlistener* listener = *iter;
        
        listener->postSolve(contact, impulse);
        ++iter;
    }
}

std::string Box2dContactListener::mapPointState(b2PointState state)
{
    std::string s = "";
    switch (state) {
        case b2_nullState:
            s = "b2_nullState";
            break;
        case b2_addState:
            s = "b2_addState";
            break;
        case b2_persistState:
            s = "b2_persistState";
            break;
        case b2_removeState:
            s = "b2_removeState";
            break;
            
        default:
            break;
    }
    return s;
}

void Box2dContactListener::subscribeListener(IContactlistener *listener)
{
    std::list<IContactlistener*>::iterator iter = listeners.begin();
    
    bool found = false;
    
    while (iter != listeners.end()) {
        IContactlistener* _listener = *iter;
        if (_listener == listener) {
            found = true;
            break;
        }
        ++iter;
    }
    
    if (!found) {
        listeners.push_back(listener);
    }

}

void Box2dContactListener::unSubscribeListener(IContactlistener *listener)
{
    listeners.remove(listener);
}