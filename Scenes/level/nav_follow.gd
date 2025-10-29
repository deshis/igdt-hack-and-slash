@tool
extends NavigationRegion2D
@export var timer: Timer
@export var player: Node2D

@export var width:int =1000
@export var height:int =1000
@export var spawner:Node2D
@onready var reg_size:Vector2i = Vector2i(width,height)

@export_tool_button("generate") var gen = gen_nav

func _ready() -> void:
	if can_process():
		timer.start()	

func _exit_tree() -> void:
	timer.stop()

func _on_timer_timeout():
	if player:
		gen_nav()
		timer.start()
		

func initialize():
	gen_nav()

func gen_nav( size:Vector2 =self.reg_size):
	self.navigation_polygon.clear()
	var offset:Vector2=to_local(player.position)
	print("generating\n Player position:")
	print(offset)

	#print("far corners")
	var corner_a: Vector2 = offset - size/2
	var corner_c: Vector2 = offset + size/2
	#print(corner_a)
	#print(corner_c)

	#print("outer corners")
	var corner_b: Vector2 = Vector2(corner_c.x, corner_a.y)
	var corner_d: Vector2 = Vector2(corner_a.x, corner_c.y)
	#print(corner_b)
	#print(corner_d)
	

	
	
	var bounding_outline = PackedVector2Array([corner_a, corner_b, corner_c, corner_d])

	var nav_poly = NavigationPolygon.new()
	nav_poly.add_outline(bounding_outline)
	nav_poly.source_geometry_group_name="navigation"
	nav_poly.source_geometry_mode=2

	self.navigation_polygon = nav_poly
	self.bake_navigation_polygon()
	#spawner.navigation_region= nav_poly
