//
//  floatAnimatedProperty.h
//  Hukimasu
//
//  Created by William DeVore on 6/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "IPropertyAction.h"
#import "IAnimatedProperty.h"

class floatAnimatedProperty : public IAnimatedProperty<float> {
private:
    float value;
    IPropertyAction<float>* propertyAction;
    
public:
    floatAnimatedProperty();
    virtual ~floatAnimatedProperty();
    
    virtual void setAction(IPropertyAction<float>* propertyAction);

    virtual void setValue(float value);
    
    virtual float getValue();
    
};
