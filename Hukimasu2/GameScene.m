//
//  GameScene.m
//  Hukimasu
//
//  Created by William DeVore on 5/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameScene.h"
#import "Utilities.h"

@implementation GameScene

-(id) init
{
    self = [super init];
    
    if (self != nil) {

        Utilities::init();
        
        worldLayer = [WorldLayer node];
        [self addChild:worldLayer z:0 tag:KGameLayer];
        [worldLayer postInit];
        
        overlayLayer = [OverlayLayer node];
        [overlayLayer linkLayers:worldLayer];
        [self addChild:overlayLayer z:0 tag:KOverlayLayer];
        [overlayLayer postInit];
    }
    
    return self;
}

-(void) setModel:(Model *)mdl
{
    model = mdl;
}

//*****************************************************************************
// DEALLOC
//*****************************************************************************
-(void) dealloc
{
    Model::instance()->release();
    
    [super dealloc];
}

@end
