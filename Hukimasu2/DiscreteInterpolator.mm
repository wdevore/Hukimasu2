//
//  DiscreteInterpolator.m
//  Hukimasu
//
//  Created by William DeVore on 5/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DiscreteInterpolator.h"

DiscreteInterpolator* DiscreteInterpolator::_instance = NULL;

DiscreteInterpolator::DiscreteInterpolator() {
    
}

DiscreteInterpolator::~DiscreteInterpolator() {
}

float DiscreteInterpolator::interpolate(float fraction)
{
    if (fraction < 1.0f) {
        return 0.0f;
    }
    return 1.0f;
}

//######################################
//## Setup scale animated property using a Discrete interpolator
//######################################
//std::vector<float> scaleValues;
//scaleValues.push_back(1.0f);       // Typically the start value in a basic 2 value animation
//scaleValues.push_back(1.0f);       // Typically the end value in a basic 2 value animation
//KeyValues<float>* scaleKeys = KeyValues<float>::createFromFloats(scaleValues);
//DiscreteInterpolator* discreteIntpFrames = new DiscreteInterpolator();
//KeyFrames<float>* scaleKeyFrames =new KeyFrames<float>(scaleKeys, discreteIntpFrames);

// keyValues is deleted by PropertySetterTimingTarget.
// We need this target so we can adjust the KeyValues.
// TODO create a factory for a default 2 vector property or constructor
//floatAnimatedProperty* iaScale = Model::instance()->getWorldScaleProperty();

//scaleTarget = new PropertySetterTimingTarget<float>(iaScale, scaleKeyFrames);

// 1000000 = 1 second.
//DiscreteInterpolator* discreteIntp = new DiscreteInterpolator();
//scaleAnimator = new Animator(1000000, 1, Animator::REVERSE, scaleTarget, discreteIntp);
//scaleAnimator->setAcceleration(0.2f);
//scaleAnimator->setDeceleration(0.2f);
