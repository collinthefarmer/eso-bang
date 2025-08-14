extends Resource
class_name LevelGeometryKernel
## mutable parameters and shared behaviors affecting level geometry
## Includes getters for AABB, Meshes, and Shapes for nodes that make up a Level's geometry.

# ---

@export
var data: LevelGeometryData:
    set(value):
        data = value
        self._dirty_cache()
        self.emit_changed()


@export_range(0, 256, 1)
var height_scale: float:
    set(value):
        height_scale = value
        self._dirty_cache()
        self.emit_changed()


@export_range(-256, 256, 1)
var min_height: float:
    set(value):
        min_height = value
        self._dirty_cache()
        self.emit_changed()


@export_range(-256, 256, 1)
var max_height: float:
    set(value):
        max_height = value
        self._dirty_cache()
        self.emit_changed()

# ---

var terrain_aabb: AABB:
    get(): return self._cache.cget("terrain_aabb")

var terrain_trimesh: ArrayMesh:
    get(): return self._cache.cget("terrain_trimesh")

var terrain_shape: ConcavePolygonShape3D:
    get(): return self._cache.cget("terrain_shape")

var terrain_bounds_shape: BoxShape3D:
    get(): return self._cache.cget("terrain_bounds_shape")

# ---

var _cache: StateCache

# ---

func _init() -> void:
    self._cache = StateCache.new()
    self._cache.cset("terrain_aabb", self._resolve_terrain_aabb)
    self._cache.cset("terrain_trimesh", self._resolve_terrain_trimesh)
    self._cache.cset("terrain_shape", self._resolve_terrain_shape)
    self._cache.cset("terrain_bounds_shape", self._resolve_terrain_bounds_shape)

# ---

func _dirty_cache():
    self._cache.set_dirty("terrain_aabb")
    self._cache.set_dirty("terrain_trimesh")
    self._cache.set_dirty("terrain_shape")
    self._cache.set_dirty("terrain_bounds_shape")


func _resolve_terrain_aabb():
    return AABB(Vector3.ZERO, Vector3(
        self.data.dimensions.x - 1,
        clamp(
            (self.data.max_height_sample - self.data.min_height_sample)
            * self.height_scale,
            self.min_height,
            self.max_height
        ),
        self.data.dimensions.y - 1
    ))


func _resolve_terrain_trimesh():
    var st = SurfaceTool.new()
    st.begin(Mesh.PRIMITIVE_TRIANGLES)
    st.set_smooth_group(-1) # no smoothing
    for vertex in self._generate_terrain_trimesh_vertices():
        st.add_vertex(vertex)
    st.generate_normals()
    return st.commit()


func _resolve_terrain_shape():
    var shape = ConcavePolygonShape3D.new()
    shape.set_faces(self._generate_terrain_trimesh_vertices())
    return shape


func _resolve_terrain_bounds_shape():
    var shape = BoxShape3D.new()
    shape.size = self.terrain_aabb.size
    return shape

func _generate_terrain_trimesh_vertices():
    var vertices = PackedVector3Array()
    vertices.resize(self.data.dimensions.x * self.data.dimensions.y * 3 * 2)

    var vi: int

    var tr: Vector3
    var tl: Vector3
    var br: Vector3
    var bl: Vector3

    for ix in self.data.dimensions.x:
        for iy in self.data.dimensions.y:
            vi = (ix + (iy * self.data.dimensions.x)) * 3 * 2

            tl = Vector3(
                ix,
                clamp(
                    self.data.sample_height(ix, iy)
                    * self.height_scale,
                    self.min_height,
                    self.max_height
                ),
                iy
            )

            if ix + 1 < self.data.dimensions.x:
                tr = Vector3(
                    ix + 1,
                    clamp(
                        self.data.sample_height(ix + 1, iy)
                        * self.height_scale,
                        self.min_height,
                        self.max_height
                    ),
                    iy
                )
            else:
                tr = tl

            if iy + 1 < self.data.dimensions.y:
                bl = Vector3(
                    ix,
                    clamp(
                        self.data.sample_height(ix, iy + 1)
                        * self.height_scale,
                        self.min_height,
                        self.max_height
                    ),
                    iy + 1
                )
            else:
                bl = tl

            if ix + 1 < self.data.dimensions.x and iy + 1 < self.data.dimensions.y:
                br = Vector3(
                    ix + 1,
                    clamp(
                        self.data.sample_height(ix + 1, iy + 1)
                        * self.height_scale,
                        self.min_height,
                        self.max_height
                    ),
                    iy + 1
                )
            else:
                br = tl

            vertices[vi + 0] = br
            vertices[vi + 1] = bl
            vertices[vi + 2] = tl
            vertices[vi + 3] = tl
            vertices[vi + 4] = tr
            vertices[vi + 5] = br

    return vertices

# ---
