module vector;

import std.conv : to;
import std.math : sqrt;

import raylib;

private static string[] content_alias() {
    return ["x", "y", "z", "w"];
}

struct Vec(T, size_t N) {
    T[N] contents;
    mixin genVecFields!(T, N, content_alias());

    void opOpAssign(string op)(Vec!(T, N) value) {
        mixin(
            "foreach (size_t i, ref T cont; value.contents)
            {
                this.contents[i] "
                ~ op ~ "= cont;
            }"
        );
    }

    Vec!(T, N) opBinary(string op : "*")(const T r) const {
        Vec!(T, N) ret;
        for (size_t i = 0; i < N; ++i) {
            ret.contents[i] = this.contents[i] * r;
        }
        return ret;
    }

    Vec!(T, N) opBinary(string op : "/")(const T r) const {
        Vec!(T, N) ret;
        for (size_t i = 0; i < N; ++i) {
            ret.contents[i] = this.contents[i] / r;
        }
        return ret;
    }

    Vec!(T, N) opBinary(string op : "%")(const T r) const {
        Vec!(T, N) ret;

        for (size_t i = 0; i < N; ++i)
            ret.contents[i] = this.contents[i];

        ret.length = this.length % r;

        return ret;
    }

    Vec!(T, N) opBinary(string op)(const Vec!(T, N) r) const {
        mixin(
            "Vec!(T, N) returning;
            foreach (size_t i, const T cont; r.contents)
            {
                returning.contents[i] = this.contents[i] "
                ~ op ~ " cont;
            }
            return returning;"
        );
    }

    Vec!(T, N) opUnary(string op)() const {
        mixin(
            "Vec!(T, N) returning;
            for (size_t i = 0; i < N; ++i)
            {
                returning.contents[i] = "
                ~ op ~ "this.contents[i];
            }
            return returning;"
        );
    }

    Vec!(T, N) scale(T scale) const {
        Vec!(T, N) ret;
        for (size_t i = 0; i < N; ++i) {
            ret.contents[i] = this.contents[i] * scale;
        }
        return ret;
    }

    static if (!is(T == double)) {
        Vec!(T, N) scale(double scale) const {
            Vec!(T, N) ret;
            for (size_t i = 0; i < N; ++i) {
                ret.contents[i] = cast(T)(cast(double) this.contents[i] * scale);
            }
            return ret;
        }
    }

    Vec!(R, N) cnv(R)() {
        Vec!(R, N) ret;

        for (size_t i = 0; i < N; ++i) {
            ret.contents[i] = cast(R) this.contents[i];
        }

        return ret;
    }

    Vec!(T, N) forEach(R)(R function(R) f) const {
        Vec!(T, N) ret;

        for (size_t i = 0; i < N; ++i) {
            ret.contents[i] = cast(T) f(this.contents[i]);
        }

        return ret;
    }

    Vec!(T, N) forEach(R)(R delegate(R) f) const {
        Vec!(T, N) ret;

        for (size_t i = 0; i < N; ++i) {
            ret.contents[i] = cast(T) f(this.contents[i]);
        }

        return ret;
    }

    @property T length() const {
        T sum = 0;
        for (size_t i = 0; i < N; ++i) {
            sum += this.contents[i] * this.contents[i];
        }

        return cast(T) sqrt(cast(real) sum);
    }

    @property void length(T set) {
        T len = this.length;

        this = this / (len / set);
    }

    @property Vec!(T, N) unit() const {
        return this / this.length;
    }

    static if (N == 2) {
        @property Vector2 rv() {
            return Vector2(cast(float) this.contents[0], cast(float) this.contents[1]);
        }
    }

    string toString() const {
        string ret = "{";

        for (size_t i = 0; i < N; ++i) {
            ret ~= to!string(this.contents[i]);
            if (i + 1 != N)
                ret ~= ", ";
        }

        return ret ~ "}";
    }
}

private mixin template genVecFields(T, size_t N, string[] content_alias) {
    mixin(_genField());

    private static string _genField() {
        string full = "this(";

        for (size_t i; i < N; ++i) {
            full ~= "T _" ~ to!string(i);
            if (i + 1 != N)
                full ~= ", ";
        }

        full ~= ") {\n";

        for (size_t i; i < N; ++i) {
            full ~= "this.contents[" ~ to!string(i) ~ "] = _" ~ to!string(i) ~ ";";
        }

        full ~= "}\n";

        for (size_t i; i < N; ++i) {
            if (i >= content_alias.length)
                break;

            full ~= "@property T " ~ content_alias[i] ~ "() const { return this.contents[" ~ to!string(
                i) ~ "]; }\n";
            full ~= "@property void " ~ content_alias[i] ~ "(T val) { contents[" ~ to!string(
                i) ~ "] = val; }\n";
        }

        return full;
    }
}

Vec!(float, 2) posFromRect(Rectangle rect) {
    return Vec!(float, 2)(rect.x, rect.y);
}

Vec!(float, 2) sizeFromRect(Rectangle rect) {
    return Vec!(float, 2)(rect.w, rect.h);
}
