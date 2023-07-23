# Modules

## Module Types

### Block

A block is the essential building block of a world.

Blocks can only have very basic state that's predefined by the game.
Their position is determined by the "slot" they occupy in the game world's block grid.
They can have an orientation that determines which of their faces are aligned with which world axis.

Blocks definitions contain the following properties:


#### orientation

```type: Boolean```

If true, the block can be oriented in different ways. This can be done by world generation or depending on how players place them.  
If false, the block is always placed in default orientation.


#### hardness

```type: Integer```

Determines the amount of damage a block requires to be destroyed.  
Different tools be defined how much damage they do against blocks with certain charateristics.


#### textures

```type: Map of Strings```

Each value should be a file path to a texture image.

The keys define which faces the textures are mapped to.
They are defined in model space, which for blocks means in their default orientation.

| key | meaning | model axis |
| :--: | -- | :--: |
| default | any face without its own value is assigned the default value | all |
| top | upward facing side | +y |
| bottom | downward facing side | -y |
| right | right facing | +x |
| left | left facing side | -x |
| far | farthest away from screen | +z |
| near | closest to screen | -z |


#### generation

```type: Structure```

If generation is defined, the block can be placed during world generation, depending on certain criteria.

##### generation.layer

```type: String```

The layer value should be a valid layer ID, one of:

| layer | meaning |
| -- | -- |
| surface | only the topmost solid blocks |
| soil | softer blocks in a defined range below the surface |
| rock | harder blocks below the surface |


##### generation.temperature

```type: Integer Range in *C```

If a given chunk's temperature is in the range, the block can be placed.



### Biome

A biome defines what kinds of blocks, animals, vegetation and structures can be placed in a certain region.

Biomes have certain characteristics and layer configurations.
The world generator matches blocks against those characteristics and decides which ones can be placed.

#### characteristics

```type: Map of String-Arrays```

Characteristics provided by the world generator for each chunk.

Available keys:

* temperature
* humidity
* altitude
* slope

Available values:
* none
* low
* medium
* high
* extreme

If a chunk's values fit into all the defined characteristics, the biome can be placed there.
Not defining a characteristic means that any value will match.

#### layers

```type: Structure```

Only layers defined here will be generated in the biome.

Currently, only the depth for the soil layer can be defined.
The surface layer always has a depth of 1 and the rock layer fills all the way to the world bottom.


#### vegetation

```type: Struture```

##### vegetation.coverage

```type: Float```

Defines what percentage of surface blocks should be decorated with vegetation.

##### vegetation.categories

```type: Structure```

Defines what categories of vegetation blocks can be placed on the surface.
The ```share``` values determine the amount of blocks that are covered by each category.
The coverage shares are weighted against each other and multiplied by the vegetation coverage.


Given a chunk surface of _16 * 16 = 256_, this works out as follows for the temperate_grasslands:

Total shares: _100 + 10 + 5 = 115_

| vegetation type | percentage of blocks | number of blocks |
| -- | -- | :--: |
| grass | 0.8 * (100/115) = 69.56 | 179 |
| grain | 0.8 * (10/115) = 6.59 | 17 |
| bush | 0.8 * (5/115) = 3.47 | 9 |
| total | 80 | 205 |