extends Control

class_name ConfirmationModal

var declineFunc: Callable
var acceptFunc: Callable

func showModal(title: String, decline: Callable, accept: Callable, info = ''):
	%Title.text = title
	if info: %Info.text = info
	declineFunc = decline
	acceptFunc = accept

	show()

func _on_cancel_btn_pressed() -> void:
	if declineFunc:
		declineFunc.call()
	else: push_error('No decline function provided')

func _on_confirm_btn_pressed() -> void:
	if acceptFunc:
		acceptFunc.call()
	else:
		push_error('No accept function provided')
