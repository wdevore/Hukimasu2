//
//  Animator.h
//  Hukimasu
//
//  Created by William DeVore on 5/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "Animator.h"
#import "cocos2d.h"

/**
 * This class controls animations.  Its constructors and various
 * set methods control the parameters under which animations are run,
 * and the other methods support starting and stopping the animation.
 * The parameters of this class use the concepts of a "cycle" (the base
 * animation) and an "envelope" that controls how the cycle is started,
 * ended, and repeated.
 * <p>
 * Most of the methods here are simple getters/setters for the properties
 * used by Animator.  Typical animations will simply use one of the 
 * two constructors (depending on whether you are constructing a repeating
 * animation), optionally call any of the <code>set*</code> methods to alter
 * any of the other parameters, and then call start() to run the animation.
 * For example, this animation will run for 1 second, calling your
 * {@link TimingTarget} with timing events when the animation is started,
 * running, and stopped:
 * <pre>
 *  Animator animator = new Animator(1000, myTarget);
 *  animator.start();
 * </pre>
 * The following variation will run a half-second animation 4 times, 
 * reversing direction each time:
 * <pre>
 *  Animator animator = new Animator(500, 4, RepeatBehavior.REVERSE, myTarget);
 *  animator.start();
 * </pre>
 * More complex animations can be created through using the properties
 * in Animator, such as {@link Animator#setAcceleration acceleration} and {@link
 * Animator#setDeceleration}. More automated animations can be created and run
 * using the {@link org.jdesktop.animation.timing.triggers triggers}
 * package to control animations through events and {@link
 * org.jdesktop.animation.timing.interpolation.PropertySetter} to 
 * handle animating object properties.
 */
#import <list>

#import "TimingSource.h"

#import "TimingSourceTarget.h"
#import "TimingTargetAdapter.h"
#import "Interpolator.h"

class Animator {
public:
    /**
     * EndBehavior determines what happens at the end of the animation.
     * @see #setEndBehavior
     */
    enum EndBehavior {
        /** Timing sequence will maintain its final value at the end */
        HOLD,
        /** Timing sequence should reset to the initial value at the end */
        RESET
    };
    
    /**
     * Direction is used to set the initial direction in which the
     * animation starts.
     * 
     * @see #setStartDirection
     */
    enum Direction {
        /**
         * cycle proceeds forward
         */
        FORWARD,
        /** cycle proceeds backward */
        BACKWARD
    };
    
    /**
     * RepeatBehavior determines how each successive cycle will flow.
     * @see #setRepeatBehavior
     */
    enum RepeatBehavior {
        /** 
         * Each repeated cycle proceeds in the same direction as the 
         * previous one.
         * For example: if one cycle is 1.0 -> 0.0, then looping around
         * would mean another 1.0 -> 0.0 cycle.
         */
        LOOP,
        /** 
         * Each cycle proceeds in the opposite direction as the 
         * previous one
         * 
         * For example: if one cycle is 1.0 -> 0.0, then reversing around
         * would mean another 0.0 -> 1.0 cycle.
         */
        REVERSE
    };
    
    /**
     * Used to specify unending duration or repeatCount
     * @see #setDuration
     * @see #setRepeatCount
     * */
    static int INFINITE;
    
private:
    // Use Cocos2d as the source from the tick() method.
    TimingSource* timer;
    
    TimingSourceTarget* timingSourceTarget;
    
    std::list<TimingTargetAdapter*> targets;
    
    long ticks;
    long accumTime;
    long previousTime;
    long cycleAccumTime;
    
    //long previousTimeDelta;
    long startTime;	    // Tracks original Animator start time
    long currentStartTime;  // Tracks start time of current cycle
    bool intRepeatCount;  // for typical cases of repeated cycles
    bool timeToStop;     // This gets triggered during fraction calculation
    bool hasBegun;
    long pauseBeginTime;        // Used for pause/resume
    bool running;        // Used for isRunning()
    
    // Private variables to hold the internal "envelope" values that control
    // how the cycle is started, ended, and repeated.
    double repeatCount;
    long startDelay;

    RepeatBehavior repeatBehavior;
    EndBehavior endBehavior;

    // Private variables to hold the internal values of the base
    // animation (the cycle)
    int duration;
    float acceleration;
    float deceleration;
    float startFraction;
    Direction startDirection; // Direction of each cycle
    Direction direction;
    
    Interpolator* interpolator;

public:
    Animator();

