extends Node

const DEBUG := true

signal lymph_picked
signal puzzle_entered(puzzle_transform, puzzle_bug)
signal puzzle_exited
signal debug_write(text)

var player_in_area_final : bool = false
var lymph_completed : bool = false
