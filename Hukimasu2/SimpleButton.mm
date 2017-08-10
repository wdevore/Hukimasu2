//
//  SimpleButton.m
//  Hukimasu2
//
//  Created by William DeVore on 11/4/11 A.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Utilities.h"
#import "SimpleButton.h"

SimpleButton::SimpleButton() {
    colorOn[0] = Utilities::Color_White[0] * 255.0f;
    colorOn[1] = Utilities::Color_White[1] * 255.0f;
    colorOn[2] = Utilities::Color_White[2] * 255.0f;
    colorOn[3] = 1.0f;
    colorOff[0] = Utilities::Color_Gray[0] * 255.0f;
    colorOff[1] = Utilities::Color_Gray[1] * 255.0f;
    colorOff[2] = Utilities::Color_Gray[2] * 255.0f;
    colorOff[3] = 1.0f;
    onOff = false;
}

SimpleButton::~SimpleButton()
{
    [_Label release];
    _Label = nil;
    
    listeners.clear();
}

void SimpleButton::subscribeListener(IMessage *listener)
{
    std::list<IMessage*>::iterator iter = listeners.begin();
    
    bool found = false;
    
    while (iter != listeners.end()) {
        IMessage* l = *iter;
        if (l == listener)
        {
            found = true;
            break;
        }
        ++iter;
    }
    
    if (!found) {
        listeners.push_back(listener);
    }

}

void SimpleButton::unSubscribeListener(IMessage *listener)
{
    listeners.remove(listener);
}

void SimpleButton::message(int message)
{
    switch (message) {
        case 1: // On
            onOff = true;
            break;
        case 0: // Off
            onOff = false;
            break;
            
        default:
            break;
    }
}

void SimpleButton::message(int message, IMessage* sender)
{
}

void SimpleButton::turnOn()
{
    message(1);
    [_Label setColor:ccc3(colorOn[0], colorOn[1], colorOn[2])];
}

void SimpleButton::turnOff()
{
    message(0);
    [_Label setColor:ccc3(colorOff[0], colorOff[1], colorOff[2])];
}

void SimpleButton::toggle()
{
    if (onOff)
        turnOff();
    else
        turnOn();
}

void SimpleButton::setColor(float r, float g, float b, float a)
{
    colorOn[0] = r * 255.0f;
    colorOn[1] = g * 255.0f;
    colorOn[2] = b * 255.0f;
    colorOn[3] = a;
    colorOff[0] = colorOn[0]/2.0f;
    colorOff[1] = colorOn[1]/2.0f;
    colorOff[2] = colorOn[2]/2.0f;
    colorOff[3] = a;
    [_Label setColor:ccc3(colorOff[0], colorOff[1], colorOff[2])];
}

void SimpleButton::setVisible(bool visible)
{
    if (visible)
        [_Label setVisible:YES ];
    else
        [_Label setVisible:NO ];
}

void SimpleButton::setText(NSString *text)
{
    setText(text, 24.0f);
}

void SimpleButton::setText(NSString *text, float fontSize)
{
    _Label = [CCLabelTTF labelWithString:text fontName:@"Arial" fontSize:fontSize];
}

void SimpleButton::setCellSize(int w, int h)
{
    hSize = h;
    wSize = w;
}

void SimpleButton::setCell(int cx, int cy)
{
    cellX = cx;
    cellY = cy;
    [_Label setPosition:ccp(cellX * wSize + wSize/2.0f, cellY * hSize + hSize/2.0f)];
    [_Label setVisible:NO ];
}

CCLabelTTF* SimpleButton::getLabel()
{
    return _Label;
}

bool SimpleButton::touched(CGPoint p)
{
    return touched(p.x, p.y);
}

bool SimpleButton::touched(int x, int y)
{
    // For example: menu button is 2,0 or col:2 row:0
    if ((x > (cellX * wSize) && x < ((cellX + 1) * wSize)) && (y > (cellY * hSize)) && (y < ((cellY + 1) * hSize)))
    {
        int m = cellX + (cellY * 5);
        sendMessage(m);
        StringUtilities::log("button message: ", m);
        return true;
    }
    return false;
}

void SimpleButton::sendMessage(int m)
{
    std::list<IMessage*>::iterator iter = listeners.begin();
    
    while (iter != listeners.end()) {
        IMessage* l = *iter;
        l->message(m, this);
        ++iter;
    }
}

