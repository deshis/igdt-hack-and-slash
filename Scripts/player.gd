class_name Player extends Character

var input: Vector2

func _ready() -> void:
	movement_speed = 400
	acceleration = 15
	HP = 100
	max_HP = 100


func _physics_process(delta) -> void:
	#player movement with acceleration
	update_input()
	velocity = lerp(velocity, input * movement_speed, acceleration * delta)
	move_and_slide()


func update_input() -> void:
	input.x = Input.get_axis("move_left", "move_right")
	input.y = Input.get_axis("move_up", "move_down")
	return input.normalized()
