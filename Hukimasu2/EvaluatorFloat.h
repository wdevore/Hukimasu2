//
//  EvaluatorFloat.h
//  Hukimasu
//
//  Created by William DeVore on 5/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "Evaluator.h"

class EvaluatorFloat : public Evaluator<float> {
private:
    
public:
    EvaluatorFloat();
    virtual ~EvaluatorFloat();
    
    virtual float evaluate(float v0, float v1, float fraction);
};
