extends Control

@export var node_size = Vector2(120, 30)

func build_tree(root):
	build_subtree(self, root)
	return
	

func build_subtree(point, parent):
	var parent_vbox = VBoxContainer.new()
	var parent_container = PanelContainer.new()

	parent_container.custom_minimum_size = node_size
	parent_container.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	parent_container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	point.add_child(parent_vbox)
	parent_vbox.add_child(parent_container)
	
	if parent.children:
		var parent_children_hbox = HBoxContainer.new()
		parent_vbox.add_child(parent_children_hbox)
		
		for child in parent.children:
			if child.children:
				build_subtree(parent_children_hbox, child)
			else:
				var child_container = PanelContainer.new()
				child_container.custom_minimum_size = node_size
				child_container.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
				child_container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
				parent_children_hbox.add_child(child_container)
	else:
		return
