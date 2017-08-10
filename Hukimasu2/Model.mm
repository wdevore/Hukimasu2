//
//  Model.m
//  Hukimasu
//
//  Created by William DeVore on 5/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "Box2D.h"
#import "Model.h"
#import "LinearRotateControl.h"
#import "AngleRotateControl.h"
#import "StringUtilities.h"
#import "Utilities.h"

#import "Circle.h"
#import "CircleShip.h"
#import "TriangleShip.h"
#import "CatcherShip.h"
#import "Emitter.h"
#import "ActorGround.h"
#import "b2Vec2AnimatedProperty.h"
#import "floatAnimatedProperty.h"
#import "WorldScalePropertyAction.h"
#import "Box2dContactListener.h"
#import "Box2dContactFilterListener.h"
#import "BasicLane.h"
#import "SampleLaneA.h"
#import "Animator.h"

Model* Model::_instance = NULL;

Model::Model()
{
    StringUtilities::log("Model::Model");
    physicsWorld = NULL;
    _contactListener = NULL;
    iaPosition = NULL;
    iaScale = NULL;
    autoScrollRing = NULL;
    emitter = NULL;
}

Model::~Model()
{
}

void Model::init()
{
    StringUtilities::log("Model::init");
    
    overlayVisible = false;
    autoScrollVisible = false;
    panEnabled = false;
    zoomEnabled = false;
    anchorEnabled = false;
    
    enableClock(false);

    setWorldWidth(getViewWidth() / pixelToMeters);
    setWorldHeight(getViewHeight() / pixelToMeters);
    
    // Define a default gravity vector. It can be changed later.
    b2Vec2 gravity;
    gravity.Set(0.0f, 0.0f);
    gravityEnabled = false;
    
    // Do we want to let bodies sleep?
    // This will speed up the physics simulation
    bool doSleep = false;
    
    // Construct a world object, which will hold and simulate the rigid bodies.
    physicsWorld = new b2World(gravity, doSleep);
    physicsWorld->SetContinuousPhysics(true);

    // Create contact listener
    _contactListener = new Box2dContactListener();
    physicsWorld->SetContactListener(_contactListener);

    contactFilterListener = new Box2dContactFilterListener();
    physicsWorld->SetContactFilter(contactFilterListener);
    
    scaleCenter.x = 0.0f;
    scaleCenter.y = 0.0f;
    setScaleFactor(0.8f);

    mSCTransform.identity();
    
    iaPosition = new b2Vec2AnimatedProperty();
    // Setting the position to a positive value is the same as if the user dragged with a finger
    // to the upper right corner. It is in view-space coordinates.
    //iaPosition->setValue(b2Vec2(100.0f, 100.0f));
    iaPosition->setValue(b2Vec2(getViewWidth() / 2.0f, getViewHeight() / 2.0f));
    
    // Note: this Action will make a call to model's setScaleFactor()
    scalePropertyAction = new WorldScalePropertyAction();
    scalePropertyAction->setTargetOfAction(this);
    
    // This is an animated property that typically a viewZone uses.
    // iaScale property is an indirect object controlled by a timing framework.
    // If an Action is set on it then it is the action that controls the value.
    iaScale = new floatAnimatedProperty();
    iaScale->setAction(scalePropertyAction);

    setScale(0.5f);
    
    exitedAutoScrollArea = false;
    leftEdgeExited = false;
    rightEdgeExited = false;
    bottomEdgeExited = false;
    topEdgeExited = false;
    
    autoScrollRing = new Circle(getViewWidth() / 2, getViewHeight() / 2, getViewHeight() / 3);
    autoScrollRing->setColor(Utilities::Color_StealBlue[0], Utilities::Color_StealBlue[1], Utilities::Color_StealBlue[2], 1.0f);
    
    maxNumberOfLanes = 2;
    laneIndex = SIMPLE_A_LANE;
    createLane(laneIndex);
}

