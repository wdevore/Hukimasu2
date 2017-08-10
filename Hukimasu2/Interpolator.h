//
//  Interpolator.h
//  Hukimasu
//
//  Created by William DeVore on 5/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

/**
 * Interface that defines the single {@link #interpolate(float)} method.
 * This interface is implemented by built-in interpolators.  
 * Applications may choose to implement
 * their own Interpolator to get custom interpolation behavior.
 *
 */

// Abstract interface
class Interpolator {

public:
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
    virtual float interpolate(float fraction) = 0;
};