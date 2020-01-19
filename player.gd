
extends KinematicBody

const ANIM_FLOOR = 0
const ANIM_AIR_UP = 1
const ANIM_AIR_DOWN = 2
const SHOOT_TIME = 1.5
const SHOOT_SCALE = 2
const CHAR_SCALE = Vector3(0.3, 0.3, 0.3)
const TURN_SPEED = 40
const ACCELERATION = 19.0
const DECELERATION = 14.0
const MAX_SPEED = 3.1

var facing_direction = Vector3(1, 0, 0)
var movement_direction = Vector3()
var jumping = false
var keep_jump_inertia = true
var air_idle_deaccel = false
var sharp_turn_threshold = 140
var prev_shoot = false
var linear_velocity = Vector3()
var shoot_blend = 0

func adjust_facing(p_facing, p_target, p_step, p_adjust_rate, current_gn):
    var n = p_target # Normal
    var t = n.cross(current_gn).normalized()
     
    var x = n.dot(p_facing)
    var y = t.dot(p_facing)
    
    var ang = atan2(y,x)
    
    if abs(ang) < 0.001: # Too small
        return p_facing
    
    var s = sign(ang)
    ang = ang * s
    var turn = ang * p_adjust_rate * p_step
    var a
    if ang < turn:
        a = ang
    else:
        a = turn
    ang = (ang - a) * s
    
    return (n * cos(ang) + t * sin(ang)) * p_facing.length()

func _handle_input(cam_transform):
    var direction = Vector3() # Where does the player intend to walk to
    
    if Input.is_action_pressed("move_forward"):
        direction += -cam_transform.basis[2]
    if Input.is_action_pressed("move_backward"):
        direction += cam_transform.basis[2]
    if Input.is_action_pressed("move_left"):
        direction += -cam_transform.basis[0]
    if Input.is_action_pressed("move_right"):
        direction += cam_transform.basis[0]
        
    return direction
    

func _physics_process(delta):
    
    var lv = linear_velocity
    var gravity = Vector3(0, -9.8, 0)

    lv += gravity * delta # Apply gravity
    
    var anim = ANIM_FLOOR
    
    var up = -gravity.normalized() # (up is against gravity)
    var vertical_velocity = up.dot(lv) # Vertical velocity
    var horizontal_velocity = lv - up * vertical_velocity # Horizontal velocity
    
    var h_direction = horizontal_velocity.normalized() # Horizontal direction
    var h_speed = horizontal_velocity.length() # Horizontal speed
    
    var cam_transform = get_node("target/camera").get_global_transform()
    
    var direction: Vector3 = _handle_input(cam_transform)
    
    var jump_attempt = Input.is_action_pressed("jump")
    
    var target_direction = (direction - up * direction.dot(up)).normalized()
    
    if is_on_floor():
        var sharp_turn = h_speed > 0.1 and rad2deg(acos(target_direction.dot(h_direction))) > sharp_turn_threshold
        
        if direction.length() > 0.1 and !sharp_turn:
            if h_speed > 0.001:
                h_direction = adjust_facing(h_direction, target_direction, delta, 1.0 / h_speed * TURN_SPEED, up)
                facing_direction = h_direction
            else:
                h_direction = target_direction
            
            if h_speed < MAX_SPEED:
                h_speed += ACCELERATION * delta
        else:
            h_speed -= DECELERATION * delta
            if h_speed < 0:
                h_speed = 0
        
        horizontal_velocity = h_direction * h_speed
        
        var mesh_transform = get_node("Armature").get_transform()
        var facing_mesh = -mesh_transform.basis[0].normalized()
        facing_mesh = (facing_mesh - up * facing_mesh.dot(up)).normalized()
        
        if h_speed > 0:
            facing_mesh = adjust_facing(facing_mesh, target_direction, delta, 1.0 / h_speed * TURN_SPEED, up)
            
        var m3 = Basis(-facing_mesh, up, -facing_mesh.cross(up).normalized()).scaled(CHAR_SCALE)
        
        get_node("Armature").set_transform(Transform(m3, mesh_transform.origin))
        
        if not jumping and jump_attempt:
            vertical_velocity = 7.0
            jumping = true
            get_node("sound_jump").play()
    else:
        if vertical_velocity > 0:
            anim = ANIM_AIR_UP
        else:
            anim = ANIM_AIR_DOWN
        
        # var hs
        if direction.length() > 0.1:
            horizontal_velocity += target_direction * (ACCELERATION * 0.2) * delta
            if (horizontal_velocity.length() > MAX_SPEED):
                horizontal_velocity = horizontal_velocity.normalized()*MAX_SPEED
        else:
            if air_idle_deaccel:
                h_speed = h_speed - (DECELERATION * 0.2) * delta
                if h_speed < 0:
                    h_speed = 0
                horizontal_velocity = h_direction * h_speed
    
    if jumping and vertical_velocity < 0:
        jumping = false
    
    lv = horizontal_velocity + (up * vertical_velocity)
    
    if is_on_floor():
        movement_direction = lv
    
    if !jumping:
        linear_velocity = move_and_slide_with_snap(lv, -up, up)
    else:
        linear_velocity = move_and_slide(lv, up)

    if is_on_floor():
        get_node("AnimationTreePlayer").blend2_node_set_amount("walk", h_speed / MAX_SPEED)
    
    get_node("AnimationTreePlayer").transition_node_set_current("state", anim)


func _ready():
    get_node("AnimationTreePlayer").set_active(true)
