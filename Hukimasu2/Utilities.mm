//
//  Utilities.m
//  Hukimasu
//
//  Created by William DeVore on 5/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "Utilities.h"

int Utilities::objIds = 0;
std::list<TimingSource*> Utilities::timerSources;

b2Vec2* Utilities::rectangleVertices = NULL;
int Utilities::rectangleVertexCount = 0;

b2Vec2* Utilities::circleVertices = NULL;
int Utilities::circleVertexCount = 0;

long Utilities::previousCount = 0;
long long Utilities::elapsedCount = 0;
long Utilities::deltaCount = 0;

double Utilities::EPSILON = 0.0005;

float Utilities::Color_BlueViolet[4] = {138.0f/255.0f, 43.0f/255.0f, 226.0f/255.0f, 1.0f};
float Utilities::Color_Coral[4] = {205.0f/255.0f, 77.0f/255.0f, 176.0f/255.0f, 1.0f};
float Utilities::Color_Orange[4] = {255.0f/255.0f, 165.0f/255.0f, 0.0f/255.0f, 1.0f};
float Utilities::Color_Orchid[4] = {153.0f/255.0f, 50.0f/255.0f, 204.0f/255.0f, 1.0f};
float Utilities::Color_White[4] = {1.0f, 1.0f, 1.0f, 1.0f};
float Utilities::Color_Gray[4] = {0.5f, 0.5f, 0.5f, 1.0f};
float Utilities::Color_Green[4] = {0.0f, 1.0f, 0.0f, 1.0f};
float Utilities::Color_Yellow[4] = {1.0f, 1.0f, 0.0f, 1.0f};
float Utilities::Color_Gold[4] = {1.0f, 215.0f/255.0f, 0.0f, 1.0f};
float Utilities::Color_Blue[4] = {0.0f, 0.0f, 1.0f, 1.0f};
float Utilities::Color_Red[4] = {1.0f, 0.0f, 0.0f, 1.0f};
float Utilities::Color_GreenYellow[4] = {173.0f/255.0f, 47.0f/255.0f, 0.0f, 1.0f};
float Utilities::Color_StealBlue[4] = {70.0f/255.0f, 130.0f/255.0f, 180.0f/255.0f, 1.0f};
float Utilities::Color_Violet[4] = {238.0f/255.0f, 130.0f/255.0f, 238.0f/255.0f, 1.0f};
float Utilities::Color_Brown[4] = {165.0f/255.0f, 42.0f/255.0f, 42.0f/255.0f, 1.0f};
float Utilities::Color_Peach[4] = {255.0f/255.0f, 218.0f/255.0f, 185.0f/255.0f, 1.0f};