void Model::release()
{
    destroyLane();
    
    delete scalePropertyAction;
    scalePropertyAction = NULL;
    delete iaScale;
    iaScale = NULL;
    delete iaPosition;
    iaPosition = NULL;
    
    delete autoScrollRing;
    autoScrollRing = NULL;
    
    delete physicsWorld;
	physicsWorld = NULL;

    delete _contactListener;
    _contactListener = NULL;
    
    delete contactFilterListener;
    contactFilterListener = NULL;
    
    //delete _instance;
    //_instance = NULL;
}

void Model::reset(b2World* const world)
{
    lane->reset(world);
}

// This syncs both the action and property
void Model::setScale(float scale)
{
    // calls setScaleFactor() which sets the scale value used in the matrix
    scalePropertyAction->action(scale);
    
    // The property needs to match the scale action initially.
    setScaleAnimatedProperty(scale);
}

const b2Vec2& Model::getScaleCenter()
{
    return scaleCenter;
}

void Model::setScaleCenter(float x, float y)
{
    scaleCenter.Set(x, y);
    setTransformDirty();
}

void Model::setTranslation(float x, float y)
{
    b2Vec2 pos = iaPosition->getValue();
    pos.Set(x, y);
    iaPosition->setValue(pos);
    setTransformDirty();
}

void Model::setTranslationByDelta(float dx, float dy)
{
    b2Vec2 pos = iaPosition->getValue();
    setTranslation(pos.x - dx, pos.y - dy);
}

void Model::setScaleCenterByDelta(float dx, float dy)
{
    setScaleCenter(scaleCenter.x - dx, scaleCenter.y - dy);
    setTransformDirty();
}

// This is typically called by an Action's action method.
void Model::setScaleFactor(float factor)
{
    // Set the matrix scale value.
    scale = factor;
    
    setTransformDirty();
}

float Model::getScaleAnimatedProperty()
{
    return iaScale->getValue();
}

void Model::setScaleAnimatedProperty(float value)
{
    iaScale->setValue(value);
    setTransformDirty();
}

float Model::getMatrixScale()
{
    return mSCTransform.getUniformScale();
}

float Model::getPixelsToMetersRatio()
{
    return pixelToMeters;
}

void Model::setPixelsToMetersRatio(float v)
{
    pixelToMeters = v;
}

void Model::setViewWidth(float v)
{
    viewWidth = v;
    widthOffset = viewWidth * 0.2f;
}

float Model::getViewWidth()
{
    return viewWidth;
}

float Model::getViewWidthOffset()
{
    return widthOffset;
}

void Model::setViewHeight(float v)
{
    viewHeight = v;
    heightOffset = viewHeight * 0.2f;
}

float Model::getViewHeight()
{
    return viewHeight;
}

float Model::getViewHeightOffset()
{
    return heightOffset;
}

void Model::setWorldWidth(float v)
{
    worldWidth = v;
}

float Model::getWorldWidth()
{
    return worldWidth;
}

void Model::setWorldHeight(float v)
{
    worldHeight = v;
}

float Model::getWorldHeight()
{
    return worldHeight;
}

ILane* Model::getLane()
{
    return lane;
}

void Model::setGravity(const b2Vec2& gravity)
{
    physicsWorld->SetGravity(gravity);
    gravityEnabled = true;
}

void Model::setVerticalGravity(float force)
{
    b2Vec2 gravity(0.0f, force);
    physicsWorld->SetGravity(gravity);
    gravityEnabled = true;
}

void Model::turnGravityOff()
{
    b2Vec2 gravity(0.0f, 0.0f);
    physicsWorld->SetGravity(gravity);
    gravityEnabled = false;
}

bool Model::isGravityOn()
{
    return gravityEnabled;
}

void Model::enableClock(bool enable)
{
    clockEnabled = enable;
}

bool Model::isClockEnabled()
{
    return clockEnabled;
}

void Model::enablePan(bool enable)
{
    panEnabled = enable;
}

bool Model::isPanEnabled()
{
    return panEnabled;
}

void Model::enableZoom(bool enable)
{
    zoomEnabled = enable;
}

bool Model::isAnchorEnabled()
{
    return anchorEnabled;
}

