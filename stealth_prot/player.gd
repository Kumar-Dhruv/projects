extends CharacterBody3D

var mov_input =  Vector2.ZERO #(X, Z)
var mov_dir = Vector2.ZERO
@onready var skin = $PlayerSkin

var walk_speed = 6.0
var sprint_speed = 8.0
var speed_modifier = walk_speed

var walk_fov = 75
var sprint_fov = 90
var cover_fov = 90      

var is_sprinting := false
var in_cover := false

var cover_normal
@onready var cover_cam = $CoverCamPivot/CoverCam
@onready var shoulder_cam = $SpringArm3D/ShoulderCam
@onready var transition_cam = $TransitionCam
var target_cam

var forward_vector = Vector2(0, 1) #X, Z
	
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if not in_cover:	
			rotation.y -= event.relative.x * 0.005
		if in_cover:
			$CoverCamPivot.rotation.y -= event.relative.x * 0.005
	
	if not is_sprinting and not in_cover:
		mov_input.y = Input.get_axis("Backward", "Forward")
		mov_input.x = Input.get_axis("Right", "Left")
		speed_modifier = walk_speed
	
	if event.is_action_pressed("Sprint"):
		if mov_input == Vector2(0, 1):
			mov_input = Vector2(0, 1)
			is_sprinting = true
			speed_modifier = sprint_speed
			change_fov(sprint_fov)
			
	if event.is_action_released("Sprint"):
		is_sprinting = false
		speed_modifier = walk_speed
		change_fov(walk_fov)
	
	if event.is_action_pressed("Cover") and $CoverRayCast.is_colliding():
		in_cover = true
		skin.toggle_cover(true)
		cover_normal = -$CoverRayCast.get_collision_normal()
		rotation.y = -cover_normal.signed_angle_to(Vector3(0, 0, 1), transform.basis.y)
		change_fov(cover_fov)
		toggle_cover_cam(true)
		
	if event.is_action_released("Cover"):
		if in_cover:
			in_cover = false
			skin.toggle_cover(false)
			change_fov(walk_fov)
			toggle_cover_cam(false)
	
	skin.motion_animation_handler(mov_input, is_sprinting)
		
func _physics_process(delta: float) -> void:
	mov_dir = mov_input.rotated(-rotation.y).normalized()
	
	forward_vector = Vector3(sin(global_rotation.y), 0 ,cos(-global_rotation.y)).normalized()
	
	velocity.x = mov_dir.x * speed_modifier
	velocity.z = mov_dir.y * speed_modifier
	
	
	move_and_slide()

func change_fov(target_fov):
	var tween = create_tween()
	tween.tween_property($SpringArm3D/ShoulderCam, "fov", target_fov, 0.05)


func toggle_cover_cam(to_cover):
	var tween = create_tween()
	tween.set_parallel(true)
	if to_cover:
		target_cam = cover_cam
		transition_cam.global_transform = shoulder_cam.global_transform
		transition_cam.fov = shoulder_cam.fov
	else:
		target_cam = shoulder_cam
		transition_cam.global_transform = cover_cam.global_transform
		transition_cam.fov = cover_cam.fov
		
	transition_cam.make_current()
	tween.tween_property(transition_cam, "global_transform", target_cam.global_transform, 0.2)
	tween.tween_property(transition_cam, "fov", target_cam.fov, 0.2)
	tween.finished.connect(switch_cam)
		
func switch_cam():
	target_cam.make_current()
