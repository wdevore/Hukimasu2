//
//  OverlayNode.m
//  Hukimasu
//
//  Created by William DeVore on 4/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OverlayLayer.h"
#import "GameScene.h"
#import "RotateControl.h"
#import "ActorShip.h"
#import "Circle.h"
#import "Utilities.h"
#import "SimpleButton.h"
#import "Model.h"
#import "ILane.h"

@implementation OverlayLayer

-(void) postInit
{
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if ((self = [super init])) {
        model = Model::instance();

		// enable touches
		self.isTouchEnabled = YES;
		
		CGSize screenSize = [CCDirector sharedDirector].winSize;
        screenWidth = screenSize.width;
        screenHeight = screenSize.height;
		//CCLOG(@"OverlayNode: Screen width %0.2f screen height %0.2f", screenSize.width, screenSize.height);
		
        horzLine = new b2Vec2[2];
        vertLine = new b2Vec2[2];
        horzLine[0].Set(0.0f, 0.0f);
        horzLine[1].Set(1.0f, 0.0f);
        vertLine[0].Set(0.0f, 0.0f);
        vertLine[1].Set(0.0f, 1.0f);
        
        anchorXAxis = new b2Vec2[2];
        anchorYAxis = new b2Vec2[2];
        anchorXAxis[0].Set(-1.0f, 0.0f);
        anchorXAxis[1].Set(1.0f, 0.0f);
        anchorYAxis[0].Set(0.0f, -1.0f);
        anchorYAxis[1].Set(0.0f, 1.0f);
        
        float widthOffset = Model::instance()->getViewWidthOffset();
        float heightOffset = Model::instance()->getViewHeightOffset();

        leftEdge = new b2Vec2[2];
        leftEdge[0].Set(widthOffset, screenHeight - heightOffset);
        leftEdge[1].Set(widthOffset, heightOffset);
        
        bottomEdge = new b2Vec2[2];
        bottomEdge[0].Set(widthOffset, heightOffset);
        bottomEdge[1].Set(screenWidth - widthOffset, heightOffset);
        
        rightEdge = new b2Vec2[2];
        rightEdge[0].Set(screenWidth - widthOffset, heightOffset);
        rightEdge[1].Set(screenWidth - widthOffset, screenHeight - heightOffset);
        
        topEdge = new b2Vec2[2];
        topEdge[0].Set(screenWidth - widthOffset, screenHeight - heightOffset);
        topEdge[1].Set(widthOffset, screenHeight - heightOffset);
        
        float hSize = screenHeight / 4.0f;
        float wSize = screenWidth / 5.0f;

        menuButton = SimpleButton::createButton(@"Menu", 24.0f, wSize, hSize, 2, 0);
        [self addChild:menuButton->getLabel()];
        menuButton->setColor(Utilities::Color_Blue[0], Utilities::Color_Blue[1], Utilities::Color_Blue[2], Utilities::Color_Blue[3]);
        menuButton->turnOn();
        buttons.push_back(menuButton);
        
        debugButton = SimpleButton::createButton(@"1Debug", 24.0f, wSize, hSize, 3, 1);
        [self addChild:debugButton->getLabel()];
        buttons.push_back(debugButton);
        
        resetButton = SimpleButton::createButton(@"Reset", 24.0f, wSize, hSize, 3, 0);
        [self addChild:resetButton->getLabel()];
        resetButton->setColor(Utilities::Color_Orange[0], Utilities::Color_Orange[1], Utilities::Color_Orange[2], Utilities::Color_Orange[3]);
        resetButton->turnOn();
        buttons.push_back(resetButton);

        menu1Button = SimpleButton::createButton(@"States", 24.0f, wSize, hSize, 0, 3);
        [self addChild:menu1Button->getLabel()];
        menu1Button->setColor(Utilities::Color_Green[0], Utilities::Color_Green[1], Utilities::Color_Green[2], Utilities::Color_Green[3]);
        menu1Button->turnOn();
        buttons.push_back(menu1Button);

        menu2Button = SimpleButton::createButton(@"Menu2", 24.0f, wSize, hSize, 1, 3);
        [self addChild:menu2Button->getLabel()];
        menu2Button->setColor(Utilities::Color_Green[0], Utilities::Color_Green[1], Utilities::Color_Green[2], Utilities::Color_Green[3]);
        menu2Button->turnOn();
        buttons.push_back(menu2Button);

        menu3Button = SimpleButton::createButton(@"Menu3", 24.0f, wSize, hSize, 2, 3);
        [self addChild:menu3Button->getLabel()];
        menu3Button->setColor(Utilities::Color_Green[0], Utilities::Color_Green[1], Utilities::Color_Green[2], Utilities::Color_Green[3]);
        menu3Button->turnOn();
        buttons.push_back(menu3Button);
        
        menu4Button = SimpleButton::createButton(@"Menu4", 24.0f, wSize, hSize, 3, 3);
        [self addChild:menu4Button->getLabel()];
        menu4Button->setColor(Utilities::Color_Green[0], Utilities::Color_Green[1], Utilities::Color_Green[2], Utilities::Color_Green[3]);
        menu4Button->turnOn();
        buttons.push_back(menu4Button);
        
        menu5Button = SimpleButton::createButton(@"Menu5", 24.0f, wSize, hSize, 4, 3);
        [self addChild:menu5Button->getLabel()];
        menu5Button->setColor(Utilities::Color_Green[0], Utilities::Color_Green[1], Utilities::Color_Green[2], Utilities::Color_Green[3]);
        menu5Button->turnOn();
        buttons.push_back(menu5Button);
        
        shutdownButton = SimpleButton::createButton(@"Shutdown", 20.0f, wSize, hSize, 4, 0);
        [self addChild:shutdownButton->getLabel()];
        shutdownButton->setColor(Utilities::Color_Red[0], Utilities::Color_Red[1], Utilities::Color_Red[2], Utilities::Color_Red[3]);
        shutdownButton->turnOn();
        buttons.push_back(shutdownButton);
        
        translateButton = SimpleButton::createButton(@"Pan", 24.0f, wSize, hSize, 1, 2);
        [self addChild:translateButton->getLabel()];
        translateButton->turnOff();
        buttons.push_back(translateButton);

        scaleButton = SimpleButton::createButton(@"Zoom", 24.0f, wSize, hSize, 1, 0);
        [self addChild:scaleButton->getLabel()];
        scaleButton->turnOff();
        buttons.push_back(scaleButton);
        
        gravityButton = SimpleButton::createButton(@"Gravity", 24.0f, wSize, hSize, 0, 0);
        [self addChild:gravityButton->getLabel()];
        buttons.push_back(gravityButton);
        
        runButton = SimpleButton::createButton(@"Run", 24.0f, wSize, hSize, 0, 1);
        [self addChild:runButton->getLabel()];
        buttons.push_back(runButton);
        
        stepButton = SimpleButton::createButton(@"Step", 24.0f, wSize, hSize, 0, 2);
        [self addChild:stepButton->getLabel()];
        buttons.push_back(stepButton);
        
        // The anchor
        scaleCenterButton = SimpleButton::createButton(@"SCenter", 24.0f, wSize, hSize, 1, 1);
        [self addChild:scaleCenterButton->getLabel()];
        scaleCenterButton->turnOff();
        buttons.push_back(scaleCenterButton);
        
        animatePauseButton = SimpleButton::createButton(@"Anime", 24.0f, wSize, hSize, 4, 1);
        [self addChild:animatePauseButton->getLabel()];
        animatePauseButton->turnOff();
        buttons.push_back(animatePauseButton);
        
        autoScrollVisButton = SimpleButton::createButton(@"AScroll", 24.0f, wSize, hSize, 2, 1);
        [self addChild:autoScrollVisButton->getLabel()];
        autoScrollVisButton->turnOff();
        buttons.push_back(autoScrollVisButton);

	}
    
	return self;
}

