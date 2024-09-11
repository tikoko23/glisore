module render;

import std.math : floor;

import raylib;

import plr;
import tile;
import chunk;
import vector;
import camera;
import assets;
import entity;
import gameobject;
import declarations;

static immutable ushort RENDER_DISTANCE = 2;

void drawTile(TilePos globalTilePos) {
	Tile tile = getTile(globalTilePos);

	if ("notRendered" in tile.tags)
		return;

	// Parse tile name to get the corresponding texture identifier
	NamespaceID fullId = splitId(tile.name);
	const string lookupName = parseId("tile/" ~ fullId.id, fullId.namespace); 

	// Allow the tile to use its custom renderer, if it exists
	if (tile.renderer != null) {

		tile.renderer(tile, globalTilePos, CAMERA);

	} else if (lookupName in TEXTURES.assets) {

		Vec!(int, 2) drawPos = tileToScreen(globalTilePos);

		Texture texture = TEXTURES[lookupName];

		DrawTextureEx(
			texture,
			Vector2(floor(cast(dec) drawPos.x), floor(cast(dec) drawPos.y)),
			0,
			cast(dec) PIXELS_PER_TILE / cast(dec) texture.width * CAMERA.scale, // Calculate texture scaling. This will downscale large textures and upscale tiny textures
			Colors.WHITE
		);
	}
}

void drawChunk(ChunkPos chunkPos) {
	for (int tile_x = 0; tile_x < CHUNK_WIDTH; ++tile_x) {
		for (int tile_y = 0; tile_y < CHUNK_HEIGHT; ++tile_y) {
			TilePos globalTilePos = chunkPos * TilePos(CHUNK_WIDTH, CHUNK_HEIGHT) + TilePos(tile_x, tile_y);

			drawTile(globalTilePos);
		}
	}
}

void draw() {
	// Draw chunks/tiles
	ChunkPos centerChunk = getChunkPosFromTile(player.position.cnv!long());

	// The chunks inside this area (centered on the player) will be drawn 
	ChunkPos chunkRenderArea = Vec!(long, 2)(RENDER_DISTANCE, RENDER_DISTANCE);
	ChunkPos startChunk = centerChunk - chunkRenderArea;
	ChunkPos endChunk = centerChunk + chunkRenderArea;

	for (long chunk_x = startChunk.x; chunk_x < endChunk.x; ++chunk_x) {
		for (long chunk_y = startChunk.y; chunk_y < endChunk.y; ++chunk_y) {

			ChunkPos chunkPos = ChunkPos(chunk_x, chunk_y);
			
			if (chunkPos !in CHUNKS)
				continue;
			
			drawChunk(chunkPos);
		}
	}

	foreach (GameObject obj; OBJECTS) {
		obj.render();
	}

	foreach (Entity entity; ENTITIES) {
		entity.render();
	}

	// Draw player
	player.render();
}