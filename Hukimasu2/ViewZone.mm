//
//  ViewZone.m
//  Hukimasu
//
//  Created by William DeVore on 6/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <sstream>
#import <iomanip>
#import <vector>

#import "ViewZone.h"
#import "Utilities.h"
#import "StringUtilities.h"
#import "floatAnimatedProperty.h"
#import "Animator.h"
#import "Model.h"

ViewZone::ViewZone() : Zone() {
    shape = NULL;
    scaleTarget = NULL;
    scaleAnimator = NULL;
}

ViewZone::~ViewZone() {
    StringUtilities::log("ViewZone::~ViewZone");
    if (shape != NULL)
    {
        StringUtilities::log("ViewZone::~ViewZone deleting shape");
        delete shape;
    }
    
    // The animator will release the target which will delete any associated keyvalues.
    if (scaleAnimator != NULL)
        delete scaleAnimator;
    
    //KeyValues<b2Vec2>* keyValues = translationTarget->getKeyValues();
    // delete translationTarget;
}

void ViewZone::init()
{
    Zone::init();
    
    // keyValues is deleted by PropertySetterTimingTarget.
    // We need this target so we can adjust the KeyValues.
    // TODO create a factory for a default 2 vector property or constructor
    floatAnimatedProperty* iaScale = Model::instance()->getWorldScaleProperty();
    
    std::vector<float> scaleValues;
    scaleValues.push_back(1.0f);       // Typically the start value in a basic 2 value animation
    scaleValues.push_back(1.0f);       // Typically the end value in a basic 2 value animation
    KeyValues<float>* scaleKeyValues = KeyValues<float>::createFromFloats(scaleValues);

    // The animator will dispose of the target and the keyvalues.
    scaleTarget = new PropertySetterTimingTarget<float>(iaScale, scaleKeyValues);
    
    // 1000000 = 1 second.
    scaleAnimator = new Animator(1000000, scaleTarget);
    //scaleAnimator->setAcceleration(0.2f);
    //scaleAnimator->setDeceleration(0.2f);
}

void ViewZone::check(const b2Vec2& point)
{
    bool inside = pointInside(point);
    
    ViewZone::CROSSSTATE state = crossed(inside);
    
    if (state == Zone::ENTERED) {
        // NOTE: we really don't want to scroll again until the object has exited the zone.
        //StringUtilities::log("WorldLayer::tick entered");
        // Activate zone action. This will scroll and zoom the zone into the forefront.
        // But only if action is not in progress.
        //        if (!animator->isRunning()) {
        //            // setup translation animator values and start the animator.
        //            KeyValues<b2Vec2>* keyValues = translationTarget->getKeyValues();
        //            // Setup and start scroll. We want to scroll the view to the center of the zone.
        //            // Map zone center to VIEW-space
        //            b2Vec2 centerW = viewZone->getCenter();
        //            b2Vec2 viewPoint = model->worldToViewSpace(centerW);
        //            
        //            b2Vec2 delta(240.0f - viewPoint.x, 160.0f - viewPoint.y);
        //            
        //            b2Vec2AnimatedProperty* iaProperty = model->getWorldPositionProperty();
        //            b2Vec2 wp = iaProperty->getValue();
        //            
        //            // The begin value is the current location of the world which is in VIEW-space coords
        //            b2Vec2* value = new b2Vec2(wp);
        //            keyValues->setBeginValue(value);
        //            
        //            value = new b2Vec2(wp.x + delta.x, wp.y + delta.y);
        //            keyValues->setEndValue(value);
        //            
        //            animator->start();
        //        }
        
        if (!scaleAnimator->isRunning()) {
            // Setup scale animator.
            KeyValues<float>* scaleKeyValues = scaleTarget->getKeyValues();
            floatAnimatedProperty* iaScale = Model::instance()->getWorldScaleProperty();
            enterScale = iaScale->getValue();
            iaScale->setValue(enterScale);
            scaleKeyValues->setBeginValue(new float(enterScale));
            scaleKeyValues->setEndValue(new float(getScale()));
            
            // We want to move the scaleCenter as if the user placed it there with dragging.
            b2Vec2 zoneCenterW = getCenter();
            // Because the zone center is already in world-space we only need to
            // map it to PTM-space.
            b2Vec2 wlPoint;
            Model::instance()->worldToPTMSpace(zoneCenterW, wlPoint);
            Model::instance()->setScaleCenter(wlPoint.x, wlPoint.y);
            
            scaleAnimator->start();
        }
        
    } else if (state == Zone::EXITED) {
        scaleAnimator->stop();
        
        // Setup scale animator.
        KeyValues<float>* scaleKeyValues = scaleTarget->getKeyValues();
        floatAnimatedProperty* iaScale = Model::instance()->getWorldScaleProperty();
        float ws = iaScale->getValue();
        iaScale->setValue(ws);
        scaleKeyValues->setBeginValue(new float(ws));
        scaleKeyValues->setEndValue(new float(enterScale));
        
        // We want to move the scaleCenter as if the user placed it there with dragging.
        b2Vec2 zoneCenterW = getCenter();
        // Because the zone center is already in world-space we only need to
        // map it to PTM-space.
        b2Vec2 wlPoint;
        Model::instance()->worldToPTMSpace(zoneCenterW, wlPoint);
        Model::instance()->setScaleCenter(wlPoint.x, wlPoint.y);
        
        scaleAnimator->start();
    }
    
}

bool ViewZone::pointInside(const b2Vec2& point)
{
    return shape->pointInside(point);
}

const b2Vec2& ViewZone::getCenter()
{
    return shape->getCenter();
}

float ViewZone::getScale()
{
    return scale;
}

void ViewZone::draw(float ratio)
{
    shape->draw(ratio);
}

std::string ViewZone::toString()
{
    std::ostringstream oss;
    oss << std::setprecision(2);
    oss << std::fixed;
    oss << Zone::toString() << shape->toString();
    return oss.str();
}