//
//  GameScene.h
//  Hukimasu
//
//  Created by William DeVore on 5/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCScene.h"
#import "WorldLayer.h"
#import "OverlayLayer.h"
#import "Model.h"

#define KGameLayer 1
#define KOverlayLayer 2

@interface GameScene : CCScene {

    Model* model;
    
    WorldLayer* worldLayer;
    OverlayLayer* overlayLayer;
}

-(void) setModel:(Model*) model;

@end
