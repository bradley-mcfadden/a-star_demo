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
		
class PathFinder:
	var frontier:Array

class PathFinderNode:
	var xy:int
	var jump_value:int
