//
//  SpineLengthItem.m
//  Hukimasu
//
//  Created by William DeVore on 5/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SplineLengthItem.h"

SplineLengthItem::SplineLengthItem() {
    length = 0.0f;
    t = 0.0f;
    fraction = 0.0f;
}

SplineLengthItem::~SplineLengthItem() {
}

SplineLengthItem::SplineLengthItem(float length, float t, float fraction) {
    this->length = length;
    this->t = t;
    this->fraction = fraction;
}

SplineLengthItem::SplineLengthItem(float length, float t) {
    this->length = length;
    this->t = t;
    fraction = 0.0f;
}

float SplineLengthItem::getLength() {
    return length;
}

float SplineLengthItem::getT() {
    return t;
}

float SplineLengthItem::getFraction() {
    return fraction;
}

void SplineLengthItem::setFraction(float totalLength) {
    fraction = length / totalLength;
}
