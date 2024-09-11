module tile;

import std.variant;
import std.math : floor;

import raylib;

import assets;
import vector;
import camera;
import declarations;

static immutable int PIXELS_PER_TILE = 64;

alias TilePos = Vec!(long, 2);

alias TileTicker = void delegate(Tile, TilePos, double);
alias TileRenderer = void delegate(Tile, TilePos, CCamera);

class Tile {
    string name;

    TileTicker ticker = null;
    TileRenderer renderer = null;

    Variant[string] metadata;
    bool[string] tags;

    this(string name) {
        this.name = name;
    }
}

class TileMaker {

    string name;

    TileTicker ticker = null;
    TileRenderer renderer = null;

    Variant[string] metadata;
    bool[string] tags;

    this(string name) {
        this.name = name;
    }

    TileMaker setTicker(TileTicker ticker) {
        this.ticker = ticker;
        return this;
    }

    TileMaker setRenderer(TileRenderer renderer) {
        this.renderer = renderer;
        return this;
    }

    TileMaker addTag(string tag) {
        this.tags[tag] = true;
        return this;
    }

    TileMaker setMetadata(T)(string key, T value) {
        this.metadata[key] = Variant(value);
        return this;
    }

    Tile build() {
        Tile tile = new Tile(this.name);

        tile.ticker = this.ticker;
        tile.renderer = this.renderer;
        
        foreach (string key, bool _; this.tags) {
            tile.tags[key] = true;
        }

        foreach (string key, Variant value; this.metadata) {
            tile.metadata[key] = value;
        }

        return tile;
    }

    @property Tile tile() {
        return this.build();
    }
}

TileMaker[string] TILES;

class Tiles {

    private static TileMaker register(TileMaker tile) {
        if (tile.name in TILES)
            throw new Exception("Tile '" ~ tile.name ~ "'already registered");

        TILES[tile.name] = tile;   
        return tile;     
    }

    static this() {
        register(new TileMaker(parseId("air"))
            .addTag("passthrough")
            .addTag("invisible")
            .addTag("notRendered")
            .setMetadata("hardness", -1));

        register(new TileMaker(parseId("grass"))
            .setMetadata("hardness", 1));
        
        register(new TileMaker(parseId("rock"))
            .setMetadata("hardness", 2));
    }
}

TilePos toTilePos(Vec!(dec, 2) p) {
    return p.forEach(&floor).cnv!long();
}

Vec!(int, 2) tileToScreen(TilePos t) {

    // Offset added because raylib draws from the top left
    t = t + TilePos(0, 1);

    // Calculate offset
    Vec!(dec, 2) _pure = ((t.scale(PIXELS_PER_TILE) * TilePos(1, -1)).cnv!dec() - CAMERA.offset);

    const Vec!(dec, 2) screenMid = SCREEN_SIZE.cnv!dec().scale(0.5);

    // Apply camera scale
    _pure = (_pure - screenMid).scale(CAMERA.scale) + screenMid;

    return _pure.cnv!int();
}

Vec!(int, 2) tileToScreen(Vec!(dec, 2) t) {
    // Offset added because raylib draws from the top left
    t = t + Vec!(dec, 2)(0, 1);

    // Calculate offset
    Vec!(dec, 2) _pure = ((t.scale(cast(dec) PIXELS_PER_TILE) * Vec!(dec, 2)(1, -1)) - CAMERA.offset);

    const Vec!(dec, 2) screenMid = SCREEN_SIZE.cnv!dec().scale(0.5);

    // Apply camera scale
    _pure = (_pure - screenMid).scale(CAMERA.scale) + screenMid;

    return _pure.cnv!int();
}