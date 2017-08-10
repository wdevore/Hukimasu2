//
//  WorldLayer.h
//  Hukimasu
//
//  Created by William DeVore on 3/26/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "GLES-Render.h"

#import "Model.h"

// The main world layer
@interface WorldLayer : CCLayer
{
	GLESDebugDraw *m_debugDraw;
    
    CGPoint touchLocation;
    CGPoint deltaDrag;

    BOOL resetting;
    
    Model* model;
    
    float screenWidth;
    float screenHeight;

    int debugCount;
    
    BOOL aStep;
    
    b2Vec2* xAxis;
    b2Vec2* yAxis;

    b2Vec2* anchorXAxis;
    b2Vec2* anchorYAxis;

    //#####################################
    //## TEMP DEBUG STUFF. REMOVED WHEN RELEASED
    //#####################################
}

-(void) postInit;
-(CGPoint) getTouchLocation;

@end
