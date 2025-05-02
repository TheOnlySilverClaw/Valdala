# Coordinates

## World

The world coordinates in Valdala are defined as

| coordinate | meaning |
| -- | -- |
| +x | East |
| -x | West |
| +y | North |
| -y | South |
| +z | Up |
| -z | Down |

Sizes in game units are measured in metres.

The player character is about 1.75 metres tall, equal to 7 tiles high.


## Hexagon Grid

Each block is a grid tile with an outer radius of 0.25 metres.  
The height of each tile is also 0.25 metres.  
The inner radius is 0.25 * &radic;3 * &half; = 0,216506351 &approx; 0.22 metres.

1 cubic metre block is approximately 4 * 5 * 4 = 80 tiles!  
(I might have to rethink this for performance reasons. We'll see... )

Grids are aligned on a 2D plane and stacked in columns on top of each other.

A grid coordinate has the following components:

| coordinate | meaning |
| +n | North-East |
| -n | South-West |
| +e | East | 
| -e | West | 
| +s | South-East |
| +s | North-West |
| +h | Up |
| -h | Down |

The s coordinate is not stored internally, but calculated on demand:  
q + r + s = 0 &rarr; s = -q - r

Grid coordinates are mapped to world coordinates as offset coordinates with "odd columns vertical layout".

Grid chunks are stored as a rhombus with sides along the East and North-East axes.

Sources:
- [Guide to Hexagonal Grids](https://www.redblobgames.com/grids/hexagons/) by Red Blob Games


## Camera

View coordinates are defined as

| coordinate | meaning |
| -- | -- |
| +x | Right |
| -x | Left |
| +y | Forward |
| +y | Backward |
| +z | Up |
| +z | Down |


## WebGPU

WebGPU normalized device coordinates are
| coordinate | meaning |
| -- | -- |
| +x | Right |
| -x | Left |
| +y | Up |
| -y | Down |
| +z | Forward |

Sources:
- [WebGPU Draft](https://www.w3.org/TR/webgpu/#coordinate-systems)