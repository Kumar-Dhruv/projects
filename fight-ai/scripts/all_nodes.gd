extends Node


enum action {
	ATTACKING,
	MOVING,
	IDLE,
	DEFENDING,
	STALLING,
	FALLBACK
}

enum status {
	SUCCESS,
	FAIL,
	RUNNING,
	PRIORITY_RUNNING
}




class Root:
	var agent
	var enemy
	var children = []
	
	func _init(_agent, _enemy, _tree):
		self.agent = _agent
		self.enemy = _enemy
		self.build_tree(self, _tree, true)
	
	func build_tree(parent, sub_tree: Array, from_root):
		var temp
		for node in sub_tree:
			if typeof(node) != TYPE_ARRAY:
				var new_node = node.new(self.agent, self.enemy)
				temp = new_node
				if not from_root:
					parent.children.append(new_node)
				else:
					self.children.append(new_node)
				continue
			else:
				self.build_tree(temp, node, false)
	
	func execute():
		self.children[0].execute()
	
class Leaf:
	
	var agent: CharacterBody3D
	var enemy: CharacterBody3D
	var children
	
	func _init(_agent, _enemy) -> void:
		self.agent = _agent
		self.enemy = _enemy

class Composite:
	var agent
	var enemy
	var children = []
	
	func _init(_agent, _enemy):
		self.agent = _agent
		self.enemy = _enemy

class Sequence extends Composite:
	var c_result = false
	var processing
	var count = 0
	
	func execute():
		match self.c_result:
			false:
				print("sequence node ", self.count+1)
				self.c_result = self.children[self.count].execute()
				self.processing = self.children[self.count]
				return status.RUNNING
			status.RUNNING:
				self.c_result = self.processing.execute()
				return status.RUNNING
			status.FAIL:
				self.c_result = false
				self.count = 0
				return status.FAIL
			status.SUCCESS:
				self.c_result = false
				self.count += 1
				if self.count >= self.children.size():
					self.count = 0
					return status.SUCCESS
				else:
					return status.RUNNING

class Selector extends Composite:
	var c_result = false
	var processing
	
	func check_and_execute(indx):
		match self.c_result:
			false:
				self.c_result = self.children[indx].execute()
				self.processing = self.children[indx]
				print("start")
				return status.RUNNING
			status.RUNNING:
				self.c_result = self.processing.execute()
				return status.RUNNING
			status.SUCCESS:
				self.c_result = false
				return status.SUCCESS
			status.FAIL:
				self.c_resule = false
				return status.FAIL

class RandomSel extends Selector:
	var rng = RandomNumberGenerator.new()
	
	func execute():
		var weights: Array
		for child in self.children:
			if not ("weight_property" in child):
				weights.append(1)
				continue
			weights.append(child.weight_property)
		return check_and_execute(rng.rand_weighted(weights))
	


class check_enemy_range extends Selector:
	func execute():
		if (agent.position.distance_to(enemy.position)) <= Blackboard.min_range:
			check_and_execute(0)
		else:
			check_and_execute(1)

class get_in_enemy_range extends Leaf:

	var speed = Blackboard.speed
	var min_range = Blackboard.min_range
	
	func execute():
		Blackboard.set_current_action(self.agent.is_red, action.MOVING)
		var dir = (enemy.position - agent.position).normalized()
		if (agent.position.distance_to(enemy.position)) <= min_range:
			agent.velocity = Vector3.ZERO
			return status.SUCCESS
			
		self.agent.velocity = dir * speed
		self.agent.get_node("Skin").rotation.y = -dir.angle_to(Vector3(0, 0, 1))
		self.agent.move_and_slide()
		return status.RUNNING

class attack extends Leaf:
	var timer: Timer
	var can_attack = true
	
	var weight_property
	
	func _init(_agent, _enemy):
		self.agent = _agent
		self.timer = agent.get_node("Temp")
		self.timer.timeout.connect(attack_timeout)
		self.weight_property = Blackboard.get_property(self.agent.is_red, "aggression")
	
	func execute():
		if Blackboard.get_current_action(self.agent.is_red) != action.ATTACKING:
			self.timer.start()
			self.can_attack = true
			Blackboard.set_current_action(self.agent.is_red, action.ATTACKING)
		
		if self.can_attack:
			return status.RUNNING
		else:
			return status.SUCCESS
	
			
	func attack_timeout():
		self.can_attack = false
		
class stall extends Leaf:
	var timer: Timer
	var can_stall = true
	var rng = RandomNumberGenerator.new()
	
	var weight_property
	
	func _init(_agent, _enemy) -> void:
		self.agent = _agent
		self.enemy = _enemy
		self.timer = self.agent.get_node("StallTimer")
		self.timer.connect("timeout", stop_stalling)
		self.weight_property = Blackboard.get_property(self.agent.is_red, "mobility")
	
	func execute():
			
		if Blackboard.get_current_action(self.agent.is_red) != action.STALLING:
			self.timer.start(rng.randf_range(1.0, 2.5))
			self.can_stall = true
			Blackboard.set_current_action(self.agent.is_red, action.STALLING)
		
		if not self.can_stall:
			return status.SUCCESS
		
		var dir_to_enemy: Vector3 = (enemy.position - agent.position).normalized()
		var normal = dir_to_enemy.rotated(Vector3.UP, PI/2)
		
		self.agent.velocity = normal * Blackboard.speed
		self.agent.get_node("Skin").rotation.y = -normal.angle_to(Vector3(0, 0, 1))
		
		self.agent.move_and_slide()
		return status.RUNNING
	
	func stop_stalling():
		self.can_stall = false

class fallback extends Leaf:
	var timer: Timer
	var can_fallback = true
	var rng = RandomNumberGenerator.new()
	
	var weight_property
	
	func _init(_agent, _enemy):
		self.agent = _agent
		self.enemy = _enemy
		self.timer = self.agent.get_node("FallbackTimer")
		self.timer.connect("timeout", stop_fallback)
		self.weight_property = Blackboard.get_property(self.agent.is_red, "mobility")
	
	func execute():
		if Blackboard.get_current_action(self.agent.is_red) != action.FALLBACK:
			self.can_fallback = true
			self.timer.start(self.rng.randf_range(0.5, 1))
			Blackboard.set_current_action(self.agent.is_red, action.FALLBACK)
		
		if not can_fallback:
			return status.SUCCESS
		
		var opp_dir = (self.agent.position - self.enemy.position).normalized()
		var fall_dir = opp_dir.rotated(Vector3.UP, rng.randf_range(-0.26, 0.26))
		
		self.agent.velocity = fall_dir * Blackboard.speed
		self.agent.move_and_slide()
		
		return status.RUNNING
		
	
	
	func stop_fallback():
		self.can_fallback = false
