//
//  IPropertyAction.h
//  Hukimasu
//
//  Created by William DeVore on 6/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

template <typename T>
class IPropertyAction {
    
public:
    /**
     * This method is called by an IAnimatedProperty as a result of a setValue()
     */
    virtual void action(T value) = 0;
};
