//
//  KeyFrames.h
//  Hukimasu
//
//  Created by William DeVore on 5/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <vector>
#import "StringUtilities.h"
#import "KeyValues.h"
#import "KeyTimes.h"
#import "KeyInterpolators.h"
#import "KeyFrames.h"

/**
 * 
 * KeyFrames holds information about the times at which values are sampled
 * (KeyTimes) and the values at those times (KeyValues). It also holds
 * information about how to interpolate between these values for times that lie
 * between the sampling points.
 * 
 */
template <typename T>
class KeyFrames {
private:
    KeyValues<T>* keyValues;
    KeyTimes* keysTimes;
    KeyInterpolators* interpolators;
    
public:
    KeyFrames()
    {
        keyValues = NULL;
        keysTimes = NULL;
        interpolators = NULL;
    };
    
    ~KeyFrames()
    {
        delete interpolators;
        delete keysTimes;
    };
    
    /**
	 * Simplest variation; determine keyTimes based on even division of 0-1
	 * range based on number of keyValues. This constructor assumes LINEAR
	 * interpolation.
	 * 
	 * @param keyValues
	 *            values that will be assumed at each time in keyTimes
	 */
	KeyFrames(KeyValues<T>* keyValues)
    {
        this->keyValues = NULL;
        keysTimes = NULL;
        interpolators = NULL;
        init(keyValues, NULL, NULL);
    }

    /**
	 * Simplest variation; determine keyTimes based on even division of 0-1
	 * range based on number of keyValues.
	 * 
	 * @param keyValues
	 *            values that will be assumed at each time in keyTimes
	 */
	KeyFrames(KeyValues<T>* keyValues, Interpolator* interpolator)
    {
        this->keyValues = NULL;
        keysTimes = NULL;
        std::vector<Interpolator*>* iList = new std::vector<Interpolator*>();
        iList->push_back(interpolator);
        init(keyValues, NULL, iList);
    }
    
    /**
	 * This variant takes both keyValues (values at each point in time) and
	 * keyTimes (times at which values are sampled).
	 * 
	 * @param keyValues
	 *            values that the animation will assume at each of the
	 *            corresponding times in keyTimes
	 * @param keyTimes
	 *            times at which the animation will assume the corresponding
	 *            values in keyValues
	 * @throws IllegalArgumentException
	 *             keyTimes and keySizes must have the same number of elements
	 *             since these structures are meant to have corresponding
	 *             entries; an exception is thrown otherwise.
	 */
	KeyFrames(KeyValues<T>* keyValues, KeyTimes* keyTimes)
    {
        init(keyValues, keyTimes, NULL);
    }

    /**
	 * Full constructor: caller provides an instance of all key* structures
	 * which will be used to calculate between all times in the keyTimes list. A
	 * null interpolator parameter is equivalent to calling
	 * {@link KeyFrames#KeyFrames(KeyValues, KeyTimes)}.
	 * 
	 * @param keyValues
	 *            values that the animation will assume at each of the
	 *            corresponding times in keyTimes
	 * @param keyTimes
	 *            times at which the animation will assume the corresponding
	 *            values in keyValues
	 * @param interpolators
	 *            collection of Interpolators that control the calculation of
	 *            values in each of the intervals defined by keyFrames. If this
	 *            value is null, a {@link LinearInterpolator} will be used for
	 *            all intervals. If there is only one interpolator, that
	 *            interpolator will be used for all intervals. Otherwise, there
	 *            must be a number of interpolators equal to the number of
	 *            intervals (which is one less than the number of keyTimes).
	 * @throws IllegalArgumentException
	 *             keyTimes and keyValues must have the same number of elements
	 *             since these structures are meant to have corresponding
	 *             entries; an exception is thrown otherwise.
	 * @throws IllegalArgumentException
	 *             The number of interpolators must either be zero
	 *             (interpolators == null), one, or one less than the size of
	 *             keyTimes.
	 */
	KeyFrames(KeyValues<T>* keyValues, KeyTimes* keyTimes, std::vector<Interpolator*>* interpolators)
    {
        init(keyValues, keyTimes, interpolators);
    }

