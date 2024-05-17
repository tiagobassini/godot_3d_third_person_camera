extends CharacterBody3D

@onready var camera: Node3D = $camera

@onready var mesh: Node3D = $mesh
@onready var animation_tree: AnimationTree = $animation_tree
@onready var spring_arm: SpringArm3D = $camera/horizontal/vertical/spring_arm
@onready var spine_ik = $mesh/Armature/GeneralSkeleton/spine_ik
@onready var general_skeleton = %GeneralSkeleton


@export var walk_speed : float= 3.5
@export var run_speed : float= 8.0
@export var jump_velocity : float = 5
@export var jump_extra: bool = false

const SPRING_ARM_LENGTH= 2.0
const SPRING_ARM_LENGTH_AIM= 0.3
		
var current_speed: float = walk_speed

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var smooth_animation :Vector2= Vector2.ZERO

var is_running :bool = false
var is_aim: bool = false
var is_crouch: bool = false

func _physics_process(delta: float) -> void:
	
	var horizontal_rotation = camera.horizontal.global_transform.basis.get_euler().y
	var camera_direction = Vector2(sin(horizontal_rotation), cos(horizontal_rotation))
		
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized().rotated(Vector3.UP, horizontal_rotation)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor() or jump_extra:
			velocity.y = jump_velocity
			jump_extra = !jump_extra
		
	
	if Input.is_action_just_pressed("ui_run"):
		is_running = !is_running
		print("is running: ", is_running)
		if is_running :
			current_speed = run_speed
		else:
			current_speed = walk_speed
	
	if Input.is_action_pressed("ui_aim") :
		spine_ik.start()
		mesh.rotation.y = lerp_angle(mesh.rotation.y, atan2(camera_direction.x, camera_direction.y ), delta * 20)
		spring_arm.spring_length = lerp(spring_arm.spring_length, SPRING_ARM_LENGTH_AIM, delta * 10)
		spring_arm.position.x = 0.4
		spring_arm.position.y = 0.05
		is_aim = true
	elif spring_arm.spring_length != SPRING_ARM_LENGTH :
		spine_ik.stop()
		#general_skeleton.clear_bones_global_pose_override()
		spring_arm.position.x =0.0
		spring_arm.position.y =0.0
		spring_arm.spring_length = lerp(spring_arm.spring_length, SPRING_ARM_LENGTH, delta * 10)
		is_aim = false
	
	if Input.is_action_just_pressed("ui_crouch") :
		is_crouch = !is_crouch
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	

	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		mesh.rotation.y = lerp_angle(mesh.rotation.y, atan2(camera_direction.x, camera_direction.y ), delta * 5)
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	
	
	if !is_running :
		smooth_animation = lerp( smooth_animation, input_dir.clamp(Vector2(-0.5,-0.5), Vector2(0.5,0.5)), delta * 5)
	else:
		smooth_animation = lerp( smooth_animation, input_dir, delta * 5)
	

	animation_tree.set("parameters/Moviment/blend_position",smooth_animation)
	animation_tree.set("parameters/Crouch Moviment/blend_position",smooth_animation)
	animation_tree.set("parameters/Stand Aim/blend_position", smooth_animation)
	
	animation_tree.set("parameters/conditions/falling", !is_on_floor())
	animation_tree.set("parameters/conditions/landed", is_on_floor())
	animation_tree.set("parameters/conditions/crouch", is_crouch)
	animation_tree.set("parameters/conditions/stand", !is_crouch)
	animation_tree.set("parameters/conditions/aim", is_aim)
	animation_tree.set("parameters/conditions/not_aim", !is_aim)
	
	move_and_slide()
