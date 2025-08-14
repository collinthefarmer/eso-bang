extends Resource
class_name LevelGeometryData
## Base, immutable data used for describing Level Geometry.

@export
var dimensions: Vector2i:
    set(value):
        dimensions = value
        self._sample_heights()
        self.emit_changed()

@export
var noise_layers: Array[FastNoiseLiteLayer]:
    set(value):
        noise_layers = value
        for layer in noise_layers:
            layer.changed.connect(self.emit_changed)

        self._sample_heights()
        self.emit_changed()

# ---

var height_samples: PackedFloat32Array:
    get():
        if not self._height_samples:
            self._sample_heights()

        return self._height_samples


var min_height_sample: float:
    get():
        if not self._height_samples:
            self._sample_heights()

        return min_height_sample


var max_height_sample: float:
    get():
        if not self._height_samples:
            self._sample_heights()

        return max_height_sample

# ---

func sample_height(x: int, y: int):
    return self.height_samples[x + y * self.dimensions.x]

# ---

var _height_samples: PackedFloat32Array

# ---

func _sample_heights():
    self.min_height_sample = INF
    self.max_height_sample = -INF
    self._height_samples = PackedFloat32Array()
    self._height_samples.resize(self.dimensions.x * self.dimensions.y)

    for ix in self.dimensions.x:
        for iy in self.dimensions.y:
            var sample = self._sample_height(ix, iy)
            self.min_height_sample = min(sample, self.min_height_sample)
            self.max_height_sample = max(sample, self.max_height_sample)
            self._height_samples[ix + iy * self.dimensions.x] = sample


func _sample_height(x: int, y: int) -> float:
    var weight_sum = 0.
    var sample = 0.
    for layer in self.noise_layers:
        sample += layer.get_noise_2d(x, y) * layer.weight
        weight_sum += layer.weight

    return sample / weight_sum
