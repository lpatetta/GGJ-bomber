extends PanelContainer

signal video_finished
export var is_playing = false;
var target_scale:Vector2;
var start_scale


export (Array, VideoStream) var streams


# Called when the node enters the scene tree for the first time.
func _ready():
	start_scale = Vector2(0.2, 0.2);
	target_scale = Vector2(0.35, 0.35);
	visible = false;
	#if was_playing and not $VideoPlayer.is_playing():
		
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rect_position = Vector2(40.0, 40.0) # TODO: depend on Position of player
	rect_scale = lerp( rect_scale, target_scale, 0.2)
	 

func _show_video():
	
	$VideoPlayer.stream = streams[ randi() % streams.size() ]
	rect_scale = start_scale
	is_playing = true
	visible = true;
	$VideoPlayer.play();
	$Timer.start()

func _on_Timer_timeout():
	emit_signal("video_finished")
	$VideoPlayer.stop();
	visible = false
	is_playing = false
