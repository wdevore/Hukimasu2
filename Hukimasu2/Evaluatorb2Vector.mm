//
//  Evaluatorb2Vector.m
//  Hukimasu
//
//  Created by William DeVore on 5/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Evaluatorb2Vector.h"

Evaluatorb2Vector::Evaluatorb2Vector() {
    
}

Evaluatorb2Vector::~Evaluatorb2Vector() {
}

b2Vec2 Evaluatorb2Vector::evaluate(b2Vec2 v0, b2Vec2 v1, float fraction)
{
    b2Vec2 vr;
    vr.x = v0.x + ((v1.x - v0.x) * fraction);
    vr.y = v0.y + ((v1.y - v0.y) * fraction);
    return vr;
}
