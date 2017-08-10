//
//  DiscreteInterpolator.h
//  Hukimasu
//
//  Created by William DeVore on 5/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "Interpolator.h"

/**
 * This class implements the Interpolator interface.  It should
 * be used in cases where a "discrete" animation is desired.  A
 * discrete animation is defined to be one where the values during
 * an animation do not change smoothly between the boundary values,
 * but suddenly, at the boundary points.  For example, a discrete animation
 * with KeyFrames where the KeyTimes are {0, .5, 1.0} and the KeyValues
 * are (0, 1, 2} would, during the animation, retain the value of 0 until
 * half-way through the animation and 1 through the rest of the animation.
 * <p>
 * Because there is no variation to this class, it is a singleton and
 * is referenced by using the {@link #getInstance} static method.
 *
 */

class DiscreteInterpolator : public Interpolator {
private:
    static DiscreteInterpolator* _instance;
    
public:
    DiscreteInterpolator();
    ~DiscreteInterpolator();
    
    static DiscreteInterpolator* instance() {
        if (_instance == NULL)
            _instance = new DiscreteInterpolator();
        
        return _instance;
    }
    
    /**
     * This method always returns 0 for inputs less than 1, 
     * which will force users of this
     * interpolation to assign a value equal to the value at the beginning
     * of this timing interval, which is the desired behavior for discrete
     * animations.  An input of 1 will return 1, since this means the
     * end of the current interval (and start to the next interval).
     * @param fraction a value between 0 and 1, representing the elapsed
     * fraction of a time interval (either an entire animation cycle or an 
     * interval between two KeyTimes, depending on where this Interpolator has
     * been set)
     * @return number representing the start of the current interval, usually
     * 0, but if <code>fracton == 0</code>, returns 1.
     */
    virtual float interpolate(float fraction);
};