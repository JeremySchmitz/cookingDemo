extends Control

class_name PauseMenu

var paused = false

func _on_button_pressed() -> void:
	if paused: resumeGame()
	else: pauseGame()

func pauseGame():
	get_tree().paused = true
	%Menu.show()

func resumeGame():
	%Menu.hide()
	get_tree().paused = false

func _on_resume_btn_pressed() -> void:
	resumeGame()

func _on_settings_btn_pressed() -> void:
	%Settings.show()

func _on_quit_btn_pressed() -> void:
	%ConfirmationModal.showModal(
		'Quit To Main Menu',
		cancel,
		quitToMenu,
		'Are you sure you want to quit? Your progress will be saved.'
		)

func _on_close_btn_pressed() -> void:
	%ConfirmationModal.showModal(
		'Quit',
		cancel,
		quiteGame,
		'Are you sure you want to quit?'
		)


func quitToMenu():
	get_tree().paused = false
	%ConfirmationModal.hide()
	SceneLoader.gotoMainMenu()

func quiteGame():
	get_tree().quit()

func cancel():
	%ConfirmationModal.hide()
