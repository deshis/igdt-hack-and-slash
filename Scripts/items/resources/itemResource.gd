extends Resource
class_name ItemResource

@export var item_name: String
@export var item_stat_info: String #placeholder
@export var item_description: String
@export var type: ItemType.Type
@export var grade: ItemType.Grade
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
	
	Stats.Stat.LIFESTEAL: "% Lifesteal"
	}
	
var stat_name
var base_movement_speed := 500
var base_light_attack_cooldown := 0.3
var base_heavy_attack_cooldown := 0.5

#NOTE: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_format_string.html

func format_stat_value(stat_type: int, value: float) -> String:

	match stat_type:
		Stats.Stat.MOVEMENT_SPEED:
			var percent = ((value / base_movement_speed) * 100)
			# %.1f is a placeholder integer
			# % operator processes the string, replaces placeholders
			# a literal % character must be escaped to avoid reading it as a placeholder. This is done by doubling the character
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
			print(percent)
			return "%.1f%%" % percent
			
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
		if dictionary_stat == "Light attackspeed" || dictionary_stat == "Heavy attackspeed":
			if value >= 0:
				sign1 = "-"
				stat_color = negative_color
			else:
				sign1 = "+"
				stat_color = positive_color
		
		var formatted_value := format_stat_value(effect.stat_type, effect.value)
		
		if dictionary_stat == "Movement Speed" || dictionary_stat == "Attack width" || dictionary_stat == "Attack length" || dictionary_stat == "Light attackspeed" || dictionary_stat == "Heavy attackspeed":
			# %s%s %s => 3 placeholders: 
			# replaced with sign, formatted_value, dictionary_stat
			stats1 = "%s%s %s\n" % [sign1, formatted_value, dictionary_stat]
			formatted_stats += "[color=" + stat_color + "]" + stats1 + "[/color]"
		else:
			stats2 = "%s%s %s\n" % [sign1, effect.value, dictionary_stat]
			formatted_stats += "[color=" + stat_color + "]" + stats2 + "[/color]"
	

	return formatted_stats
