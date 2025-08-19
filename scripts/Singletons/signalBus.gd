extends Node


signal startSlice(p: Vector2)
signal endSlice(p: Vector2)
signal modeChange(m: GlobalEnums.Mode)
signal stopDrag()

signal cameraMove()
signal cameraStop()
signal cameraShake()

signal portSelected(p: Vector2)
signal portClicked(n: String)


signal dragging(w: float)
signal drop()

signal progressBarEmpty()
signal progressBarFull()

signal canDock(canDock: bool)