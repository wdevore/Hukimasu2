//
//  StringUtilities.h
//  Hukimasu
//
//  Created by William DeVore on 5/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <iostream>
#import <iomanip>
#import <sstream>
#import "Box2D.h"
#import "vmath.h"

class StringUtilities {
   
public:
    
    // Utilities
    static std::string toString(double value)
    {
        std::ostringstream oss;
        oss << std::setprecision(2);
        oss << std::fixed;
        oss << value;
        return oss.str();
    }
    
    static std::string toString(float value)
    {
        std::ostringstream oss;
        oss << std::setprecision(8);
        oss << std::fixed;
        oss << value;
        return oss.str();
    }
    
    static std::string toString(int value)
    {
        std::ostringstream oss;
        oss << value;
        return oss.str();
    }
    
    static std::string toString(long value)
    {
        std::ostringstream oss;
        oss << value;
        return oss.str();
    }
    
    static std::string toString(long long value)
    {
        std::ostringstream oss;
        oss << value;
        return oss.str();
    }
    
    static std::string toString(long double value)
    {
        std::ostringstream oss;
        oss << value;
        return oss.str();
    }
    
    static std::string toString(b2Vec2 value)
    {
        std::ostringstream oss;
        oss << std::setprecision(2);
        oss << std::fixed;
        oss << "(" << value.x << ", " << value.y << ")";
        return oss.str();
    }

    static std::string toString(Vector2f value)
    {
        std::ostringstream oss;
        oss << std::setprecision(2);
        oss << std::fixed;
        oss << "(" << value.x << ", " << value.y << ")";
        return oss.str();
    }
    
//    static std::string toString(CGPoint value)
//    {
//        std::ostringstream oss;
//        oss << "(" << value.x << ", " << value.y << ")";
//        return oss.str();
//    }
//    
    static std::string toString(Vector3f value)
    {
        std::ostringstream oss;
        oss << std::setprecision(2);
        oss << std::fixed;
        oss << "(" << value.x << ", " << value.y << ", " << value.z << ")";
        return oss.str();
    }
    
    static std::string toString(Vector4f value)
    {
        std::ostringstream oss;
        oss << std::setprecision(2);
        oss << std::fixed;
        oss << "(" << value.x << ", " << value.y << ", " << value.z << ", " << value.w << ")";
        return oss.str();
    }
    
    static void dump(const std::string& msg)
    {
        std::cout << "##################################################" << std::endl;
        std::cout << "## " << msg << std::endl;
        std::cout << "##################################################" << std::endl;
    }
    
    static void log(const std::string& msg)
    {
        std::cout << msg << std::endl;
    }

    static void log(const std::string& msg, const std::string& value)
    {
        std::cout << msg << value << std::endl;
    }

    static void log(const std::string& msg, int value)
    {
        std::cout << msg << toString(value) << std::endl;
    }

    static void log(const std::string& msg, long value)
    {
        std::cout << msg << toString(value) << std::endl;
    }
    
    static void log(const std::string& msg, long long value)
    {
        std::cout << msg << toString(value) << std::endl;
    }
    
    static void log(const std::string& msg, long double value)
    {
        std::cout << msg << toString(value) << std::endl;
    }
    
    static void log(const std::string& msg, float value)
    {
        std::cout << msg << toString(value) << std::endl;
    }

    static void log(const std::string& msg, double value)
    {
        std::cout << msg << toString(value) << std::endl;
    }

    static void log(const std::string& msg, b2Vec2 value)
    {
        std::cout << msg << toString(value) << std::endl;
    }
    
    static void log(const std::string& msg, Vector2f value)
    {
        std::cout << msg << toString(value) << std::endl;
    }
    
    static void log(const std::string& msg, Vector3f value)
    {
        std::cout << msg << toString(value) << std::endl;
    }
    
    static void log(const std::string& msg, Vector4f value)
    {
        std::cout << msg << toString(value) << std::endl;
    }

//    static void log(const std::string& msg, CGPoint value)
//    {
//        std::cout << msg << toString(value) << std::endl;
//    }
//    
};
