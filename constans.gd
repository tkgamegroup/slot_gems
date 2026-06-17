extends Node

const SPRITE_SZ : float = 72.0
const TILE_SZ : float = 72.0
const SPRITE_TO_TILE : float = TILE_SZ / SPRITE_SZ
const UI_BOARD_CENTER : Vector2i = Vector2i(18, 7)
const RESOLUTION : Vector2i = Vector2i(1920, 1080)

const REFILL_TIMES_TO_SHOW = 10

enum Event
{
	RoundBegin,
	RoundEnd,
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
	EliminatedEffect,
	Activated,
	ItemMoved,
	Chain,
	Exploded,
	Count,
	Any
}

enum ObjectType
{
	Game,
	Gem,
	Relic,
	Pattern,
	Other
}

enum Duration
{
	ThisChain,
	ThisMatching,
	ThisRound,
	OnBoard,
	Eternal
}

enum TutorialScript
{
	None,
	Dialog,
	Actions,
	Logic
}

enum TutorialAction
{
	Hover,
	Click,
	Swap
}
