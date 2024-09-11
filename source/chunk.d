module chunk;

import std.conv : to;
import std.math : floor;

import tile;
import vector;
import math_utils;
import declarations;
import string_utils;
import assets : parseId;

alias ChunkPos = Vec!(long, 2);

static immutable uint CHUNK_WIDTH = 16;
static immutable uint CHUNK_HEIGHT = 16;
static immutable uint PIXELS_PER_CHUNK_H = PIXELS_PER_TILE * CHUNK_WIDTH;
static immutable uint PIXELS_PER_CHUNK_V = PIXELS_PER_TILE * CHUNK_HEIGHT;

static immutable uint CHUNK_PRELOAD_WIDTH = 8;
static immutable uint CHUNK_PRELOAD_HEIGHT = 8;

class Chunk {
    Tile[CHUNK_WIDTH][CHUNK_HEIGHT] tiles = new Tile[CHUNK_WIDTH][CHUNK_HEIGHT];

    ref Tile[CHUNK_HEIGHT] opIndex(uint index) {       
        return this.tiles[index];
    }

    void generate() {

    }

    void load(string filename) {

    }

    void save(string filename) {

    }

    this() {
        for (int x = 0; x < CHUNK_WIDTH; ++x) {
            for (int y = 0; y < CHUNK_HEIGHT; ++y) {
                this.tiles[x][y] = TILES[parseId("air")].tile;
            }
        }
    }
}

Chunk[ChunkPos] CHUNKS;

void loadChunksAround(ChunkPos pos, const Vec!(uint, 2) size = Vec!(uint, 2)(CHUNK_PRELOAD_WIDTH, CHUNK_PRELOAD_HEIGHT)) {
    
}

string getChunkName(ChunkPos pos) {
    return prettify(GAME_NAME, CapsOptions.NONE)[0..2] ~ "_chunk_x" ~ to!string(pos.x) ~ "_y" ~ to!string(pos.y);
}

ChunkPos getChunkPosFromTile(TilePos pos) {
    return ChunkPos(
        cast(long) floor(cast(dec) pos.x / CHUNK_WIDTH),
        cast(long) floor(cast(dec) pos.y / CHUNK_HEIGHT)
    );
}

Tile getTile(TilePos pos) {
    TilePos chunkOffset = TilePos(loopIdx!long(pos.x, CHUNK_WIDTH), loopIdx!long(pos.y, CHUNK_HEIGHT));
    ChunkPos chunkPos = getChunkPosFromTile(pos);

    if (chunkPos !in CHUNKS)
        return null;
    
    Chunk chunk = CHUNKS[chunkPos];

    return chunk.tiles[chunkOffset.x][chunkOffset.y];
}