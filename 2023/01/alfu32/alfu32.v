module main

import os
import regex
import arrays
const replacements = {
	"ONE"   : u8(1),
	"TWO"   : 2,
	"THREE" : 3,
	"FOUR"  : 4,
	"FIVE"  : 5,
	"SIX"   : 6,
	"SEVEN" : 7,
	"EIGHT" : 8,
	"NINE"  : 9,
	"ZERO"  : 0,
	"1" : 1,
	"2" : 2,
	"3" : 3,
	"4" : 4,
	"5" : 5,
	"6" : 6,
	"7" : 7,
	"8" : 8,
	"9" : 9,
	"0" : 0,
}
const numbers_query = r'\d'
const literals_query = r'(\d)|(ONE)|(TWO)|(THREE)|(FOUR)|(FIVE)|(SIX)|(SEVEN)|(EIGHT)|(NINE)'
struct DebugItem {
	line_number u32
	input_line string
	found_tokens []string
	found_numbers []u8
	value u32
}
pub fn (d DebugItem) to_csv() string {
	return "${d.line_number};${d.input_line};0x${d.input_line.bytes().map("${it:2X}").join("")};${d.found_tokens.join("|")};${d.found_numbers.map(it.str()).join("")};${d.value}"
}
fn main(){
	mut filename := os.args[1] or {"/home/devlin/Development/adventofcode/2023/01/alfu32/input.txt"}
	lines := os.read_lines(filename) or { panic("file [$filename] not found")}

	clean1 := clean_input(lines,numbers_query)
	println("part 1:")
	for c in clean1 { println(c.to_csv())}
	sum1 := arrays.fold[DebugItem,u32](clean1,0,fn(a u32,c DebugItem) u32 { return a+c.value})
	println("result part 1: $sum1")
	clean2 := clean_input(lines,literals_query)
	println("part 2:")
	for c in clean2 { println(c.to_csv())}
	sum2 := arrays.fold[DebugItem,u32](clean2,0,fn(a u32,c DebugItem) u32 { return a+c.value})
	println("result part 2: $sum2")
}

fn clean_input(lines []string,regex_string string) []DebugItem {

	mut rx := regex.regex_opt(regex_string) or {
		println(err)
		panic ("regex [$err] was no good")
	}

	mut line_number:= u32(1)
	mut ints := []DebugItem{}
	for line in lines {
		found := rx.find_all_str(line.trim("\n\r\t ").to_upper())
		nums:=found.map(fn(token string) u8{return replacements[token]})
		mut value := nums.first()*10 + nums.last()
		if nums.len == 0 {
			panic("zero width result")
		} else if nums.len == 1 {
			value = nums[0]
		}
		ints << DebugItem{
			line_number: line_number
			input_line: line
			found_tokens: found
			found_numbers: nums
			value: value
		}
		line_number++
	}
	return ints

}

