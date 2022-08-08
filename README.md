# A-Star Pathfinding Demo

![image](https://github.com/bradley-mcfadden/a-star_demo/blob/master/astar2.png)

Implementation of A-star pathfinding on a tilemap in Godot. A start (white block) and a goal (red block)
can be moved around by the used. The black path shows the path the AI thinks it should take to reach the
goal. Some jank happens when it has to jump, because the jump value is improperly set to 0 sometimes. As
such, this isn't a perfect or game ready implementation, but it is demonstrative.

A better demo would perhaps allow the user to view the frontier at each iteration, and see the heuristic.
However, this is not a better demo. Nevertheless, it is interesting and probably useful for some. It makes
use of a poor implementation of a priority queue and a 2d list to store the search space. The solution is
returned by a linked list.

## Using

Build the demo in Godot (tested with version 3.4) and use left click to clear tiles, and to move and drag
the start and end goals. Right click allows a tile to be placed.
