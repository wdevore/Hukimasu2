//
//  KeyValues.h
//  Hukimasu
//
//  Created by William DeVore on 5/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <vector>

#import "Box2D.h"
#import "StringUtilities.h"

#import "Evaluator.h"
#import "EvaluatorFloat.h"
#import "Evaluatorb2Vector.h"

template <typename T>
class KeyValues {
private:
    std::vector<T*> values;
    Evaluator<T>* evaluator;
    T startValue;
    
public:
    KeyValues()
    {
    };
    
    ~KeyValues()
    {
        values.clear();
    };
    
    static KeyValues<float>* createFromFloats(std::vector<float> values)
    {
        KeyValues<float>* kvalues = new KeyValues<float>();
        kvalues->evaluator = new EvaluatorFloat();
        
        std::vector<float>::iterator iter = values.begin();
        int i = 0;
        while (iter != values.end()) {
            float* f = new float(values[i++]);
            kvalues->values.push_back(f);
            ++iter;
        }

        return kvalues;
    }
    
    static KeyValues<b2Vec2>* createFromb2Vectors(std::vector<b2Vec2> values)
    {
        KeyValues<b2Vec2>* kvalues = new KeyValues<b2Vec2>();
        kvalues->evaluator = new Evaluatorb2Vector();

        std::vector<b2Vec2>::iterator iter = values.begin();
        int i = 0;
        while (iter != values.end()) {
            b2Vec2 iv = values[i++];
            b2Vec2* v = new b2Vec2(iv);
            kvalues->values.push_back(v);
            ++iter;
        }

        return kvalues;
    }
    
    void releaseAsFloats()
    {
        std::vector<float*>::iterator iter = values.begin();
        while (iter != values.end()) {
            StringUtilities::log("KeyValues::releaseAsFloats deleting value");
            float* f = *iter;
            delete f;
            ++iter;
        }
    }
    
    void releaseAsb2Vectors()
    {
        std::vector<b2Vec2*>::iterator iter = values.begin();
        while (iter != values.end()) {
            b2Vec2* f = *iter;
            delete f;
            ++iter;
        }
    }
    
    void setEvaluator(Evaluator<T>* evaluator)
    {
        this->evaluator = evaluator;
    }

    void setValue(int index, T* value)
    {
        T* cv = values[index];
        delete cv;
        values[index] = value;
    }
    
    /**
     * Used for simple two-value animations.
     * This sets the Intial start value.
     */
    void setBeginValue(T* value)
    {
        setValue(0, value);
    }
    
    /**
     * Used for simple two-value animations.
     * This sets the ending value.
     */
    void setEndValue(T* value)
    {
        setValue(1, value);
    }
    
	/**
	 * Returns the number of values stored in this object.
	 * 
	 * @return the number of values stored in this object
	 */
    int getSize()
    {
        return (int)values.size();
    }

    /**
	 * Called at start of animation; sets starting value in simple "to"
	 * animations.
	 */
	void setStartValue(T startValue)
    {
        if (isToAnimation()) {
            this->startValue = startValue;
        }
    }

    /**
	 * Utility method for determining whether this is a "to" animation (true if
	 * the first value is null).
	 */
	bool isToAnimation()
    {
        return (values[0] == NULL);
    }

    /**
	 * Returns value calculated from the value at the lower index, the value at
	 * the upper index, the fraction elapsed between these endpoints, and the
	 * evaluator set up by this object at construction time.
	 */
	T getValue(int i0, int i1, float fraction)
    {
        T value;
        T* lowerValue = values[i0];
        
        if (lowerValue == NULL) {
            // "to" animation
            *lowerValue = startValue;
        }
        
        if (i0 == i1) {
            // trivial case
            value = *lowerValue;
        } else {
            T* v0 = lowerValue;
            T* v1 = values[i1];
            value = evaluator->evaluate(*v0, *v1, fraction);
        }
        
        return value;
    }

    std::string toStringAsFloats()
    {
        std::string s = "[";
        std::vector<float*>::iterator iter = values.begin();
        while (iter != values.end()) {
            float* value = *iter;
            s.append(StringUtilities::toString(*value));
            s.append(", ");
            ++iter;
        }
        s = s.substr(0, s.size() - 2);
        s.append("]");
        return s;
    }

    std::string toStringAsb2Vectors()
    {
        std::string s = "[";
        std::vector<b2Vec2*>::iterator iter = values.begin();
        while (iter != values.end()) {
            b2Vec2* value = *iter;
            s.append("{");
            s.append(StringUtilities::toString((*value).x));
            s.append(", ");
            s.append(StringUtilities::toString((*value).y));
            s.append("}");
            s.append(", ");
            ++iter;
        }
        s = s.substr(0, s.size() - 2);
        s.append("]");
        return s;
    }
};