void Model::enableAnchor(bool enable)
{
    anchorEnabled = enable;
}

bool Model::isZoomEnabled()
{
    return zoomEnabled;
}

void Model::previousLane()
{
    destroyLane();
    switch (laneIndex) {
        case BASIC_LANE:
            laneIndex = SIMPLE_A_LANE;
            break;
        case SIMPLE_A_LANE:
            laneIndex = BASIC_LANE;
            break;
        default:
            break;
    }
    createLane(laneIndex);
}

void Model::nextLane()
{
    destroyLane();
    switch (laneIndex) {
        case BASIC_LANE:
            laneIndex = SIMPLE_A_LANE;
            break;
        case SIMPLE_A_LANE:
            laneIndex = BASIC_LANE;
            break;
        default:
            break;
    }
    createLane(laneIndex);
}

void Model::createLane(eLanes eLane)
{
    switch (eLane) {
        case BASIC_LANE:
        {
            lane = new BasicLane();
            lane->init();
        }
            break;

        case SIMPLE_A_LANE:
        {
            lane = new SampleLaneA();
            lane->init();
        }
            break;
            
        default:
            break;
    }
}

void Model::destroyLane()
{
    lane->release(physicsWorld);
    delete lane;
    lane = NULL;
}

HuActor* Model::getActiveActor()
{
    return lane->getActiveActor();
}

TriangleShip* Model::buildSuit()
{
    spaceSuit = new TriangleShip();
    spaceSuit->setName("Triangle Ship");
    spaceSuit->thrusting(0, 0, -1, -1);
    
    spaceSuit->init(getPhysicsWorld());
    //rotateControl->setAnglePower(ship->getRotatePower());
    
    // The ship needs contact info from the physics engine.
    Box2dContactListener* contactListener = getWorldContactListener();
    spaceSuit->subscribeAsContactListener(contactListener);
    return spaceSuit;
}

CircleShip* Model::buildCircleShip()
{
    ship = new CircleShip();
    ship->setName("Circle Ship");
    ship->thrusting(0, 0, -1, -1);
    
    ship->init(getPhysicsWorld());
    //rotateControl->setAnglePower(ship->getRotatePower());
    
    // The ship needs contact info from the physics engine.
    Box2dContactListener* contactListener = getWorldContactListener();
    ship->subscribeAsContactListener(contactListener);
    return ship;
}

CatcherShip* Model::buildCatcherShip()
{
    catcherShip = new CatcherShip();
    catcherShip->setName("Catcher Ship");
    catcherShip->thrusting(0, 0, -1, -1);
    
    catcherShip->init(getPhysicsWorld());
    //rotateControl->setAnglePower(ship->getRotatePower());
    
    // The ship needs contact info from the physics engine.
    Box2dContactListener* contactListener = getWorldContactListener();
    catcherShip->subscribeAsContactListener(contactListener);
    return catcherShip;
}

Emitter* Model::buildEmitter()
{
    emitter = new Emitter();
    emitter->init(physicsWorld);
    return emitter;
}

ActorGround* Model::buildGround(std::list<edge>& edges)
{
    ground = new ActorGround();
    ground->init(physicsWorld, edges);
    return ground;
}

Animator* Model::buildPanAnimator()
{
    std::vector<b2Vec2> values;
    // Place holders
    values.push_back(b2Vec2(0.0f, 0.0f));       // Typically the start value in a basic 2 value animation
    values.push_back(b2Vec2(0.0f, 0.0f));       // Typically the end value in a basic 2 value animation
    KeyValues<b2Vec2>* keyValues = KeyValues<b2Vec2>::createFromb2Vectors(values);
    
    // keyValues is deleted by PropertySetterTimingTarget.
    // We need this target so we can adjust the KeyValues.
    // TODO create a factory for a default 2 vector property or constructor
    translationTarget = new PropertySetterTimingTarget<b2Vec2>(iaPosition, keyValues);
    
    // 1000000 = 1 second.
    animator = new Animator(2000000, translationTarget);
    animator->setAcceleration(0.6f);
    animator->setDeceleration(0.3f);
    
    return animator;
}

