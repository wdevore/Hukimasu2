//
//  b2Vec2AnimatedProperty.h
//  Hukimasu
//
//  Created by William DeVore on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "IPropertyAction.h"

#import "IAnimatedProperty.h"
#import "Box2D.h"

class b2Vec2AnimatedProperty : public IAnimatedProperty<b2Vec2> {
private:
    b2Vec2 value;
    IPropertyAction<b2Vec2>* propertyAction;

public:
    b2Vec2AnimatedProperty();
    virtual ~b2Vec2AnimatedProperty();
    
    virtual void setAction(IPropertyAction<b2Vec2>* propertyAction);

    virtual void setValue(b2Vec2 value);
    
    virtual b2Vec2 getValue();
    
};
