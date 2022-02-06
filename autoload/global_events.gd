extends Node

#----------------------#
#-----Level Events-----#
#----------------------#

signal level_completed()
signal level_complete_started()
signal level_world_selector_loaded()
signal level_checkpoint_activated()
signal level_subsection_changed(pos)
signal level_changed(world, level)

#-----------------------#
#-----Player Events-----#
#-----------------------#

signal player_anim_sprite_reset()
signal player_anim_sprite_direction_changed(facing_right) # bool
signal player_dashed()
signal player_invincibility_started()
signal player_invincibility_stopped()

signal player_death_started()
signal player_died()

signal player_used_powerup(item_name) # string
signal player_powerup_ended(item_name) # string

signal player_collected_powerup(item_name) # string
signal player_collected_collectable(item_name) # string
signal player_collected_equippable(item_name) # string

signal player_collected_coin(amount) # int
signal player_collected_orb(amount) # int
signal player_collected_gem(index) # int

signal player_hurt_from_enemy(hurt_type, knockback, damage) # Globals.HurtTypes, int, int
signal player_hurt_enemy(hurt_type) # Globals.HurtTypes
signal player_killed_enemy(hurt_type) # Globals.HurtTypes
signal player_equipped(equippable) # string
signal player_used_springboard(amount) # int
signal player_level_increased(type)
# Used by HUD in world selector and noti
signal player_level_increase_animation_finished()

#---------------------#
#-----Save Events-----#
#---------------------#

signal save_file_saved(save_silent) # bool
signal save_file_created(index) # bool
signal save_stat_updated()

#-------------------#
#-----UI Events-----#
#-------------------#

signal ui_dialogue_hidden()
signal ui_dialogued(content, person, func_call) # string

signal ui_settings_updated()


signal ui_faded()
signal ui_notification_shown(noti) # string
signal ui_notification_finished()
signal ui_button_pressed(alt) # bool
signal ui_button_pressed_to_prompt()
signal ui_button_hovered()
signal ui_profile_focus_index_changed()

signal ui_play_pressed()
signal ui_settings_pressed()
signal ui_settings_back_pressed()
signal ui_settings_credits_pressed()
signal ui_settings_credits_back_pressed()
signal ui_settings_initial_started()
signal ui_settings_language_pressed()
signal ui_settings_language_back_pressed()
signal ui_settings_language_back_pressed_initial()
signal ui_settings_language_english_pressed()
signal ui_settings_language_spanish_pressed()
signal ui_settings_language_buttons_updated(region) # String
signal ui_settings_controls_customize_pressed()
signal ui_settings_controls_customize_back_pressed()
signal ui_settings_erase_all_pressed()
signal ui_settings_erase_all_prompt_no_pressed()
signal ui_settings_erase_all_prompt_yes_pressed()
signal ui_settings_erase_all_prompt_extra_no_pressed()
signal ui_settings_erase_all_prompt_extra_yes_pressed()
signal ui_settings_reset_settings_pressed()
signal ui_settings_reset_settings_prompt_no_pressed()
signal ui_settings_reset_settings_prompt_yes_pressed()
signal ui_controller_warning_no_pressed()
signal ui_controller_warning_yes_pressed()
signal ui_quick_play_pressed()
signal ui_quick_play_prompt_no_pressed()
signal ui_quick_play_prompt_yes_pressed()
signal ui_quit_pressed()
signal ui_quit_prompt_no_pressed()
signal ui_quit_prompt_yes_pressed()
signal ui_profile_selector_return_pressed()
signal ui_profile_selector_manage_pressed()
signal ui_profile_selector_profile_pressed()
signal ui_profile_selector_delete_pressed()
signal ui_profile_selector_delete_prompt_no_pressed()
signal ui_profile_selector_delete_prompt_yes_pressed()
signal ui_profile_selector_update_pressed()
signal ui_profile_selector_update_prompt_no_pressed()
signal ui_profile_selector_update_prompt_yes_pressed()
signal ui_pause_menu_pressed()
signal ui_pause_menu_continue_pressed()
signal ui_pause_menu_return_pressed()
signal ui_pause_menu_return_prompt_no_pressed()
signal ui_pause_menu_return_prompt_yes_pressed()
signal ui_pause_menu_restart_pressed()
signal ui_pause_menu_restart_prompt_no_pressed()
signal ui_pause_menu_restart_prompt_yes_pressed()
signal ui_level_enter_menu_pressed()
signal ui_inventory_opened()
signal ui_inventory_closed()
signal ui_shop_opened(shop_dict)
signal ui_shop_bought(item, amount, cost)
signal ui_shop_closed()
signal ui_game_beat_shown()
signal ui_all_gems_shown()
signal ui_welcome_shown()
signal ui_level_upgrade_shown()
signal ui_adrenaline_shown()

#--------------------#
#-----Mob Events-----#
#--------------------#

signal mob_used_springboard(amount, mob) #int, mob reference

#----------------------#
#-----Story Events-----#
#----------------------#

signal story_boss_activated(idx)
signal story_boss_killed(idx)
signal story_boss_camera_animated(idx)
signal story_boss_level_end_completed(idx)

signal story_w3_attempt_beat()
signal story_w3_fernand_anim_finished()
signal story_fernand_beat()
