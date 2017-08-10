//
//  TimingEventListener.h
//  Hukimasu
//
//  Created by William DeVore on 5/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "TimingSource.h"

/**
 * This interface is implemented by any object wishing to receive events from a
 * {@link TimingSource} object. The TimingEventListener would be added as a 
 * listener to the TimingSource object via the {@link 
 * TimingSource#addEventListener(TimingEventListener)} method.
 * <p>
 * This functionality is handled automatically inside of {@link Animator}. To
 * use a non-default TimingSource object for Animator, simply call 
 * {@link Animator#setTimer(TimingSource)} and the appropriate listeners
 * will be set up internally.
 *
 */

// Abstract class
class TimingEventListener {
private:
    int id;
    
public:
    TimingEventListener();
    virtual ~TimingEventListener();
    
    /**
     * This method is called by the {@link TimingSource} object while the
     * timer is running.
     *
     * @param timingSource the object that generates the timing events.
     */
    virtual void timingSourceEvent(TimingSource* timingSource) = 0;
    
    void setId(int id);
    int getId();

    bool operator==(const TimingEventListener& other) const
    {
        return (id == other.id);
    }
};
