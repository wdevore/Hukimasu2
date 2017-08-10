//
//  SimpleButton.h
//  Hukimasu2
//
//  Created by William DeVore on 11/4/11 A.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import <list>
#import "IMessage.h"

class SimpleButton : public IMessage {
private:
    std::list<IMessage*> listeners;
    int cellX;
    int cellY;
    int hSize;
    int wSize;
    float colorOn[4];
    float colorOff[4];
    bool onOff;
    
    CCLabelTTF* _Label;

public:
    SimpleButton();
    ~SimpleButton();

    static SimpleButton* createButton(NSString* text, float fontSize, int cellWidth, int cellHeight, int cellX, int cellY)
    {
        SimpleButton* button = new SimpleButton();
        button->setText(text, fontSize);
        button->setCellSize(cellWidth, cellHeight);
        button->setCell(cellX, cellY);
        return button;
    }
    
    // IMessage interface methods.
    virtual void subscribeListener(IMessage* listener);
    virtual void unSubscribeListener(IMessage* listener);
    virtual void message(int message);
    virtual void message(int message, IMessage* sender);
    
    void setText(NSString* text);
    void setText(NSString* text, float fontSize);
    void setCellSize(int w, int h);
    void setCell(int x, int y);
    void setVisible(bool visible);
    void setColor(float r, float g, float b, float a);
    
    void turnOn();
    void turnOff();
    void toggle();
    
    bool touched(int x, int y);
    bool touched(CGPoint p);
    
    void sendMessage(int m);
    
    CCLabelTTF* getLabel();
};