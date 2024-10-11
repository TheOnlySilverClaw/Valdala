module graphics;

import std::math;
import std::io;

import geometry;

const UP = Vec3 { 0, 1, 0 };

struct Camera {
    Vec3 position;
    Quaternion rotation;
}

fn Matrix4! Camera.view(&self) {

    Vec3 eye = { 0, -1, 0 };
    Quaternion rotation = geometry::from_axis_angle(Vec3{1, 0, 0}.normalize(), math::deg_to_rad(90));

    Vec3 target = eye.rotate_quat(rotation);
    Matrix4 lookat = math::matrix::look_at(<double>)(eye, target, UP);
    io::printfn("matrix: %s", lookat.m);
    Matrix4! inverted = lookat.inverse();
    
    if(try inverted) {
        return inverted;
    } else {
        return lookat;
    }
}