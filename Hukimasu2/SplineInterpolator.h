//
//  SplineInterpolator.h
//  Hukimasu
//
//  Created by William DeVore on 5/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <list>
#import "Interpolator.h"
#import "Box2D.h"

/**
 * This class interpolates fractional values using Bezier splines.  The anchor
 * points  * for the spline are assumed to be (0, 0) and (1, 1).  Control points
 * should all be in the range [0, 1].
 * <p>
 * For more information on how splines are used to interpolate, refer to the
 * SMIL specification at http://w3c.org.
 * <p>
 * This class provides one simple built-in facility for non-linear
 * interpolation.  Applications are free to define their own Interpolator
 * implementation and use that instead when particular non-linear
 * effects are desired.
 *
 */
class SplineLengthItem;

class SplineInterpolator : public Interpolator {
private:

    // Note: (x0,y0) and (x1,y1) are implicitly (0, 0) and (1,1) respectively
    float x1, y1, x2, y2;
    std::list<SplineLengthItem*> lengths;

public:
    SplineInterpolator();
    ~SplineInterpolator();
    
    SplineInterpolator(float x1, float y1, float x2, float y2);
    
    /**
     * Given a fraction of time along the spline (which we can interpret
     * as the length along a spline), return the interpolated value of the
     * spline.  We first calculate the t value for the length (by doing
     * a lookup in our array of previousloy calculated values and then
     * linearly interpolating between the nearest values) and then
     * calculate the Y value for this t.
     * @param lengthFraction Fraction of time in a given time interval.
     * @return interpolated fraction between 0 and 1
     */
    virtual float interpolate(float lengthFraction);
    
private:
    /**
     * Calculates the XY point for a given t value.
     *
     * The general spline equation is:
     *   x = b0*x0 + b1*x1 + b2*x2 + b3*x3
     *   y = b0*y0 + b1*y1 + b2*y2 + b3*y3
     * where:
     *   b0 = (1-t)^3
     *   b1 = 3 * t * (1-t)^2
     *   b2 = 3 * t^2 * (1-t)
     *   b3 = t^3
     * We know that (x0,y0) == (0,0) and (x1,y1) == (1,1) for our splines,
     * so this simplifies to:
     *   x = b1*x1 + b2*x2 + b3
     *   y = b1*x1 + b2*x2 + b3
     * @param t parametric value for spline calculation
     */
    b2Vec2 getXY(float t);
    
    /**
     * Utility function: When we are evaluating the spline, we only care
     * about the Y values.  See {@link getXY getXY} for the details.
     */
    float getY(float t);

};