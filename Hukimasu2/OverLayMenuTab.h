//
//  OverLayMenuTab.h
//  Hukimasu2
//
//  Created by William DeVore on 11/4/11 A.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
//
// x x x x x
// x x x x x
// x x x x x

#import "Model.h"
#import <vector>

class OverLayMenuTab {
private:
    Model* _model;
    std::vector<CCLabelTTF*> _labels;
    
public:
    OverLayMenuTab();
    ~OverLayMenuTab();
    
    void setModel(Model* model);
    
};