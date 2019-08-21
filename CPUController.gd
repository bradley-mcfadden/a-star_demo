extends Node
func _ready():
	randomize()
	var pq: PriorityQueue = PriorityQueue.new()
	for i in range(10):
		pq.add(randi() % (i + 1), randi() % 10)
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
		var frontier:PriorityQueue = PriorityQueue.new()
		self.width = width
		self.height = height
		came_from = []
		var cost_so_far:PoolByteArray = []
		for i in range(width * height):
			came_from.append(-1)
			cost_so_far.append(-1)
		cost_so_far[start[1] << int(log(width) / (log(2))) | start[0]] = 0
	
	func make_new_node(x:int, y:int, jv:int) -> PathFinderNode:
		return PathFinderNode.new(y << int(log(width) / (log(2))) | x, jv)
	
	func distance(a:PathFinderNode, b:PathFinderNode) ->  int:
		var distance:int = 0
		distance += abs((a.xy & width) - (b.xy & width))
		distance += abs((a.xy >> int(log(width) / log(2))) - (b.xy >> int(log(width) / log(2))))
		return distance
	
	func heuristic(next:PathFinderNode) -> int:
		var cost:int = 0
		cost += abs((next.xy & width) - (goal & width))
		cost += abs((next.xy >> int(log(width) / log(2))) - (goal >> int(log(width) / log(2))))
		return cost
	
	func neighbours(node:PathFinderNode) -> Array:
		var neighbours:Array = []
		var tpos:Vector2 = Vector2(node.xy & width, node.xy >> int(log(width) / log(2)))
		if graph.get_cellv(tpos + Vector2(1, 0)) == 1 && (tpos + Vector2(0, 1)).x < width:
			# add a new node to the right
			# set each jump value equal to node.jump_value + 1
			pass
		if graph.get_cellv(tpos + Vector2(-1, 0)) == 1 && (tpos + Vector2(-1, 0)).x > 0:
			# add a new node to the right
			# set each jump value equal to node.jump_value + 1
			pass
		if graph.get_cellv(tpos + Vector2(0, 1)) == 1 && (tpos + Vector2(0, 1)).x < height:
			# add a new node to the right
			# set each jump value equal to node.jump_value + 1
			pass
		if graph.get_cellv(tpos + Vector2(1, 0)) == 1 && (tpos + Vector2(0,1)).x > 0:
			# add a new node to the right
			# set each jump value equal to node.jump_value + 1
			pass
		return neighbours
