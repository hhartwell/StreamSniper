extends RayCast2D


var is_casting := false setget set_is_casting


func _ready() -> void:
    set_physics_process(false)
    
    # Hide line
    $Line2D.points[0] = Vector2.ZERO
    $Line2D.points[1] = Vector2.ZERO

func _physics_process(delta: float) -> void:
    #var cast_point := cast_to
    force_raycast_update()
    
    # TODO: If we want to only display stuff when colliding, use this?
    #if is_colliding():
    #	cast_point = to_local(get_collision_point())
        
    #var cast_point = get_viewport().get_mouse_position()
    
    #var cast_point = get_local_mouse_position()		
    #$Line2D.points[1] = cast_point
    
    var cast_point = get_local_mouse_position()
    var start_point = $Line2D.points[0]
    var direction = (cast_point - start_point).normalized()
    var laser_length = 10000  # Choose a large enough value to extend offscreen
    $Line2D.points[1] = start_point + direction * laser_length


func set_is_casting(cast: bool) -> void:
    is_casting = cast
    
    if is_casting:
        appear()
    else:
        disappear()
        
    set_physics_process(is_casting)


func appear() -> void:
    if $Tween.is_active():
        $Tween.stop_all()
    $Tween.interpolate_property($Line2D, "width", 0, 10.0, 0.2)
    $Tween.start()
    
func disappear() -> void:
    if $Tween.is_active():
        $Tween.stop_all()
    $Tween.interpolate_property($Line2D, "width", 10.0, 0, 0.2)
    $Tween.start()
