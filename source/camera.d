module camera;

import raylib;

import vector;
import declarations;

class CCamera {
    Vec!(dec, 2) offset = Vec!(dec, 2)(0, 0);
    Vec!(dec, 2) velocity = Vec!(dec, 2)(0, 0);

    dec scale = 1;
    dec minScale = 0.1;
    dec maxScale = 10;
    dec speed = 1;

    Vec!(T, 2) transform(T)(Vec!(T, 2) pos) {
        return (pos - SCREEN_SIZE.scale(0.5).cnv!T()).scale(this.scale) + SCREEN_SIZE.scale(0.5).cnv!T();
    }

    Rectangle transform(Rectangle r) {
        Vec!(float, 2) pos = transform(posFromRect(r));
        return Rectangle(pos.x, pos.y, r.w * this.scale, r.h * this.scale);
    }
}

CCamera CAMERA;
Vec!(int, 2) SCREEN_SIZE = Vec!(int, 2)(-1, -1);