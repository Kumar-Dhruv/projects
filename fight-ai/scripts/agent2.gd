extends CharacterBody3D

var GetInEnemyRange
var Attack
var CheckEnemyRange
var Fallback
var RSel
var Stall
var enemy
var tag	 = "Blue"


func _ready():
	_load()
	

func _load():
	Blackboard.blue = self
	enemy = Blackboard.red
	
	Fallback = AllNodes.fallback.new(self, enemy)
	GetInEnemyRange = AllNodes.get_in_enemy_range.new(self, enemy)
	Attack = AllNodes.attack.new(self)
	Stall = AllNodes.stall.new(self, enemy)
	RSel = AllNodes.RandomSel.new(self, enemy, [Stall, Fallback, Attack], [Blackboard.blue_mobility, Blackboard.blue_mobility, Blackboard.blue_aggression])
	CheckEnemyRange = AllNodes.check_enemy_range.new(self, enemy, [RSel, GetInEnemyRange])
	
func _physics_process(delta: float) -> void:
	if not (is_instance_valid(Blackboard.blue) and is_instance_valid(enemy)):
		_load()
		return
	CheckEnemyRange.execute()
