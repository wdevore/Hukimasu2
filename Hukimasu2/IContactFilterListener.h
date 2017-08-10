//
//  IContactFilterListener.h
//  Hukimasu2
//
//  Created by William DeVore on 7/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

class b2Fixture;

class IContactFilterListener {
public:
 	virtual bool shouldCollide(const b2Fixture* const fixtureA, const b2Fixture* const fixtureB) = 0;
};
