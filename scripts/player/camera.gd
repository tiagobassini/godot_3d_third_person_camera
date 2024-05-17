extends Node3D

@export var sensitivity : float= 0.2
@export var acceleration :float= 10

const MIN := -300
const MAX := 250

var cam_hor :float= 0.0
var cam_ver :float = 0.0

@onready var horizontal: Node3D = $horizontal
@onready var vertical: Node3D = $horizontal/vertical

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion :
		cam_hor -= event.relative.x * sensitivity
		cam_ver -= event.relative.y * sensitivity
	
	if Input.is_action_just_pressed("ui_cancel") :
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta: float) -> void:
	
	cam_ver = clamp(cam_ver, MIN, MAX)
	
	horizontal.rotation_degrees.y = lerp(horizontal.rotation_degrees.y, cam_hor, acceleration*delta)
	vertical.rotation_degrees.x = lerp(horizontal.rotation_degrees.x, cam_ver, acceleration*delta)
