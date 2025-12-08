extends Resource
class_name ItemResource

@export var item_name: String
@export var item_stat_info: String #placeholder
@export var item_description: String
@export var type: ItemType.Type
@export var grade: ItemType.Grade
@export var attack_type: ItemType.AttackType
@export var weapon_type: ItemType.WeaponType
@export var weapon_mesh: Mesh
@export var icon: Texture2D
@export var effects: Array[Stats] = []

#Dictionary to format and give stat enums abbreviations
const STAT_NAMES = {
	Stats.Stat.HEALTH: "HP",
	Stats.Stat.HEALTH_REGEN: "HP/5s",
	Stats.Stat.FLAT_DAMAGE_REDUCTION: "Damage reduction",
	Stats.Stat.PERCENT_DAMAGE_REDUCTION: "% Damage reduction", 
	Stats.Stat.MOVEMENT_SPEED: "Movement Speed",  
	
	Stats.Stat.LIGHT_DAMAGE: "Light damage",
	Stats.Stat.HEAVY_DAMAGE: "Heavy damage",
	Stats.Stat.LIGHT_COOLDOWN: "Light attackspeed",
	Stats.Stat.HEAVY_COOLDOWN: "Heavy attackspeed",
	
	Stats.Stat.LIGHT_SIZE_X: "Attack width",
	Stats.Stat.LIGHT_SIZE_Y: "Attack length",
	Stats.Stat.HEAVY_SIZE_X: "Attack width",
	Stats.Stat.HEAVY_SIZE_Y: "Attack length",
	
	Stats.Stat.LIFESTEAL: "% Lifesteal",
	Stats.Stat.DOT_EFFECT: "Dot info",
	Stats.Stat.PRIMARY_CHECK: "Primary check",
	Stats.Stat.DASH_COOLDOWN: "Dash cooldown",
	Stats.Stat.DASH_LENGTH: "Dash length",
	Stats.Stat.DASH_SPEED: "Dash speed"
	}
#CRITICAL: DEFINITELY SYNC THESE WITH THE STATS
var stat_name
var base_movement_speed := 5
var base_light_attack_damage := 1.0
var base_heavy_attack_damage := 2.0
var base_light_attack_cooldown := 1.5
var base_heavy_attack_cooldown := 0.5
var base_dash_cooldown := 3.0
var base_dash_length := 0.15
var base_dash_speed := 25

func set_primary_weapon_type_name() -> void:
	
	match weapon_type: 
		ItemType.WeaponType.NONE:
			ItemGlobals.primary_weapon_type = "Default"
		ItemType.WeaponType.DAGGER:
			ItemGlobals.primary_weapon_type = "Dagger"
		ItemType.WeaponType.SWORD:
			ItemGlobals.primary_weapon_type = "Sword"
		ItemType.WeaponType.MAUL:
			ItemGlobals.primary_weapon_type = "Maul"
		ItemType.WeaponType.AXE:
			ItemGlobals.secondary_weapon_type = "Axe"
			
func set_primary_attack_type_name() -> void:
	
	match attack_type: 
		ItemType.AttackType.PRIMARY:
			ItemGlobals.primary_attack_type = "Primary"
		ItemType.AttackType.SECONDARY:
			ItemGlobals.primary_attack_type = "Secondary"
			
func set_secondary_weapon_type_name() -> void:
	
	match weapon_type: 
		ItemType.WeaponType.NONE:
			ItemGlobals.secondary_weapon_type = "Dagger"
		ItemType.WeaponType.DAGGER:
			ItemGlobals.secondary_weapon_type = "Dagger"
		ItemType.WeaponType.SWORD:
			ItemGlobals.secondary_weapon_type = "Sword"
		ItemType.WeaponType.MAUL:
			ItemGlobals.secondary_weapon_type = "Maul"
		ItemType.WeaponType.AXE:
			ItemGlobals.secondary_weapon_type = "Axe"
			
func set_secondary_attack_type_name() -> void:
	
	match attack_type: 
		ItemType.AttackType.PRIMARY:
			ItemGlobals.secondary_attack_type = "Primary"
		ItemType.AttackType.SECONDARY:
			ItemGlobals.secondary_attack_type = "Secondary"

#NOTE: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_format_string.html

