//
//  MyContactListener.h
//  Box2DPong
//
//

#import "Box2D.h"
#import <vector>
#import <algorithm>
#import <string>
#import <list>

#import "IContactlistener.h"

class Box2dContactListener : public b2ContactListener {
private:
    std::list<IContactlistener*> listeners;

public:
    
    Box2dContactListener();
    ~Box2dContactListener();
    
	virtual void BeginContact(b2Contact* contact);
	virtual void EndContact(b2Contact* contact);
	virtual void PreSolve(b2Contact* contact, const b2Manifold* oldManifold);    
	virtual void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse);

    void subscribeListener(IContactlistener* listener);
    void unSubscribeListener(IContactlistener* listener);
    
private:
    std::string mapPointState(enum b2PointState);
    
};
