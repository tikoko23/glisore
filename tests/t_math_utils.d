module t_math_utils;

unittest {
    import math_utils : lerp;

    assert(lerp(2, 5, 0.5) == 3.5);
    assert(lerp(9, 5, 0.0) == 9);
}

unittest {
    import raylib;

    import std.random : Random;

    import declarations : dec;
    import math_utils : PerlinNoise;

    static immutable int SEED = 23;
    static immutable int RENDER_SIZE = 1024;
    static immutable int NOISE_SIZE = 16;
    static immutable int SCALE = RENDER_SIZE / NOISE_SIZE;
    static immutable ushort LAYERS = 4;

    auto noise = new PerlinNoise!(LAYERS, NOISE_SIZE)(Random(SEED));

    SetTraceLogLevel(7);

    InitWindow(RENDER_SIZE, RENDER_SIZE, "PERLIN NOISE");
    SetTargetFPS(60);
    SetExitKey(KeyboardKey.KEY_NULL);

    dec[RENDER_SIZE][RENDER_SIZE] result = new dec[RENDER_SIZE][RENDER_SIZE];

    for (dec x = 0; x < RENDER_SIZE; ++x) {
        for (dec y = 0; y < RENDER_SIZE; ++y) {
            result[cast(int) x][cast(int) y] = noise.get(x / SCALE, y / SCALE);
        }
    }

    /*********************************************
    *      Arguments used for assertions:        *
    *      SEED = 23                             *
    *      RENDER_SIZE = 1024                    *
    *      NOISE_SIZE = 16                       *
    *      SCALE = RENDER_SIZE / NOISE_SIZE      *
    *      LAYERS = 4                            *
    *********************************************/

    assert(result[0][0] == 0.5);
    assert(result[23][23] == 0.576121747493743896484375);
    assert(result[5][654] == 0.623888552188873291015625);

    while (!WindowShouldClose()) {
        if (GetKeyPressed() != KeyboardKey.KEY_NULL)
            break;

        BeginDrawing();
        ClearBackground(Colors.WHITE);

        for (int x = 0; x < RENDER_SIZE; ++x) {
            for (int y = 0; y < RENDER_SIZE; ++y) {
                dec f = result[x][y];
                DrawPixel(x, y, Color(cast(ubyte) (255 * f), cast(ubyte) (255 * f), cast(ubyte) (255 * f), 255));
            }
        }

        EndDrawing();
    }

    CloseWindow();
}