class_name Player extends Character

var input: Vector2

@export var walk_speed := 400.0
@export var accel := 15.0

@export var max_health := 100.0


var can_dash:= true
var dashing = false
@onready var dash_cooldown_timer: Timer = $DashCooldownTimer
@onready var dash_length_timer: Timer = $DashLengthTimer
var dash_cooldown:= 3.0
var dash_length:= 0.15
var dash_speed:= 3000


func _ready() -> void:
	movement_speed = walk_speed
	acceleration = accel
	HP = max_health
	max_HP = max_health


func _physics_process(delta) -> void:
	#player movement with acceleration
	update_input()
	
	if Input.is_action_just_pressed("movement_ability") and can_dash:
		can_dash = false
		dashing = true
		dash_length_timer.start(dash_length)
		dash_cooldown_timer.start(dash_cooldown)
		movement_speed = dash_speed
	else:
		velocity = lerp(velocity, input * movement_speed, acceleration * delta)
	
	move_and_slide()


func update_input() -> void:
	if not dashing:
		input.x = Input.get_axis("move_left", "move_right")
		input.y = Input.get_axis("move_up", "move_down")
	input = input.normalized()


func _on_dash_cooldown_timer_timeout() -> void:
	can_dash=true


func _on_dash_length_timer_timeout() -> void:
	movement_speed = walk_speed
	dashing = false
