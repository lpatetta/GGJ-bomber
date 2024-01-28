extends PanelContainer

signal video_finished
var was_playing = false;
var target_scale:Vector2;
var start_scale


# Called when the node enters the scene tree for the first time.
func _ready():
	start_scale = Vector2(0.2, 0.2);
	target_scale = Vector2(1, 1);
	visible = false;
	#if was_playing and not $VideoPlayer.is_playing():
		
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rect_scale = lerp( rect_scale, target_scale, 0.2)
	 

func _show_video():
	rect_scale = start_scale
	was_playing = true
	visible = true;
	$VideoPlayer.play();
	$Timer.start()
	
	
	


func _on_Timer_timeout():
	emit_signal("video_finished")
	visible = false
	was_playing = false
