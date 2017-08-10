//
//  KeyTimes.h
//  Hukimasu
//
//  Created by William DeVore on 5/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <vector>

/**
 * Stores a list of times from 0 to 1 (the elapsed fraction of an animation
 * cycle) that are used in calculating interpolated
 * values for PropertySetter given a matching set of KeyValues and
 * Interpolators for those time intervals.  In the simplest case, a
 * KeyFrame will consist of just two times in KeyTimes: 0 and 1.
 */
class KeyTimes {
private:
    std::vector<float> times;

public:
    KeyTimes();
    ~KeyTimes();
    
    KeyTimes(std::vector<float> times);
    
    void addTime(float time);
    
    std::vector<float> getTimes();
    int getSize();
    
    /**
     * Returns time interval that contains this time fraction
     */
    int getInterval(float fraction);
    
    float getTime(int index);
    
    std::string toString();

};