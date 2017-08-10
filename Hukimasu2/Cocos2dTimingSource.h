//
//  Cocos2dTimingSource.h
//  Hukimasu
//
//  Created by William DeVore on 5/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "TimingSource.h"

class Animator;

// Instead of using a separate thread to implement timing, this class
// attaches itself to the Cocos2d timing tick() method.
class Cocos2dTimingSource : public TimingSource {
    
public:
    Cocos2dTimingSource();
    virtual ~Cocos2dTimingSource();

    virtual void start();
    virtual void stop();
    virtual void setResolution(int resolution);
    virtual void setStartDelay(long delay);

};