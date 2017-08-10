//
//  WorldLayer.mm
//  Hukimasu
//
//  Created by William DeVore on 3/26/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//
#import <iostream>
#import <vector>

#import "StringUtilities.h"
#import "Utilities.h"

// Import the interfaces
#import "WorldLayer.h"
//#import "AngleRotateControl.h"
//#import "LinearRotateControl.h"
#import "GameScene.h"
#import "OverlayLayer.h"
//#import "LinearInterpolator.h"
//#import "SplineInterpolator.h"
//#import "DiscreteInterpolator.h"

//#import "PropertySetterTimingTarget.h"
//#import "SimpleTestPropertyFloat.h"
//#import "b2Vec2AnimatedProperty.h"
//#import "floatAnimatedProperty.h"

#import "ILane.h"

#import "b2Math.h"
#import "TransformUtils.h"

#import "Model.h"
#import "CircleShip.h"
//#import "ActorGround.h"

//#import "ViewZone.h"
#import "Circle.h"

#import "SimpleButton.h"

// HelloWorldLayer implementation
@implementation WorldLayer

-(void) postInit
{
    //----------------------------------------
    // Model
    //----------------------------------------
    model = Model::instance();
    model->setPixelsToMetersRatio(PTM_RATIO);
    model->setViewWidth(screenWidth);
    model->setViewHeight(screenHeight);
    
    model->init();
    
    GameScene* gs = (GameScene*) self.parent;
    [gs setModel:model];
    b2World* world = model->getPhysicsWorld();

    // Debug Draw functions
    m_debugDraw = new GLESDebugDraw(PTM_RATIO);
    world->SetDebugDraw(m_debugDraw);
    
    uint32 flags = 0;
    flags += b2DebugDraw::e_shapeBit;
    flags += b2DebugDraw::e_jointBit;
    //		flags += b2DebugDraw::e_aabbBit;
    //flags += b2DebugDraw::e_pairBit;
    flags += b2DebugDraw::e_centerOfMassBit;
    m_debugDraw->SetFlags(flags);		
    
    //#####################################
    //## TEMP DEBUG STUFF. REMOVED WHEN RELEASED
    //#####################################
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if ((self = [super init])) {
		// DEBUG
        debugCount = 0;
        aStep = NO;
        resetting = NO;
        
		// enable touches
		self.isTouchEnabled = YES;
		
		// enable accelerometer
		self.isAccelerometerEnabled = NO;
		
		CGSize screenSize = [CCDirector sharedDirector].winSize;
        screenWidth = screenSize.width;
        screenHeight = screenSize.height;
		CCLOG(@"Screen width %0.2f screen height %0.2f", screenSize.width, screenSize.height);
		
        xAxis = new b2Vec2[2];
        yAxis = new b2Vec2[2];
        xAxis[0].Set(0.0f, 0.0f);
        xAxis[1].Set(1.0f, 0.0f);
        yAxis[0].Set(0.0f, 0.0f);
        yAxis[1].Set(0.0f, 1.0f);

        anchorXAxis = new b2Vec2[2];
        anchorYAxis = new b2Vec2[2];
        anchorXAxis[0].Set(-1.0f, 0.0f);
        anchorXAxis[1].Set(1.0f, 0.0f);
        anchorYAxis[0].Set(0.0f, -1.0f);
        anchorYAxis[1].Set(0.0f, 1.0f);

		[self schedule: @selector(tick:)];
	}
	return self;
}

// visit() called first then tick()
-(void) visit
{
    glPushMatrix();
    
    [self transform];
    
    [self draw];

	glPopMatrix();

}

-(void) transform
{	
    // Model transform
    model->transform();
    
    glMultMatrixf(model->getTransform());

}

