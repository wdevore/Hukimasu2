//
//  SpineLengthItem.h
//  Hukimasu
//
//  Created by William DeVore on 5/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

/**
 * Struct used to store information about length values.  Specifically,
 * each item stores the "length" (which can be thought of as the time
 * elapsed along the spline path), the "t" value at this length (used to
 * calculate the (x,y) point along the spline), and the "fraction" which
 * is equal to the length divided by the total absolute length of the spline.
 * After we calculate all LengthItems for a give spline, we have a list
 * of entries which can return the t values for fractional lengths from 
 * 0 to 1.
 */

class SplineLengthItem {
private:
    float length;
    float t;
    float fraction;

public:
    SplineLengthItem();
    ~SplineLengthItem();
    
    SplineLengthItem(float length, float t, float fraction);
    
    SplineLengthItem(float length, float t);
    
    float getLength();
    
    float getT();
    
    float getFraction();
    
    void setFraction(float totalLength);

};