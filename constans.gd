extends Node

const SPRITE_SZ : int = 72
const BOARD_TILE_SZ : int = SPRITE_SZ
const BOARD_CENTER : Vector2i = Vector2i(18, 7)
const RESOLUTION : Vector2i = Vector2i(1920, 1080)

const REFILL_TIMES_TO_SHOW = 10
const REFILL_TIMES_TO_STOP = 40

enum Event
{
	RoundBegan,
	RoundEnded,
	BeforeMatching,
	MatchingFinished,
	BeforeScoreCalculating,
	GainGem,
	LostGem,
	GainRelic,
	LostRelic,
	GainPattern,
	LostPattern,
	ModifierChanged,
	GemBaseScoreChanged,
	GemBonusScoreChanged,
	GemEntered,
	GemLeft,
	Matched,
	Eliminated,
	Activated,
	ItemMoved,
	Combo,
	Exploded,
	Count,
	Any
}

enum HostType
{
	Gem,
	Relic,
	Other
}
