@tool
extends GridMap # Straight from another project :D

@export var grid_2d: TileMapLayer 

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
	
	
func _enter_tree():
	pass

func _ready():
	pass
	
