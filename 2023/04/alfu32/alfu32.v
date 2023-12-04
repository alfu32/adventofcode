module main

import os
import regex
import arrays

const cutset = "\r\n\t "
struct Card {
	pub mut:
	number u64
	code string
	winning_numbers []u64
	chosen_numbers []u64
}

pub fn card_from_string(text string) Card {

	mut digits := regex.regex_opt(r'\d') or {
		println(err)
		panic ("regex [$err] was no good")
	}
	tokens := text.split(":").map(it.trim(cutset))
	if tokens.len < 2 {
		panic("invalid card definition : [$text]")
	}
	mut card := Card{
		code: tokens[0],
		number: digits.find_all_str(tokens[0]).join("").u64()
	}

	lists := tokens[1].split("|").map(it.trim(cutset))
	if lists.len < 2 {
		panic("invalid card number lists definition : [$text]")
	}
	card.winning_numbers = lists[0].split(" ").map(it.u64()).filter(it>0)
	card.chosen_numbers = lists[1].split(" ").map(it.u64()).filter(it>0)
	return card
}
pub fn (c Card) points() u64 {
	println(c)
	mut hits := 0
	for n in c.chosen_numbers {
		if n in c.winning_numbers {
			println("$n in ${c.winning_numbers}")
			hits++
		}
	}
	mut result := if hits == 0 { u64(0) } else {u64(1<<(hits-1))}
	println("$result points [$hits hits]")
	return result
}
fn main(){
	mut filename := os.args[1] or {"/home/devlin/Development/adventofcode/2023/04/alfu32/input.txt"}
	data := os.read_file(filename) or { panic("file [$filename] not found")}
	println (data)
	test_cards := data.split("\n").filter(!it.is_blank()).map(card_from_string(it))
	total := arrays.fold(test_cards,u64(0),fn(t u64,c Card) u64 {
		return t+c.points()
	})
	println("total : $total")
}
