extends RefCounted

class_name Curse

var type : String
var coord : Vector2i = Vector2i(-1, -1)

static func apply_curses():
	var cates = {}
	for c in G.current_curses:
		if cates.has(c.type):
			cates[c.type].append(c)
		else:
			cates[c.type] = [c]
	for k in cates.keys():
		var cs = cates[k]
		match k:
			"curse_red_no_score":
				G.no_score_marks[Gem.ColorRed].push_front(true)
			"curse_orange_no_score":
				G.no_score_marks[Gem.ColorOrange].push_front(true)
			"curse_green_no_score":
				G.no_score_marks[Gem.ColorGreen].push_front(true)
			"curse_blue_no_score":
				G.no_score_marks[Gem.ColorBlue].push_front(true)
			"curse_magenta_no_score":
				G.no_score_marks[Gem.ColorMagenta].push_front(true)
			"curse_wave_no_score":
				G.no_score_marks[Gem.RuneWave].push_front(true)
			"curse_palm_no_score":
				G.no_score_marks[Gem.RunePalm].push_front(true)
			"curse_starfish_no_score":
				G.no_score_marks[Gem.RuneStarfish].push_front(true)

func remove():
	match type:
		"curse_red_no_score":
			G.no_score_marks[Gem.ColorRed].pop_front()
		"curse_orange_no_score":
			G.no_score_marks[Gem.ColorOrange].pop_front()
		"curse_green_no_score":
			G.no_score_marks[Gem.ColorGreen].pop_front()
		"curse_blue_no_score":
			G.no_score_marks[Gem.ColorBlue].pop_front()
		"curse_magenta_no_score":
			G.no_score_marks[Gem.ColorMagenta].pop_front()
		"curse_wave_no_score":
			G.no_score_marks[Gem.RuneWave].pop_front()
		"curse_palm_no_score":
			G.no_score_marks[Gem.RunePalm].pop_front()
		"curse_starfish_no_score":
			G.no_score_marks[Gem.RuneStarfish].pop_front()
