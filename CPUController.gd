extends Node
const MAX_JUMP = 8
func _ready():
	randomize()
	var pf = PathFinder.new(get_parent(), Vector2(2, 2), Vector2(2, 0), 3, 3)
	var path = pf.came_from[2].xy
	var path2:Array = []
	while true:
		path2.append(path)
		path = pf.came_from[path].xy
		if pf.came_from[path].xy == 8:
			break
	print(path2)
	
		
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
		assert data.size() > 0
		var remove:int = priority.find(priority.min())
		var polled = data[remove]
		data.remove(remove)
		priority.remove(remove)
		return polled
	
	func peek():
		assert data.size() > 0
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

class PathFinder:
	var came_from:Array
	var width:int
	var height:int
	var goal:int
	var graph:TileMap
	
	func _init(graph:TileMap, start:Vector2, goal:Vector2, width:int, height:int):
		assert start.x < width && start.x >= 0 && start.y < height && start.y >= 0
		assert goal.x < width && goal.x >= 0 && goal.y < height && goal.y >= 0
		self.goal = (goal.y * width) + goal.x
		self.graph = graph
		self.width = width
		self.height = height
		#warning-ignore:unused_variable
		var frontier:PriorityQueue = PriorityQueue.new()
		frontier.add(make_new_node(start.x, start.y, 0), 0)
		came_from = []
		var cost_so_far:PoolByteArray = []
		#warning-ignore:unused_variable
		for i in range(width * height):
			came_from.append(null)
			cost_so_far.append(0)
		cost_so_far[int(start.y) << int(log(width) / (log(2))) | int(start.x)] = 0
		
		while frontier.data.size() > 0:
			var current:PathFinderNode = frontier.poll()
			
			if current.xy == self.goal:
				break
				
			for next in neighbours(current):
				if came_from.has(next) == false:
					var priority = heuristic(next)
					frontier.add(next, priority)
					came_from[next.xy] = current
				if next.xy == self.goal:
					print("Found the goal")
		print()
	
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
		cost += abs((next.xy & width) - (goal & width))
		#warning-ignore:narrowing_conversion
		cost += abs((next.xy >> int(log(width) / log(2))) - (goal >> int(log(width) / log(2))))
		return cost
	
	func neighbours(node:PathFinderNode) -> Array:
		var neighbours:Array = []
		var tpos:Vector2 = Vector2(node.xy % width, node.xy / width)
		if node.jump_value % 2 == 0 && graph.get_cellv(tpos + Vector2(1, 0)) == 0 && (tpos + Vector2(1, 0)).x < width:
			# add a new node to the right
			neighbours.append(make_new_nodev(tpos + Vector2(1, 0), node.jump_value + 1))
		if node.jump_value % 2 == 0 && graph.get_cellv(tpos + Vector2(-1, 0)) == 0 && (tpos + Vector2(-1, 0)).x >= 0:
			# add a new node to the left
			neighbours.append(make_new_nodev(tpos + Vector2(-1, 0), node.jump_value + 1))
		if graph.get_cellv(tpos + Vector2(0, 1)) == 0 && (tpos + Vector2(0, 1)).y < height:
			# add a new node to the bottom
			neighbours.append(make_new_nodev(tpos + Vector2(0, 1),
				node.jump_value + 1 if (node.jump_value + 1) % 2 == 0 else node.jump_value + 2))
		if (graph.get_cellv(tpos + Vector2(0, -1)) == 0 && (tpos + Vector2(0, -1)).y >= 0 &&
			next_even(node.jump_value + 2) <= MAX_JUMP):
			# add a new node to the top
			neighbours.append(make_new_nodev(tpos + Vector2(0, -1),
				node.jump_value + 1 if (node.jump_value + 1) % 2 == 0 else node.jump_value + 2))
		for neighbour in neighbours:
			if is_node_on_floor(neighbour) == true:
				neighbour.jump_value = 0
		return neighbours
	
	func is_tile_on_floor(position:Vector2) -> bool:
		assert position.x >= 0 && position.x < width && position.y >= 0 && position.y < height
		if graph.get_cellv(position + Vector2(0, 1)) == 1:
			return true
		return false
	
	func is_node_on_floor(node:PathFinderNode):
		return is_tile_on_floor(Vector2(node.xy % width, node.xy / width))
		
	func next_even(number:int) -> int:
		return number + 1 if (number + 1) % 2 == 0 else number + 2