-(void) draw
{

	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states:  GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
    ILane* lane = model->getLane();
    lane->draw();
    
    // Draw the X,Y axis at 0,0 origin point.
    glVertexPointer(2, GL_FLOAT, 0, xAxis);
    glColor4f(Utilities::Color_Red[0], Utilities::Color_Red[1], Utilities::Color_Red[2], 1.0f);
    
    glPushMatrix();
    glTranslatef(0.0f, 0.0f, 0.0f);
    glScalef(20.0f, 1.1f, 0.0f);
	glDrawArrays(GL_LINES, 0, 2);
    glPopMatrix();

    glVertexPointer(2, GL_FLOAT, 0, yAxis);
    glColor4f(Utilities::Color_Blue[0], Utilities::Color_Blue[1], Utilities::Color_Blue[2], 1.0f);
    
    glPushMatrix();
    glTranslatef(0.0f, 0.0f, 0.0f);
    glScalef(1.1f, 20.0f, 0.0f);
	glDrawArrays(GL_LINES, 0, 2);
    glPopMatrix();
    
    // Draw anchor
    glColor4f(Utilities::Color_White[0], Utilities::Color_White[1], Utilities::Color_White[2], 1.0f);
    glVertexPointer(2, GL_FLOAT, 0, anchorXAxis);
 
	// restore default GL states
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
}

