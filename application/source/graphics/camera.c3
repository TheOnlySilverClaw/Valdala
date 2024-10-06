module graphics;

import std::math;
import std::io;

const UP = Vec3 { 0, 0, 1 };

struct Camera {
    inline Transform transform;
    
}

fn move_right() {

}

fn Matrix4f! Camera.project(&self) {

    Matrix4 identity = MATRIX4_IDENTITY;
    io::printfn("identity: %s", identity.m);
    Matrix4 translated = identity.translate(self.position);
    io::printfn("translated: %s", translated.m);

    Matrix4 inverted = translated.inverse()!;

    return to_float(inverted);
}

fn Matrix4f to_float(Matrix4 dm) {

    Matrix4f fm;

    for(int i = 0; i < dm.m.len; i++) {
        fm.m[i] = (float) dm.m[i];
    }

    return fm;
}