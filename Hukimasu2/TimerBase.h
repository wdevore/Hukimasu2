//
//  TimerBase.h
//  Hukimasu2
//
//  Created by William DeVore on 10/30/11 A.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import "ITimerTarget.h"

class TimerBase {
private:
    ITimerTarget* _target;
    long _duration;
    long _interval;
    long _originalInterval;
    long intervalCount;
    bool paused;
    int _id;
    
public:
    TimerBase(ITimerTarget* target, int Id);
    ~TimerBase();
    
    void setDuration(long duration);
    void setInterval(long interval);
    
    void start();
    void stop();
    void pause();
    void resume();
    void reset();
    void update(long dt);
    bool isPaused();
    
};
