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

## Hexagon Grid

A grid position has the following coordinates:

| coordinate | meaning |
| -- | -- |
| +n | North |
| -n | South |
| +se | South East | 
| -ae | North West | 
| +h | Up |
| -h | Down |

Grid chunks are stored as a rhombus with sides along the North and South-East axes.

Sources:
- [Guide to Hexagonal Grids](https://www.redblobgames.com/grids/hexagons/) by Red Blob Games


## Camera

View coordinates are defined as

| coordinate | meaning |
| -- | -- |
| +x | Right |
| -x | Left |
| +y | Forward |
| -y | Backward |
| +z | Up |
| -z | Down |


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