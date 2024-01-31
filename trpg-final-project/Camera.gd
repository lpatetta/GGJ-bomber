extends Camera2D
 
export (NodePath) var TargetNodepath = null
export (float) var lerpspeed = 0.05
export (Vector2) var target_zoom;
export (float) var zoomspeed = 0.05
var target_node

var is_zooming = false;

 
func _ready():
	var node  = get_node(TargetNodepath)
	target_node = node.get_node("PathFollow2D/Sprite")
	
		
func _process(delta): 
	
	var target_pos = target_node.get_global_position();
	
	if is_zooming:
		zoom = lerp(zoom, target_zoom, zoomspeed);
		target_pos.y -= 40;
	else:
		zoom = lerp(zoom, Vector2(1,1), zoomspeed * 3);
		
		
	position = lerp(position, target_pos, lerpspeed)
