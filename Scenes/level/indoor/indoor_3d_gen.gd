@tool
extends GridMap # Straight from another project :D

@export var grid_2d: TileMapLayer 
@export var grass: MultiMeshInstance3D

@export_tool_button("generate") var gen = _generate
@export_tool_button("navmesh") var bake = bake_gridmap_navmesh

@export_range(1, 10, 1) var height := 5:
	set(v):
		height=v
		#_generate()
@export_tool_button("clear map") var clr = _clear

@export var noise_scale: int
@export var noise_sharp: FastNoiseLite
@export var noise_gradual: FastNoiseLite

@onready var enemy_spawner = $"../../../EnemySpawner"

func _notification(notification):
	if notification == NOTIFICATION_EDITOR_PRE_SAVE:
		grass.multimesh.instance_count = 0

func _clear():
	clear()
	grass.multimesh.instance_count = 0
	print("clear!")
	
func _generate():
	clear()
	var texture = NoiseTexture2D.new()
	texture.noise = noise_gradual
	await texture.changed
	var noiseImage = texture.get_image()
	
	var peaks =NoiseTexture2D.new()
	peaks.noise=noise_sharp
	await peaks.changed
	var noisePeaks =peaks.get_image()
	
	var tex_width = texture.width / noise_scale
	var tex_height = texture.height / noise_scale
	
	#var xi=tex_height/2
	#var yj=tex_width/2
	#0 ground
	#1 obstacle
	#2 wall
	#3 ????
	var ground =[]
	for cell in grid_2d.get_used_cells():
		if grid_2d.get_cell_atlas_coords(cell)==Vector2i(0,0):
			self.set_cell_item(Vector3i(cell.x,0,cell.y),0)
			ground.append(cell)
		if grid_2d.get_cell_atlas_coords(cell)==Vector2i(1,0):
			self.set_cell_item(Vector3i(cell.x,1,cell.y),2) 
			self.set_cell_item(Vector3i(cell.x,2,cell.y),2)	
	
	for cell in ground:
		var xtmp=abs(cell.x)
		var ytmp=abs(cell.y)
		#var flow:int = noiseImage.get_pixel(cell.x,cell.y).r * height
		var points:int = noisePeaks.get_pixel(xtmp,ytmp).r * height
		if points>=4:
			self.set_cell_item(Vector3i(cell.x,1,cell.y),1)
	
	
	print_debug(texture.height)
	print("gridmap done!")
	#bake_gridmap_navmesh()
	
	#_generate_grass()
	#print("grass done!")
	#enemy_spawner.start_spawner()

func bake_gridmap_navmesh():
	get_parent().bake_navigation_mesh(true)
	print("navmesh done!")

func _generate_grass():
	var grass_positions: Array[Transform3D] = []

	for cell in self.get_used_cells():
		if self.get_cell_item(cell) == 2:
			var tile_center := self.map_to_local(cell)

			for i in range(50):
				var rand_offset = Vector3(randf() - 0.5,0,randf() - 0.5) * 2.0   # keeps blades within the tile

				var pos = tile_center + rand_offset

				var xf = Transform3D()
				xf = xf.rotated(Vector3.UP, randf() * TAU)
				xf = xf.rotated(Vector3.RIGHT, deg_to_rad(-30))
				xf.origin = pos

				grass_positions.append(xf)

	var mm = grass.multimesh
	mm.instance_count = grass_positions.size()

	for i in grass_positions.size():
		mm.set_instance_transform(i, grass_positions[i])
	
func _enter_tree():
	pass

#func _ready():
	#_generate() #This is called the engine even touches the file becaus of the "tool" tag
	#_generate_grass() #Place the grass when loaded
