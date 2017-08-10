//
//  LinearInterpolator.h
//  Hukimasu
//
//  Created by William DeVore on 5/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "Interpolator.h"

/**
 * This class implements the Interpolator interface by providing a
 * simple interpolate function that simply returns the value that
 * it was given. The net effect is that callers will end up calculating
 * values linearly during intervals.
 * <p>
 * Because there is no variation to this class, it is a singleton and
 * is referenced by using the {@link #instance} static method.
 *
 */

class LinearInterpolator : public Interpolator {
private:
    static LinearInterpolator* _instance;

public:
    LinearInterpolator();
    ~LinearInterpolator();
    
    static LinearInterpolator* instance() {
        if (_instance == NULL)
            _instance = new LinearInterpolator();
        
        return _instance;
    }

    /**
     * This function takes an input value between 0 and 1 and returns
     * another value, also between 0 and 1. The purpose of the function
     * is to define how time (represented as a (0-1) fraction of the
     * duration of an animation) is altered to derive different value
     * calculations during an animation.
     * @param fraction a value between 0 and 1, representing the elapsed
     * fraction of a time interval (either an entire animation cycle or an 
     * interval between two KeyTimes, depending on where this Interpolator has
     * been set)
     * @return a value between 0 and 1.  Values outside of this boundary may
     * be clamped to the interval [0,1] and cause undefined results.
     */
    virtual float interpolate(float fraction);
};