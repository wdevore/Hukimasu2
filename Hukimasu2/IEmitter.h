//
//  IEmitter.h
//  Hukimasu2
//
//  Created by William DeVore on 10/29/11 A.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

class IEmitter {
public:
    // How long to pause between emissions.
    virtual void setInterval(long microseconds) = 0;
    // How many things to emit.
    virtual void setCount(int count) = 0;
    virtual void start() = 0;
    virtual void pause() = 0;
    virtual void resume() = 0;
};
