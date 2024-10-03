module graphics;

import std;

fn float[] square(float size) {
	
	float[] vertices = {
		// x	y		z		u  v  texture index
		-size,	size,	0.5,	0, 0, 0,
		-size, -size,	0.5,	0, 1, 0,
		size, -size,	0.5,	1, 1, 0,

		size, -size,	0.5,	1, 1, 1,
		size, size,		0.5,	1, 0, 1,
		-size, size,	0.5,	0, 0, 1,
	};
	// TODO allocate
	return vertices;
}

