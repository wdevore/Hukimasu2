//
//  WorldScalePropertyAction.m
//  Hukimasu
//
//  Created by William DeVore on 6/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "StringUtilities.h"
#import "WorldScalePropertyAction.h"

WorldScalePropertyAction::WorldScalePropertyAction()
{
    model = NULL;
}

WorldScalePropertyAction::~WorldScalePropertyAction()
{
    StringUtilities::log("WorldScalePropertyAction::~WorldScalePropertyAction");
}

void WorldScalePropertyAction::setTargetOfAction(Model *model)
{
    this->model = model;
}

void WorldScalePropertyAction::action(float value)
{
    // We want to compute a scalor value such that when the transform
    // matrix is computed the scale will result in the value being passed
    // this action() method.
    // To compute the next value for the scale we take the current scale
    // value from the matrix and divide it into the new scale value being
    // passed to this method. This gives us a
    // multiplication ratio value (factor) that will set the matrix scale to the
    // new value.
    // factor = new(value) / current(matrix value).
    // For example, if the current value is 0.3 and the new value is 0.44, then
    // factor = 0.44 / 0.3 = 1.466. Hence, 0.3 * 1.466 = 0.44 which is the new
    // value we want in the matrix.
    //
    // To look at it visually we have:
    //
    //                                     duration
    // .------------------------------------------------------------------------------.
    // |         |           |        |          |...                                               |
    //           A          B
    //
    // To get B with a incoming value of V we use dimensional analysis
    // V = B / A such that V * A will equal B.
    // B is the new matrix value
    // A is the previous matrix value
    // V is the ratio that takes us from A to B during the matrix multplication
    // in the Model::transform method.
    float factor = value / model->getMatrixScale();
    model->setScaleFactor(factor);
}