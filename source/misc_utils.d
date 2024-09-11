module misc_utils;

import raylib;

import vector;
import declarations;

enum Direction {
    UP,
    DOWN,
    LEFT,
    RIGHT
}

enum Axis {
    X,
    Y
}

immutable Direction[] DIRECTIONS = [Direction.UP, Direction.RIGHT, Direction.DOWN, Direction.LEFT];
immutable Rectangle EMPTY_RECT = Rectangle(0, 0, 0, 0);

Vec!(T, 2) getDirVector(T)(Direction d) {
    final switch (d) {
    case Direction.UP:
        return Vec!(T, 2)(0, -1);
    case Direction.DOWN:
        return Vec!(T, 2)(0, 1);
    case Direction.LEFT:
        return Vec!(T, 2)(-1, 0);
    case Direction.RIGHT:
        return Vec!(T, 2)(1, 0);
    }
}

Vec!(T, 2) getAxisVector(T)(Axis a, T value = 1) {
    if (a == Axis.X)
        return Vec!(T, 2)(value, 0);

    return Vec!(T, 2)(0, value);
}

Rectangle scaleRect(Rectangle r, dec s) {
    return Rectangle(r.x * s, r.y * s, r.width * s, r.height * s);
}

Rectangle rectFromV(Vec!(float, 2) pos, Vec!(float, 2) size) {
    return Rectangle(pos.x, pos.y, size.x, size.y);
}

Rectangle rectOffset(Rectangle r, Vec!(float, 2) offset) {
    return Rectangle(r.x + offset.x, r.y + offset.y, r.width, r.height);
}

Axis inv(Axis a) {
    return a == Axis.X ? Axis.Y : Axis.X;
}

Axis axisOf(Direction d) {
    switch (d) {
    case Direction.UP:
        return Axis.Y;
    case Direction.DOWN:
        return Axis.Y;
    default:
        return Axis.X;
    }
}

T boolToNum(T)(bool b) {
    return b ? 1 : 0;
}

float measureRect(Rectangle r, Axis a) {
    final switch (a) {
    case Axis.X:
        return r.width;
    case Axis.Y:
        return r.height;
    }
}