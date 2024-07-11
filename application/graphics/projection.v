module graphics

import math { radians, tan }

pub fn projection(fov_degrees u16, aspect_ratio f32, distance f32) []f32 {

	mut p := []f32{len: 16}

	f := tan(math.pi_2 - radians(fov_degrees) * 0.5)
	near := 0.001
	far := distance + near
	inv_distance := 1.0 / distance

	p[0] = f32(f / aspect_ratio)
	p[5] = f32(f)
	p[10] = f32(far * inv_distance)
	p[11] = f32(-1)
	p[14] = f32(near * far * inv_distance)

	return p
}