@tool
extends Node2D

@onready var sky :TileMapLayer =$sky
@onready var play :TileMapLayer =$"play-level"
@onready var ground:TileMapLayer =$ground

const tree =[11,1,0,2] # Trunk, center, corner, side
const gnd =[3,4] # ground, rocks



@export_tool_button("generate") var gen = _generate
@export_range(1, 10, 1) var height := 4:
	set(v):
		height=v
		#_generate()
@export_tool_button("clear map") var clr = _clear

@export var noise: FastNoiseLite:
	set(new_noise):
		noise=new_noise
		_generate()




func _clear():
	sky.clear()
	play.clear()
	ground.clear()
	print("clear!")
	
func _generate():
	var texture = NoiseTexture2D.new()
	texture.noise = noise
	await texture.changed
	var noiseImage = texture.get_image()
	
	
	for i in texture.height:
		for j in texture.width:
			var value:int = noiseImage.get_pixel(i,j).r * height  #make [-1, 1] [-height, height]
			var location=Vector2i(i,j)
			
			if value==1:
				ground.set_cell(location, 1, Vector2i(gnd[1],0)) #add rocks
			else:
				ground.set_cell(location, 1, Vector2i(gnd[0],0))
				
			if value==3:
				create_tree(location)

	
	
	
func create_tree( location:Vector2i):
	var x=location.x
	var y=location.y
	#Trunk
	play.set_cell(location,1 ,Vector2i(tree[0],0))
	#Center of leavage
	sky.set_cell(location,1 ,Vector2i(tree[1],0))
	sky.set_cell(Vector2i(x,y+1),1 ,Vector2i(tree[1],0))	
	sky.set_cell(Vector2i(x,y-1),1 ,Vector2i(tree[1],0))		
	sky.set_cell(Vector2i(x+1,y),1 ,Vector2i(tree[1],0))	
	sky.set_cell(Vector2i(x-1,y),1 ,Vector2i(tree[1],0))	
	
	##Large tree, need rotation for corners :weary:
	#leavage 
	#sky.set_cell(Vector2i(x-1,y-1),1 ,Vector2i(tree[2],0))
	#sky.set_cell(Vector2i(x-1,y+1),1 ,Vector2i(tree[2],0))
	#sky.set_cell(Vector2i(x+1,y-1),1 ,Vector2i(tree[2],0))
	#sky.set_cell(Vector2i(x+1,y+1),1 ,Vector2i(tree[2],0))
	
	# Edge of middle
	#sky.set_cell(Vector2i(x,y+2),1 ,Vector2i(tree[3],0))	
	#sky.set_cell(Vector2i(x,y-2),1 ,Vector2i(tree[3],0))		
	#sky.set_cell(Vector2i(x+2,y),1 ,Vector2i(tree[3],0))	
	#sky.set_cell(Vector2i(x-2,y),1 ,Vector2i(tree[3],0))	
	
	
	
func _enter_tree():
	pass

func _ready():
	pass
