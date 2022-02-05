extends Node

# Attack the player if it is touched by the enemy
export var enemy_path: NodePath
export var hit_area_path: NodePath
export var flying_enemy: bool = false
export var attack_by_jump: bool = true

var cooling_down: bool = false

onready var hit_area := get_node(hit_area_path) as Area2D
onready var enemy := get_node(enemy_path) as KinematicBody2D
onready var mob_component := get_parent() as MobComponentManager
onready var cooldown_timer := $Cooldown as Timer


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("player_invincibility_stopped", self, "_player_invincibility_stopped")
	__ = hit_area.connect("body_entered", self, "_hit_area_body_entered")


func damage_by_jump() -> void:
	cooling_down = true
	cooldown_timer.start(0.3)
	mob_component.damage(Globals.HurtTypes.JUMP)
	GlobalEvents.emit_signal("player_hurt_enemy", Globals.HurtTypes.JUMP)


func damage_by_touch() -> void:
	if attack_by_jump:
		#yield(get_tree(), "physics_frame")
		#yield(get_tree(), "physics_frame")
		if mob_component.dead: return
		if mob_component.damaging_self: return
		if cooling_down: return

	cooling_down = true
	cooldown_timer.start(0.3)

	if flying_enemy:
		GlobalEvents.emit_signal("player_hurt_from_enemy", Globals.HurtTypes.TOUCH_AIR,
				mob_component.knockback, mob_component.attack_damage)
	else:
		GlobalEvents.emit_signal("player_hurt_from_enemy", Globals.HurtTypes.TOUCH,
				mob_component.knockback, mob_component.attack_damage)
	mob_component.emit_signal("hit_player")


func _hit_area_body_entered(body: Node) -> void:
	if mob_component.dead: return
	if mob_component.damaging_self: return
	if cooling_down: return

	if body.is_in_group("Player"):
		if attack_by_jump:
			var in_jump_boots := false
			var areas := hit_area.get_overlapping_areas()

			for area in areas:
				if area.is_in_group("PlayerBoots"):
					in_jump_boots = true

			if cooling_down:
				return

			if get_node(GlobalPaths.PLAYER).dashing:
				damage_by_jump()
				print(get_parent().get_parent().name + " Damage Enemy bc dash")
				return
			elif in_jump_boots and (body.was_falling or not body.is_on_floor()):
				damage_by_jump()
				print(get_parent().get_parent().name + " Damage Enemy bc fall")
				return
			else:
				#yield(get_tree(), "physics_frame")
				if not cooling_down:
					damage_by_touch()
					print(get_parent().get_parent().name + " Damage Player")
					return
		else:
			damage_by_touch()
			return


func _player_invincibility_stopped() -> void:
	if mob_component.dead: return
	if mob_component.damaging_self: return
	if cooling_down: return

	yield(get_tree(), "physics_frame")

	if hit_area.monitoring:
		var bodies = hit_area.get_overlapping_bodies()

		for body in bodies:
			if body.is_in_group("Player"):
				_hit_area_body_entered(body)
				if flying_enemy:
					GlobalEvents.emit_signal("player_hurt_from_enemy", Globals.HurtTypes.TOUCH_AIR, mob_component.knockback, mob_component.attack_damage)
				else:
					GlobalEvents.emit_signal("player_hurt_from_enemy", Globals.HurtTypes.TOUCH, mob_component.knockback, mob_component.attack_damage)


func _on_Cooldown_timeout() -> void:
	cooling_down = false
