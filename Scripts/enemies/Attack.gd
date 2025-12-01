extends Node2D
class_name Attack

@export var damage := 2.0
@export var hitbox_duration := 0.05
@export var animation_duration := 2.0
@export var size := Vector2(1, 1)

@export var follow := true
@export var offset := Vector2.ZERO

@onready var area: Area2D = $Area2D
@onready var coll: CollisionShape2D = $Area2D/CollisionShape2D

signal attack_hit(target: Node, damage: float)

func _ready() -> void:
	connect("tree_exited", Callable(self, "_on_attack_removed"))
	
	set_scale(size)
	normalize_offset()
	
	if follow:
		position = offset
	else:
		var world_pos = global_position + offset
		get_parent().remove_child(self)
		GameManager.current_stage.add_child(self)
		global_position = world_pos
	
	start_attack()

func _process(_delta: float) -> void:
	if follow:
		var parent = get_parent()
		global_position = parent.global_position + offset.rotated(parent.global_rotation)

func normalize_offset() -> void:
	if coll.shape is RectangleShape2D:
		var coll_size = coll.shape.extents * 2 * area.scale
		offset = Vector2(offset.x * coll_size.x, offset.y * coll_size.y)
	if coll.shape is CircleShape2D:
		var radius = coll.shape.radius
		var coll_size = Vector2(radius * 2 * area.scale.x, radius * 2 * area.scale.y)
		offset = Vector2(offset.x * coll_size.x, offset.y * coll_size.y)

func start_attack() -> void:
	for body in area.get_overlapping_areas():
		_on_area_2d_area_entered(body)
	
	# hitbox duration
	await get_tree().create_timer(hitbox_duration).timeout
	area.monitoring = false
	
	# animation duration
	await get_tree().create_timer(animation_duration - hitbox_duration).timeout
	remove_attack()

func remove_attack() -> void:
	queue_free()

func _on_area_2d_area_entered(_area: Area2D) -> void:
	attack_hit.emit(area, damage)
