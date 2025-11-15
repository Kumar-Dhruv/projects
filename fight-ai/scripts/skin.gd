extends Node3D

@onready var response_one_shot = $AnimationTree.get("parameters/ResponseOneShot/request")
@onready var response_anim: AnimationNodeAnimation = $AnimationTree.tree_root.get_node("ResponseAnim")


func slash():
	response_anim.set_animation("anims/slash1")
	$AnimationTree.set("parameters/ResponseOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
