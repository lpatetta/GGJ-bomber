extends Unit

onready var _changing_skin_timer: Timer = $Timer
var _is_changing_skin = false;
var _current_skin = 0;

export var starting_scale:Vector2;
export var target_scale:Vector2;
export var tween_duration:float;

export var trasition_type_in:int = Tween.TRANS_LINEAR;
export var trasition_type_out:int = Tween.TRANS_SINE;


export (Array, Texture) var skins

func _ready():
	._ready();
	
	if skins:
		set_skin(skins[_current_skin])

func _unhandled_input(event: InputEvent) -> void:
	if _is_changing_skin and event.is_action_released("activate"):
		_set_next_skin();

func _set_next_skin():
	_is_changing_skin = false;
	_changing_skin_timer.start();
	_current_skin+=1;
	if (_current_skin >= skins.size() ):
		_current_skin = 0;
		
	var tween = get_node("Tween")
	tween.interpolate_property($PathFollow2D/Sprite, "scale", starting_scale,target_scale, tween_duration,
		trasition_type_in, Tween.EASE_IN_OUT)
		
	tween.interpolate_callback(self, tween_duration, "_return_scale");
	#tween.tween_callback(_return_scale);
	tween.start();
	set_skin( skins[_current_skin])
	
func _return_scale():
	var tween = get_node("Tween")
	
	tween.interpolate_property($PathFollow2D/Sprite, "scale", target_scale, starting_scale, tween_duration * 0.7,
		trasition_type_out, Tween.EASE_IN_OUT)

func _on_Timer_timeout():
	_is_changing_skin = true;
	
	
func set_skins(value: Array) -> void:
	skin = value[0]
	if not _sprite:
		yield(self, "ready")
	_sprite.texture = value[0]
