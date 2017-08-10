//
//  SimpleTestPropertyFloat.h
//  Hukimasu
//
//  Created by William DeVore on 5/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IAnimatedProperty.h"
#import "StringUtilities.h"

template <typename T>
class SimpleTestPropertyFloat : public IAnimatedProperty<T> {
private:
    T value;
    
public:
    SimpleTestPropertyFloat() {};
    virtual ~SimpleTestPropertyFloat() {};
    
    virtual void setValue(T value)
    {
        StringUtilities::log("SimpleTestProperty::setValue : ", (float)value);
        this->value = value;
    }

    virtual T getValue()
    {
        return value;
    }

};
