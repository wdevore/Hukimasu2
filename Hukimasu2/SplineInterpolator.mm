//
//  SplineInterpolator.m
//  Hukimasu
//
//  Created by William DeVore on 5/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "SplineInterpolator.h"
#import "StringUtilities.h"
#import "SplineLengthItem.h"

SplineInterpolator::SplineInterpolator() {
    
}

SplineInterpolator::~SplineInterpolator() {
    lengths.clear();
}

SplineInterpolator::SplineInterpolator(float x1, float y1, float x2, float y2)
{
    if (x1 < 0.0f || x1 > 1.0f ||
        y1 < 0.0f || y1 > 1.0f ||
        x2 < 0.0f || x2 > 1.0f ||
        y2 < 0.0f || y2 > 1.0f) {
        StringUtilities::dump("Control points must be in the range [0, 1]:");
    }
    
    this->x1 = x1;
    this->y1 = y1;
    this->x2 = x2;
    this->y2 = y2;
    
    lengths.clear();
    
    // Now contruct the array of all lengths to t in [0, 1.0]
    float prevX = 0.0f;
    float prevY = 0.0f;
    float prevLength = 0.0f; // cumulative length
    for (float t = 0.01f; t <= 1.0f; t += .01f) {
        b2Vec2 xy = getXY(t);
        float length = prevLength + (float)sqrt((xy.x - prevX) * (xy.x - prevX) + (xy.y - prevY) * (xy.y - prevY));
        SplineLengthItem* lengthItem = new SplineLengthItem(length, t);
        lengths.push_back(lengthItem);
        prevLength = length;
        prevX = xy.x;
        prevY = xy.y;
    }

    StringUtilities::log("SplineInterpolator::SplineInterpolator lengths.size(): ", (int)lengths.size());
    StringUtilities::log("SplineInterpolator::SplineInterpolator prevLength: ", prevLength);

    // Now calculate the fractions so that we can access the lengths
    // array with values in [0,1].  prevLength now holds the total
    // length of the spline.
    std::list<SplineLengthItem*>::iterator iter = lengths.begin();

    if (!lengths.empty()) {
        while (iter != lengths.end()) {
            SplineLengthItem* lengthItem = *iter;
            lengthItem->setFraction(prevLength);
            ++iter;
        }
    }

}

b2Vec2 SplineInterpolator::getXY(float t)
{
    b2Vec2 xy;
    float invT = (1.0f - t);
    float b1 = 3.0f * t * (invT * invT);
    float b2 = 3.0f * (t * t) * invT;
    float b3 = t * t * t;
    xy.x = (b1 * x1) + (b2 * x2) + b3;
    xy.y = (b1 * y1) + (b2 * y2) + b3;
    return xy;
}

float SplineInterpolator::getY(float t)
{
    float invT = (1.0f - t);
    float b1 = 3.0f * t * (invT * invT);
    float b2 = 3.0f * (t * t) * invT;
    float b3 = t * t * t;
    return (b1 * y1) + (b2 * y2) + b3;
}

float SplineInterpolator::interpolate(float lengthFraction)
{
    //StringUtilities::log("SplineInterpolator::interpolate lengthFraction: ", lengthFraction);

    // REMIND: speed this up with binary search
    float interpolatedT = 1.0f;
    float prevT = 0.0f;
    float prevLength = 0.0f;
    
    std::list<SplineLengthItem*>::iterator iter = lengths.begin();
    
    while (iter != lengths.end()) {
        SplineLengthItem* lengthItem = *iter;
        
        float fraction = lengthItem->getFraction();
        float t = lengthItem->getT();
        //StringUtilities::log("SplineInterpolator::interpolate fraction: ", fraction);
        //StringUtilities::log("SplineInterpolator::interpolate t: ", t);
        
        if (lengthFraction <= fraction) {
            // answer lies between last item and this one
            float proportion = (lengthFraction - prevLength) / (fraction - prevLength);
            interpolatedT = prevT + proportion * (t - prevT);
            return getY(interpolatedT);
        }
        
        prevLength = fraction;
        prevT = t;
        
        ++iter;
    }
    
    return getY(interpolatedT);
}