TriangleShip* Model::getSuit()
{
    return spaceSuit;
}

CircleShip* Model::getCircleShip()
{
    return ship;
}

CatcherShip* Model::getCatcherShip()
{
    return catcherShip;
}

Emitter* Model::getEmitter()
{
    return emitter;
}

ActorGround* Model::getGround()
{
    return ground;
}

Animator* Model::getPanAnimator()
{
    return animator;
}

void Model::destroySuit()
{
    spaceSuit->release(getPhysicsWorld());
    Box2dContactListener* contactListener = getWorldContactListener();
    contactListener->unSubscribeListener(spaceSuit);
    delete spaceSuit;
    spaceSuit = NULL;
}

void Model::destroyCircleShip()
{
    ship->release(getPhysicsWorld());
    Box2dContactListener* contactListener = getWorldContactListener();
    contactListener->unSubscribeListener(ship);
    delete ship;
    ship = NULL;
}

void Model::destroyCatcherShip()
{
    catcherShip->release(getPhysicsWorld());
    Box2dContactListener* contactListener = getWorldContactListener();
    contactListener->unSubscribeListener(catcherShip);
    delete catcherShip;
    catcherShip = NULL;
}

void Model::destroyEmitter()
{
    emitter->release(getPhysicsWorld());
    delete emitter;
    emitter = NULL;
}

void Model::destroyGround()
{
    ground->release(getPhysicsWorld());
    delete ground;
    ground = NULL;
}

void Model::destroyPanAnimator()
{
    // TODO clean up containers
    if (animator != NULL)
    {
        delete animator;
        animator = NULL;
        delete translationTarget;
        translationTarget = NULL;
    }
}

RotateControl* Model::getRotateControl()
{
    return lane->getRotateControl();
}

RotateControl* Model::createRotateControl(int index)
{
    RotateControl* control = NULL;
    
    switch (index) {
        case 0:
            control = new LinearRotateControl();
            break;
        case 1:
            control = new AngleRotateControl();
            break;
        default:
            break;
    }
    
    return control;
}

b2World* Model::getPhysicsWorld()
{
    return physicsWorld;
}

Box2dContactListener* Model::getWorldContactListener()
{
    return _contactListener;
}

Box2dContactFilterListener* Model::getWorldContactFilterListener()
{
    return contactFilterListener;
}


b2Vec2AnimatedProperty* Model::getWorldPositionProperty()
{
    return iaPosition;
}

void Model::setWorldPositionProperty(const b2Vec2& position)
{
    b2Vec2AnimatedProperty* iaProperty = getWorldPositionProperty();
    b2Vec2 wp = iaProperty->getValue();
    
    wp.x = wp.x + position.x;
    wp.y = wp.y + position.y;
    
    iaProperty->setValue(wp);
    setTransformDirty();
}

floatAnimatedProperty* Model::getWorldScaleProperty()
{
    return iaScale;
}

