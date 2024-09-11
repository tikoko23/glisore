module plr;

import raylib;

import dbg;
import tile;
import camera;
import vector;
import entity;
import gameobject;
import declarations;

class Player : Entity {
    override void render() {

        Rectangle shape = this.collider.shapes[0];

        Vec!(int, 2) pos = CAMERA.transform((this.position * Vec!(dec, 2)(1, -1) + posFromRect(shape)) * (cast(dec) PIXELS_PER_TILE) - CAMERA.offset).cnv!int();
        Vec!(int, 2) size = sizeFromRect(shape).scale(CAMERA.scale * PIXELS_PER_TILE).cnv!int();

        DrawRectangle(pos.x, pos.y, size.x, size.y, Colors.RED);
    }

    this() {
        collider = new Collider([Rectangle(-0.25, -0.375, 0.5, 0.75)]);
        this.headHeight = 0.36;
        this.jumpVelocity = 12;
        this.moveSpeed = 32;
    }
}

Player player;