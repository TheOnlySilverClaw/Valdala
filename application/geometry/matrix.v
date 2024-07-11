module geometry

pub fn mat4x4(a []f32) []f32 {
	mut m := []f32{len: 0, cap: 16}

	for row := 0; row < 4; row++ {
		for column := 0; column < 4; column++ {
			m << a[row + column * 4]
		}
	}
	// println(m.len)
	// println(m[0..4])
	// println(m[4..8])
	// println(m[8..12])
	// println(m[12..16])
	return m
}
