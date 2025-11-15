extends CharacterBody3D

var GetInEnemyRange
var Attack
var CheckEnemyRange
var FallBack
var RSel
var Stall
var enemy
var Root
@export var is_red = true

func _ready():
	_load()
	$TreeBuilder.build_tree(Root)
	if is_red:
		Blackboard.connect("red_action_changed", action_changed)
	else:
		Blackboard.connect("blue_action_changed", action_changed)

func _load():
	if is_red:
		Blackboard.red = self
	else:
		Blackboard.blue = self
	
	if is_red:
		enemy = Blackboard.blue
	else:
		enemy = Blackboard.red
	

	#print(typeof(AllNodes.check_enemy_range))
	var tree = [AllNodes.check_enemy_range, [AllNodes.RandomSel, [AllNodes.Sequence, [AllNodes.attack, AllNodes.fallback], AllNodes.stall, AllNodes.fallback], AllNodes.get_in_enemy_range]]
	#print(tree)
	
	Root = AllNodes.Root.new(self, enemy, tree)

	
	
	#FallBack = AllNodes.fallback.new(self, enemy)
	#GetInEnemyRange = AllNodes.get_in_enemy_range.new(self, enemy)
	#Attack = AllNodes.attack.new(self, enemy)
	#Stall = AllNodes.stall.new(self, enemy)
	#
	#if is_red:
		#RSel = AllNodes.RandomSel.new(self, enemy, [Stall, FallBack, Attack])
	#else:
		#RSel = AllNodes.RandomSel.new(self, enemy, [Stall, FallBack, Attack])
	#
	#CheckEnemyRange = AllNodes.check_enemy_range.new(self, enemy, [RSel, GetInEnemyRange])

	
func _physics_process(delta: float) -> void:
	if not (is_instance_valid(enemy)):
		_load()
		return
	#CheckEnemyRange.execute()
	Root.execute()
	
func action_changed(new_action):
	var action_name = AllNodes.action.keys()[new_action]
	if action_name == "ATTACKING":
		$Skin.slash()

	