    /**
	 * Utility constructor that assumes even division of times according to size
	 * of keyValues and interpolation according to interpolators parameter.
	 * 
	 * @param keyValues
	 *            values that the animation will assume at each of the
	 *            corresponding times in keyTimes
	 * @param interpolators
	 *            collection of Interpolators that control the calculation of
	 *            values in each of the intervals defined by keyFrames. If this
	 *            value is null, a {@link LinearInterpolator} will be used for
	 *            all intervals. If there is only one interpolator, that
	 *            interpolator will be used for all intervals. Otherwise, there
	 *            must be a number of interpolators equal to the number of
	 *            intervals (which is one less than the number of keyTimes).
	 * @throws IllegalArgumentException
	 *             The number of interpolators must either be zero
	 *             (interpolators == null), one, or one less than the size of
	 *             keyTimes.
	 */
	KeyFrames(KeyValues<T>* keyValues, std::vector<Interpolator*>* interpolators)
    {
        init(keyValues, NULL, interpolators);
    }

    KeyValues<T>* getKeyValues()
    {
        return keyValues;
    }

    KeyTimes* getKeyTimes()
    {
        return keysTimes;
    }

    bool isToAnimation()
    {
        return keyValues[0]->isToAnimation();
    }

    /**
	 * Returns time interval that contains this time fraction
	 */
	int getInterval(float fraction)
    {
        return keysTimes->getInterval(fraction);
    }

    /**
	 * Returns a value for the given fraction elapsed of the animation cycle.
	 * Given the fraction, this method will determine what interval the fraction
	 * lies within, how much of that interval has elapsed, what the boundary
	 * values are (from KeyValues), what the interpolated fraction is (from the
	 * Interpolator for the interval), and what the final interpolated
	 * intermediate value is (using the appropriate Evaluator). This method will
	 * call into the Interpolator for the time interval to get the interpolated
	 * method. To ensure that future operations succeed, the value received from
	 * the interpolation will be clamped to the interval [0,1].
	 */
	T getValue(float fraction)
    {
        // First, figure out the real fraction to use, given the
        // interpolation type and keyTimes
        int interval = getInterval(fraction);
        float t0 = keysTimes->getTime(interval);
        float t1 = keysTimes->getTime(interval + 1);
        float t = (fraction - t0) / (t1 - t0);
        
        float interpolatedT = interpolators->interpolate(interval, t);
        
        // clamp to avoid problems with buggy Interpolators
        if (interpolatedT < 0.0f) {
            interpolatedT = 0.0f;
        } else if (interpolatedT > 1.0f) {
            interpolatedT = 1.0f;
        }
        
        return keyValues->getValue(interval, (interval + 1), interpolatedT);
    }

    std::string toStringAsFloats()
    {
        std::string s = "values: ";
        s.append(keyValues->toStringAsFloats());
        s.append(", times:");
        s.append(keysTimes->toString());
        return s;
    }

    std::string toStringAsb2Vectors()
    {
        std::string s = "values: ";
        s.append(keyValues->toStringAsb2Vectors());
        s.append(", times:");
        s.append(keysTimes->toString());
        return s;
    }
    
private:
	/**
	 * Utility function called by constructors to perform common initialization
	 * chores
	 */
    void init(KeyValues<T>* keyValues, KeyTimes* keyTimes, std::vector<Interpolator*>* interpolators)
    {
        int numFrames = keyValues->getSize();
        bool allocatedTimes = false;
        
        // If keyTimes null, create our own
        if (keyTimes == NULL) {
            std::vector<float> keyTimesArray(numFrames, 0);
            float timeVal = 0.0f;
            keyTimesArray[0] = timeVal;
            
            for (int i = 1; i < (numFrames - 1); ++i) {
                timeVal += (1.0f / (numFrames - 1));
                keyTimesArray[i] = timeVal;
            }
            
            keyTimesArray[numFrames - 1] = 1.0f;
            
            this->keysTimes = new KeyTimes(keyTimesArray);
            allocatedTimes = true;
        } else {
            this->keysTimes = keyTimes;
        }
        
        this->keyValues = keyValues;
        
        if (numFrames != this->keysTimes->getSize()) {
            StringUtilities::dump("keyValues and keyTimes must be of equal size");
            if (allocatedTimes && this->keysTimes != NULL)
                delete this->keysTimes;
            return;
        }
        
        if (interpolators != NULL && (interpolators->size() != (numFrames - 1)) && (interpolators->size() != 1)) {
            StringUtilities::dump("interpolators must be either null (implying interpolation for all intervals), a single interpolator (which will be used for all intervals), or a number of interpolators equal to one less than the number of times.");
            if (allocatedTimes && this->keysTimes != NULL)
                delete this->keysTimes;
            return;
        }
        
        this->interpolators = new KeyInterpolators(numFrames - 1, interpolators);
    }

};