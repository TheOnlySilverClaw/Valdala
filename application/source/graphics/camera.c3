module graphics;

import std::math::matrix;
import std::math::vector;
import std::io;

import geometry;

def Quaternion = geometry::Quaternion;

const UP = geometry::Z_AXIS;

struct Camera {
    inline Transform transform;
}

fn Matrix4f! Camera.view(&self) {

    Vec3f eye = { 0, -1, 0 };
    float degree = 90;
    Quaternion rotation = geometry::from_axis_angle(Vec3f{1, 0, 0}, (float) math::deg_to_rad(degree));

    Vec3f target = eye.rotate_quat(rotation);
    Matrix4f lookat = math::matrix::look_at(<float>)(eye, target, UP);
    Matrix4f! inverted = lookat.inverse();
    
    if(try inverted) {
        return inverted;
    } else {
        return lookat;
    }
}