func format_stat_value(stat_type: int, value: float) -> String:

	match stat_type:
		Stats.Stat.MOVEMENT_SPEED:
			var percent = ((value / base_movement_speed) * 100)
			# %.1f is a placeholder integer
			# % operator processes the string, replaces placeholders
			# a literal % character must be escaped to avoid reading it as a placeholder. This is done by doubling the character
			return "%.1f%%" % percent
		Stats.Stat.LIGHT_DAMAGE:
			var percent = (value / base_light_attack_damage) * 100
			return "%.1f%%" % percent
		Stats.Stat.HEAVY_DAMAGE:
			var percent = (value / base_heavy_attack_damage) * 100
			return "%.1f%%" % percent
		Stats.Stat.LIGHT_SIZE_X:
			var percent = (value * 100)
			return "%.1f%%" % percent
		Stats.Stat.LIGHT_SIZE_Y:
			var percent = (value * 100)
			return "%.1f%%" % percent
		Stats.Stat.HEAVY_SIZE_X:
			var percent = (value * 100)
			return "%.1f%%" % percent 
		Stats.Stat.HEAVY_SIZE_Y:
			var percent = (value * 100)
			return "%.1f%%" % percent
		Stats.Stat.LIGHT_COOLDOWN:
			value = abs(value)
			var percent = ((1 -(base_light_attack_cooldown-value) / base_light_attack_cooldown) * 100)
			#print(percent)
			return "%.1f%%" % percent
		Stats.Stat.HEAVY_COOLDOWN:
			value = abs(value)
			var percent = ((1 -(base_heavy_attack_cooldown-value) / base_heavy_attack_cooldown) * 100)
			return "%.1f%%" % percent
		Stats.Stat.DASH_COOLDOWN:
			value = abs(value)
			var percent = ((1 -(base_dash_cooldown-value) / base_dash_cooldown) * 100)
			return "%.1f%%" % percent
		Stats.Stat.DASH_LENGTH:
			value = abs(value)
			var percent = ((1 -(base_dash_length-value) / base_dash_length) * 100)
			return "%.1f%%" % percent
		#Stats.Stat.DASH_SPEED:
			#value = abs(value)
			#var percent = ((1 -(base_dash_speed-value) / base_dash_speed) * 100)
			#return "%.1f%%" % percent
			
	return ""

func get_formatted_stats() -> String:

	var formatted_stats := ""
	var stats1 := ""
	var stats2 := ""
	var sign1
	var positive_color := "#a0a3a1"
	var negative_color := "#b32a20"
	var stat_color := ""
	
	for effect in effects:

		var dictionary_stat = STAT_NAMES.get(effect.stat_type, stat_name)
		var value = effect.value
		
		if value >= 0:
			sign1 = "+"
			stat_color = positive_color
		else:
			sign1 = ""
			stat_color = negative_color
		
		# NOTE: Bandaid
		if dictionary_stat == "Light attackspeed" || dictionary_stat == "Heavy attackspeed"  || dictionary_stat == "Dash cooldown" || dictionary_stat == "Dash length":
			if value >= 0:
				sign1 = "+"
				stat_color = negative_color
			else:
				sign1 = "-"
				stat_color = positive_color
		
		var formatted_value := format_stat_value(effect.stat_type, effect.value)
		
		#NOTE: Stats that shouldn't be shown in the item description go here
		if dictionary_stat == "Primary check" || dictionary_stat == "Dash speed":
			formatted_stats += ""
			return formatted_stats
			
		if dictionary_stat == "Dot info":
			formatted_stats += "[color=" + effect.dot_resource.dot_item_desc_color + "]" + "+" + effect.dot_resource.dot_name + "[/color]\n"
			return formatted_stats
			
		if dictionary_stat == "Light damage" || dictionary_stat == "Heavy damage" ||dictionary_stat == "Movement Speed" || dictionary_stat == "Attack width" || dictionary_stat == "Attack length" || dictionary_stat == "Light attackspeed" || dictionary_stat == "Heavy attackspeed" ||  dictionary_stat == "Dash cooldown" ||  dictionary_stat == "Dash length":
			# %s%s %s => 3 placeholders: 
			# replaced with sign, formatted_value, dictionary_stat
			stats1 = "%s%s %s\n" % [sign1, formatted_value, dictionary_stat]
			formatted_stats += "[color=" + stat_color + "]" + stats1 + "[/color]"
			#return formatted_stats
		else:
			stats2 = "%s%s %s\n" % [sign1, effect.value, dictionary_stat]
			formatted_stats += "[color=" + stat_color + "]" + stats2 + "[/color]"
	

	return formatted_stats
