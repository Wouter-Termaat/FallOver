extends Node

## Autoload. PRD §4.6/§5.1: coins are the per-level budget, never a
## persistent currency, never purchasable. Spend/refund are tied to command
## do()/undo() (placement_command.gd, sell_command.gd, clear_all_command.gd)
## so undo/redo keeps the coin total exact for free — there is no separate
## coin-tracking code path to keep in sync.
##
## No code path here adds coins beyond load_level()'s starting amount, and
## none converts diamonds into coins. That is a design invariant (PRD §5.1),
## not an oversight — do not add one.

signal changed

var total: int = 0
var remaining: int = 0


func load_level(coin_amount: int) -> void:
	total = coin_amount
	remaining = coin_amount
	changed.emit()


func can_afford(price: int) -> bool:
	return remaining >= price


func spend(price: int) -> bool:
	if not can_afford(price):
		return false
	remaining -= price
	changed.emit()
	return true


func refund(price: int) -> void:
	remaining += price
	changed.emit()
