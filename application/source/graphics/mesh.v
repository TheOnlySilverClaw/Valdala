module graphics

fn square(size f32) []f32 {
	// vfmt off
	return [
		// x	y		z		u  v  texture index
		-size,	size,	0.5,	0, 0, 0,
		-size, -size,	0.5,	0, 1, 0,
		size, -size,	0.5,	1, 1, 0,

		size, -size,	0.5,	1, 1, 0,
		size, size,		0.5,	1, 0, 0,
		-size, size,	0.5,	0, 0, 0,
	]
	// vfmt on
}