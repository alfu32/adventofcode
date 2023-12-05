module main

import os
const cutset = "\r\n\t "

struct Table{
	pub:
	name string
	ranges []Range
}
pub fn table_create_from_list(name string,list string) Table {
	t := Table{
		name: name
		records: list.trim(cutset).split(" ").map(it.trim(cutset).u64())
	}
	return t
}
pub fn table_create_from_range(name string,range Range) Table {
	t := Table{
		name: name
		ranges: [range]
	}
}
struct Database{
	seed Table
	soil Table
	fertilizer Table
	water Table
	light Table
	temperature Table
	humidity Table
	location Table
	seed_to_soil Table
	soil_to_fertilizer Table
	fertilizer_to_water Table
	water_to_light Table
	light_to_temperature Table
	temperature_to_humidity Table
	humidity_to_location Table
}

pub fn database_init_from_text(text string) Database{
	mut db := Database{}
}
fn main(){
	mut filename := os.args[1] or {"/home/devlin/Development/adventofcode/2023/04/alfu32/input.txt"}
	data := os.read_file(filename) or { panic("file [$filename] not found")}
	println (data)
}
