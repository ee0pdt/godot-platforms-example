tool

extends Spatial

# Used below for settings etc.
enum TARGET {
    start,
    end
}

enum MODE {
    manual,
    auto
}

var time_passed: int = 0
var initial_position: Vector3
var end_vector: Vector3
var start_vector: Vector3
var direction_vector: Vector3
var geometry_node: Node

# Settings available in Editor
export(float) var total_time = 2
export(TARGET) var current_target = TARGET.end
export(MODE) var mode = MODE.auto
export(bool) var is_active = true
export(PackedScene) var platform_scene

# Called when the node enters the scene tree for the first time.
func _ready():
    _onetime_setup()
    _initialize()

func _onetime_setup():
    geometry_node = $Geometry
    if !platform_scene:
        return
        
    # Get the old placeholder node
    var old_node = geometry_node

    # Create new node
    var new_node = platform_scene.instance()

    # Add the new node to the tree, under the same parent
    self.add_child(new_node)

    # Move it to same order within children
    #self.move_child(new_node, old_node.index)

    # Set properties you want to be the same
    new_node.name = old_node.name
    new_node.translation = old_node.translation
    new_node.rotation = old_node.rotation
    new_node.scale = old_node.scale
    geometry_node = new_node
    
    print(new_node)
    
    # Remove it from the tree
    self.remove_child(old_node)

    # Destroy it (not immediately, some code might still use it)
    old_node.call_deferred("free")
        
func _initialize():
    time_passed = 0
    start_vector = $StartPosition.translation
    end_vector = $EndPosition.translation
    if geometry_node:
        if current_target == TARGET.end:
            direction_vector = end_vector - start_vector
            geometry_node.translation = start_vector
        else:
            direction_vector = start_vector - end_vector
            geometry_node.translation = end_vector
        initial_position = geometry_node.translation

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if is_active:
        _process_movement(delta)

func _process_movement(delta):
    time_passed = time_passed + delta
    var percent_complete = time_passed / total_time
    # Hack for bug in editor - better solution?
    if geometry_node:
        geometry_node.translation = initial_position + (direction_vector * Vector3(percent_complete, percent_complete, percent_complete)) 
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
    