-(void) linkLayers:(WorldLayer *)layer
{
    worldLayer = layer;
}

-(void) draw
{
    //GameScene* gs = (GameScene*) self.parent;
    ActorShip* actor = static_cast<ActorShip*>(model->getActiveActor());

	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states:  GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
    // Overlays
    float rowSize = screenHeight / 4.0f;
    float colSize = screenWidth / 5.0f;
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    if (model->isOverlayVisible()) {
        for (std::list<SimpleButton*>::iterator iter = buttons.begin(); iter != buttons.end(); ++iter)
            (*iter)->setVisible(true);

        glVertexPointer(2, GL_FLOAT, 0, horzLine);
        glColor4f(Utilities::Color_Peach[0], Utilities::Color_Peach[1], Utilities::Color_Peach[2], 0.4f);

        for (int row = 1; row < 4; row++) {
            glPushMatrix();
            glTranslatef(0.0f, rowSize * row, 0.0f);
            glScalef(screenWidth, 1.0f, 0.0f);
            glDrawArrays(GL_LINES, 0, 2);
            glPopMatrix();
        }
        
        glVertexPointer(2, GL_FLOAT, 0, vertLine);
        for (int col = 1; col < 5; col++) {
            glPushMatrix();
            glTranslatef(colSize * col, 0.0f, 0.0f);
            glScalef(1.0f, screenHeight, 0.0f);
            glDrawArrays(GL_LINES, 0, 2);
            glPopMatrix();
        }
    } else {
        for (std::list<SimpleButton*>::iterator iter = buttons.begin(); iter != buttons.end(); ++iter)
            (*iter)->setVisible(false);

        // Draw menu square region.
        glVertexPointer(2, GL_FLOAT, 0, horzLine);
        glColor4f(Utilities::Color_Peach[0], Utilities::Color_Peach[1], Utilities::Color_Peach[2], 0.2f);
        
        glPushMatrix();
        glTranslatef(2 * colSize, rowSize, 0.0f);
        glScalef(screenWidth - (4.0f * (screenWidth / 5.0f)), 1.0f, 0.0f);
        glDrawArrays(GL_LINES, 0, 2);
        glPopMatrix();

        glVertexPointer(2, GL_FLOAT, 0, vertLine);
        glPushMatrix();
        glTranslatef(2 * colSize, 0.0f, 0.0f);
        glScalef(1.0f, screenHeight - (3.0f * (screenHeight / 4.0f)), 0.0f);
        glDrawArrays(GL_LINES, 0, 2);
        glPopMatrix();
        glPushMatrix();
        glTranslatef(3 * colSize, 0.0f, 0.0f);
        glScalef(1.0f, screenHeight - (3.0f * (screenHeight / 4.0f)), 0.0f);
        glDrawArrays(GL_LINES, 0, 2);
        glPopMatrix();
        
        // Draw thrust bar to the left side.
        //ActorShip* actor = static_cast<ActorShip*>(model->getActiveActor());
        b2Vec2* thrustLocation = actor->getThrustTouchLocation();

        glVertexPointer(2, GL_FLOAT, 0, Utilities::getNormalizedVertexRectangle());

        glPushMatrix();
        glTranslatef(colSize / 4.0f, 0.0f, 0.0f);
        glScalef(colSize / 3.0f, thrustLocation->y, 0.0f);

        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glColor4f(Utilities::Color_Red[0], Utilities::Color_Red[1], Utilities::Color_Red[2], 0.2f);
        glDrawArrays(GL_TRIANGLE_FAN, 0, Utilities::rectangleVertexCount);

        glColor4f(Utilities::Color_Red[0], Utilities::Color_Red[1], Utilities::Color_Red[2], 0.7f);
        glDrawArrays(GL_LINE_LOOP, 0, Utilities::rectangleVertexCount);
        glPopMatrix();

    }
    
    b2Vec2 shipW = actor->getPosition();   // This value is in WORLD-space
    b2Vec2 viewPoint;
    Model::instance()->worldToViewSpace(shipW, viewPoint);
    
    // Draw autoscroll circle
    if (Model::instance()->isAutoScrollVisible()) {
        Circle* autoScrollCircle = Model::instance()->getAutoScrollCircle();
        autoScrollCircle->draw(1.0f);
    }
    
    // Draw anchor
	glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
    glVertexPointer(2, GL_FLOAT, 0, anchorXAxis);
    
    b2Vec2 scaleCenter = Model::instance()->getScaleCenter();
    // This scaleCenter is in PTM-space. we need to map it to view-space.
    b2Vec2 wsPoint;
    Model::instance()->PTMToworldSpace(scaleCenter, wsPoint);
    b2Vec2 vsPoint;
    Model::instance()->worldToViewSpace(wsPoint, vsPoint);
    
    glPushMatrix();
    glTranslatef(vsPoint.x, vsPoint.y, 0.0f);
    glScalef(5.0f, 1.0f, 0.0f);
	glDrawArrays(GL_LINES, 0, 2);
    glPopMatrix();
    
    glVertexPointer(2, GL_FLOAT, 0, anchorYAxis);
    
    glPushMatrix();
    glTranslatef(vsPoint.x, vsPoint.y, 0.0f);
    glScalef(1.0f, 5.0f, 0.0f);
	glDrawArrays(GL_LINES, 0, 2);
    glPopMatrix();
    
    RotateControl* rotateControl = Model::instance()->getRotateControl();

    // Render ship control
    if (actor->isRotating()) {
        rotateControl->draw();
    }

	// restore default GL states
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
	for( UITouch *touch in touches )
    {
		touchLocation = [touch locationInView: [touch view]];
		
		touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
        
        if (deltaDrag.x == 0.0f && deltaDrag.y == 0.0f)
        {
            if (menuButton->touched(touchLocation))
            {
                if (model->isOverlayVisible())
                    model->setOverlayVisible(false);
                else
                    model->setOverlayVisible(true);
            }
            
            if (model->isOverlayVisible()) {
                if (debugButton->touched(touchLocation))
                {
                    StringUtilities::log("Pulse debug");
                    model->getLane()->debug();
                    model->setOverlayVisible(false);
                }
                
                if (stepButton->touched(touchLocation))
                {
                    StringUtilities::log("Clock stepped");
                    //aStep = YES;
                }
                
                if (runButton->touched(touchLocation))
                {
                    if (model->isClockEnabled()) {
                        StringUtilities::log("Clock disabled");
                        model->enableClock(false);
                        runButton->turnOff();
                    } else {
                        StringUtilities::log("Clock enabled");
                        model->enableClock(true);
                        runButton->turnOn();
                    }
                    model->setOverlayVisible(false);
                }
                
                if (gravityButton->touched(touchLocation))
                {
                    if (model->isGravityOn()) {
                        StringUtilities::log("Gravity off");
                        model->turnGravityOff();
                        gravityButton->turnOff();
                    }
                    else {
                        StringUtilities::log("Gravity on");
                        model->setVerticalGravity(-2.5f);
                        gravityButton->turnOn();
                    }
                    model->setOverlayVisible(false);
                }
                
                if (translateButton->touched(touchLocation)) {
                    // Toggle position translation. If the delta between press and release is less than an epsilon then it is a button push and not
                    // a swipe.
                    model->enableZoom(false);
                    model->enableAnchor(false);
                    scaleButton->turnOff();
                    scaleCenterButton->turnOff();

                    if (model->isPanEnabled())
                    {
                        StringUtilities::log("World translation off");
                        model->enablePan(false);
                        translateButton->turnOff();
                    }
                    else
                    {
                        StringUtilities::log("World translation on");
                        model->enablePan(true);
                        translateButton->turnOn();
                    }
                    model->setOverlayVisible(false);
                }
                
                if (scaleButton->touched(touchLocation)) {
                    // Toggle scale
                    
                    model->enablePan(false);
                    model->enableAnchor(false);
                    translateButton->turnOff();
                    scaleCenterButton->turnOff();

                    if (model->isZoomEnabled())
                    {
                        StringUtilities::log("Scale off");
                        model->enableZoom(false);
                        scaleButton->turnOff();
                    }
                    else
                    {
                        StringUtilities::log("Scale on");
                        model->enableZoom(true);
                        scaleButton->turnOn();
                    }
                    model->setOverlayVisible(false);
                }
                
                if (scaleCenterButton->touched(touchLocation)) {
                    // Toggle anchor
                    model->enablePan(false);
                    model->enableZoom(false);
                    translateButton->turnOff();
                    scaleButton->turnOff();
                    if (model->isAnchorEnabled())
                    {
                        StringUtilities::log("Anchor off");
                        model->enableAnchor(false);
                        scaleCenterButton->turnOff();
                    }
                    else
                    {
                        StringUtilities::log("Anchor on");
                        model->enableAnchor(true);
                        scaleCenterButton->turnOn();
                    }
                    model->setOverlayVisible(false);
                }
                
                if (autoScrollVisButton->touched(touchLocation)) {
                    if (model->isAutoScrollVisible()) {
                        model->setAutoScrollVisible(false);
                        StringUtilities::log("Autoscroll invisible");
                        autoScrollVisButton->turnOff();
                    } else {
                        model->setAutoScrollVisible(true);
                        StringUtilities::log("Autoscroll visible");
                        autoScrollVisButton->turnOn();
                    }
                    model->setOverlayVisible(false);
                }
                
                if (resetButton->touched(touchLocation)) {
                    StringUtilities::log("Resetting");
                    //resetting = YES;
                    model->reset(model->getPhysicsWorld());
                    model->setOverlayVisible(false);
                }
                
                if (shutdownButton->touched(touchLocation)) {
                    StringUtilities::log("Shutting down");
                    StringUtilities::log("Clock disabled");
                    model->enableClock(false);
                    
                    model->release();
                }
            }
        }
    }
    
    deltaDrag.x = 0.0f;
    deltaDrag.y = 0.0f;

}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
    delete [] horzLine;
    delete [] vertLine;
    
    delete [] leftEdge;
    delete [] rightEdge;
    delete [] bottomEdge;
    delete [] topEdge;

    delete [] anchorXAxis;
    delete [] anchorYAxis;

	// don't forget to call "super dealloc"
	[super dealloc];

    for (std::list<SimpleButton*>::iterator iter = buttons.begin(); iter != buttons.end(); ++iter)
    {
        SimpleButton* b = *iter;
        delete b;
    }
    
    buttons.clear();
    
    // Once they get to the correct state this button shows.
    if (ejectButton != NULL)
        delete ejectButton;
    
}

@end