    /**
     * Constructor: this is a utility constructor
     * for a simple timing sequence that will run for 
     * <code>duration</code> length of time.  This variant takes no
     * TimingTarget, and is equivalent to calling {@link #Animator(int, 
     * TimingTarget)} with a TimingTarget of <code>null</code>.
     * 
     * @param duration The length of time that this will run, in milliseconds.
     */
    Animator(int duration);

    /**
     * Constructor: this is a utility constructor
     * for a simple timing sequence that will run for 
     * <code>duration</code> length of time.
     * 
     * @param duration The length of time that this will run, in milliseconds.
     * @param target TimingTarget object that will be called with
     * all timing events.  Null is acceptable, but no timingEvents will be
     * sent to any targets without future calls to {@link #addTarget}.
     */
    Animator(int duration, TimingTargetAdapter* target);

    /**
     * Constructor that sets the most common properties of a 
     * repeating animation.
     * @param duration the length of each animation cycle, in milliseconds.
     * This value can also be {@link #INFINITE} for animations that have no
     * end.  Note that fractions sent out with such unending animations will
     * be undefined since there is no fraction of an infinitely long cycle.
     * @param repeatCount the number of times the animation cycle will repeat.
     * This is a positive value, which allows a non-integral number
     * of repetitions (allowing an animation to stop mid-cycle, for example).
     * This value can also be {@link #INFINITE}, indicating that the animation
     * will continue repeating forever, or until manually stopped.
     * @param repeatBehavior {@link RepeatBehavior} of each successive
     * cycle.  A value of null is equivalent to RepeatBehavior.REVERSE.
     * @param target TimingTarget object that will be called with
     * all timing events.  Null is acceptable, but no timingEvents will be
     * sent to any targets without future calls to {@link #addTarget}.
     * @throws IllegalArgumentException if any parameters have invalid
     * values
     * @see Animator#INFINITE
     * @see Direction
     * @see EndBehavior
     */
    Animator(int duration, double repeatCount, RepeatBehavior repeatBehavior, TimingTargetAdapter* target);

    Animator(int duration, double repeatCount, RepeatBehavior repeatBehavior, TimingTargetAdapter* target, Interpolator* interpolator);

    ~Animator();

    void initialize();
    
    /**
     * Adds a TimingTarget to the list of targets that get notified of each
     * timingEvent.  This can be done at any time before, during, or after the
     * animation has started or completed; the new target will begin
     * having its TimingTarget methods called as soon as it is added.
     * If <code>target</code> is already on the list of targets in this Animator, it
     * is not added again (there will be only one instance of any given
     * target in any Animator's list of targets).
     * @param target TimingTarget to be added to the list of targets that
     * get notified by this Animator of all timing events. Target cannot
     * be null.
     */
    void addTarget(TimingTargetAdapter* target);

    /**
     * Removes the specified TimingTarget from the list of targets that get
     * notified of each timingEvent.  This can be done at any time before,
     * during, or after the animation has started or completed; the 
     * target will cease having its TimingTarget methods called as soon
     * as it is removed.
     * @param target TimingTarget to be removed from the list of targets that
     * get notified by this Animator of all timing events.
     */
    void removeTarget(TimingTargetAdapter* target);

    /**
     * Returns the initial direction for the animation.
     * @return direction that the initial animation cycle will be moving
     */
    Direction getStartDirection();

    /**
     * Sets the startDirection for the initial animation cycle.  The default 
     * startDirection is {@link Direction#FORWARD FORWARD}.
     * 
     * @param startDirection initial animation cycle direction
     * @see #isRunning()
     * @throws IllegalStateException if animation is already running; this
     * parameter may only be changed prior to starting the animation or 
     * after the animation has ended
     */
    void setStartDirection(Direction startDirection);

    /**
     * Returns the interpolator for the animation.
     * @return interpolator that the initial animation cycle uses
     */
    Interpolator* getInterpolator();

    /**
     * Sets the interpolator for the animation cycle.  The default 
     * interpolator is {@link LinearInterpolator}.
     * @param interpolator the interpolation to use each animation cycle
     * @see #isRunning()
     */
    void setInterpolator(Interpolator* interpolator);

    /**
     * Sets the fraction of the timing cycle that will be spent accelerating
     * at the beginning. The default acceleration value is 0 (no acceleration).
     * @param acceleration value from 0 to 1
     * @throws IllegalArgumentException acceleration value must be between 0 and
     * 1, inclusive. 
     * @throws IllegalArgumentException acceleration cannot be greater than
     * (1 - deceleration)
     * @throws IllegalStateException if animation is already running; this
     * parameter may only be changed prior to starting the animation or 
     * after the animation has ended
     * @see #isRunning()
     * @see #setDeceleration(float)
     */
    void setAcceleration(float acceleration);

