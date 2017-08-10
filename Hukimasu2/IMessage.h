//
//  IMessage.h
//  Hukimasu2
//
//  Created by William DeVore on 7/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

// Interface
class IMessage {
public:
    virtual void subscribeListener(IMessage* listener) = 0;
    virtual void unSubscribeListener(IMessage* listener) = 0;

    virtual void message(int message) = 0;
    virtual void message(int message, IMessage* sender) = 0;
};
