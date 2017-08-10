//
//  Box2dContactFilterListener.h
//  Hukimasu2
//
//  Created by William DeVore on 7/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Box2D.h"
#import "IContactFilterListener.h"

class Box2dContactFilterListener : public b2ContactFilter {
private:
    IContactFilterListener* listener;
    
public:
    
    Box2dContactFilterListener();
    ~Box2dContactFilterListener();
    
	/// Return true if contact calculations should be performed between these two shapes.
	/// @warning for performance reasons this is only called when the AABBs begin to overlap.
	virtual bool ShouldCollide(b2Fixture* fixtureA, b2Fixture* fixtureB);
    
    void subscribeListener(IContactFilterListener* listener);
    void unSubscribeListener();

};
