//
//  AContact.h
//  Hukimasu2
//
//  Created by William DeVore on 7/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

struct AContact {
    
    b2Fixture *fixtureA;
    b2Fixture *fixtureB;
    b2WorldManifold worldManifold;

    bool operator==(const AContact& other) const
    {
        return (fixtureA == other.fixtureA) && (fixtureB == other.fixtureB);
    }
    
};
