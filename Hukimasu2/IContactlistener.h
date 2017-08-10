//
//  IContactlistener.h
//  Hukimasu2
//
//  Created by William DeVore on 7/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

class b2Contact;
class b2Manifold;
class b2ContactImpulse;

class IContactlistener {
public:
    virtual void beginContact(b2Contact* contact) = 0;
    virtual void endContact(b2Contact* contact) = 0;
    virtual void preSolve(b2Contact* contact, const b2Manifold* oldManifold) = 0;
    virtual void postSolve(b2Contact* contact, const b2ContactImpulse* impulse) = 0;
};
