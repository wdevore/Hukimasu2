//
//  LandingPadTypeB.h
//  Hukimasu2
//
//  Created by William DeVore on 7/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "HuActor.h"

// This pad is a pulsing pad.
class LandingPadTypeB : public HuActor {
    
private:
    
public:
    LandingPadTypeB();
    virtual ~LandingPadTypeB();
    
    virtual void message(int message);
    
};
