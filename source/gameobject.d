module gameobject;

import std.math : exp, abs;

import raylib;

import time;
import event;
import vector;
import math_utils;
import declarations;

class Collider {
    Rectangle[] shapes;

    this(Rectangle[] shapes) {
        this.shapes = shapes;
    }

    Event!GameObject touched = new Event!GameObject();

    @property dec height() {
        dec highestPoint = float.infinity;
        dec lowestPoint = -float.infinity;

        foreach (Rectangle shape; shapes) {
            highestPoint = min(highestPoint, shape.y);
            lowestPoint = max(lowestPoint, shape.y + shape.height);
        }

        return abs(highestPoint - lowestPoint);
    }

    static bool isValidCollision(Rectangle r) {
        return r.w > 0 && r.h > 0;
    }
}

abstract class GameObject {
    bool enabled = true;
    Vec!(dec, 2) position;
    Vec!(dec, 2) velocity;
    Collider collider;

    void tick() {
        position += velocity;
        velocity = velocity.scale(exp(-1 * DELTA_TIME));
    }

    abstract void render();

    this() {
        this.position = Vec!(dec, 2)(0, 0);
        this.velocity = Vec!(dec, 2)(0, 0);
        this.collider = new Collider([Rectangle(-1, -1, 2, 2)]);
    }
}

GameObject[] OBJECTS = [];