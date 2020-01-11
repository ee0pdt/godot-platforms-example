extends Spatial

enum TARGET {
    start,
    end
}

enum MODE {
    manual,
    auto
}

var end_vector: Vector3
var start_vector: Vector3
var direction_vector: Vector3
var movement_vector: Vector3

export(float) var total_time = 2
export(TARGET) var current_target = TARGET.end
export(MODE) var mode = MODE.auto
var time_passed = 0
var initial_position: Vector3
export(bool) var is_active = true

# Called when the node enters the scene tree for the first time.
func _ready():
    _initialize()
        
func _initialize():
    time_passed = 0
    start_vector = $StartPosition.translation
    end_vector = $EndPosition.translation
    if current_target == TARGET.end:
        direction_vector = end_vector - start_vector
        $Mesh.translation = start_vector
    else:
        direction_vector = start_vector - end_vector
        $Mesh.translation = end_vector
    initial_position = $Mesh.translation

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
    if is_active:
        _process_movement(delta)

func _process_movement(delta):
    time_passed = time_passed + delta
    var percent_complete = time_passed / total_time
    $Mesh.translation = initial_position + (direction_vector * Vector3(percent_complete, percent_complete, percent_complete)) 
    if percent_complete > 1:
        percent_complete = 1
        if mode == MODE.auto:
            if current_target == TARGET.end:
                current_target = TARGET.start
            else:
                current_target = TARGET.end
            _initialize()
        else:
            is_active = false
    
