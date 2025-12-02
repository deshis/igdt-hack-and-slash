@tool
extends GridMap # Straight from another project :D

@export var grid_2d: TileMapLayer 

@export_tool_button("generate") var gen = _generate

@export_range(1, 10, 1) var height := 1:
	set(v):
		height=v
		#_generate()
@export_tool_button("clear map") var clr = _clear

@export var noise: FastNoiseLite:
	set(new_noise):
		noise=new_noise
		_generate()
		




func _clear():
	clear()
	print("clear!")
	
func _generate():
	clear()
	var texture = NoiseTexture2D.new()
	texture.noise = noise
	await texture.changed
	var noiseImage = texture.get_image()
	var data = noiseImage.get_data()
	var xi=texture.height/2
	var yj=texture.width/2
	for i in texture.height:
		for j in texture.width:
			var value = noiseImage.get_pixel(i,j).r * height  #make [-1, 1] [-10, 10]
			var location=Vector3(i-xi,value,j-yj)
			self.set_cell_item(location,0)	
	
func _enter_tree():
	pass

func _ready():
	pass
	
