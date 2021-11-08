extends Node

# Levels
signal level_changed(world, level)
signal sublevel_changed(pos)
signal level_change_attempted(world, level)

# Player
signal player_hurt_from_enemy(hurt_type, knockback, damage)
signal player_hurt_enemy(hurt_type)
signal player_killed_enemy(hurt_type)

signal player_invincibility_stopped()
signal start_player_death()
signal player_death()
signal player_dashed()
signal equipped(equipable)
signal inventory_changed(is_open)
signal coin_collected(amount)
signal adrenaline_updated()
signal orb_collected(amount)
signal quick_item_collected(item_name)
signal quick_item_used(item_name)
signal quick_item_ended(item_name)
signal collectable_collected(item_name)
signal equipable_collected(item_name)

# Game Functions
signal profile_deleted()
signal profile_updated()
signal world_selector_ready()
signal level_completed()
signal checkpoint_activated()
signal save()
signal new_save_file(index)
signal dialog(content, person, func_call)

# Errors
signal error_level_changed()
