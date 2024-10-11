module graphics;

import std::math::matrix;

fn float[4*4] to_float_array(Matrix4 dm) {

    float[4*4] array;

    for(int i = 0; i < dm.m.len; i++) {
        array[i] = (float) dm.m[i];
    }

    return array;
}