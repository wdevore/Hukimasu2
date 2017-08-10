//
//  WorldScalePropertyAction.h
//  Hukimasu
//
//  Created by William DeVore on 6/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "IPropertyAction.h"
#import "Model.h"

// This object is going to change the value according to a time
// step scale.
// This action needs the following information:
// FRAME time. This is 1/FPS = 1/60 = 16666us.
// Duration of animation. For example 1 sec = 1000000us.
// The Start and End values of the property. For example, 0.3 -> 1.0
//
// We also need to track the previous value so that a dimensional
// analysis can be performed to find the multiplier such that we can find
// the next value.
//
// To compute the next value for the scale we take the current scale
// value and divide it into the new scale value. This gives us a
// multiplication ratio value (factor) that will set the matrix scale to the
// new value.
// factor = new / current.
// For example, if the current value is 0.3 and the new value is 0.44, then
// factor = 0.44 / 0.3 = 1.466. Hence, 0.3 * 1.466 = 0.44 the new value
// we want in the matrix.
class WorldScalePropertyAction : public IPropertyAction<float> {
private:
    Model* model;
    
public:
    WorldScalePropertyAction();
    virtual ~WorldScalePropertyAction();
    
    virtual void action(float value);
    
    void setTargetOfAction(Model* model);
};
