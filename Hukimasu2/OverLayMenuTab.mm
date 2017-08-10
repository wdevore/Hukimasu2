//
//  OverLayMenuTab.m
//  Hukimasu2
//
//  Created by William DeVore on 11/4/11 A.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "OverLayMenuTab.h"

OverLayMenuTab::OverLayMenuTab() {
}

OverLayMenuTab::~OverLayMenuTab()
{
    std::vector<CCLabelTTF*>::iterator iter = _labels.begin();
    
    while (iter != _labels.end()) {
        CCLabelTTF* label = *iter;
        [label release];
        label = nil;
        ++iter;
    }

}

void OverLayMenuTab::setModel(Model *model)
{
    _model = model;
    
    CCLabelTTF* menuLabel = [CCLabelTTF labelWithString:@"Menu" fontName:@"Arial" fontSize:32.0];
    _labels.push_back(menuLabel);
}