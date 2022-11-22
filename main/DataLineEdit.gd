extends LineEdit


# Declare member variables here. Examples:
var presets = ["preset 1", "preset 2"]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



func _on_DataPresets_preset_chosen(preset_id):
	text = presets[preset_id]
