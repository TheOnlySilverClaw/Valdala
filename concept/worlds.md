# Worlds

Worlds can be huge, but are *not* infinite. The size and basic shape of a world is determined during generation when starting a new game.

Settlements and other complex features might be loaded on demand when players discover new parts of the world.

## Generation

general steps:

- generate height map at chunk scale
- generate height map at block scale on top
- fill chunks below sea level with ocean
- evenly distribute temperature per chunk with the maximum at 0 x and the minimum at mimimum and maximum x
- generate wind paths by following temperature and going around steep elevation increases
- randomly distriute river sources
- generate river paths from river sources downhill
- simulate terrain erosion along wind and river paths
- minerals are distributed around oceans, rocks and along erosion paths
- humidity is distributed along oceans, rivers and lakes and towards the end of wind paths
- plants are generated based on block hardness, temperature, humidity and minerals
- herbivore animals are distributed based on chunk temperature, humidity  and plant availability
- carnivore animals are distributed based on chunk temperature, humidity and prey availability
- settlements are distributed based on terrain flatness, availability of building material and proximity to water and food sources