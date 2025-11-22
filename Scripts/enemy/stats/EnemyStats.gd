extends Resource
class_name EnemyStats

@export var name := "unnamed enemy"
@export var type: Type = Type.NORMAL

@export var speed := 250.0
@export var max_health := 4.0
var health := max_health
@export var damage := 2.0

@export var cost := 2.0

var acceleration := 20.0
var rotation_speed := 8.0

enum Type {
	NORMAL,
	MINIBOSS,
	BOSS
}
