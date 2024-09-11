module dbg;

import std.stdio : stderr, write, writef;
import std.math : floor, fmod;
import std.container : DList;

import raylib;

import plr;
import tile;
import chunk;
import camera;
import render;
import string_utils;

class Logger {
    string context;
    string prefix;
    string suffix;
    bool colored;
    bool errorToStderr = true;

    this(string context, bool colored = true, string prefix = "", string suffix = "\n") {
        this.context = context;
        this.colored = colored;
        this.prefix = prefix;
        this.suffix = suffix;
    }

    void log(string message) {
        write(prefix ~ "[" ~ context ~ "] LOG: " ~ message ~ suffix);
    }

    void warn(string message) {
        string msg = prefix ~ "[" ~ context ~ "] WARN: " ~ message ~ suffix;
        
        if (this.colored) {
            write("\x1b[33m" ~ msg ~ "\x1b[39m");
        } else {
            write(msg);
        }
    }

    void error(string message) {
        string msg = prefix ~ "[" ~ context ~ "] ERROR: " ~ message ~ suffix;
        
        if (this.colored) {
            msg = "\x1b[31m" ~ msg ~ "\x1b[39m";
        }

        if (this.errorToStderr) {
            stderr.write(msg);
        } else {
            write(msg);
        }
    }

    void logf(T...)(string format, T args) {
        writef(prefix ~ "[" ~ context ~ "] LOG: " ~ format ~ suffix, args);
    }

    void warnf(T...)(string message, T args) {
        string msg = prefix ~ "[" ~ context ~ "] WARN: " ~ message ~ suffix;
        
        if (this.colored) {
            writef("\x1b[33m" ~ msg ~ "\x1b[39m", args);
        } else {
            writef(msg, args);
        }
    }

    void errorf(T...)(string message, T args) {
        string msg = prefix ~ "[" ~ context ~ "] ERROR: " ~ message ~ suffix;
        
        if (this.colored) {
            msg = "\x1b[31m" ~ msg ~ "\x1b[39m";
        }

        if (this.errorToStderr) {
            stderr.writef(msg, args);
        } else {
            writef(msg, args);
        }
    }
}

alias DebugDrawQuery = void delegate();

DList!DebugDrawQuery DEBUG_DRAW_QUERIES;

void debugDraw() {
	draw();

	while (!DEBUG_DRAW_QUERIES.empty()) {
		DebugDrawQuery top = DEBUG_DRAW_QUERIES.front();

		top();

		DEBUG_DRAW_QUERIES.removeFront();
	}

	// X AXIS
	DrawLineEx(
		(Vector2(0, -CAMERA.offset.y) - SCREEN_SIZE.rv / 2) * CAMERA.scale + SCREEN_SIZE.rv / 2,
		(Vector2(SCREEN_SIZE.x, -CAMERA.offset.y) - SCREEN_SIZE.rv / 2) * CAMERA.scale + SCREEN_SIZE.rv / 2,
		2,
		Color(0, 0, 255, 255)
	);

	// Y AXIS
	DrawLineEx(
		(Vector2(-CAMERA.offset.x, 0) - SCREEN_SIZE.rv / 2) * CAMERA.scale + SCREEN_SIZE.rv / 2,
		(Vector2(-CAMERA.offset.x, SCREEN_SIZE.y) - SCREEN_SIZE.rv / 2) * CAMERA.scale + SCREEN_SIZE.rv / 2,
		2,
		Color(255, 0, 0, 255)
	);

	// Tile borders

	for (size_t y = 0; y <= SCREEN_SIZE.y / PIXELS_PER_TILE; ++y) {
		float y_val = (-fmod(CAMERA.offset.y, PIXELS_PER_TILE) + y * PIXELS_PER_TILE - SCREEN_SIZE.y / 2) * CAMERA.scale + SCREEN_SIZE.y / 2;
		DrawLineEx(
			Vector2(0, y_val),
			Vector2(SCREEN_SIZE.x, y_val),
			1,
			Color(210, 210, 0, 100)
		);
	}

	for (size_t x = 0; x <= SCREEN_SIZE.x / PIXELS_PER_TILE; ++x) {
		float x_val = (-fmod(CAMERA.offset.x, PIXELS_PER_TILE) + x * PIXELS_PER_TILE - SCREEN_SIZE.x / 2) * CAMERA.scale + SCREEN_SIZE.x / 2;
		DrawLineEx(
			Vector2(x_val, 0),
			Vector2(x_val, SCREEN_SIZE.y),
			1,
			Color(210, 210, 0, 100)
		);
	}

	// Chunk borders

	// for (size_t y = 0; y <= SCREEN_SIZE.y / PIXELS_PER_CHUNK_V; ++y) {
	// 	float y_val = (-fmod(CAMERA.offset.y, PIXELS_PER_CHUNK_V) + y * PIXELS_PER_CHUNK_V - SCREEN_SIZE.y / 2) * CAMERA.scale + SCREEN_SIZE.y / 2;
	// 	DrawLineEx(
	// 		Vector2(0, y_val),
	// 		Vector2(SCREEN_SIZE.x, y_val),
	// 		1,
	// 		Color(255, 100, 100, 100)
	// 	);
	// }

	DrawRing(Vector2(SCREEN_SIZE.x / 2, SCREEN_SIZE.y / 2), 4, 2, 0, 360, 32, Color(0, 255, 0, 255));

	int offset = 10;

	DrawText("Performance:", 10, offset, 24, Color(200, 200, 200, 255));

	offset += 34;

	DrawText(TextFormat("FPS: %d", GetFPS()), 10, offset, 20, Colors.WHITE);

	offset += 30;

	DrawText("Camera:", 10, offset, 24, Color(200, 200, 200, 255));

	offset += 34;

	DrawText(TextFormat("Offset X: %.2f Y: %.2f", CAMERA.offset.x, CAMERA.offset.y), 10, offset, 20, Colors.WHITE);

	offset += 30;

	DrawText(TextFormat("Scale: %.2f", CAMERA.scale), 10, offset, 20, Colors.WHITE);

	offset += 30;

	DrawText(
		TextFormat(
			"Center X: %d Y: %d",
			cast(int) floor((CAMERA.offset.x + SCREEN_SIZE.x / 2) / PIXELS_PER_TILE),
			cast(int) floor((-CAMERA.offset.y - SCREEN_SIZE.y / 2) / PIXELS_PER_TILE),
		),
		10, offset, 20, Color(0, 255, 0, 255)
	);
	
	offset += 30;

	DrawText("Player:", 10, offset, 24, Color(200, 200, 200, 255));

	offset += 34;

	DrawText(TextFormat("Position: %.2fm, %.2fm", player.position.x, player.position.y), 10, offset, 20, Colors.WHITE);

	offset += 30;

	DrawText(TextFormat("Velocity: %.2fm/s, %.2fm/s", player.velocity.x, player.velocity.y), 10, offset, 20, Colors.WHITE);

	offset += 30;

	TilePos overlapping = player.position.forEach(&floor).cnv!long();
	Tile tile = getTile(overlapping);

	DrawText(TextFormat("Tile: %s", cast(char*) nstr(tile.name)), 10, offset, 20, Colors.WHITE);
}