extends Camera2D

var shake_amount := 0.0
var shake_decay := 3.0  # Higher = faster stop
var shake_strength := 10.0  # Max pixel offset

var rng := RandomNumberGenerator.new()
var original_position := Vector2.ZERO

func _ready():
	original_position = position
	rng.randomize()

func _process(delta):
	if shake_amount > 0.01:
		# Apply random shake
		var offset_x = rng.randf_range(-1.0, 1.0) * shake_amount * shake_strength
		var offset_y = rng.randf_range(-1.0, 1.0) * shake_amount * shake_strength
		position = original_position + Vector2(offset_x, offset_y)
		
		# Reduce shake over time
		shake_amount = max(shake_amount - delta * shake_decay, 0)
	else:
		# Reset position
		position = original_position

func shake(intensity: float = 1.0):
	shake_amount = clamp(intensity, 0.0, 1.0)
