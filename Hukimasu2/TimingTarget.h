//
//  TimingTarget.h
//  Hukimasu
//
//  Created by William DeVore on 5/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

/**
 * This interface provides the methods which
 * are called by Animator during the course of a timing
 * sequence.  Applications
 * that wish to receive timing events will either create a subclass
 * of TimingTargetAdapter and override or they can create or use
 * an implementation of TimingTarget. A TimingTarget can be passed
 * into the constructor of Animator or set later with the 
 * {@link Animator#addTarget(TimingTarget)}
 * method.  Any Animator may have multiple TimingTargets.
 */

// Abstract interface
class TimingTarget {
private:
    int id;
    
public:
    TimingTarget();
    virtual ~TimingTarget();
    
    void setId(int id);
    int getId();

    bool operator==(const TimingTarget& other) const
    {
        return (id == other.id);
    }

    /**
     * This method will receive all of the timing events from an Animator
     * during an animation.  The fraction is the percent elapsed (0 to 1)
     * of the current animation cycle.
     * @param fraction the fraction of completion between the start and
     * end of the current cycle.  Note that on reversing cycles
     * ({@link Animator.Direction#BACKWARD}) the fraction decreases
     * from 1.0 to 0 on backwards-running cycles.  Note also that animations
     * with a duration of {@link Animator#INFINITE INFINITE} will call
     * timingEvent with an undefined value for fraction, since there is
     * no fraction that makes sense if the animation has no defined length.
     * @see Animator.Direction
     */
    virtual void timingEvent(float fraction) = 0;
    
    /**
     * Called when the Animator's animation begins.  This provides a chance
     * for targets to perform any setup required at animation start time.
     */
    virtual void begin() = 0;
    
    /**
     * Called when the Animator's animation ends
     */
    virtual void end() = 0;
    
    /**
     * Called when the Animator repeats the animation cycle
     */
    virtual void repeat() = 0;

};