    /**
     * Sets the fraction of the timing cycle that will be spent decelerating
     * at the end. The default deceleration value is 0 (no deceleration).
     * @param deceleration value from 0 to 1
     * @throws IllegalArgumentException deceleration value must be between 0 and
     * 1, inclusive. 
     * @throws IllegalArgumentException deceleration cannot be greater than
     * (1 - acceleration)
     * @throws IllegalStateException if animation is already running; this
     * parameter may only be changed prior to starting the animation or 
     * after the animation has ended
     * @see #isRunning()
     * @see #setAcceleration(float)
     */
    void setDeceleration(float deceleration);

    /**
     * Returns the current value of acceleration property
     * @return acceleration value
     */
    float getAcceleration();

    /**
     * Returns the current value of deceleration property
     * @return deceleration value
     */
    float getDeceleration();

    /**
     * Returns the duration of the animation.
     * @return the length of the animation, in milliseconds. A
     * return value of -1 indicates an {@link #INFINITE} duration.
     */
    int getDuration();

    /**
     * Sets the duration for the animation
     * @param duration the length of the animation, in milliseconds.  This
     * value can also be {@link #INFINITE}, meaning the animation will run
     * until manually stopped.
     * @throws IllegalStateException if animation is already running; this
     * parameter may only be changed prior to starting the animation or 
     * after the animation has ended
     * @see #isRunning()
     * @see #stop()
     */
    void setDuration(int duration);

    /**
     * @return the number of times the animation cycle will repeat.
     */
    double getRepeatCount();

    /**
     * Sets the number of times the animation cycle will repeat. The default
     * value is 1.
     * @param repeatCount Number of times the animation cycle will repeat.
     * This value may be >= 1 or {@link #INFINITE} for animations that repeat 
     * indefinitely.  The value may be fractional if the animation should
     * stop at some fractional point.
     * @throws IllegalArgumentException if repeatCount is not >=1 or 
     * INFINITE.
     * @throws IllegalStateException if animation is already running; this
     * parameter may only be changed prior to starting the animation or 
     * after the animation has ended
     * @see #isRunning()
     */
    void setRepeatCount(double repeatCount);

    /**
     * Returns the amount of delay prior to starting the first animation
     * cycle after the call to {@link #start}.
     * @return the duration, in milliseconds, between the call
     * to start the animation and the first animation cycle actually 
     * starting.
     * @see #start
     */
    int getStartDelay();

    /**
     * Sets the duration of the initial delay between calling {@link #start}
     * and the start of the first animation cycle. The default value is 0 (no 
     * delay).
     * @param startDelay the duration, in milliseconds, between the call
     * to start the animation and the first animation cycle actually 
     * starting. This value must be >= 0.
     * @throws IllegalArgumentException if startDelay is < 0
     * @throws IllegalStateException if animation is already running; this
     * parameter may only be changed prior to starting the animation or 
     * after the animation has ended
     * @see #isRunning()
     */
    void setStartDelay(long startDelay);

    /**
     * Returns the {@link RepeatBehavior} of the animation. The default
     * behavior is REVERSE, meaning that the animation will reverse direction
     * at the end of each cycle.
     * @return whether the animation will repeat in the same
     * direction or will reverse direction each time.
     */
    RepeatBehavior getRepeatBehavior();

    /**
     * Sets the {@link RepeatBehavior} of the animation.
     * @param repeatBehavior the behavior for each successive cycle in the
     * animation.  A null behavior is equivalent to specifying the default:
     * REVERSE.  The default behaviors is HOLD.
     * @throws IllegalStateException if animation is already running; this
     * parameter may only be changed prior to starting the animation or 
     * after the animation has ended
     * @see #isRunning()
     */
    void setRepeatBehavior(RepeatBehavior repeatBehavior);

    /**
     * Returns the {@link EndBehavior} of the animation, either HOLD to 
     * retain the final value or RESET to take on the initial value. The 
     * default behavior is HOLD.
     * @return the behavior at the end of the animation
     */
    EndBehavior getEndBehavior();

    /**
     * Sets the behavior at the end of the animation.
     * @param endBehavior the behavior at the end of the animation, either
     * HOLD or RESET.  A null value is equivalent to the default value of
     * HOLD.
     * @throws IllegalStateException if animation is already running; this
     * parameter may only be changed prior to starting the animation or 
     * after the animation has ended
     * @see #isRunning
     */
    void setEndBehavior(EndBehavior _endBehavior);

    /**
     * Returns the fraction that the first cycle will start at.
     * @return fraction between 0 and 1 at which the first cycle will start.
     */
    float getStartFraction();
    
