@tool
extends GridMap # Straight from another project :D

@export var grid_2d: TileMapLayer 
@export var grass: MultiMeshInstance3D

@export_tool_button("generate") var gen = _generate

@export_range(1, 10, 1) var height := 5:
	set(v):
		height=v
		#_generate()
@export_tool_button("clear map") var clr = _clear

@export var noise_sharp: FastNoiseLite
		
@export var noise_gradual: FastNoiseLite


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
	
	var xi=texture.height/2
	var yj=texture.width/2
	for i in texture.height:
		for j in texture.width:
			var flow:int = noiseImage.get_pixel(i,j).r * height
			var points:int = noisePeaks.get_pixel(i,j).r * height
			var location=Vector3(i-xi,0,j-yj)
	
			if flow>=2:
				var location2=Vector3(i-xi,1,j-yj)
				self.set_cell_item(location2,1)
				
			if flow>=3:
				var location2=Vector3(i-xi,2,j-yj)
				self.set_cell_item(location2,2)
			
			if points>=4:
				var location2=Vector3(i-xi,3,j-yj)
				self.set_cell_item(location2,3)
				var location3=Vector3(i-xi,4,j-yj)
				self.set_cell_item(location3,3)

			self.set_cell_item(location,0)		
			
	print("gridmap done!")
	_generate_grass()
	print("grass done!")

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
				xf.origin = pos

				grass_positions.append(xf)

	var mm = grass.multimesh
	mm.instance_count = grass_positions.size()

	for i in grass_positions.size():
		mm.set_instance_transform(i, grass_positions[i])
	
func _enter_tree():
	pass

func _ready():
	pass
	
