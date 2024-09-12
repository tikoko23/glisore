module entity;

import std.math : exp, floor, ceil;

import raylib;

import dbg;
import time;
import tile;
import chunk;
import vector;
import camera;
import gameobject;
import misc_utils;
import declarations;

abstract class Entity : GameObject {
    bool grounded = false;
    bool useGravity = true;
    dec headHeight = 0;
    dec jumpVelocity = 0;
    dec moveSpeed = 0;

    // Takes the current velocity as an argument, returns the final velocity
    Vec!(dec, 2) delegate(Vec!(dec, 2)) dampeningFn = null;

    override void tick() {

        // Some physics stuff idk
        if (this.useGravity)
            this.velocity += GRAVITY_ACCELARATION * DELTA_TIME;

        this.position += this.velocity * DELTA_TIME;

        if (this.dampeningFn != null)
            this.velocity = this.dampeningFn(this.velocity);

        this.handleTileCollision();
    }

    void handleTileCollision() {
        Vec!(dec, 2) targetOffset = Vec!(dec, 2)(0, 0);
        bool collided = false;
        bool collidedX = false;
        bool collidedY = false;

        for (size_t i = 0; i < this.collider.shapes.length; ++i) {
            foreach (Direction dir; DIRECTIONS) {
                Rectangle res = testSideTiles(dir, i);

                // If collided...
                if (res != EMPTY_RECT) {
                    targetOffset = targetOffset + -getDirVector!dec(dir) * measureRect(res, axisOf(dir));
                    collided = true;

                    if (axisOf(dir) == Axis.Y)
                        collidedY = true;
                    else
                        collidedX = true;
                }
            }
        }

        if (!collided)
            return;

        if (collidedX)
            this.velocity.x = 0;
        
        if (collidedY)
            this.velocity.y = 0;

        this.position = this.position + targetOffset;
    }

    Rectangle testSideTiles(Direction d, size_t shapeIdx = 0) {
        TilePos otherTilePos = toTilePos(this.position) + getDirVector!long(d);

        dec sizeOffset = ceil(this.collider.height / 2);
        Vec!(dec, 2) offsetV = axisOf(d) == Axis.X ? Vec!(dec, 2)(0, sizeOffset) : Vec!(dec, 2)(sizeOffset, 0);
        Tile otherTile = getTile(otherTilePos);

        if ("passthrough" in otherTile.tags)
            return EMPTY_RECT;

        Rectangle thisCollider = rectOffset(this.collider.shapes[shapeIdx], this.position.cnv!float());
        Rectangle otherTileCollider = rectFromV(
            otherTilePos.cnv!float() - offsetV,
            Vec!(float, 2)(1.0f, 1.0f) + offsetV * 2
        );

        DEBUG_DRAW_QUERIES.insertFront(() {
            if (axisOf(d) == Axis.X)
                drawDebugRect(rectOffset(otherTileCollider, Vec!(float, 2)(0, 2)));
            else
                drawDebugRect(otherTileCollider);
            
        });

        Rectangle colRes = GetCollisionRec(thisCollider, otherTileCollider);

        if (Collider.isValidCollision(colRes))
            return colRes;
        
        return EMPTY_RECT;
    }

    void jump() {
        this.velocity.y = this.velocity.y + this.jumpVelocity;
    }

    this() {
        this.dampeningFn = (Vec!(dec, 2) v) => v.scale(exp(-1 * DELTA_TIME));
    }
}

Vec!(dec, 2) GRAVITY_ACCELARATION = Vec!(dec, 2)(0, -9.81);

Entity[] ENTITIES;
