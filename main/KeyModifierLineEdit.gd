extends LineEdit


# Declare member variables here. Examples:
signal crypting(decrypt, key_modifier)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_DecryptButton_button_up():
	emit_signal("crypting", true, text)


func _on_EncryptButton_button_up():
	emit_signal("crypting", false, text)
