//
//  EvaluatorFloat.m
//  Hukimasu
//
//  Created by William DeVore on 5/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EvaluatorFloat.h"

EvaluatorFloat::EvaluatorFloat() {
    
}

EvaluatorFloat::~EvaluatorFloat() {
}

float EvaluatorFloat::evaluate(float v0, float v1, float fraction)
{
    return v0 + ((v1 - v0) * fraction);
}
