module geometry;

import std::math;
import std::io;

def Quaternion = math::quaternion::Quaternion(<float>);

fn Quaternion from_axis_angle(Vec3f axis, float angle) {

    float half_angle = angle / 2.0;
    float sin, cos;
    math::sincos_ref(half_angle, &sin, &cos);

    Quaternion quat = {
        axis.x * sin,
        axis.y * sin,
        axis.z * sin,
        cos
    };
    
    return quat;
}

fn void test_from_axis_angle() @test {
    Quaternion q = from_axis_angle({0,0,0}, 0.0);
    assert(q.v == {0, 0, 0, 1});
}