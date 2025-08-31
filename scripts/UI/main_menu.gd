extends Control
class_name MainMenu

@onready var continueButton: Button = %ContinueBtn
@onready var startButton: Button = %StartBtn
@onready var settingsButton: Button = %SettingsBtn
@onready var creditsButton: Button = %CreditsBtn
@onready var pauseMenu: PauseMenu = %PauseMenu


func _ready() -> void:
	var hasSave = ResourceLoader.exists(Utils.SAVE_PATH)
	continueButton.disabled = !hasSave

func _on_continue_btn_pressed() -> void:
	SaveLoader.loadGame()
	pauseMenu.show()
	hide()

func _on_start_btn_pressed() -> void:
	Utils.RNG.randomize()
	SceneLoader.goto_scene(Utils.TRAVEL_PATH)
	hide()
	pauseMenu.show()

func _on_settings_btn_pressed() -> void:
	%Settings.show()

func _on_credits_btn_pressed() -> void:
	%Credits.show()

func _on_volume_slider_value_changed(value: float) -> void:
	%volumeLabel.text = str(int(value))
	Settings.masterVolume = value

func _on_music_slider_value_changed(value: float) -> void:
	%musicLabel.text = str(int(value))
	Settings.musicVolume = value

func _on_sfx_slider_value_changed(value: float) -> void:
	%sfxLabel.text = str(int(value))
	Settings.sfxVolume = value

func _on_check_button_toggled(toggled_on: bool) -> void:
	Settings.screenShake = toggled_on

func _on_fullscreen_button_toggled(toggled_on: bool) -> void:
	Settings.fullscreen = toggled_on

func _on_credits_close_btn_pressed() -> void:
	%Credits.hide()
