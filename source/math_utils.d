module math_utils;

import std.math : floor, PI, sin, cos, abs;
import std.random : Random, uniform;
import std.datetime : Clock;

import vector;

import declarations;

pragma(inline, true)
dec max(dec a, dec b) {
    return a > b ? a : b;
}

pragma(inline, true)
dec min(dec a, dec b) {
    return a < b ? a : b;
}

pragma(inline, true)
dec lerp(dec a, dec b, dec t) {
    return (1 - t) * a + t * b;
}

pragma(inline, true)
dec clamp(dec x, dec mn, dec mx) {
    return max(mn, min(mx, x));
}

// Integer modulus that loops back with negative numbers (Example: -1 % 10 = 9)
pragma(inline, true)
size_t loopIdx(T)(T a, T r) {
    if (a < 0)
        return (r - (cast(size_t) abs(a) % r)) % r;

    return a % r;
}

T[] shuffle(T)(T[] __arr, Random random = Random(Clock.currTime().toUnixTime!int())) {

    T[] arr = [];

    arr ~= __arr;

    shuffleImpl(arr, random);

    return arr;
}

void shuffleImpl(T)(ref T[] arr, Random random = Random(Clock.currTime().toUnixTime!int())) {
    for (size_t it = 0; it < arr.length; ++it) {
        size_t idx1 = uniform(0, arr.length, random);
        size_t idx2 = uniform(0, arr.length, random);

        T tmp = arr[idx1];
        arr[idx1] = arr[idx2];
        arr[idx2] = tmp;
    }
}

private class PerlinNoiseGenerator(ubyte directionCount = 36) {
    private int[] permutation = [];
    private int tableSize;
    private static Vec!(dec, 2)[directionCount] directions = new Vec!(dec, 2)[directionCount];

    dec get(dec x, dec y) {
        int x0 = cast(int) floor(x) % tableSize;
        int x1 = (x0 + 1) % tableSize;
        int y0 = cast(int) floor(y) % tableSize;
        int y1 = (y0 + 1) % tableSize;

        float rx = x - floor(x);
        float ry = y - floor(y);

        float u = fade(rx);
        float v = fade(ry);

        int aa = permutation[permutation[x0] + y0];
        int ab = permutation[permutation[x0] + y1];
        int ba = permutation[permutation[x1] + y0];
        int bb = permutation[permutation[x1] + y1];

        float d1 = lerp(grad(aa, rx, ry), grad(ba, rx - 1, ry), u);
        float d2 = lerp(grad(ab, rx, ry - 1), grad(bb, rx - 1, ry - 1), u);

        return (lerp(d1, d2, v) + 1) / 2;
    }

    private static dec fade(dec t) {
        return t * t * t * (t * (t * 6 - 15) + 10);
    }

    private static dec grad(int hash, dec x, dec y) {
        hash %= directionCount;
        return directions[hash].x * x + directions[hash].y * y;
    }

    this(int tableSize = 512, Random randGen = Random(Clock.currTime().toUnixTime!int())) {
        this.tableSize = tableSize;

        for (int i = 0; i < tableSize; ++i)
            permutation ~= i;
        
        permutation = shuffle(permutation, randGen);

        permutation ~= permutation;
    }

    static this() {
        dec a = 2 * PI / directionCount;
        for (int i = 0; i < directionCount; ++i) {
            Vec!(dec, 2) direction = Vec!(dec, 2)(cos(i * a), sin(i * a));
            directions[i] = direction;
        }
    }
}

class PerlinNoise(ushort LAYERS, int baseSize = 256, ubyte directionCount = 36, bool exponentialScaling = true, int multiplierIfLinear = 4, dec persistence = 0.5) {
    
    static assert(LAYERS > 0, "Layers must be more than 0");
    static assert(!(exponentialScaling && LAYERS > 6), "Layers must be less than 7 if exponentialScaling is true due to performance problems");

    private PerlinNoiseGenerator!directionCount[LAYERS] generators = new PerlinNoiseGenerator!directionCount[LAYERS];
    private dec[LAYERS] scales = new dec[LAYERS];

    dec get(dec x, dec y) {
        dec result = 0;
        dec amplitude = 1.0;
        dec totalAmplitude = 0.0;

        for (ushort i = 0; i < LAYERS; ++i) {
            result += generators[i].get(x * scales[i] / baseSize, y * scales[i] / baseSize) * amplitude;
            totalAmplitude += amplitude;
            amplitude *= persistence;
        }

        return result / totalAmplitude;
    }

    this(Random randGen = Random(Clock.currTime().toUnixTime!int())) {
        for (ushort i = 0; i < LAYERS; ++i) {
            int size = baseSize;

            static if (exponentialScaling)
                size *= 1 << (i + 1);
            else
                size *= multiplierIfLinear * (i + 1);

            if (size < 1) size = 1;

            Random ps = Random(uniform(int.min, int.max, randGen));
            generators[i] = new PerlinNoiseGenerator!directionCount(size, ps);
            scales[i] = size;
        }
    }

    this(Random[LAYERS] randGens) {
        for (ushort i = 0; i < LAYERS; ++i) {
            int size = baseSize;

            static if (exponentialScaling)
                size *= 1 << (i + 1);
            else
                size *= multiplierIfLinear * (i + 1);
            
            if (size < 1) size = 1;

            generators[i] = new PerlinNoiseGenerator!directionCount(size, randGens[i]);
            scales[i] = size;
        }
    }
}