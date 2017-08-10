//
//  KeyTimes.m
//  Hukimasu
//
//  Created by William DeVore on 5/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "StringUtilities.h"
#import "KeyTimes.h"
#import "Box2D.h"

KeyTimes::KeyTimes() {
    
}

KeyTimes::~KeyTimes() {
}

KeyTimes::KeyTimes(std::vector<float> times) {
    std::vector<float>::iterator iter = times.begin();
    int i = 0;
    while (iter != times.end()) {
        this->times.push_back(times[i++]);
        ++iter;
    }
}

void KeyTimes::addTime(float time)
{
    if (times.empty()) {
        if (time != 0.0f) {
            StringUtilities::dump("First time value must be zero. Last time value must be one.");
            return;
        }
    }
    
    times.push_back(time);
}

std::vector<float> KeyTimes::getTimes()
{
    return times;
}

int KeyTimes::getSize()
{
    return (int)times.size();
}

int KeyTimes::getInterval(float fraction)
{
    int prevIndex = -1;
    int i = 0;
    
    std::vector<float>::iterator iter = times.begin();
    
    while (iter != times.end()) {
        float time = *iter;
        if (time >= fraction) { 
            // inclusive of start time at next interval.  So fraction==1
            // will return the final interval (times.size() - 1)
            if (prevIndex == -1)
                return 0;
            else
                return prevIndex;
        }
        ++iter;
        prevIndex = i;
        i++;
    }
    
    return prevIndex;
}

float KeyTimes::getTime(int index)
{
    return times[index];
}

std::string KeyTimes::toString()
{
    std::string s = "[";
    std::vector<float>::iterator iter = times.begin();
    while (iter != times.end()) {
        float value = *iter;
        s.append(StringUtilities::toString(value));
        s.append(", ");
        ++iter;
    }
    s = s.substr(0, s.size() - 2);
    s.append("]");
    return s;
}

