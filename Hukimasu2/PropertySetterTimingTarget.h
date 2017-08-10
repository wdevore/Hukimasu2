//
//  PropertySetterTimingTarget.h
//  Hukimasu
//
//  Created by William DeVore on 5/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TimingTargetAdapter.h"
#import "IAnimatedProperty.h"
#import "KeyFrames.h"
#import "Animator.h"
#import "Evaluator.h"

template <typename T>
class PropertySetterTimingTarget : public TimingTargetAdapter {
private:
    IAnimatedProperty<T>* object;
    KeyFrames<T>* keyFrames;
    
public:
    PropertySetterTimingTarget()
    {
        object = NULL;
        this->keyFrames = NULL;
    };
    
    virtual ~PropertySetterTimingTarget()
    {
        if (this->keyFrames != NULL)
            delete keyFrames;
    };
    
    /**
     * Constructor for a PropertySetter where the values the propert
     * takes on during the animation are specified in a {@link KeyFrames}
     * object.
     * @param object the object whose property will be animated
     * @param keyFrames the fractional times, values, and interpolation
     * to be used in calculating the values set on the object's property.
     */
    PropertySetterTimingTarget(IAnimatedProperty<T>* object, KeyFrames<T>* keyFrames)
    {
        this->object = object;
        this->keyFrames = keyFrames;
    }

    /**
     * Constructor for a PropertySetter where the values the propert
     * takes on during the animation are specified in a {@link KeyFrames}
     * object.
     * @param object the object whose property will be animated
     * @param params the values that the object will take on during the
     * animation.  Internally, a KeyFrames object will be created that
     * will use times that split the total duration evenly. Supplying
     * only one value for params implies that this is a "to" animation
     * whose intial value will be determined dynamically when the animation
     * starts.
     */
    PropertySetterTimingTarget(IAnimatedProperty<T>* object, KeyValues<T>* values)
    {
        this->object = object;
        this->keyFrames = new KeyFrames<T>(values);
    }

    KeyValues<T>* getKeyValues()
    {
        return keyFrames->getKeyValues();
    }
    
    KeyFrames<T>* getKeyFrames()
    {
        return keyFrames;
    }
    
    /**
     * Utility method that constructs a PropertySetter and an Animator using
     * that PropertySetter and returns the Animator
     * @param duration the duration, in milliseconds, of the animation
     * @param object the object whose property will be animated
     * @param keyFrames the fractional times, values, and interpolation
     * to be used in calculating the values set on the object's property.
     */
    static Animator* createAnimator(int duration, IAnimatedProperty<T>* object, KeyFrames<T>* keyFrames)
    {
        PropertySetterTimingTarget* ps = new PropertySetterTimingTarget(object, keyFrames);
        Animator* animator = new Animator(duration, ps);
        return animator;
    }

    /**
     * Utility method that constructs a PropertySetter and an Animator using
     * that PropertySetter and returns the Animator
     * @param duration the duration, in milliseconds, of the animation
     * @param object the object whose property will be animated
     * @param params the values that the object will take on during the
     * animation.  Internally, a KeyFrames object will be created that
     * will use times that split the total duration evenly. Supplying
     * only one value for params implies that this is a "to" animation
     * whose intial value will be determined dynamically when the animation
     * starts.
     */
    static Animator* createAnimator(int duration, IAnimatedProperty<T>* object, KeyValues<T> values)
    {
        PropertySetterTimingTarget* ps = new PropertySetterTimingTarget(object, values);
        Animator* animator = new Animator(duration, ps);
        return animator;
    }
    
    //
    // TimingTargetAdapter overrides
    //
    /**
     * Called from Animator to signal a timing event.  This
     * causes PropertySetter to invoke the property-setting method (as 
     * specified by the propertyName in the constructor) with the
     * appropriate value of the property given the range of values in the
     * KeyValues object and the fraction of the timing cycle that has
     * elapsed.
     * <p>
     * This method is not intended for use by application code.
     */
    virtual void timingEvent(float fraction)
    {
        T value = keyFrames->getValue(fraction);
        object->setValue(value);
    }

    /**
     * Called by Animator to signal that the timer is about to start.
     * The only operation performed in this method is setting an initial
     * value for the animation if appropriate; this accounts
     * for "to" animations, which need to start from the current value.
     * <p>
     * This method is not intended for use by application code.
     */
    virtual void begin()
    {
        if (isToAnimation()) {
            setStartValue(object->getValue());
        }
    }

    virtual void end()
    {
        
    }
    
    virtual void repeat()
    {
        
    }

private:
    /**
     * Utility method for determining whether this is a "to" animation
     * (true if the first value is null).
     */
    bool isToAnimation()
    {
        return (keyFrames->getKeyValues()->isToAnimation());
    }

    /**
     * Called during begin() if this is a "to" animation, to set the start
     * value of the animation to whatever the current value is.
     */
    void setStartValue(T value)
    {
        keyFrames->getKeyValues()->setStartValue(value);
    }

};

//--------------------------------
//-- PropertySetter test
//--------------------------------
//iaPosition = new WorldPositionProperty<float>();

//std::vector<float> values;
//values.push_back(5.0f);
//values.push_back(15.0f);
//KeyValues<float>* keyValues = KeyValues<float>::createFromFloats(values);
//StringUtilities::log("keyValues: ", keyValues->toStringAsFloats());

//KeyFrames<float>* keyFrames = new KeyFrames<float>(keyValues);
//StringUtilities::log("keyFrames: \n", keyFrames->toStringAsFloats());

// Should PropertySetterTimingTarget dispose of pointers?
//animator = PropertySetterTimingTarget<float>::createAnimator(2000000, iaPosition, keyFrames);

