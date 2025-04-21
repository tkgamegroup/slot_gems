extends Object

class_name Relic

const relic_frames : SpriteFrames = preload("res://images/relics.tres")

var name : String
var image_id : int
var description : String
var price : int
var extra : Dictionary

var on_event : Callable

func setup(n : String):
	name = n
	if name == "Explosives":
		image_id = 1
		description = "Explosion [color=gray][b]Range[/b][/color] +1 but power -3."
		on_event = func(event : int, source1, source2):
			if event == Game.Event.GainRelic:
				if source1 == self:
					Game.explode_range_modifier += 1
					Game.explode_power_modifier -= 3
	elif name == "Red Stone":
		image_id = 1
		description = "Red gems' base score +{value}."
		extra["value"] = 4
		on_event = func(event : int, source1, source2):
			if event == Game.Event.GainRelic:
				if source1 == self:
					for g in Game.gems:
						on_event.call(Game.Event.GainGem, g, null)
			elif event == Game.Event.GainGem:
				if source1.type == Gem.Type.Red:
					source1.base_score += extra["value"]
	elif name == "Orange Stone":
		image_id = 1
		description = "Orange gems' base score +{value}."
		extra["value"] = 4
		on_event = func(event : int, source1, source2):
			if event == Game.Event.GainRelic:
				if source1 == self:
					for g in Game.gems:
						on_event.call(Game.Event.GainGem, g, null)
			elif event == Game.Event.GainGem:
				if source1.type == Gem.Type.Orange:
					source1.base_score += extra["value"]
	elif name == "Green Stone":
		image_id = 1
		description = "Green gems' base score +{value}."
		extra["value"] = 4
		on_event = func(event : int, source1, source2):
			if event == Game.Event.GainRelic:
				if source1 == self:
					for g in Game.gems:
						on_event.call(Game.Event.GainGem, g, null)
			elif event == Game.Event.GainGem:
				if source1.type == Gem.Type.Green:
					source1.base_score += extra["value"]
	elif name == "Blue Stone":
		image_id = 1
		description = "Blue gems' base score +{value}."
		extra["value"] = 4
		on_event = func(event : int, source1, source2):
			if event == Game.Event.GainRelic:
				if source1 == self:
					for g in Game.gems:
						on_event.call(Game.Event.GainGem, g, null)
			elif event == Game.Event.GainGem:
				if source1.type == Gem.Type.Blue:
					source1.base_score += extra["value"]
	elif name == "Pink Stone":
		image_id = 1
		description = "Pink gems' base score +{value}."
		extra["value"] = 4
		on_event = func(event : int, source1, source2):
			if event == Game.Event.GainRelic:
				if source1 == self:
					for g in Game.gems:
						on_event.call(Game.Event.GainGem, g, null)
			elif event == Game.Event.GainGem:
				if source1.type == Gem.Type.Pink:
					source1.base_score += extra["value"]
	elif name == "Rock Bottom":
		image_id = 1
		description = "Gems' score will not descent."
		on_event = func(event : int, source1, source2):
			if event == Game.Event.GemBaseScoreChanged || event == Game.Event.GemBonusScoreChanged:
				if source2 < 0:
					return 0
				return source2

func get_tooltip():
	var ret : Array[Pair] = []
	var content = description.format(extra)
	ret.append(Pair.new(name, content))
	return ret
