//
//  OverlayNode.h
//  Hukimasu
//
//  Created by William DeVore on 4/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <list>
#import "cocos2d.h"
#import "Box2D.h"
#import "Model.h"
#import "WorldLayer.h"

class SimpleButton;
class Model;

// This layer draws all the overlays like grids and stuff.
//
@interface OverlayLayer : CCLayer
{
    WorldLayer* worldLayer;
    
    // Overlays
    float screenWidth;
    float screenHeight;
    
    CGPoint touchLocation;
    CGPoint deltaDrag;
    Model* model;

    b2Vec2* horzLine;
    b2Vec2* vertLine;

    b2Vec2* anchorXAxis;
    b2Vec2* anchorYAxis;

    // Auto scroll boundary box. Each is a separate edge.
    b2Vec2* leftEdge;
    b2Vec2* rightEdge;
    b2Vec2* bottomEdge;
    b2Vec2* topEdge;
    
    std::list<SimpleButton*> buttons;
    SimpleButton* menuButton;
    SimpleButton* debugButton;
    SimpleButton* resetButton;

    SimpleButton* menu1Button;
    SimpleButton* menu2Button;
    SimpleButton* menu3Button;
    SimpleButton* menu4Button;
    SimpleButton* menu5Button;
    
    // Menu tab 1
    SimpleButton* shutdownButton;
    SimpleButton* translateButton;
    SimpleButton* scaleButton;
    SimpleButton* gravityButton;
    SimpleButton* runButton;
    SimpleButton* stepButton;
    SimpleButton* scaleCenterButton;
    SimpleButton* animatePauseButton;
    SimpleButton* autoScrollVisButton;
    
    // Once they get to the correct state this button shows.
    SimpleButton* ejectButton;
    
}

-(void) postInit;

-(void) linkLayers:(WorldLayer*) layer;

@end
