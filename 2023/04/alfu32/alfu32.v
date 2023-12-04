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
	//println(c)
	mut hits := 0
	for n in c.chosen_numbers {
		if n in c.winning_numbers {
			//println("$n in ${c.winning_numbers}")
			hits++
		}
	}
	mut result := if hits == 0 { u64(0) } else {u64(1<<(hits-1))}
	//println("$result points [$hits hits]")
	return result
}

pub fn (cards []Card) count(limit int) int{
	cc := cards.count_cards(cards.filter(it.points()>0).map(it.number),limit)
	return arrays.flat_map[[]u64, u64](cc, fn(a []u64) []u64 { return a }).len
}
pub fn (cards []Card) count_cards(allowed_ids []u64,limit int) [][]u64{
	mut ref := [allowed_ids.clone()]
	mut refs :=[][]u64{}
	mut u := 0
	mut total := cards.filter(it.points()>0).len
	for ref.len > 0 && u < limit{
		ref = get_copies_ref(cards,arrays.flat_map[[]u64, u64](ref, fn(a []u64) []u64 { return a }))
		total+=ref.len
		refs << ref
		println("u:$u,ref:$ref,total:$total")
		u++
	}
	return refs

}

pub fn get_copies_ref(cards []Card,only []u64) [][]u64 {

	mut copies := cards
	.filter(fn[only](c Card) bool {
		return c.number in only
	})
	.map(fn[cards](c Card) []u64 {
		points := c.points()
		mut indices := []u64{}
		if points > 0 {
			for k in 0..(points+1) {
				indices << u64(1+c.number+k)
			}
		} else {
			indices = []u64{}
		}
		len := cards.len
		return indices.map(fn[len](ix u64) u64 {return if ix<=len { ix } else { u64(len) }})
	})
	return copies
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
	total2 := test_cards.count(2000)
	println("total2 : $total2")
}
