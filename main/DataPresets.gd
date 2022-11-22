extends MenuButton

var popup

signal preset_chosen(preset_id)

# Called when the node enters the scene tree for the first time.
func _ready():
	popup = get_popup()
	popup.connect("id_pressed", self, "_on_id_pressed")
	
func _on_id_pressed(id):
	emit_signal("preset_chosen", id)

