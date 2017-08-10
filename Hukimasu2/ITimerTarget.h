//
//  ITimerTarget.h
//  Hukimasu2
//
//  Created by William DeVore on 10/30/11 A.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

// This interface is passed to a TimerBase class. The action method
// is called when an interval is reached.
class ITimerTarget {
public:
    virtual void action(int Id) = 0;
    virtual bool shouldStop(int Id) = 0;
};
