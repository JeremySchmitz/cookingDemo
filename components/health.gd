class_name Cook
extends Node

signal cookedChanged(diff: int)
signal cookedMedium()
signal cookedWellDone()
signal cookedBurnt()

@export var cooked: int = 0 : set = setCooked
@export var medium: int = 50
@export var wellDone: int = 75
@export var burnt: int = 100

var _isMedium: bool = false
var _isWellDone: bool = false
var _isBurnt: bool = false

func setCooked(val: int):
	if val != cooked:
		if val >= medium && val < wellDone && !_isMedium:
			_isMedium = true
			cookedMedium.emit()
		if val >= wellDone && val < burnt && !_isWellDone:
			_isMedium = false
			_isWellDone = true
			cookedWellDone.emit()
		elif val >= burnt && !_isBurnt:
			val = burnt
			_isMedium = false
			_isWellDone = false
			_isBurnt = true
			cookedBurnt.emit()
		var dif = val - cooked
		cooked = val
		cookedChanged.emit(dif)
