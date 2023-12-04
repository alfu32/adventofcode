module main

import os
import arrays

const cutset = "\r\n\t "
struct Round {
	pub mut:
	red u32
	green u32
	blue u32
}

pub fn round_from_text(text string) Round {
	tokens:=text.trim(cutset).split(",").map(it.trim(cutset))
	mut round:=Round{}
	for tk in tokens {
		m := tk.split(" ").map(it.trim(cutset))
		if m.len < 2 {
			panic("not enough tokens to initialize a round in [$text]}")
		}
		match m[1] {
			'red' { round.red=m[0].u32()}
			'green' { round.green=m[0].u32()}
			'blue' { round.blue=m[0].u32()}
			else {
				panic("invalid token name [${m[1]}] in [$text]}")
			}
		}
	}
	return round
}

pub fn (r Round) is_possible(max_round Round) bool {
	return (r.red <= max_round.red) && (r.green <= max_round.green) && (r.blue <= max_round.blue)
}
pub fn (r Round) power() u32 {
	return r.red*r.green*r.blue
}
struct Game {
	pub mut:
		name string
	    code string
		number u32
		rounds []Round
}
pub fn game_from_text(text string) Game {
	mut game := Game{}
	tokens:= text.split(":").map(it.trim(cutset))

	if tokens.len < 2 {
		panic("not enough tokens to initialize a game from [$text]}")
	}
	game.name=tokens[0]
	game.code = tokens[0].bytes().filter((it>=48) && (it<=57)).bytestr()
	game.number = game.code.u32()

	rounds_text := tokens[1].split(";").map(it.trim(cutset))
	game.rounds = rounds_text.map(fn(round_text string) Round {
		return round_from_text(round_text)
	})
	return game
}
pub fn (g Game) is_possible(max_round Round) bool {
	return g.rounds.filter(fn[max_round](r Round) bool {return r.is_possible(max_round)}).len == g.rounds.len
}
pub fn (g Game) smallest_common_denominator_round() Round {
	mut scd:=Round{}
	for r in g.rounds {
		if r.red > scd.red { scd.red=r.red }
		if r.green > scd.green { scd.green=r.green }
		if r.blue > scd.blue { scd.blue=r.blue }
	}
	return scd
}
fn main(){
	mut filename := os.args[1] or {"/home/devlin/Development/adventofcode/2023/02/alfu32/input.txt"}
	max_round := Round {
		red:12
		green:13
		blue:14
	}
	lines := os.read_lines(filename) or { panic("file [$filename] not found")}
	games := lines.map(fn(text string) Game {
		return game_from_text(text)
	})
	possible_games := games.filter(fn[max_round](g Game) bool { return g.is_possible(max_round)})

	println(games)
	println(possible_games)
	println("sum of ids : ${arrays.fold(possible_games,u32(0), fn (acc u32,elem Game) u32 {return elem.number+acc })}")

	println("sum of all powers : ${arrays.fold(games.map(it.smallest_common_denominator_round().power()),u64(0),fn(acc u64,pw u32) u64 { return acc + pw })}")
	println("sum of valid powers : ${arrays.fold(possible_games.map(it.smallest_common_denominator_round().power()),u64(0),fn(acc u64,pw u32) u64 { return acc + pw })}")
}
