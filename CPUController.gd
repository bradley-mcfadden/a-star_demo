extends Node2D
const MAX_JUMP = 8


export var WIDTH := 3
export var HEIGHT := 3
export var start:Vector2
export var goal:Vector2
onready var path:Array


func find_path():
	path = []
	var pf = PathFinder.new(get_parent(), start, goal, WIDTH, HEIGHT)
	var next_step:PathFinderNode = pf.goal
	path.append(pf.goal)
	# if pf.success == false:
	# 	update()
	# 	return
	while next_step != null and next_step.xy != -1:
		path.append(next_step)
		next_step = pf.came_from[next_step.xy][next_step.jump_value]
	for i in range(1, path.size()):
		print(path[path.size()-i].to_string())
	update()


func _draw():
	for i in range(0, path.size() - 1):
		draw_line(Vector2(16, 16) + Vector2(path[i].xy % WIDTH, path[i].xy / WIDTH) * 32, Vector2(16, 16) + Vector2(path[i+1].xy % WIDTH, path[i+1].xy / WIDTH) * 32, Color(0, 0, 0))


class PriorityQueue:
	var data:Array
	var priority:Array
	
	
	func _init():
		data = []
		priority = []
	
	
	func add(a, p:int):
		data.push_front(a)
		priority.push_front(p)
	
	
	func poll():
		# assert data.size() > 0
		var remove:int = priority.find(priority.min())
		var polled = data[remove]
		data.remove(remove)
		priority.remove(remove)
		return polled
	
	
	func peek():
		# assert data.size() > 0
		var remove:int = priority.find(priority.min())
		var polled = data[remove]
		return polled
	
	
class PathFinderNode:
	var xy:int
	var jump_value:int
	func _init(xy:int, jump_value:int):
		self.xy = xy
		self.jump_value = jump_value
	
	func equals(node:PathFinderNode) -> bool:
		return self.xy == node.xy && self.jump_value == node.jump_value
	
	func to_string() -> String:
		return "XY: " + str(xy) + " Jump Value:" + str(jump_value)


class PathFinder:
	var came_from:Array
	var width:int
	var height:int
	var goal:PathFinderNode
	var graph:TileMap
	var success:bool

	
	func _init(graph:TileMap, start:Vector2, ggoal:Vector2, width:int, height:int):
		# assert start.x < width && start.x >= 0 && start.y < height && start.y >= 0
		# assert ggoal.x < width && ggoal.x >= 0 && ggoal.y < height && ggoal.y >= 0
		self.graph = graph
		self.width = width
		self.height = height
		success = false
		#warning-ignore:unused_variable
		var frontier:PriorityQueue = PriorityQueue.new()
		var start_node:PathFinderNode = make_new_node(start.x, start.y, 0)
		self.goal = make_new_node(ggoal.x, ggoal.y, 0)
		frontier.add(start_node, 0)
		came_from = []
		var cost_so_far:PoolByteArray = []
		#warning-ignore:unused_variable
		for i in range(width * height):
			came_from.append([])
			for j in range(4 * height):
				came_from[i].append(null)
			cost_so_far.append(0)
		came_from[start_node.xy][start_node.jump_value] = PathFinderNode.new(-1, -1)
		cost_so_far[int(start.y) << int(log(width) / (log(2))) | int(start.x)] = 0
		
		while frontier.data.size() > 0:
			# print(frontier.data)
			var current:PathFinderNode = frontier.poll()
			
			if current.xy == self.goal.xy:
				self.goal = current
				success = true
				break
				
			#print("Looking at current %d" % current.xy)
			for next in neighbours(current):
				if came_from[next.xy][next.jump_value] == null:
					var priority = heuristic(next)
					frontier.add(next, priority)
					came_from[next.xy][next.jump_value] = current
				if next.xy == self.goal.xy:
					print("Found the goal")

	
	func make_new_node(x:int, y:int, jv:int) -> PathFinderNode:
		return PathFinderNode.new((y * width) + x, jv)

	
	func make_new_nodev(xy:Vector2, jv:int) -> PathFinderNode:
		return PathFinderNode.new(int(xy.y) * width + int(xy.x), jv)

	
	func distance(a:PathFinderNode, b:PathFinderNode) ->  int:
		var distance:int = 0
		#warning-ignore:narrowing_conversion
		distance += abs((a.xy & width) - (b.xy & width))
		#warning-ignore:narrowing_conversion
		distance += abs((a.xy >> int(log(width) / log(2))) - (b.xy >> int(log(width) / log(2))))
		return distance

	
	func heuristic(next:PathFinderNode) -> int:
		var cost:int = 0
		#warning-ignore:narrowing_conversion
		cost += abs((next.xy & width) - (goal.xy & width))
		#warning-ignore:narrowing_conversion
		cost += abs((next.xy >> int(log(width) / log(2))) - (goal.xy >> int(log(width) / log(2))))
		return cost

	
	func neighbours(node:PathFinderNode) -> Array:
		var neighbours:Array = []
		var tpos:Vector2 = Vector2(node.xy % width, node.xy / width)
		if node.jump_value % 2 == 0 && graph.get_cellv(tpos + Vector2.RIGHT) == 0 && (tpos + Vector2.RIGHT).x < width:
			# add a new node to the right
			neighbours.append(make_new_nodev(tpos + Vector2.RIGHT, node.jump_value + 1))
		if node.jump_value % 2 == 0 && graph.get_cellv(tpos + Vector2.LEFT) == 0 && (tpos + Vector2.LEFT).x >= 0:
			# add a new node to the left
			neighbours.append(make_new_nodev(tpos + Vector2.LEFT, node.jump_value + 1))
		if graph.get_cellv(tpos + Vector2.UP) == 0 && (tpos + Vector2.UP).y < height:
			# add a new node to the bottom
			neighbours.append(make_new_nodev(tpos + Vector2.UP, MAX_JUMP))
				#node.jump_value #+ 1))
				#+ 1 if (node.jump_value + 1) % 2 == 0 else node.jump_value + 2))
		if (graph.get_cellv(tpos + Vector2.DOWN) == 0 && (tpos + Vector2.DOWN).y >= 0 &&
			next_even(node.jump_value + 1) <= MAX_JUMP):
			# add a new node to the top
			neighbours.append(make_new_nodev(tpos + Vector2.DOWN,
				node.jump_value + 1 if (node.jump_value + 1) % 2 == 0 else node.jump_value + 2))
		for neighbour in neighbours:
			if is_node_on_floor(neighbour) == true:
				neighbour.jump_value = 0
		return neighbours

	
	func is_tile_on_floor(position:Vector2) -> bool:
		# assert position.x >= 0 && position.x < width && position.y >= 0 && position.y < height
		if graph.get_cellv(position + Vector2(0, 1)) == 1:
			return true
		return false
	
	
	func is_node_on_floor(node:PathFinderNode):
		return is_tile_on_floor(Vector2(node.xy % width, node.xy / width))
		
	
	
	func next_even(number:int) -> int:
		return number + 1 if (number + 1) % 2 == 0 else number + 2
