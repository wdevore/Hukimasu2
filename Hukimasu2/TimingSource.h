//
//  TimingSource.h
//  Hukimasu
//
//  Created by William DeVore on 5/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <list>

class TimingSourceTarget;
class TimingEventListener;
class Animator;

class TimingSource {
private:
    std::list<TimingSourceTarget*> listeners;
    
protected:
    int tid;
    
    Animator *animator;
    bool running;
    int resolution;
    bool delayEnabled;
    long delay;
    // This accumulates until it reaches the resolution.
    // Any rollover is carried into the next time window.
    long long accumTime;
    long timeDelta;
    long previousTimeDelta;
    
public:
    TimingSource();
    virtual ~TimingSource();
    
    virtual int getId();
    
    virtual void attachAnimator(Animator* animator);

    virtual void tick(long dt);

    //virtual long microTimeDelta();
    
    /**
     * Starts the TimingSource
     */
    virtual void start() = 0;
    
    /**
     * Stops the TimingSource
     */
    virtual void stop() = 0;

    /**
     * NOTE: Because the source is driven by Cocos2d frame rate, the
     * resolution is automatically 1/60sec = 16666usecs.
     * Resolution for us is going to be how manys usecs before another tick
     * is sent to the animator. The default as indicated is 1/60secs, so for
     * a animation that is 2secs long there will be 120 ticks.
     *
     * So if we want only 10 ticks over 2secs = 2000000usecs, then we need to accumulate
     * for 200000usecs before we forward a tick to the animator.
     *
     * Sets the delay between callback events. This 
     * will be called by Animator if its
     * {@link Animator#setResolution(int) setResolution(int)}
     * method is called. Note that the actual resolution may vary,
     * according to the resolution of the timer used by the framework as well
     * as system load and configuration; this value should be seen more as a
     * minimum resolution than a guaranteed resolution.
     * @param resolution delay, in milliseconds, between 
     * each timing event callback.
     * @see Animator#setResolution(int)
     */
    virtual void setResolution(int resolution) = 0;

    /**
     * Sets delay which should be observed by the 
     * TimingSource after a call to {@link #start()}. Some timers may not be
     * able to adhere to specific resolution requests
     * @param delay delay, in milliseconds, to pause before
     * starting timing events.
     * @see Animator#setStartDelay(int)
     */
    virtual void setStartDelay(long delay) = 0;

    /**
     * Adds a TimingEventListener to the set of listeners that
     * receive timing events from this TimingSource.
     * @param listener the listener to be added.
     */
    void addEventListener(TimingSourceTarget* listener);

    /**
     * Removes a TimingEventListener from the set of listeners that
     * receive timing events from this TimingSource.
     * @param listener the listener to be removed.
     */
    void removeEventListener(TimingSourceTarget* listener);

    /**
     * Subclasses call this method to post timing events to this
     * object's {@link TimingEventListener} objects.
     */
    void timingEvent();

};
