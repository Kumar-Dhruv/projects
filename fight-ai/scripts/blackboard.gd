extends Node3D

#@export var red : CharacterBody3D
#@export var blue : CharacterBody3D
var red
var blue

var red_current_action
var blue_current_action
#@onready var red = get_node("Red")
#@onready var blue = get_node("Blue")
var min_range = 2.0
var speed = 3.0

var red_weights = {
	"aggression": 2,
	"mobility": 1
}

var blue_weights = {
	"aggression": 1,
	"mobility": 2
}

signal red_action_changed(current_action)
signal blue_action_changed(current_action)
	

func get_current_action(is_red):
	if is_red:
		return red_current_action
	else:
		return blue_current_action

func set_current_action(is_red, action):
	if is_red:
		red_current_action = action
		red_action_changed.emit(action)
		#print(action)
		
	else:
		blue_current_action = action
		blue_action_changed.emit(action)
		#print(action)

#func _ready() -> void:
	#red = get_node("Red")
	#blue = get_node("Blue")

func get_property(is_red, property):
	if is_red:
		return red_weights[property]
	else:
		return blue_weights[property]
