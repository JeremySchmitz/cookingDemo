extends Node

var ports: Array[PortResource]
var tileSet: TileSet

func reset():
	ports = []
	tileSet = null