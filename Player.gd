extends KinematicBody2D

signal collided(collision, position)

# Movement
const GRAVITY = 1000 
export var speed = 150.0
var velocity = Vector2()
var sliding = false

# Jump
export var max_jump = -250
var jump_speed = 6000
var has_jumped = false
var is_max_jump = false
var jumping = false
var wall_jump = false

# Direction
const sliding_factor = 750
var reversed = false
var direction = 1
var is_walking = false
var is_sliding = false

# Dash
var is_dashing = false
export var dash_speed = 600
var current_speed = speed
var dash_cooldown = false

func _ready():
	$AnimationPlayer.play("idle")

func get_input(delta):
	if Input.is_action_pressed("left"):
		is_walking = true
		if !reversed: 
			$Sprite.set_flip_h(true)
			reversed = true;
		$AnimationPlayer.play('drop_walk')
		direction = -1
		velocity.x = direction * current_speed
		
	if Input.is_action_pressed("right"):
		is_walking = true
		if reversed: 
			$Sprite.set_flip_h(false)
			$AnimationPlayer.play('drop_walk')
			reversed = false;
		else:
			$AnimationPlayer.play('drop_walk')
		direction = 1
		velocity.x = direction * current_speed
		
	if Input.is_action_pressed("jump") and !is_max_jump:
		if !has_jumped and jumping and velocity.y > max_jump:
			velocity.y -= jump_speed * delta
			
		elif !has_jumped and jumping:
			is_max_jump = true
			
		elif !jumping and (is_on_floor() or is_sliding):
			jumping = true
			
	if Input.is_action_just_released("jump"):
		has_jumped = true
		
	if Input.is_action_just_released("left") or Input.is_action_just_released("right"):
		$AnimationPlayer.play("drop_stop_walk")
		$AnimationPlayer.play("idle")
		is_walking = false
		sliding = 0
		is_sliding = false
		if wall_jump:
			$WallJumpTimer.stop()
			wall_jump = false
	
	if Input.is_action_just_pressed("dash"):
		if !dash_cooldown and is_walking: 
			$DashTimer.start()
			if direction < 0:
				$Sprite/Particles2D.texture = load("res://Assets/dash_trail_drop_reverse.png")
			else:
				$Sprite/Particles2D.texture = load("res://Assets/dash_trail_drop.png")
			is_dashing = true

func _physics_process(delta):
	velocity.x = 0
	
	if !is_dashing:
		velocity.y += delta * (GRAVITY)
	else :
		velocity.y = 0
	
	get_input(delta)
	
	if !is_dashing:
		$Sprite/Particles2D.emitting = false
		current_speed = speed
	else:
		dash_cooldown = true
		$DashCooldownTimer.start()
		
		$Sprite/Particles2D.emitting = true
		current_speed = dash_speed

	if has_jumped and is_on_floor():
		has_jumped = false
		is_max_jump = false
		jumping = false
		velocity.y = 0;
	
	if is_sliding:
		velocity.y -= delta * sliding_factor
	
	if wall_jump:
		if velocity.x > 0: 
			velocity.x -= 250
		else: 
			velocity.x += 250
			
		
	
	velocity = move_and_slide(velocity, Vector2(0,-1))
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision:
			emit_signal("collided", collision, position)

func _on_DashTimer_timeout():
	is_dashing = false

func _on_DashCooldownTimer_timeout():
	dash_cooldown = false

func _on_TileMap_is_colliding_with_wall():
	
	if (Input.is_action_pressed("left") or Input.is_action_pressed("right")) and !is_on_floor():
		is_sliding = true
		if Input.is_action_just_pressed("jump"):
			has_jumped = false
			wall_jump = true
			$WallJumpTimer.start()
			velocity.y = 0
			is_max_jump = false
			jumping = true
		if Input.is_action_pressed("jump"):
			is_sliding = false


func _on_WallJumpTimer_timeout():
	wall_jump = false