void Model::transform()
{
    //***************************************************************
    // BEGIN Approach "A"
    // This version is the matrix version of approach "B". It is limited in that
    // you can't move the scale center without the view shifting.
    //***************************************************************
    //Matrix4<float> mPosition;
    //mPosition.setTranslation(wPosition.x, wPosition.y, 0.0f);
    
    //Matrix4<float> mNegScaleCenter;
    //mNegScaleCenter.setTranslation(-scaleCenter.x, -scaleCenter.y, 0.0f);
    
    //Matrix4<float> mScale;
    //mScale.setScale(wScale, wScale, 0.0f);
    
    //Matrix4<float> mScaleCenter;
    //mScaleCenter.setTranslation(scaleCenter.x, scaleCenter.y, 0.0f);
    
    // Apply the mulplies in the order of OpenGL.
    //Matrix4<float> transform = mPosition * mScaleCenter * mScale * mNegScaleCenter;
    //glMultMatrixf(transform);
    //***************************************************************
    // END
    //***************************************************************
    
    //***************************************************************
    // BEGIN Approach "B"
    // This is the basic as done from opengl calls. It lacks state and as such
    // isn't any better that "A"
    //***************************************************************
    // glTranslatef(wPosition.x, wPosition.y, 0.0f);           //<--- mPosition
    // glTranslatef(scaleCenter.x, scaleCenter.y, 0.0f);     //<--- mScaleCenter
    // glScalef(wScale, wScale, 1.0f);                            //<--- mScale
    // glTranslatef(-scaleCenter.x, -scaleCenter.y, 0.0f);   //<--- mNegScaleCenter
    //***************************************************************
    // END
    //***************************************************************
    
    //***************************************************************
    // BEGIN Approach "C".
    // This version is a mix of OpenGL and matrices.
    //***************************************************************
    //glTranslatef(wPosition.x, wPosition.y, 0.0f);           //<--- mPosition
    
    //if (transformDirty == YES) {
    //    Matrix4<float> mScaleCenter;
    //    mScaleCenter.setTranslation(scaleCenter.x, scaleCenter.y, 0.0f);
    
    //    transform = transform * mScaleCenter;
    
    //    Matrix4<float> scaleTransform;
    //    scaleTransform.setScale(wScale);
    
    //    transform = transform * scaleTransform;
    
    //    Matrix4<float> mNegScaleCenter;
    //   mNegScaleCenter.setTranslation(-scaleCenter.x, -scaleCenter.y, 0.0f);
    
    //    transform = transform * mNegScaleCenter;
    
    //    transformDirty = NO;
    //}
    
    //glMultMatrixf(transform);
    //***************************************************************
    // END
    //***************************************************************
    
    //***************************************************************
    // BEGIN Approach "D"
    // This version is a mix. It is the correct way to zoom. It is
    // the same as "C" but uses only matrices.
    //***************************************************************
    if (transformDirty) {
        mTransform.identity();
        
        b2Vec2 pos = iaPosition->getValue();
        //    StringUtilities::log("=================================");
        //    
        mTransform.setTranslation(pos.x, pos.y, 0.0f);
        //    StringUtilities::log("mTransform A \n", mTransform.toString());
        //    StringUtilities::log("mSCTransform \n", mSCTransform.toString());
        //    StringUtilities::log("scaleCenter: ", scaleCenter);
        //    StringUtilities::log("scale: ", scale);
        //StringUtilities::log("pos: ", pos);
        
        // Do we override the current accumulated scale and set it directly?
        //StringUtilities::log("-------- DIRTY ----------");
        Matrix4f mScaleCenter;
        // scaleCenter is in VIEW-space
        mScaleCenter.setTranslation(scaleCenter.x, scaleCenter.y, 0.0f);
        
        Matrix4f scaleTransform;
        scaleTransform.setScale(scale);
        
        Matrix4f mNegScaleCenter;
        mNegScaleCenter.setTranslation(-scaleCenter.x, -scaleCenter.y, 0.0f);
        
        mSCTransform =  mSCTransform * mScaleCenter * scaleTransform * mNegScaleCenter;
        //        StringUtilities::log("mTransform \n", mTransform.toString());
        //        StringUtilities::log("mSCTransform \n", mSCTransform.toString());
        
        // We need to reset scale back to 1.0 because mSCTransform is accumulative.
        scale = 1.0f;
        
        // Now that we have rebuilt the transform matrix is it no longer dirty/stale.
        transformDirty = false;
        
        mTransform = mTransform * mSCTransform;
        //StringUtilities::log("mTransform B \n", mTransform.toString());
    }
    
    //***************************************************************
    // END
    //***************************************************************
}

void Model::resetMatrix()
{
    mSCTransform.identity();
    setTransformDirty();
}

Matrix4f Model::getTransform()
{
    return mTransform;
}

void Model:: setTransformDirty()
{
    transformDirty = true;
}    

