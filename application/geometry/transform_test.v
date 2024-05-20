module geometry

import math

const tolerance = 0.0000001

pub fn test_translate() {
	mut t := Transform{}

	t.translate(Vector{1, 0, 0})
	assert t.position.x == 1.0
	assert t.position.y == 0.0
	assert t.position.z == 0.0

	t.translate(Vector{-2, -1, 1})
	assert t.position.x == -1.0
	assert t.position.y == -1.0
	assert t.position.z == 1.0

	t.translate_x(1.0)
	assert t.position.x == 0

	t.translate_y(-1.5)
	t.translate_y(2.5)
	assert t.position.y == 0

	t.translate_z(-1.0)
	assert t.position.z == 0
}

pub fn test_rotate_z() {
	mut t := Transform{}

	t.rotate_z(math.pi)
	assert t.position.x == 0.0
	assert t.position.y == 0.0
	assert t.position.z == 0.0

	t.translate_y(1.0)
	t.rotate_z(math.pi / 2)
	assert t.position.eq_approx(Vector{-1, 0, 0}, geometry.tolerance)

	t.rotate_z(-math.pi)
	assert t.position.eq_approx(Vector{1, 0, 0}, geometry.tolerance)

	t.rotate_z(-math.pi / 4)
	assert t.position.eq_approx(Vector{0.70710678118, -0.70710678118, 0}, geometry.tolerance)
}
