extends Camera2D
 
export (NodePath) var TargetNodepath = null
var target_node
export (float) var lerpspeed = 0.05
 
func _ready():
	var node  = get_node(TargetNodepath)
	target_node = node.get_node("PathFollow2D/Sprite")
		
		
func _process(delta):
 
	self.position = lerp(self.position, target_node.get_global_position(), lerpspeed)
