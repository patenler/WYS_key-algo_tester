extends LineEdit

signal crypting(decrypt, key_modifier, key)

var level1_key = "Q"
var level2_key = "HUMANSCANTSOLVETHISSOBETTERSTOPHERE"
var level3_key = "EILLE"
var level4_key = "XDYOYOY"
var presets = [level1_key, level2_key, level3_key, level4_key]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_KeyPresets_preset_chosen(preset_id):
	text = presets[preset_id]
	


func _on_KeyModifierLineEdit_crypting(decrypt, key_modifier):
	emit_signal("crypting", decrypt, key_modifier, text)
