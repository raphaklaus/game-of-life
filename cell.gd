extends ColorRect

var new_color

var is_alive

func init(size, pos, alive):
	rect_size = size
	rect_position = pos
	is_alive = alive

#func _ready():
#	if (is_alive):
#		color = new_color
#	else:
#		color = Color(1,1,1)
		
func set_alive(status):
	is_alive = status
	
#	print(is_alive)
	
	if is_alive:
		color = Color(0,0,0)
#		print("black")
	else:
		color = Color(1,1,1)
#		print("white")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):

