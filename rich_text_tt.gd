extends RichTextLabel

func _ready() -> void:
	self.meta_hover_started.connect(func(meta):
		var s = str(meta)
		if s.begins_with("w_"):
			STooltip.show(self, 0, [Pair.new(tr(s), tr(s + "_desc"))])
		elif s.begins_with("gem_"):
			STooltip.show(self, 0, [Pair.new(tr(s), "")])
		elif s.begins_with("rune_"):
			STooltip.show(self, 0, [Pair.new(tr(s), "")])
		elif s.begins_with("relic_"):
			var r = Relic.new()
			r.setup(s.substr(6))
			STooltip.show(self, 0, r.get_tooltip())
		'''
		elif s.begins_with("item_"):
			var item_name = s.substr(5)
			STooltip.show(self, 0, [Pair.new(tr("item_name_" + item_name), tr("item_desc_" + item_name))])
		else:
			var item = Item.new()
			item.setup(thing)
			STooltip.show(self, 0, item.get_tooltip())
		'''
	)
	self.meta_hover_ended.connect(func(meta):
		STooltip.close()
	)
