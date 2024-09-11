module app;

import raylib;

import dbg;
import plr;
import init; 
import game;
import time;
import tile;
import chunk;
import vector;
import render;
import assets;
import keyboard;
import declarations;

void main() {
	Logger dbg = new Logger("MAIN");

	player = new Player();

	SetTraceLogLevel(RAYLIB_LOG_LEVEL);

	_init();
	void function() drawFn = &draw;
	Color backgroundColor = Color(15, 15, 25, 255);

	Keyboard.getKeyPressedEvent(KeyboardKey.KEY_F7).bind(() {
		if (!IsKeyDown(KeyboardKey.KEY_LEFT_ALT))
			return;
		
		if (drawFn == &draw)
			drawFn = &debugDraw;
		else
			drawFn = &draw;
	});

	{
		Chunk chunk = new Chunk();
		for (int i = 0; i < 3; ++i) {
			for (int j = 0; j < CHUNK_WIDTH; ++j) {
				chunk[i][j] = TILES[parseId("rock")].tile;
			}
		}

		CHUNKS[ChunkPos(0, 0)] = chunk;
	}

	long pregenSize = 2;
	for (long x = -pregenSize; x <= pregenSize; ++x) {
		for (long y = -pregenSize; y <= pregenSize; ++y) {
			if (x == 0 && y == 0)
				continue;
			
			CHUNKS[ChunkPos(x, y)] = new Chunk();
		}
	}

	{
		Chunk chunk = new Chunk();
		for (int j = 0; j < CHUNK_WIDTH; ++j) {
			chunk[j][$ - 1] = TILES[parseId("rock")].tile;
		}

		CHUNKS[ChunkPos(0, -1)] = chunk;
	}

	player.position = Vec!(dec, 2)(4, 4);

	Keyboard.getKeyPressedEvent(KeyboardKey.KEY_W).bind(() {
		player.jump();
	});

	PlayMusicStream(MUSIC["larden"]);

	dbg.log("Entering event loop...");
	while (!WindowShouldClose()) {
		DELTA_TIME = GetFrameTime();
		
		//UpdateMusicStream(MUSIC["larden"]);

		process();

		BeginDrawing();
		ClearBackground(backgroundColor);
		drawFn();
		EndDrawing();
	}

	dbg.log("Event loop finished");

	finish();
}