extends Control

signal textbox_closed

@export var enemy : Resource = null

var player_cycle : int = 0

var current_player_1_health : int = 0
var current_player_2_health : int = 0
var current_player_3_health : int = 0
var current_enemy_health : int = 0

var player_1_is_defending : bool = false
var player_2_is_defending : bool = false
var player_3_is_defending : bool = false

var player_1_special : bool = true
var player_2_special : bool = true
var player_3_special : bool = true

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
	clear_highlight_name()
	$PlayerContainer1/Label.set("theme_override_colors/font_color", Color(1.0, 0.0, 0.0, 1.0))

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
	check_win()
	
	clear_highlight_name()
	$EnemyContainer/Label.set("theme_override_colors/font_color", Color(1.0, 0.0, 0.0, 1.0))
	
	display_text("%s attacks you!" % enemy.name)
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
				display_text("You defended!")
				await textbox_closed
			attacking = false
		elif rand == 1 and current_player_2_health != 0:
			if not player_2_is_defending:
				current_player_2_health = max(current_player_2_health - enemy.attack, 0)
				set_health($PlayerContainer2/ProgressBar, current_player_2_health, State.player_2_max_health)
				attacked = true
			else:
				display_text("You defended!")
				await textbox_closed
			attacking = false
		elif current_player_3_health != 0:
			if not player_3_is_defending:
				current_player_3_health = max(current_player_3_health - enemy.attack, 0)
				set_health($PlayerContainer3/ProgressBar, current_player_3_health, State.player_3_max_health)
				attacked = true
			else:
				display_text("You defended!")
				await textbox_closed
			attacking = false
	
	player_1_is_defending = false
	player_2_is_defending = false
	player_3_is_defending = false
	
	if attacked:
		display_text("%s dealt %d damage!" % [enemy.name, enemy.attack])
		await textbox_closed
	
	if current_player_1_health == 0 and current_player_2_health == 0 and current_player_3_health == 0:
		display_text("Your party has died.")
		await textbox_closed
		await get_tree().create_timer(0.25).timeout
		
		Global.change = Global.current
		get_tree().change_scene_to_file("res://loading.tscn")
	
	$ActionsPanel.show()
	clear_highlight_name()
	$PlayerContainer1/Label.set("theme_override_colors/font_color", Color(1.0, 0.0, 0.0, 1.0))

func _on_attack_pressed():
	display_text("You swing your sword.")
	await textbox_closed
	
	if player_cycle == 0:
		current_enemy_health = max(current_enemy_health - State.player_1_attack, 0)
		player_1_special = true
	elif player_cycle == 1:
		current_enemy_health = max(current_enemy_health - State.player_2_attack, 0)
		player_2_special = true
	elif player_cycle == 2:
		current_enemy_health = max(current_enemy_health - State.player_3_attack, 0)
		player_3_special = true
	set_health($EnemyContainer/ProgressBar, current_enemy_health, enemy.health)
	
	$AnimationPlayer.play("enemy_damaged")
	await $AnimationPlayer.animation_finished
	
	if player_cycle == 0:
		display_text("You dealt %d damage!" % State.player_1_attack)
	elif player_cycle == 1:
		display_text("You dealt %d damage!" % State.player_2_attack)
	elif player_cycle == 2:
		display_text("You dealt %d damage!" % State.player_3_attack)
	await textbox_closed
	
	check_win()
	
	player_cycle += 1
	if player_cycle == 3:
		player_cycle = 0
		enemy_turn()
	else:
		$ActionsPanel.show()
		clear_highlight_name()
		if player_cycle == 0:
			$PlayerContainer1/Label.set("theme_override_colors/font_color", Color(1.0, 0.0, 0.0, 1.0))
		elif player_cycle == 1:
			$PlayerContainer2/Label.set("theme_override_colors/font_color", Color(1.0, 0.0, 0.0, 1.0))
		elif player_cycle == 2:
			$PlayerContainer3/Label.set("theme_override_colors/font_color", Color(1.0, 0.0, 0.0, 1.0))

