extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ScanCover.hide() #show()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_pressed("ui_accept") and $ScanCover.visible == true:
		$ScanCover.hide()
	elif Input.is_action_just_released("ui_accept") and $ScanCover.visible == false: #Input.is_action_just_released("ui_up") or Input.is_action_just_released("ui_down") or Input.is_action_just_released("ui_left") or Input.is_action_just_released("ui_right"):
		$ScanCover.hide() #show()
