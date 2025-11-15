extends Node3D

@onready var motion_mach = $AnimationTree.get("parameters/MotionMach/playback")

var is_moving := false

func toggle_motion(val):
	if is_moving != val:
		is_moving = val
		var tween = create_tween()
		tween.tween_method(idle_to_motion_blend, 1 - float(is_moving), float(is_moving), 0.2)

func toggle_cover(to_cover):
	var tween1 = create_tween()
	tween1.tween_method(cover_blend, 1 - float(to_cover), float(to_cover), 0.2)
	if to_cover:
		rotation_degrees.y = -150
	else:
		rotation_degrees.y = 0
	
func motion_animation_handler(motion_dir: Vector2, sprinting):
	if motion_dir != Vector2.ZERO:
		toggle_motion(true)
		
		if sprinting:
			travel(motion_mach, "Sprint")
		else:
			match motion_dir:
				Vector2(0, 1): #F
					travel(motion_mach, "Walk_F")
				Vector2(0, -1): #B
					travel(motion_mach, "Walk_B")
				Vector2(1, 0): #L
					$AnimationPlayer.speed_scale = -1
					travel(motion_mach, "Strafe")
				Vector2(-1, 0): #R
					travel(motion_mach, "Strafe")
					$AnimationPlayer.speed_scale = 1
		
	else:
		toggle_motion(false)
	
func cover_blend(val):
	$AnimationTree.set("parameters/CoverBlend/blend_amount", val)

func travel(mach, state):
	mach.travel(state)

func idle_to_motion_blend(val):
	$AnimationTree.set("parameters/MotionBlend/blend_amount", val)
