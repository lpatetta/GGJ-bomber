## Represents a unit on the game board.
## The board manages its position inside the game grid.
## The unit itself holds stats and a visual representation that moves smoothly in the game world.
tool
class_name Unit
extends Path2D

## Emitted when the unit reached the end of a path along which it was walking.
signal walk_finished;
signal talk_finished;


## Shared resource of type Grid, used to calculate map coordinates.
export var grid: Resource

## Texture representing the unit.
export var skin: Texture setget set_skin
export var laugh: Texture setget set_laugh

onready var tween = $Tween
onready var audio = $AudioStreamPlayer2D

## Distance to which the unit can walk in cells.
export var move_range := 6
## Offset to apply to the `skin` sprite in pixels.
export var skin_offset := Vector2.ZERO setget set_skin_offset
## The unit's move speed when it's moving along a path.
export var move_speed := 600.0

export var is_main:= false
export var is_reacting:=false

export var starting_scale:Vector2;
export var target_scale:Vector2;
export var tween_duration:float;

export var trasition_type_in:int = Tween.TRANS_LINEAR;
export var trasition_type_out:int = Tween.TRANS_SINE;

export var color_id:int = 0;
var color_ids:Array;

## Coordinates of the current cell the cursor moved to.
var cell := Vector2.ZERO setget set_cell
## Toggles the "selected" animation on the unit.
var is_selected := false setget set_is_selected

var _is_walking := false setget _set_is_walking

var is_npc = true;
var reaction_id:int;


onready var _sprite: Sprite = $PathFollow2D/Sprite
onready var _anim_player: AnimationPlayer = $AnimationPlayer
onready var _path_follow: PathFollow2D = $PathFollow2D

func _ready() -> void:
	set_process(false)
	
	

	self.cell = grid.calculate_grid_coordinates(position)
	position = grid.calculate_map_position(cell)
	
	# We create the curve resource here because creating it in the editor prevents us from
	# moving the unit.
	if not Engine.editor_hint:
		curve = Curve2D.new()


func _process(delta: float) -> void:
	_path_follow.offset += move_speed * delta

	if _path_follow.offset >= curve.get_baked_length():
		self._is_walking = false
		_path_follow.offset = 0
		position = grid.calculate_map_position(cell)
		curve.clear_points()
		emit_signal("walk_finished")


## Starts walking along the `path`.
## `path` is an array of grid coordinates that the function converts to map coordinates.
func walk_along(path: PoolVector2Array) -> void:
	if path.empty():
		return

	curve.add_point(Vector2.ZERO)
	for point in path:
		curve.add_point(grid.calculate_map_position(point) - position)
	cell = path[-1]
	self._is_walking = true


func set_cell(value: Vector2) -> void:
	cell = grid.clamp(value)


func set_is_selected(value: bool) -> void:
	is_selected = value
	if is_selected:
		_anim_player.play("selected")
	else:
		_anim_player.play("idle")

func set_skin(value: Texture) -> void:
	skin = value
	if not _sprite:
		yield(self, "ready")
	_sprite.texture = value

func set_laugh(value: Texture) -> void:
	laugh = value
	if not _sprite:
		yield(self, "ready")

func set_color(c:Color) -> void:
	$PathFollow2D/Sprite.modulate = c;
	$PathFollow2D/Color.modulate = c;
	
func set_skin_offset(value: Vector2) -> void:
	skin_offset = value
	if not _sprite:
		yield(self, "ready")
	_sprite.position = value


func _set_is_walking(value: bool) -> void:
	_is_walking = value
	set_process(_is_walking)

func react(reaction):
	reaction_id = reaction
	$Timer.start()
	
	
func _on_Timer_timeout():
	if ( reaction_id == color_id ):
		_sprite.texture = laugh
		color_ids = get_parent().color_ids
		
		var color:Color = color_ids[color_id]
		
		tween.interpolate_property($PathFollow2D/Sprite, "modulate", color, modulate, 2, trasition_type_in, Tween.EASE_IN_OUT);
		tween.interpolate_property($PathFollow2D, "modulate:a", modulate.a, 0.6, tween_duration, trasition_type_out, Tween.EASE_OUT);
		tween.interpolate_property($PathFollow2D/Sprite, "scale", starting_scale, target_scale, tween_duration,
			trasition_type_out, Tween.EASE_OUT)
		tween.start();
		
		$TimerLaugh.start()
		audio.play()
	else:
		tween.interpolate_property($PathFollow2D/Sprite, "modulate", Color.red, modulate, 1, trasition_type_in, Tween.EASE_IN_OUT);		
		tween.start();
		emit_signal("talk_finished")


func _on_TimerLaugh_timeout():
	#tween.reset_all();
	#tween.interpolate_property($PathFollow2D/Sprite, "modulate:a", modulate.a, 1, tween_duration/5, trasition_type_out, Tween.EASE_OUT);
	#tween.start();
	emit_signal("talk_finished")
	visible = false;
	audio.stop()
	get_tree().call_group("GameBoard","clear_deleted_units")
	queue_free();