void Model::worldToViewSpace(const b2Vec2& wPoint, b2Vec2& vPoint)
{
    // Transfer to vector for use with the Matrix library. Note: the last component
    // must be a 1.0f in order to be homogenious. Linear transformations only work
    // homogenious coords.
    // "* PTM_RATIO" this maps from world to pixel space.
    Vector4f pixelPoint(wPoint.x * PTM_RATIO, wPoint.y * PTM_RATIO, 0.0f, 1.0f);
    
    // Now transform the PIXEL-space coord to VIEW-space
    Vector4f viewPoint = mTransform * pixelPoint;
    vPoint.Set(viewPoint.x, viewPoint.y);
}

void Model::viewToWorldSpace(const b2Vec2& vPoint, b2Vec2& wPoint)
{
    Vector4f vsPoint(vPoint.x, vPoint.y, 0.0f, 1.0f);
    Vector4f wsPoint = mTransform.inverse() * vsPoint;
    wPoint.Set(wsPoint.x / PTM_RATIO, wsPoint.y / PTM_RATIO);
}

void Model::worldToPTMSpace(const b2Vec2& point, b2Vec2& wPoint)
{
    wPoint.Set(point.x * PTM_RATIO, point.y * PTM_RATIO);
}

void Model::PTMToworldSpace(const b2Vec2& point, b2Vec2& wPoint)
{
    wPoint.Set(point.x / PTM_RATIO, point.y / PTM_RATIO);
}

// NOTE NOT WORKING YET
void Model::worldLayerSpaceToWorldSpace(const b2Vec2& point, b2Vec2& wPoint)
{
    Vector4f wlPoint(point.x, point.y, 0.0f, 1.0f);
    Vector4f wsPoint = mTransform.inverse() * wlPoint;
    
    wPoint.Set(wsPoint.x / PTM_RATIO, wsPoint.y / PTM_RATIO);
}

// NOTE NOT WORKING YET
void Model::worldLayerSpaceToViewSpace(const b2Vec2& point, b2Vec2& vPoint)
{
    Vector4f vwlPoint(point.x, point.y, 0.0f, 1.0f);
    Vector4f wsPoint = mTransform.inverse() * vwlPoint;
    
    vPoint.Set(wsPoint.x, wsPoint.y);
}

bool Model::autoScrollAreaExited(const b2Vec2& position)
{
    exitedAutoScrollArea = false;
    leftEdgeExited = false;
    rightEdgeExited = false;
    bottomEdgeExited = false;
    topEdgeExited = false;

    // Check left edge plane.
    if (position.x < widthOffset) {
        leftEdgeExited = true;
        exitedAutoScrollArea = true;
    }
    
    // Bottom edge plane
    if (position.y < heightOffset) {
        bottomEdgeExited = true;
        exitedAutoScrollArea = true;
    }
    
    // Right edge plane
    if (position.x > (viewWidth - widthOffset)) {
        rightEdgeExited = true;
        exitedAutoScrollArea = true;
    }
    
    // Top edge plane
    if (position.y > (viewHeight - heightOffset)) {
        topEdgeExited = true;
        exitedAutoScrollArea = true;
    }

    return exitedAutoScrollArea;
}

Model::EdgeExited Model::whichEdgeExited()
{
    if (leftEdgeExited)
        return LEFTEDGE;
    if (rightEdgeExited)
        return RIGHTEDGE;
    if (bottomEdgeExited)
        return BOTTOMEDGE;
    if (topEdgeExited)
        return TOPEDGE;
    return NONE;
}

bool Model::autoScrollCircleAreaExited(const b2Vec2& position)
{
    exitedAutoScrollArea = false;
    
    if (!autoScrollRing->pointInside(position)) {
        exitedAutoScrollArea = true;
    }
    
    return exitedAutoScrollArea;
}

Circle* Model::getAutoScrollCircle()
{
    return autoScrollRing;
}

void Model::setOverlayVisible(bool visible)
{
    overlayVisible = visible;
}

bool Model::isOverlayVisible()
{
    return overlayVisible;
}

void Model::setAutoScrollVisible(bool visible)
{
    autoScrollVisible = visible;
}

bool Model::isAutoScrollVisible()
{
    return autoScrollVisible;
}