func _on_defend_pressed():
	if player_cycle == 0:
		player_1_is_defending = true
		player_1_special = true
	elif player_cycle == 1:
		player_2_is_defending = true
		player_2_special = true
	elif player_cycle == 2:
		player_3_is_defending = true
		player_3_special = true
	
	display_text("You prepare defensively.")
	await textbox_closed	
	await get_tree().create_timer(0.25).timeout
	
	player_cycle += 1
	if player_cycle == 3:
		player_cycle = 0
		enemy_turn()
	else:
		$ActionsPanel.show()
		clear_highlight_name()
		if player_cycle == 0:
			$PlayerContainer1/Label.set("theme_override_colors/font_color", Color(1.0, 0.0, 0.0, 1.0))
		elif player_cycle == 1:
			$PlayerContainer2/Label.set("theme_override_colors/font_color", Color(1.0, 0.0, 0.0, 1.0))
		elif player_cycle == 2:
			$PlayerContainer3/Label.set("theme_override_colors/font_color", Color(1.0, 0.0, 0.0, 1.0))

func _on_special_pressed():
	var used_special : bool = true
	
	if player_cycle == 0:
		if player_1_special:
			current_enemy_health = max(current_enemy_health - (State.player_1_attack * 2), 0)
			set_health($EnemyContainer/ProgressBar, current_enemy_health, enemy.health)
			
			$AnimationPlayer.play("enemy_damaged")
			await $AnimationPlayer.animation_finished
			
			display_text("You dealt %d damage!" % (State.player_1_attack * 2))
			await textbox_closed
			
			player_1_special = false
			
			check_win()
		else:
			used_special = false
			display_text("You cannot use your special this turn.")
			await textbox_closed
	elif player_cycle == 1:
		if player_2_special:
			player_1_is_defending = true
			player_2_is_defending = true
			player_3_is_defending = true
			
			player_2_special = false
			
			display_text("Everyone prepares defensively.")
			await textbox_closed
			await get_tree().create_timer(0.25).timeout
		else:
			used_special = false
			display_text("You cannot use your special this turn.")
			await textbox_closed
	elif player_cycle == 2:
		if player_3_special:
			current_player_1_health = min(current_player_1_health + 10, State.player_1_max_health)
			current_player_2_health = min(current_player_2_health + 10, State.player_2_max_health)
			current_player_3_health = min(current_player_3_health + 10, State.player_3_max_health)
			
			player_3_special = false
			
			display_text("Everyone heals some health.")
			await textbox_closed
			await get_tree().create_timer(0.25).timeout
		else:
			used_special = false
			display_text("You cannot use your special this turn.")
			await textbox_closed
	
	if used_special:
		player_cycle += 1
		if player_cycle == 3:
			player_cycle = 0
			enemy_turn()
		else:
			$ActionsPanel.show()
			clear_highlight_name()
			if player_cycle == 0:
				$PlayerContainer1/Label.set("theme_override_colors/font_color", Color(1.0, 0.0, 0.0, 1.0))
			elif player_cycle == 1:
				$PlayerContainer2/Label.set("theme_override_colors/font_color", Color(1.0, 0.0, 0.0, 1.0))
			elif player_cycle == 2:
				$PlayerContainer3/Label.set("theme_override_colors/font_color", Color(1.0, 0.0, 0.0, 1.0))
	else:
		$ActionsPanel.show()
		clear_highlight_name()
		if player_cycle == 0:
			$PlayerContainer1/Label.set("theme_override_colors/font_color", Color(1.0, 0.0, 0.0, 1.0))
		elif player_cycle == 1:
			$PlayerContainer2/Label.set("theme_override_colors/font_color", Color(1.0, 0.0, 0.0, 1.0))
		elif player_cycle == 2:
			$PlayerContainer3/Label.set("theme_override_colors/font_color", Color(1.0, 0.0, 0.0, 1.0))

func check_win():
	if current_enemy_health == 0:
		display_text("%s was defeated!" % enemy.name)
		await textbox_closed
		
		$AnimationPlayer.play("enemy_died")
		await $AnimationPlayer.animation_finished
		await get_tree().create_timer(0.25).timeout
		
		Global.change = Global.current
		get_tree().change_scene_to_file("res://loading.tscn")

func clear_highlight_name():
	var white = Color(1.0, 1.0, 1.0, 1.0)
	$EnemyContainer/Label.set("theme_override_colors/font_color", white)
	$PlayerContainer1/Label.set("theme_override_colors/font_color", white)
	$PlayerContainer2/Label.set("theme_override_colors/font_color", white)
	$PlayerContainer3/Label.set("theme_override_colors/font_color", white)
