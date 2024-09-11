module game;

import std.math : exp, ceil;

import raylib;

import plr;
import dbg;
import tile;
import time;
import chunk;
import camera;
import vector;
import entity;
import keyboard;
import math_utils;
import gameobject;
import declarations;

void process() {
	foreach (GameObject obj; OBJECTS) {
		if (!obj.enabled)
			continue;

		obj.tick();
	}

	foreach (Entity entity; ENTITIES) {
		entity.tick();
	}

	player.tick();

	CAMERA.offset += CAMERA.velocity.scale(0.5);

	CAMERA.velocity = CAMERA.velocity.scale(exp(-7.5 * DELTA_TIME));

	CAMERA.speed = clamp(CAMERA.speed + Keyboard.getAxis(KeyboardKey.KEY_LEFT_SHIFT, KeyboardKey.KEY_LEFT_CONTROL) * 0.25 * DELTA_TIME, 0.001, 2.0);

	CAMERA.scale = clamp(
		CAMERA.scale + Keyboard.getAxis(KeyboardKey.KEY_E, KeyboardKey.KEY_Q) * DELTA_TIME,
		CAMERA.minScale, CAMERA.maxScale
	);

	Keyboard.update();

	float inputVector = Keyboard.getAxis(
		KeyboardKey.KEY_A,
		KeyboardKey.KEY_D
	);

	player.velocity = player.velocity + Vec!(dec, 2)(inputVector * player.moveSpeed * DELTA_TIME, 0);

	CAMERA.offset = player.position.scale(cast(dec) PIXELS_PER_TILE) * Vec!(dec, 2)(1, -1) + SCREEN_SIZE.scale(-0.5).cnv!dec();
}