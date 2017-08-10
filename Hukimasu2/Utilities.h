//
//  Utilities.h
//  Hukimasu
//
//  Created by William DeVore on 5/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <list>
#import "cocos2d.h"
#import "StringUtilities.h"
#import "TimingSource.h"

class Utilities {
public:
    //Pixel to metres ratio. Box2D uses metres as the unit for measurement.
    //This ratio defines how many pixels correspond to 1 Box2D "metre"
    //Box2D is optimized for objects of 1x1 metre therefore it makes sense
    //to define the ratio so that your most common object type is 1x1 metre.
    
    static long previousCount;
    static long long elapsedCount;
    static long deltaCount;
    
    static int objIds;
    
    static std::list<TimingSource*> timerSources;

    static b2Vec2* rectangleVertices;
    static int rectangleVertexCount;

    static b2Vec2* circleVertices;
    static int circleVertexCount;
    
    static double EPSILON;
    
    // -------------------------------------------------------------------
    // Simple colors
    // -------------------------------------------------------------------
    static float Color_BlueViolet[4];
    static float Color_Coral[4];
    static float Color_Orange[4];
    static float Color_Orchid[4];  // purple like color
    static float Color_White[4];
    static float Color_Gray[4];
    static float Color_Green[4];
    static float Color_Yellow[4];
    static float Color_Gold[4];
    static float Color_Blue[4];
    static float Color_Red[4];
    static float Color_GreenYellow[4];
    static float Color_StealBlue[4];
    static float Color_Violet[4];
    static float Color_Brown[4];
    static float Color_Peach[4];

    static void init()
    {
        struct timeval now;

        gettimeofday( &now, NULL);
        previousCount = now.tv_usec;
        
        elapsedCount = 0;
        deltaCount = 0;
    }
    
    static int genId()
    {
        return objIds++;
    }
    
    static long getTimeDelta()
    {
        struct timeval now;
        
        if( gettimeofday(&now, NULL) != 0 ) {
            StringUtilities::dump("Utilities::getTimeDelta error in gettimeofday");
            return 0;
        }
        
        if (now.tv_usec < previousCount)
        {
            // A rollover occurred:
            // N = Current usec count, P = previouse usec count.
            //
            // 0 - - - - - - - N - - - - - P - - - - - - 999999
            //  \----A-------/              \-----B--------/ 
            //
            // If N < P then we had a rollover of the counter which maxes out at 999999
            // So we add B + A = (999999 - P) + (0 + N) to get the total delta since previous call.
            deltaCount = 999999 - previousCount + now.tv_usec;
            elapsedCount += deltaCount;
        }
        else
        {
            deltaCount = now.tv_usec - previousCount;
            elapsedCount += deltaCount;
        }
        
        previousCount = now.tv_usec;

        return deltaCount;
    }
    
    static void addTimingSource(TimingSource* source)
    {
        std::list<TimingSource*>::iterator iter = timerSources.begin();
        
        bool found = false;
        
        while (iter != timerSources.end()) {
            TimingSource* tsource = *iter;
            if (tsource->getId() == source->getId()) {
                found = true;
                break;
            }
            ++iter;
        }
        
        if (!found) {
            timerSources.push_back(source);
        }
    }
    
    static void updateTimingSources(long dt)
    {
        std::list<TimingSource*>::iterator iter = timerSources.begin();
        
        while (iter != timerSources.end()) {
            TimingSource* source = *iter;
            source->tick(dt);
            ++iter;
        }
    }
    
    // This rectangle is defined as:
    // 0,1                 1,1
    //  .<---------------.
    //  |                    ^
    //  |                    |
    //  |                    |
    //  |                    |
    //  v                    |
    //  .--------------->.
    // 0,0                 1,0
    //
    // Upper left quadrant.
    // You need to translate it by 0.5f if you need it centered.
    static b2Vec2* getNormalizedVertexRectangle()
    {
        if (rectangleVertices == NULL) {
            rectangleVertexCount = 4;
            rectangleVertices = new b2Vec2[rectangleVertexCount];
            rectangleVertices[0].Set(0.0f, 0.0f);
            rectangleVertices[1].Set(1.0f, 0.0f);
            rectangleVertices[2].Set(1.0f, 1.0f);
            rectangleVertices[3].Set(0.0f, 1.0f);
        }
        
        return rectangleVertices;
    }
    
    static b2Vec2* getNormalizedVertexCircle()
    {
        if (circleVertices == NULL) {
            // This ship is a circle plus to columns
            circleVertexCount = 32;
            float32 k_segments = circleVertexCount;
            float32 k_increment = 2.0f * b2_pi / k_segments;
            float32 theta = 0.0f;
            const float32 radius = 1.0f;
            
            circleVertices = new b2Vec2[circleVertexCount];
            for (int32 i = 0; i < k_segments; ++i)
            {
                b2Vec2 v = radius * b2Vec2(cosf(theta), sinf(theta));
                circleVertices[i].Set(v.x, v.y);
                theta += k_increment;
            }
        }
        
        return circleVertices;
    }
    
    static void release()
    {
        timerSources.clear();
        delete rectangleVertices;
        delete circleVertices;
    }
};