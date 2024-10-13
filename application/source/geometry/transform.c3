module geometry;

import std::math;
import std::io;

const X_AXIS = Vec3f { 1, 0, 0 };
const Y_AXIS = Vec3f { 0, 1, 0 };
const Z_AXIS = Vec3f { 0, 0, 1 };

struct Transform {
    Vec3f position;
    Quaternion rotation;
    Vec3f scale;
}

const Transform IDENTITY = {
    .position = Vec3f { 0, 0, 0 },
    .rotation = math::quaternion::IDENTITY(<float>),
    .scale = { 1, 1, 1 }
};

fn Vec3f Transform.pitch_axis(&self) {
    return X_AXIS.rotate_quat(self.rotation);
}

fn Vec3f Transform.roll_axis(&self) {
    return Y_AXIS.rotate_quat(self.rotation);
}

fn Vec3f Transform.yaw_axis(&self) {
    return Z_AXIS.rotate_quat(self.rotation);
}

fn void Transform.translate(&self, Vec3f direction) {
    self.position.x += direction.x;
    self.position.y += direction.y;
    self.position.z += direction.z;
}

fn void Transform.translate_x(&self, float distance) {
    self.position.x += distance;
}

fn void Transform.translate_y(&self, float distance) {
    self.position.y += distance;
}

fn void Transform.translate_z(&self, float distance) {
    self.position.z += distance;
}


fn void Transform.translate_roll(&self, float distance) {
    
    Vec3f rollAxis = self.roll_axis();

    Vec3f direction = Vec3f {
        rollAxis.x * distance,
        rollAxis.y * distance,
        rollAxis.z * distance
    };

    self.translate(direction);
}

fn void Transform.rotate(&self, Vec3f axis, float angle) {
    
    Quaternion rotation = geometry::from_axis_angle(axis, angle);
    self.rotation = rotation.mul(self.rotation).normalize();
    // rotate_quad seems to be off?
    self.position = self.position.rotate_axis(axis, angle);
}

fn void Transform.rotate_x(&self, float angle) {
    self.rotate(X_AXIS, angle);
}

fn void Transform.rotate_y(&self, float angle) {
    self.rotate(Y_AXIS, angle);
}

fn void Transform.rotate_z(&self, float angle) {
    self.rotate(Z_AXIS, angle);
}


fn void test_transform_rotate_x() @test {

    float rad90 = (float) math::deg_to_rad(90f);

    Transform t = IDENTITY;
    t.position = { 1.5, 2.5, 3.5 };

    t.rotate_x(rad90);
    assert_close_vec(t.position, { 1.5, -3.5, 2.5 });
}

fn void test_transform_rotate_y() @test {

    float rad90 = (float) math::deg_to_rad(90f);

    Transform t = IDENTITY;
    t.position = { 1.5, 2.5, 3.5 };
    
    t.rotate_y(rad90);
    assert_close_vec(t.position, { 3.5, 2.5, -1.5 });
}

fn void test_transform_rotate_z() @test {
    
    float rad90 = (float) math::deg_to_rad(90.0);
    
    Transform t = IDENTITY;
    t.position = { 1.5, 2.5, 3.5 };
    
    t.rotate_z(rad90);
    assert_close_vec(t.position, { -2.5, 1.5, 3.5 });
}

// fn void test_transform_rotate_multiple() @test {

//     double rad90 = math::deg_to_rad(90);

//     Transform t = IDENTITY;

//     t.translate_x(-1.0);
//     assert_close_vec(t.position, { -1.0, 0, 0 });
    
//     t.translate_x(2.0);
//     assert_close_vec(t.position, { 1.0, 0, 0 });
    
//     t.translate_y(1.5);
//     assert_close_vec(t.position, { 1.0, 1.5, 0 });
    
//     t.rotate_x(rad90);
//     assert_close_vec(t.position, { 1.0, 0, 1.5 });
    
//     t.rotate_x(rad90 * 2);
//     assert_close_vec(t.position, { 1.0, 0, -1.5 });
    
//     t.rotate_y(rad90);
//     assert_close_vec(t.position, { -1.5, 0, -1.0 });
// }

const TOLERANCE = 0.00000000001;

fn void assert_close(double actual, double expected, double tolerance = TOLERANCE) {
    assert(expected - tolerance <= actual && expected + tolerance >= actual, "expected %f\tactual %f", expected, actual);
}

fn void assert_close_vec(Vec3f actual, Vec3f expected, double tolerance = TOLERANCE) {
    // io::printfn("actual %s expected %s", actual, expected);
    assert_close(actual.x, expected.x, tolerance);
    assert_close(actual.y, expected.y, tolerance);
    assert_close(actual.z, expected.z, tolerance);
}