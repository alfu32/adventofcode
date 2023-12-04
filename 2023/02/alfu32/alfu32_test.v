module main

fn test_scd(){

	lines := {
		"Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green" : Round{4,2,6}
		"Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue" : Round{1,3,4}
		"Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red" : Round{20,13,6}
		"Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red" : Round{14,3,15}
		"Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green" : Round{6,3,2}
	}

	for line,round in lines{
		game := game_from_text(line)
		scd_round := game.smallest_common_denominator_round()
		println("scd:$scd_round /// $round")
		assert scd_round == round
	}
}
