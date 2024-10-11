module geometry::transform;

import std::math;
import std::io;

const X_AXIS = Vec3 { 1, 0, 0 };
const Y_AXIS = Vec3 { 0, 1, 0 };
const Z_AXIS = Vec3 { 0, 0, 1 };

struct Transform {
    Vec3 position;
    Quaternion rotation;
    Vec3 scale;
}

const Transform IDENTITY = {
    .position = Vec3 { 0, 0, 0 },
    .rotation = math::quaternion::IDENTITY(<double>),
    .scale = { 1, 1, 1}
};

fn Vec3 Transform.pitch_axis(&self) {
    return X_AXIS.rotate_quat(self.rotation).normalize();
}

fn Vec3 Transform.roll_axis(&self) {
    return Y_AXIS.rotate_quat(self.rotation).normalize();
}

fn Vec3 Transform.yaw_axis(&self) {
    return Z_AXIS.rotate_quat(self.rotation).normalize();
}

fn void Transform.translate(&self, Vec3 direction) {
    self.position.x += direction.x;
    self.position.y += direction.y;
    self.position.z += direction.z;
}

fn void Transform.translate_x(&self, double distance) {
    self.position.x += distance;
}

fn void Transform.translate_y(&self, double distance) {
    self.position.y += distance;
}

fn void Transform.translate_z(&self, double distance) {
    self.position.z += distance;
}


fn void Transform.translate_roll(&self, double distance) {
    
    Vec3 rollAxis = self.roll_axis();

    Vec3 direction = Vec3 {
        rollAxis.x * distance,
        rollAxis.y * distance,
        rollAxis.z * distance
    };

    self.translate(direction);
}

fn void Transform.rotate(&self, Quaternion rotation) {
    self.rotation = self.rotation.mul(rotation).normalize();
    self.position = self.position.rotate_quat(rotation);
}

fn void Transform.rotate_x(&self, double angle) {

    Quaternion rotation = geometry::from_axis_angle(X_AXIS, angle);
    self.rotate(rotation);
}

fn void Transform.rotate_y(&self, double angle) {

    Quaternion rotation = geometry::from_axis_angle(Y_AXIS, angle);
    self.rotate(rotation);
}

fn void Transform.rotate_z(&self, double angle) {

    Quaternion rotation = geometry::from_axis_angle(Z_AXIS, angle);
    self.rotate(rotation);
}

fn void test_transform() @test {

    double rad90 = math::deg_to_rad(90);

    Transform t = IDENTITY;

    io::printfn("pitch %s", t.pitch_axis());
    assert_close_vec(t.pitch_axis(), X_AXIS);
    assert_close_vec(t.roll_axis(), Y_AXIS);
    assert_close_vec(t.yaw_axis(), Z_AXIS);
    
    t.translate_roll(2.5);
    
    assert_close(t.position.y, 2.5);
    
    t.rotate_y(rad90);    
    
    assert_close_vec(t.pitch_axis(), { 0, 0, -1 });
    assert_close_vec(t.roll_axis(), Y_AXIS);
    assert_close_vec(t.yaw_axis(), X_AXIS);

    assert_close_vec(t.position, { 0 , 2.5, 0 });
    
    t.rotate_z(rad90);
    assert_close_vec(t.position, {-2.5, 0, 0 });
    
}

fn void assert_close(double actual, double expected, double distance = 0.00000000001) {
    assert(actual - distance <= expected && actual + distance >= expected, "expected %f  actual %f", expected, actual);
}

fn void assert_close_vec(Vec3 actual, Vec3 expected, double distance = 0.00000000001) {
    io::printfn("actual %s expected %s", actual, expected);
    assert_close(actual.x, expected.x, distance);
    assert_close(actual.y, expected.y, distance);
    assert_close(actual.z, expected.z, distance);
}