//
//  IAnimatedProperty.h
//  Hukimasu
//
//  Created by William DeVore on 5/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "IPropertyAction.h"

// Abstract class

template <typename T>
class IAnimatedProperty {

public:
    //IAnimatedProperty();
    //virtual ~IAnimatedProperty();

    virtual void setAction(IPropertyAction<T>* action) = 0;
    
    /**
     * This method is called by the PropertySetter in relation to an Animator.
     */
    virtual void setValue(T value) = 0;

    virtual T getValue() = 0;

};
