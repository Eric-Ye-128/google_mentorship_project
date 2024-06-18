extends Control

signal textbox_closed

@export var enemy : Resource = null

var current_player_1_health : int = 0
var current_player_2_health : int = 0
var current_player_3_health : int = 0
var current_enemy_health : int = 0

var player_1_is_defending : bool = false
var player_2_is_defending : bool = false
var player_3_is_defending : bool = false

func _ready():
	set_health($EnemyContainer/ProgressBar, enemy.health, enemy.health)
	
	set_health($PlayerContainer1/ProgressBar, State.player_1_current_health, State.player_1_max_health)
	set_health($PlayerContainer2/ProgressBar, State.player_2_current_health, State.player_2_max_health)
	set_health($PlayerContainer3/ProgressBar, State.player_3_current_health, State.player_3_max_health)
	
	$EnemyContainer/Enemy.texture = enemy.texture
	
	current_player_1_health = State.player_1_current_health
	current_player_2_health = State.player_2_current_health
	current_player_3_health = State.player_3_current_health
	current_enemy_health = enemy.health
	
	$TextBox.hide()
	$ActionsPanel.hide()
	
	display_text("A wild %s appears!" % enemy.name.to_upper())
	await textbox_closed
	$ActionsPanel.show()

func set_health(progess_bar, health, max_health):
	progess_bar.value = health
	progess_bar.max_value = max_health

func _input(event):
	if (Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)) and $TextBox.visible:
		$TextBox.hide()
		emit_signal("textbox_closed")

func display_text(text):
	$ActionsPanel.hide()
	$TextBox.show()
	$TextBox/Label.text = text

func enemy_turn():
	display_text("%s attacks you" % enemy.name)
	await textbox_closed
	
	var rand : int = (randi() % 3)
	var attacking : bool = true
	var attacked : bool = false
	while attacking:
		rand = (randi() % 3)
		if rand == 0 and current_player_1_health != 0:
			if not player_1_is_defending:
				current_player_1_health = max(current_player_1_health - enemy.attack, 0)
				set_health($PlayerContainer1/ProgressBar, current_player_1_health, State.player_1_max_health)
				attacked = true
			else:
				display_text("You defended")
				await textbox_closed
			attacking = false
		elif rand == 1 and current_player_2_health != 0:
			if not player_2_is_defending:
				current_player_2_health = max(current_player_2_health - enemy.attack, 0)
				set_health($PlayerContainer2/ProgressBar, current_player_2_health, State.player_2_max_health)
				attacked = true
			else:
				display_text("You defended")
				await textbox_closed
			attacking = false
		elif current_player_3_health != 0:
			if not player_3_is_defending:
				current_player_3_health = max(current_player_3_health - enemy.attack, 0)
				set_health($PlayerContainer3/ProgressBar, current_player_3_health, State.player_3_max_health)
				attacked = true
			else:
				display_text("You defended")
				await textbox_closed
			attacking = false
	
	player_1_is_defending = false
	player_2_is_defending = false
	player_3_is_defending = false
	
	if attacked:
		display_text("%s dealt %d damage!" % [enemy.name, enemy.attack])
		await textbox_closed
	
	if current_player_1_health == 0 and current_player_2_health == 0 and current_player_3_health == 0:
		display_text("Your party has died")
		await textbox_closed
		await get_tree().create_timer(0.25).timeout
		Global.change = Global.current
		get_tree().change_scene_to_file("res://loading.tscn")
	
	$ActionsPanel.show()

func _on_attack_pressed():
	display_text("You swing your sword")
	await textbox_closed
	
	current_enemy_health = max(current_enemy_health - State.player_1_attack, 0)
	set_health($EnemyContainer/ProgressBar, current_enemy_health, enemy.health)
	
	$AnimationPlayer.play("enemy_damaged")
	await $AnimationPlayer.animation_finished
	
	display_text("You dealt %d damage!" % State.player_1_attack)
	await textbox_closed
	
	if current_enemy_health == 0:
		display_text("%s was defeated" % enemy.name)
		await textbox_closed
		
		$AnimationPlayer.play("enemy_died")
		await $AnimationPlayer.animation_finished
		await get_tree().create_timer(0.25).timeout
		Global.change = Global.current
		get_tree().change_scene_to_file("res://loading.tscn")
	
	enemy_turn()

func _on_defend_pressed():
	player_1_is_defending = true
	player_2_is_defending = true
	player_3_is_defending = true
	
	display_text("You prepare defensively")
	await textbox_closed	
	await get_tree().create_timer(0.25).timeout
	
	enemy_turn()
