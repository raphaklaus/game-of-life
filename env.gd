extends ColorRect

const cellScene = preload("res://cell.tscn")
const grid = 16
const cellW = grid
const cellH = grid
var viewport_size
var max_w_grids
var max_h_grids
var population = []
const max_pop = 900
var pop_count = 0
var frames = 0
var generation = 0
var is_clicking = false
var is_sim_running = true

const sim_step = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	viewport_size = get_viewport().size
	max_w_grids = viewport_size.x / grid
	max_h_grids = viewport_size.y / grid

	rect_size = viewport_size
	
	var max_vp_w = viewport_size.x - cellW
	var max_vp_h = viewport_size.y - cellH

	population = create_initial_generation(population)
#	print(population)
	position_population(population)

func create_initial_generation(population):
	for h in max_h_grids:
		population.append([])
		
		for w in max_w_grids:
			population[h].append({"status": -1, "ref": null})

	while (pop_count < max_pop):
		var h_index = int(rand_range(0, max_h_grids))
		var w_index = int(rand_range(0, max_w_grids))
		population[h_index][w_index] = {"status": 1, "ref": create_cell(w_index, h_index, true)}

		pop_count += 1
	
	return population

func create_cell(w, h, alive):
	var position = Vector2(grid * w, grid * h)
	var instance = cellScene.instance()
	instance.init(Vector2(cellW, cellH), position, alive)
	add_child(instance)
	return instance

func position_population(population):
	for h in max_h_grids:
		for w in max_w_grids:
			if (population[h][w].status == 1):
				if (population[h][w].ref == null):
					population[h][w] = {"status": 1, "ref": create_cell(w, h, true)}
				
				population[h][w].ref.set_alive(true)
			elif (population[h][w].status == -1):
				if (population[h][w].ref):
					population[h][w].ref.set_alive(false)
				else:
					population[h][w] = {"status": -1, "ref": create_cell(w, h, false)}
					population[h][w].ref.set_alive(false)
					
				

	
func rule(population, new_population, w, h, current_status, predicate, target_status):
	var count = 0
	if (population[h][w].status == current_status):
		if w > 0 and population[h][w-1].status == 1: 
			count += 1
			
		if w < max_w_grids - 1 and population[h][w+1].status == 1:
			count += 1
			
		if h > 0 and population[h-1][w].status == 1:
			count += 1
		
		if h < max_h_grids - 1 and population[h+1][w].status == 1:
			count += 1
			
		if (h > 0 and w > 0) and population[h-1][w-1].status == 1:
			count += 1

		if (h > 0 and w < max_w_grids - 1) and population[h-1][w+1].status == 1:
			count += 1

		if (h < max_h_grids - 1 and w > 0) and population[h+1][w-1].status == 1:
			count += 1

		if (h < max_h_grids - 1 and w < max_w_grids - 1) and population[h+1][w+1].status == 1:
			count += 1

		if (predicate.call_func(count)):
			new_population[h][w].status = target_status
		
	return new_population
		
func is_count_more_than_3(count):
	return count > 3	

func is_count_2_or_3(count):
	return count == 2 or count == 3

func is_count_3(count):
	return count == 3

func is_count_less_than_2(count):
	return count < 2

func create_next_generation(population, new_population):
	for h in max_h_grids:
		for w in max_w_grids:
			# underpopulation
			new_population = rule(population, new_population, w, h, 1, funcref(self, "is_count_less_than_2"), -1)
			# overpopulation
			new_population = rule(population, new_population, w, h, 1, funcref(self, "is_count_more_than_3"), -1)
			# reproduction
			new_population = rule(population, new_population, w, h, -1, funcref(self, "is_count_3"), 1)
			# keeps existing
			new_population = rule(population, new_population, w, h, 1, funcref(self, "is_count_2_or_3"), 1)
			
	return new_population

func update_label(generation, is_sim_running):
	get_tree().get_root().get_node("Node2D/Label").text = "Generation #%s\nSimulation: %s" % [String(generation), "playing" if is_sim_running == true else "stopped"]

func check_for_restart():
	if (Input.is_action_just_pressed("ui_accept")):
		get_tree().reload_current_scene()

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			is_clicking = true
		else:
			is_clicking = false

func toggle_sim():
	if (Input.is_action_just_released("ui_down")):
		is_sim_running = !is_sim_running


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	check_for_restart()
	toggle_sim()
	update_label(generation, is_sim_running)

	if is_clicking:
			var w = int(get_viewport().get_mouse_position().x / grid)
			var h = int(get_viewport().get_mouse_position().y / grid)
			
#			print(w)
#			print(h)
			
			population[h][w] = {"status": 1, "ref": create_cell(w, h, true)}
#			print(population[1])
			position_population(population)

	if is_sim_running:
		if frames > sim_step - 1:
			generation += 1
			var new_population = population.duplicate(true)
			population = create_next_generation(population, new_population)
#			print("a", population[1])
#			print("---------------")
			position_population(population)
			frames = 0
		else:
			frames += 1

#
	
	
