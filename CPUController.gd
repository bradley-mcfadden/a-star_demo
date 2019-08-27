extends Node
func _ready():
	randomize()
	var pq: PriorityQueue = PriorityQueue.new()
	for i in range(10):
		pq.add(randi() % (i + 1), randi() % 10)
#warning-ignore:unused_variable
	for i in range(10):
		pq.poll()
	
		
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
	var came_from:PoolByteArray
	var width:int
	var height:int
	var goal:int
	var graph:TileMap
	
	func _init(graph:TileMap, start:PoolByteArray, goal:PoolByteArray, width:int, height:int):
		assert start[0] < width && start[0] > 0 && start[1] < height && start[1] > 0
		assert goal[0] < height && goal[0] > 0 && start[1] < height && start[1] > 0
		self.goal = goal[1] << int(log(width) / (log(2))) | goal[0]
		self.graph = graph
#warning-ignore:unused_variable
		var frontier:PriorityQueue = PriorityQueue.new()
		self.width = width
		self.height = height
		came_from = []
		var cost_so_far:PoolByteArray = []
#warning-ignore:unused_variable
		for i in range(width * height):
			came_from.append(-1)
			cost_so_far.append(-1)
		cost_so_far[start[1] << int(log(width) / (log(2))) | start[0]] = 0
	
	func make_new_node(x:int, y:int, jv:int) -> PathFinderNode:
		return PathFinderNode.new(y << int(log(width) / (log(2))) | x, jv)
	
	func make_new_nodev(xy:Vector2, jv:int) -> PathFinderNode:
		return PathFinderNode.new(int(xy.y) << int(log(width) / (log(2))) | int(xy.x), jv)
	
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
		var tpos:Vector2 = Vector2(node.xy & width, node.xy >> int(log(width) / log(2)))
		if graph.get_cellv(tpos + Vector2(1, 0)) == 1 && (tpos + Vector2(0, 1)).x < width:
			# add a new node to the right
			neighbours.append(make_new_nodev(tpos + Vector2(1, 0), node.jump_value + 1))
		if graph.get_cellv(tpos + Vector2(-1, 0)) == 1 && (tpos + Vector2(-1, 0)).x > 0:
			# add a new node to the left
			neighbours.append(make_new_nodev(tpos + Vector2(-1, 0), node.jump_value + 1))
		if graph.get_cellv(tpos + Vector2(0, 1)) == 1 && (tpos + Vector2(0, 1)).x < height:
			# add a new node to the bottom
			neighbours.append(make_new_nodev(tpos + Vector2(1, 0), 
					node.jump_value + 1 if (node.jump_value + 1) % 2 == 0 else node.jump_value + 2))
		if graph.get_cellv(tpos + Vector2(0, -1)) == 1 && (tpos + Vector2(0, -1)).y > 0:
			# add a new node to the top
			neighbours.append(make_new_nodev(tpos + Vector2(-1, 0), 
					node.jump_value + 1 if (node.jump_value + 1) % 2 == 0 else node.jump_value + 2))
		for neighbour in neighbours:
			if is_node_on_floor(neighbour) == true:
				neighbour.jump_value = 0
		return neighbours
	
	func is_tile_on_floor(position:Vector2) -> bool:
		assert position.x < 0 && position.x > width && position.y < 0 && position.y > height
		if graph.get_cellv(position + Vector2(0, 1)) == 1:
			return true
		return false
	
	func is_node_on_floor(node:PathFinderNode):
		return is_tile_on_floor(Vector2(node.xy & width, (node.xy >> int(log(width) / log(2)))))
