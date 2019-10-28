extends Node

export (PackedScene) var Mob
var score

func _ready():
	randomize()
#	Create grids in the world around the player
#	initialize temps in the grid
#   Kickoff

var render_count
var entities
var flow_grid
var temp_grid

#1 indicates this should be done and complete before moving on to any tasks on the next number
func _process(delta):
	render_count = render_count + 1
	if render_count > 3:
		print("todo")
		cull_grid()
		temp_calc(delta)
		flow_calc(delta)
		render_count = 0
	ai()
	
# Every tick entities should check to see if they die from temp or not. No need to check for a few ticks if last check was really far away
# Every entity needs to know how to react to its current AI state
# Every entity needs to do collision itself and hook back to core functions if necessary

#Function to change the temp at a location
func change_temp(diff, x, y):
	print("todo")

#Function to change the flow at a location
func change_flow(diff, x, y):
	print("todo")

#Function to remove tracked entity - only objects that care about the world and ai, not particles etc
func remove_entity(id):
	print("todo")
	
#Function to add tracked entity
func add_entity(id):
	print("todo")

#1
func initialise_temps():
	print("todo")

#1
#Get player location, store grids that are out of range and retreive or generate grids that are now within range
func cull_grid():
	print("todo")

#1
#Move the temps of the world
func temp_calc(delta):
	print("todo")

#Move the flows of the world
func flow_calc(delta):
	print("todo")

#1
#Tells the AIs what they need to be doing each round so they can be aware of their surroundings.
#Basic to start with, just uses their position and basic actions to do stuff
func ai():
	print("todo")


# sdftype Atom struct {
#amount int64
#element string
#}
#
#type GridItem struct {
#type string
#contents []Atom
#temp int64
#}
#
#tempgrid1 := make([][]GridItem{})
#tempgrid2:= make([][]GridItem{})
#activeGrid:= &[][]GridItem{}
#inactiveGrid:= &[][]GridItem{}
#gridLength := 100
#gridHeight := 100
#transferCoefficient := 0.2
#func tempCalc() {
#for x := range 1..(gridLength -2) {
#for y := range 1..(gridHeight-2) {
#currTemp := activeGrid[x][y].temp
#inactiveGrid[x][y] = currTemp  + (currTemp-activeGrid[x-1][y])*transferCoefficient + (currTemp-activeGrid[x+1][y])*transferCoefficient + (currTemp-activeGrid[x][y-1])*transferCoefficient + (currTemp-activeGrid[x][y+1])*transferCoefficient
#}
#}
#tempPointer := activeGrid
#activeGrid = inactiveGrid
#inactiveGrid = tempPointer 
#}