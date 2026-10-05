extends CharacterBody2D


const SPEED = 120.0
var is_flashing: bool = false
var can_flash: bool = true
var is_hiding: bool = false
var is_in_hiding_area: bool = false
var facing_dir := Vector2(0, 1)
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera_flash: Area2D = $CameraFlash
@onready var collision_shape_2d: CollisionShape2D = $CameraFlash/CollisionShape2D
@onready var color_rect: ColorRect = $CameraFlash/ColorRect
@onready var hide_area: Area2D = $Hide_Area


func _physics_process(delta: float) -> void:

	if is_flashing:
		velocity = Vector2.ZERO
		move_and_slide()
		
		return
	
	if is_hiding:
		velocity = Vector2.ZERO
		move_and_slide()
		if Input.is_action_just_pressed("Interact"):
			stop_hiding()
		return
	
	var direction_x := Input.get_axis("ui_left", "ui_right")
	var direction_y := Input.get_axis("ui_up", "ui_down")
	
	direction_x = Input.get_axis("ui_left", "ui_right")
	direction_y = Input.get_axis("ui_up", "ui_down")
	
	if direction_x != 0:
		velocity.x = direction_x * SPEED
		velocity.y = 0
		facing_dir = Vector2(direction_x, 0)
		
		if direction_x > 0:
			animated_sprite_2d.play("Walk_Right")
		else:
			animated_sprite_2d.play("Walk_Left")
		
	
	elif direction_y != 0:
		velocity.y = direction_y * SPEED
		velocity.x = 0
		facing_dir = Vector2(0, direction_y)
		
		if direction_y > 0:
			animated_sprite_2d.play("Walk_Down")
		else:
			animated_sprite_2d.play("Walk_Up")
			
	else:
		velocity.x = 0
		velocity.y = 0
		
		
		if facing_dir.x > 0:
			animated_sprite_2d.play("Idle_Right")
		elif facing_dir.x < 0:
			animated_sprite_2d.play("Idle_Left")
		elif facing_dir.y > 0:
			animated_sprite_2d.play("Idle_Down")
		elif facing_dir.y < 0:
			animated_sprite_2d.play("Idle_Up")
	
	move_and_slide()
	
	if Input.is_action_just_pressed("Interact") and is_in_hiding_area:
		start_hiding()
		return
		
	if Input.is_action_just_pressed("Flash") and can_flash:
		flash()
		

func flash() -> void:
	is_flashing = true
	can_flash = false
	camera_flash.position = facing_dir * 8
	collision_shape_2d.disabled = false
	flash_light()
	
	await get_tree().create_timer(0.25).timeout
	collision_shape_2d.disabled = true
	
	is_flashing = false
	
	cooldown_timer(4.75)

func cooldown_timer(duration: float) -> void:
	await get_tree().create_timer(duration).timeout
	can_flash = true
	print("Camera ready!")
	
func flash_light() -> void:
	color_rect.visible = true
	
	var flash_tween = create_tween()
	
	flash_tween.tween_property(color_rect, "modulate:a", 1.0, 0.10)
	flash_tween.tween_property(color_rect, "modulate:a", 0.0, 0.25)
	
	await flash_tween.finished
	
	color_rect.visible = false

func start_hiding() -> void:
	is_hiding = true
	can_flash = false
	if facing_dir.x > 0:
		animated_sprite_2d.play("Idle_Right")
	elif facing_dir.x < 0:
		animated_sprite_2d.play("Idle_Left")
	elif facing_dir.y > 0:
		animated_sprite_2d.play("Idle_Down")
	elif facing_dir.y < 0:
		animated_sprite_2d.play("Idle_Up")
	await get_tree().create_timer(0.5).timeout
	animated_sprite_2d.set_deferred("visible", false)
	
	

func stop_hiding() -> void:
	await get_tree().create_timer(0.5).timeout
	is_hiding = false
	can_flash = true
	animated_sprite_2d.set_deferred("visible", true)

func _on_hide_area_area_entered(area: Area2D) -> void:
	if area.name == "Entrance_Area":
		is_in_hiding_area = true


func _on_hide_area_area_exited(area: Area2D) -> void:
	if area.name == "Entrance_Area":
		is_in_hiding_area = false
