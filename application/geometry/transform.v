module geometry

import math { cos, sin }
import math.vec

pub type Vector = vec.Vec3[f64]

pub struct Rotation {
}

pub struct Transform {
pub mut:
	position Vector
	rotation Vector
	scale    Vector
}

pub fn (mut transform Transform) translate(distance Vector) {
	// += does not work?
	transform.position = transform.position + distance
}

pub fn (mut transform Transform) translate_x(distance f32) {
	transform.position.x += distance
}

pub fn (mut transform Transform) translate_y(distance f32) {
	transform.position.y += distance
}

pub fn (mut transform Transform) translate_z(distance f32) {
	transform.position.z += distance
}

pub fn (mut transform Transform) rotate_z(angle f32) {
	x := transform.position.x
	y := transform.position.y
	z := transform.position.z

	transform.position = Vector{cos(angle) * x - sin(angle) * y, sin(angle) * x + cos(angle) * y, z}
}
