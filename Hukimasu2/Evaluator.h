//
//  Evaluator.h
//  Hukimasu
//
//  Created by William DeVore on 5/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

template <typename T>
class Evaluator {
private:
    
public:
    Evaluator() {};
    virtual ~Evaluator() {};
    
    /**
     * Abstract method to evaluate between two boundary values.  Built-in
     * implementations all use linear parametric evaluation:
     * <pre>
     *      v = v0 + (v1 - v0) * fraction
     * </pre>
     * Extenders of Evaluator will need to override this method
     * and do something similar for their own types.  Note that this
     * mechanism may be used to create non-linear interpolators for
     * specific value types, although it may besimpler to just use 
     * the linear/parametric interpolation
     * technique here and perform non-linear interpolation through 
     * custom Interpolators rather than perform custom calculations in
     * this method; the point of this class is to allow calculations with
     * new/unknown types, not to provide another mechanism for non-linear
     * interpolation.
     */
    virtual T evaluate(T v0, T v1, float fraction) = 0;
};
