module time;

import event;

double DELTA_TIME = 0.0;

class Timer {
    private double elapsed;
    private double target;
    private bool paused;

    public bool pausedOnFinish = true;

    Event!Timer onFinish;

    this(double target, bool paused = true, double elapsed = 0.0) {
        this.target = target;
        this.paused = paused;
        this.elapsed = elapsed;
    }

    this() {
        this.target = 0.0;
        this.paused = true;
        this.elapsed = 0.0;
    }

    void resume() {
        this.paused = false;
    }

    void pause() {
        this.paused = true;
    }

    bool isPaused() {
        return this.paused;
    }

    Timer setPaused(bool state) {
        this.paused = state;
        return this;
    }

    double getElapsed() {
        return this.elapsed;
    }

    Timer setElapsed(double elapsed) {
        this.elapsed = elapsed;
        return this;
    }

    double getTarget() {
        return this.target;
    }

    Timer setTarget(double target) {
        this.target = target;
        return this;
    }

    void pauseOnFinish(bool set) {
        this.pausedOnFinish = set;
    }

    Timer reset() {
        this.elapsed = 0.0;
        this.paused = this.pausedOnFinish;
        return this;
    }

    void tick(double dt) {
        if (this.paused)
            return;

        this.elapsed += dt;

        if (this.elapsed >= this.target) {
            if (this.pausedOnFinish)
                this.paused = true;

            onFinish.trigger(this);
        }
    }
}