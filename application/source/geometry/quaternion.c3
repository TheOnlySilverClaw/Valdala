module geometry;

import std::math;

def Quaternion = math::quaternion::Quaternion(<double>) @local;

fn Quaternion from_axis_angle(Vec3 axis, double angle) {

    double sin, cos;
    math::sincos_ref(angle * 0.5, &sin, &cos);

    return Quaternion {
        axis.x * sin,
        axis.y * sin,
        axis.z * sin,
        cos
    };
}

fn void test_from_axis_angle() @test {
    Quaternion q = from_axis_angle({0,0,0}, 0.0);
    assert(q.v == {0, 0, 0, 1});
}