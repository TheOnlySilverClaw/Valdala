module graphics;

import std::math;

struct Transform {
    Vec3 position;
    Quaternion rotation;
    Vec3 scale;
}