    /**
     * Sets the initial fraction at which the first animation cycle will
     * begin.  The default value is 0.
     * @param startFraction
     * @see #isRunning()
     * @throws IllegalArgumentException if startFraction is less than 0
     * or greater than 1
     * @throws IllegalStateException if animation is already running; this
     * parameter may only be changed prior to starting the animation or 
     * after the animation has ended
     */
    void setStartFraction(float startFraction);

    /**
     * Starts the animation
     * @throws IllegalStateException if animation is already running; this
     * command may only be run prior to starting the animation or 
     * after the animation has ended
     */
    void start();

    /**
     * Returns whether this Animator object is currently running
     */
    bool isRunning();

    /**
     * This method is optional; animations will always stop on their own
     * if Animator is provided with appropriate values for
     * duration and repeatCount in the constructor.  But if the application 
     * wants to stop the timer mid-stream, this is the method to call.
     * This call will result in calls to the <code>end()</code> method
     * of all TimingTargets of this Animator.
     * @see #cancel()
     */
    void stop();

    /**
     * This method is like the {@link #stop} method, only this one will
     * not result in a calls to the <code>end()</code> method in all 
     * TimingTargets of this Animation; it simply cancels the Animator
     * immediately.
     * @see #stop()
     */
    void cancel();

    /**
     * This method pauses a running animation.  No further events are sent to
     * TimingTargets. A paused animation may be d again by calling the
     * {@link #resume} method.  Pausing a non-running animation has no effect.
     * 
     * @see #resume()
     * @see #isRunning()
     */
    void pause();

    /**
     * This method resumes a paused animation.  Resuming an animation that
     * is not paused has no effect.
     *
     * @see #pause()
     */
    void resume();

    /**
     * Returns the total elapsed time for the current animation.
     * @param currentTime value of current time to use in calculating
     * elapsed time.
     * @return the total time elapsed between the time
     * the Animator started and the supplied currentTime.
     */
    long getTotalElapsedTime(long currentTime);

    /**
     * Returns the total elapsed time for the current animation.  Calculates
     * current time.
     * @return the total time elapsed between the time
     * the Animator started and the current time.
     */
    long getTotalElapsedTime();

    /**
     * Returns the elapsed time for the current animation cycle.
     * @param currentTime value of current time to use in calculating
     * elapsed time.
     * @return the time elapsed between the time
     * this cycle started and the supplied currentTime.
     */
    long getCycleElapsedTime(long currentTime);

    /**
     * Returns the elapsed time for the current animation cycle. Calculates
     * current time.
     * @return the time elapsed between the time
     * this cycle started and the current time.
     */
    long getCycleElapsedTime();

    /**
     * This method calculates and returns the fraction elapsed of the current
     * cycle based on the current time
     * @return fraction elapsed of the current animation cycle
     */
    float getTimingFraction(long timeDelta);

    /**
     * Sets a new TimingSource that will supply the timing 
     * events to this Animator. Animator uses an internal
     * TimingSource by default and most developers will probably not
     * need to change this default behavior. But for those wishing to
     * supply their own timer, this method can be called to
     * tell Animator to use a different TimingSource instead. Setting a
     * new TimingSource implicitly removes this Animator as a listener
     * to any previously-set TimingSource object.
     * 
     * @param timer the object that will provide the
     * timing events to Animator. A value of <code>null</code> is
     * equivalent to telling Animator to use its default internal
     * TimingSource object.
     * @throws IllegalStateException if animation is already running; this
     * parameter may only be changed prior to starting the animation or 
     * after the animation has ended.
     */
    void setTimer(TimingSource* timer);

    /**
     * Internal timingEvent method that sends out the event to all targets
     */
    void timingEvent(float fraction);
    
private:
    //
    // TimingTarget implementations
    // Note that Animator does not actually implement TimingTarget directly;
    // it does not want to make public methods of these events.  But it uses
    // the same methods internally to propagate the events to all of the
    // Animator's targets.
    //
    
    /**
     * Internal begin event that sends out the event to all targets
     */
    void begin();

    /**
     * Internal end event that sends out the event to all targets
     */
    void end();

    /**
     * Internal repeat event that sends out the event to all targets
     */
    void repeat();

    /**
     * This method calculates a new fraction value based on the
     * acceleration and deceleration settings of Animator.  It then
     * passes this value through the interpolator (by default, 
     * a LinearInterpolator) before returning it to the caller (who
     * will then call the timingEvent() methods in the TimingTargets
     * with this fraction).
     */
    float timingEventPreprocessor(float fraction);

    void validateRepeatCount(double repeatCount);
    
};
