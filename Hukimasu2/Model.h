//
//  Model.h
//  Hukimasu
//
//  Created by William DeVore on 5/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "vmath.h"
#import "Box2D.h"
#import "Edge.h"
#import <list>
#import "PropertySetterTimingTarget.h"

const double PTM_RATIO = 32.0;

class HuActor;
class ActorShip;
class RotateControl;
class ActorGround;
class b2Vec2AnimatedProperty;
class floatAnimatedProperty;
class WorldScalePropertyAction;
class Circle;
class Box2dContactListener;
class Box2dContactFilterListener;
class ILane;
class TriangleShip;
class CircleShip;
class CatcherShip;
class Emitter;
class Animator;

class Model {
public:
    // Which edge was crossed
    enum EdgeExited {
        NONE,
        LEFTEDGE,
        RIGHTEDGE,
        TOPEDGE,
        BOTTOMEDGE
    };
    
    // Lane enumerations
    enum eLanes {
        BASIC_LANE,
        SIMPLE_A_LANE
    };

    // Actors to create
    enum eActors {
        CIRCLE_SHIP,
        TRIANGLE_SHIP,
        CATCHER_SHIP,
        EMITTER
    };
    

private:
    static Model* _instance;
    
    float viewWidth;
    float viewHeight;
    
    // These values are the view/PTM_RATIO
    float worldWidth;
    float worldHeight;

    //*********************************
    // Physics stuff
    //*********************************
    b2World* physicsWorld;
    Box2dContactListener* _contactListener;
    Box2dContactFilterListener* contactFilterListener;
    
    float pixelToMeters;
    
    //*********************************
    // World objects
    //*********************************
    TriangleShip* spaceSuit;
    CircleShip* ship;
    CatcherShip* catcherShip;
    Emitter* emitter;
    ActorGround* ground;

    //*********************************
    // WorldLayer transform stuff
    //*********************************
    bool transformDirty;
    Matrix4f mSCTransform;
    // Comlete transform that includes translation of world and scale center.
    Matrix4f mTransform;
    
    b2Vec2 scaleCenter;
    // This is an animated property of the world position in VIEW-space
    b2Vec2AnimatedProperty* iaPosition;
    // START ------------------------------------------------------
    // An animator to animate the world's translation property vector
    Animator* animator;
    
    // This a timing target of the Animator object. Timing events
    // are sent to it.
    PropertySetterTimingTarget<b2Vec2>* translationTarget;
    // END ------------------------------------------------------
    

    //***********************************
    //** Scale/Zoom
    //***********************************
    // This is the scale while in the zone. An animator will animate
    // towards this value.
    floatAnimatedProperty* iaScale;
    WorldScalePropertyAction* scalePropertyAction;
    
    // Zoom scaling around scaleCenter
    float scale;

    // Offsets from VIEW-space outer edges
    float widthOffset;
    float heightOffset;

    // Has an object exited the auto scroll area. This
    // is typically the ship.
    bool exitedAutoScrollArea;
    // The edges where the object exited through
    bool leftEdgeExited;
    bool rightEdgeExited;
    bool bottomEdgeExited;
    bool topEdgeExited;

    bool autoScrollVisible;
    Circle* autoScrollRing;

    bool overlayVisible;
    
    eLanes laneIndex;
    int maxNumberOfLanes;
    ILane* lane;

    // controls if tick() method is completes
    bool clockEnabled;
    bool gravityEnabled;
    bool panEnabled;
    bool zoomEnabled;
    bool anchorEnabled;
    
protected:
    Model();

public:
    ~Model();
    
    static Model* instance() {
        if (_instance == NULL) {
            _instance = new Model;
        }
        return _instance;
    }
    
    void init();
    void release();
    void reset(b2World* const world);
    
    void setViewWidth(float v);
    float getViewWidth();
    float getViewWidthOffset();
    
    void setViewHeight(float v);
    float getViewHeight();
    float getViewHeightOffset();
    
    void setWorldWidth(float v);
    float getWorldWidth();
    
    void setWorldHeight(float v);
    float getWorldHeight();
    
    void setGravity(const b2Vec2& gravity);
    void setVerticalGravity(float gravity);
    void turnGravityOff();
    bool isGravityOn();
    
    void enableClock(bool enable);
    bool isClockEnabled();
    
    void enableZoom(bool enable);
    bool isZoomEnabled();
    
    void enablePan(bool enable);
    bool isPanEnabled();
    
    void enableAnchor(bool enable);
    bool isAnchorEnabled();
    
    ILane* getLane();
    void previousLane();
    void nextLane();
    void createLane(eLanes lane);
    void destroyLane();

    // ##########################################
    // ## Builders
    // ##########################################
    TriangleShip* buildSuit();
    CircleShip* buildCircleShip();
    CatcherShip* buildCatcherShip();
    Emitter* buildEmitter();
    ActorGround* buildGround(std::list<edge>& edges);
    
    Animator* buildPanAnimator();
    
    TriangleShip* getSuit();
    CircleShip* getCircleShip();
    CatcherShip* getCatcherShip();
    Emitter* getEmitter();
    ActorGround* getGround();
    Animator* getPanAnimator();
    
    // ##########################################
    // ## Destroyers
    // ##########################################
    void destroySuit();
    void destroyCircleShip();
    void destroyCatcherShip();
    void destroyEmitter();
    void destroyGround();
    void destroyPanAnimator();
    
    HuActor* getActiveActor();
    
    RotateControl* createRotateControl(int index);
    RotateControl* getRotateControl();
    
    b2World* getPhysicsWorld();
    Box2dContactListener* getWorldContactListener();
    Box2dContactFilterListener* getWorldContactFilterListener();
    
    // This animated property is controlled by an auto scroll region.
    // When the ship exits it the animator moves the ship back
    // to the center.
    b2Vec2AnimatedProperty* getWorldPositionProperty();
    void setWorldPositionProperty(const b2Vec2& position);
    floatAnimatedProperty* getWorldScaleProperty();
    
    float getPixelsToMetersRatio();
    void setPixelsToMetersRatio(float v);
    
    void setScale(float scale);
    const b2Vec2& getScaleCenter();
    void setScaleCenter(float x, float y);
    void setScaleCenterByDelta(float dx, float dy);
    float getScaleAnimatedProperty();
    void setScaleAnimatedProperty(float value);
    
    void transform();
    Matrix4f getTransform();
    void setTransformDirty();
    void resetMatrix();
    
    void setTranslation(float x, float y);
    void setTranslationByDelta(float dx, float dy);
    void setScaleFactor(float factor);
    float getMatrixScale();
    
    void worldToViewSpace(const b2Vec2& wPoint, b2Vec2& vPoint);
    void viewToWorldSpace(const b2Vec2& vPoint, b2Vec2& wPoint);
    
    void worldToPTMSpace(const b2Vec2& point, b2Vec2& pPoint);
    void PTMToworldSpace(const b2Vec2& point, b2Vec2& pPoint);

    // NOT WORKING
    void worldLayerSpaceToWorldSpace(const b2Vec2& point, b2Vec2& wPoint);
    void worldLayerSpaceToViewSpace(const b2Vec2& point, b2Vec2& vPoint);
    
    // position is in VIEW-space
    bool autoScrollAreaExited(const b2Vec2& position);
    EdgeExited whichEdgeExited();

    // position is in VIEW-space
    bool autoScrollCircleAreaExited(const b2Vec2& position);
    Circle* getAutoScrollCircle();
    
    void setOverlayVisible(bool visible);
    bool isOverlayVisible();

    void setAutoScrollVisible(bool visible);
    bool isAutoScrollVisible();
    
};
