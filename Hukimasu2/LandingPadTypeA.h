//
//  LandingPadTypeA.h
//  Hukimasu2
//
//  Created by William DeVore on 7/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "HuActor.h"

// Type A landing pad.
//
//
//          .----------------.
//          |         A         |
//    .---..--------------- -..---.
//    |   |                       |   |
//    |   |                       |   |
//    |   | B                    |   | C
//    |   |                       |   |
//    |   |                       |   |
//    .---.                       .---.
//
// A pad moves up and down between columns B and C
//
// It transmits messages that indicate the pad has passed
// a certain point downwards or upwards.
//
// Because this element inherits from IElementListener it can also receive messages
// from other elements possibly a circular relationship. For example, one pad could
// activate another pad.
// And because it inherits from Element it can also have subscribers that it too can
// transmit message towards.

class LandingPadTypeA : public HuActor {
    
private:
    
public:
    LandingPadTypeA();
    virtual ~LandingPadTypeA();
    
    virtual void message(int message);

};