// visit() called first then tick()
-(void) tick: (ccTime) dt
{
    long delta = Utilities::getTimeDelta();
    
    //StringUtilities::log("WorldLayer::tick elapsedCount ", delta);
    Utilities::updateTimingSources(delta);
    
    if (model->isClockEnabled() == NO && aStep == NO) {
        return;
    }
    
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
    ILane* lane = model->getLane();
    
    lane->beforeStep(delta);

    b2World* world = model->getPhysicsWorld();

    // We reset once before the physics engine performs a step and then
    // again after. This way the physics engine can recognize the velocities
    // changes.
//    if (resetting)
//    {
//        model->reset(world);
//    }

	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(dt, velocityIterations, positionIterations);

//    if (resetting)
//    {
//        model->reset(world);
//        resetting = NO;
//    }

    lane->afterStep(delta);
    
    //###########################################
    // Now that the physics engine has completed calculations we can
    // perform game logic based on the results
    //###########################################
    
    //**************************************************
    // ***** This version scrolls the view using an animator.
    //**************************************************
    // Check's ship position and scroll the world if it has exited the scroll region.
    // Disable this check while the animation is playing and re-enable when
    // the animation is done.
    // The animation will translate the ship's exit point to the VIEW-space origin.
    //b2Vec2 shipW = ship->getPosition();   // This value is in WORLD-space
    //b2Vec2 viewPoint = Model::instance()->worldToViewSpace(shipW);
    
    //bool exited = Model::instance()->autoScrollAreaExited(viewPoint);
    //if (exited && !animator->isRunning()) {
        // setup animator values and start the animator.
    //    KeyValues<b2Vec2>* keyValues = translationTarget->getKeyValues();

        // We want to move the view's center to the current location of the ship
    //    b2Vec2 delta(240.0f - viewPoint.x, 160.0f - viewPoint.y);
        
    //    b2Vec2AnimatedProperty* iaProperty = Model::instance()->getWorldPositionProperty();
    //    b2Vec2 wp = iaProperty->getValue();

        // The begin value is the current location of the world which is in VIEW-space coords
    //    b2Vec2* value = new b2Vec2(wp);
    //    keyValues->setBeginValue(value);

    //    value = new b2Vec2(wp.x + delta.x, wp.y + delta.y);
    //    keyValues->setEndValue(value);
        
    //    animator->start();
    //}
    //**************************************************
    //** END
    //**************************************************
    
    //**************************************************
    // ** This version just slides the view along with the ship
    //**************************************************
    HuActor* ship = model->getActiveActor();
    b2Vec2 shipW = ship->getPosition();   // This value is in WORLD-space
    b2Vec2 viewPoint;
    model->worldToViewSpace(shipW, viewPoint);
    
    if (model->autoScrollCircleAreaExited(viewPoint)) {
        // Move view such that the ship is back in the auto area
        // Need to find vector from ship to circle center. Then
        // move ship towards center.
        
        Circle* autoScrollCircle = model->getAutoScrollCircle();
        b2Vec2 rPos = autoScrollCircle->getCenter();

        float distance = autoScrollCircle->distanceFromEdge(viewPoint);
        b2Vec2 vector(rPos.x - viewPoint.x, rPos.y - viewPoint.y);
        vector.Normalize();
        vector *= distance;
        
        model->setWorldPositionProperty(vector);
    }
    //**************************************************
    //** END
    //**************************************************

    // The default is to clear forces.
    // world->ClearForces();
    
    aStep = NO;
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	for( UITouch *touch in touches ) {
		touchLocation = [touch locationInView: [touch view]];
		
		touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];

        model->getLane()->touchBegin(touchLocation.x, touchLocation.y);
    }

    deltaDrag.x = 0.0f;
    deltaDrag.y = 0.0f;

}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // When the overlay is visible drags don't mean anything.
    if (model->isOverlayVisible())
        return;
    
    // This method is like a drag.
	for( UITouch *touch in touches )
    {
        
		CGPoint location2 = [touch locationInView: [touch view]];
		
		location2 = [[CCDirector sharedDirector] convertToGL: location2];

        deltaDrag.x = touchLocation.x - location2.x;
        deltaDrag.y = touchLocation.y - location2.y;

        if (model->isPanEnabled())
        {
            // NOTE: This drag delta is in VIEW-space.
            model->setTranslationByDelta(deltaDrag.x, deltaDrag.y);
        }
        
        if (model->isZoomEnabled())
        {
            if (deltaDrag.y < 0.0f) {
                model->setScaleFactor(1.05f);
            } else {
                model->setScaleFactor(0.95f);
            }
        }
        
        if (model->isAnchorEnabled())
        {
            //Model::instance()->setScaleCenterByDelta(deltaDrag.x, deltaDrag.y);
            b2Vec2 tsPoint(touchLocation.x, touchLocation.y);
            b2Vec2 wsPoint;
            model->viewToWorldSpace(tsPoint, wsPoint);
            b2Vec2 wlPoint;
            model->worldToPTMSpace(wsPoint, wlPoint);
            model->setScaleCenter(wlPoint.x, wlPoint.y);
        }
        
        if (!model->isPanEnabled() && !model->isZoomEnabled() && !model->isAnchorEnabled())
        {
            model->getLane()->touchMove(location2.x, location2.y, deltaDrag.x, deltaDrag.y);
        }
        
        touchLocation.x = location2.x;
        touchLocation.y = location2.y;
    }
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	for( UITouch *touch in touches ) {
		touchLocation = [touch locationInView: [touch view]];
		
		touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
        
        model->getLane()->touchEnd(touchLocation.x, touchLocation.y);

        deltaDrag.x = 0.0f;
        deltaDrag.y = 0.0f;
	}
}

- (CGPoint) getTouchLocation
{
    return touchLocation;
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{	
	static float prevX=0, prevY=0;
	
	//#define kFilterFactor 0.05f
#define kFilterFactor 1.0f	// don't use filter. the code is here just as an example
	
	float accelX = (float) acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
	float accelY = (float) acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
	
	prevX = accelX;
	prevY = accelY;
	
	// accelerometer values are in "Portrait" mode. Change them to Landscape left
	// multiply the gravity by 10
	b2Vec2 gravity( -accelY * 10, accelX * 10);
	
	//world->SetGravity( gravity );
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
    model->destroyPanAnimator();
    Utilities::release();
    
	// in case you have something to dealloc, do it in this method
	
	delete m_debugDraw;
    
    delete [] xAxis;
    delete [] yAxis;

    delete [] anchorXAxis;
    delete [] anchorYAxis;

    //#####################################
    //## TEMP DEBUG STUFF. REMOVED WHEN RELEASED
    //#####################################
    
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
