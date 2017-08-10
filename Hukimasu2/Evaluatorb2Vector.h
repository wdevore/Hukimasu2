//
//  Evaluatorb2Vector.h
//  Hukimasu
//
//  Created by William DeVore on 5/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "Evaluator.h"
#import "Box2D.h"

class Evaluatorb2Vector : public Evaluator<b2Vec2> {
private:
    
public:
    Evaluatorb2Vector();
    virtual ~Evaluatorb2Vector();
    
    virtual b2Vec2 evaluate(b2Vec2 v0, b2Vec2 v1, float fraction);
};
