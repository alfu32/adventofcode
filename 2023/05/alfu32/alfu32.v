module main

import os

const cutset = "\r\n\t "

pub fn clean_split(s string,c string) []string {
	return s.trim(cutset).split(c).map(it.trim(cutset))
}

struct List{
	pub:
	name string
	records []u64
}
pub fn list_create_from_string(def string) !List {
	tokens := clean_split(def, " ")
	if tokens.len < 2 {
		return error("$def is not a good definitions of a List")
	}
	t := List{
		name: tokens[0]
		records: tokens[1..].map(it.u64())
	}
	return t
}
pub fn list_create_intervals_string(def string) ![]Interval {
	mut intervals := []Interval{}
	numbers := clean_split(def, " ")[1..].map(it.u64())
	if (numbers.len < 2) || (numbers.len%2 != 0) {
		return error("$def is not a good definitions of a list of intervals")
	}
	for i,n in numbers {
		if i>0 && i%2 == 0 {
			intervals << Interval{numbers[i-1],n}
		}
	}
	return intervals
}
struct Association{
	pub mut:
	primary_name string
	secondary_name string
	primary_intervals map[u64]Interval
	secondary_intervals map[u64]Interval
}
pub fn (a Association) get_name() string {
	return "${a.primary_name}-to-${a.secondary_name}"
}
pub fn (mut a Association) set_names_from_string(def string) {
}
pub fn create_association_from_string(def string) Association {
	mut a := Association{}
	lines := def.split("\n")
	for k,line in lines {
		if k == 0 {
			tokens := clean_split(line.replace(" map:",""),"-to-")
			if tokens.len < 2 {
				panic("$line is not an Association definition")
			}
			a.primary_name=tokens[0]
			a.secondary_name=tokens[1]
		} else {
			tokens := line.split(" ")
			if tokens.len < 3 {
				panic (" bad definition [$line] for index of ${a.get_name()}")
			}
			a.add_primary_interval(tokens[1].u64(),tokens[1].u64(),tokens[2].u64())
			a.add_secondary_interval(tokens[1].u64(),tokens[0].u64(),tokens[2].u64())
		}
	}
	return a
}

// pub fn create_association(primary string,secondary string) Association {
///// 	return Association{
///// 		primary_name: primary,
///// 		secondary_name: secondary,
///// 	}
///// }
//
// add_primary_interval
pub fn (mut a Association) add_primary_interval(index u64, primary u64,length u64) {
	interval := Interval{primary,primary+length+1}
	a.primary_intervals[index]=interval
}
pub fn (mut a Association) add_secondary_interval(index u64, secondary u64,length u64) {
	interval := Interval{secondary,secondary+length+1}
	a.secondary_intervals[index]=interval
}
pub fn (a Association) get_associated_by_id(primary u64) u64 {
	/// println("get ${a.secondary_name} for ${a.primary_name}($primary) from $a")
	for index,primary_interval in a.primary_intervals {
		if primary_interval.contains(primary) {
			secondary_interval := a.secondary_intervals[index]
			dist := primary_interval.index_of(primary)
			associated_value := secondary_interval.value_at_index(dist)
			return associated_value
		}
	}
	/// println("no associated value for primary index $primary in $a")
	return primary
	// return error("no associated value for primary index $primary in $a")
}
pub fn (a Association) get_associated_to_interval(intv Interval) []Interval {
	/// println("get ${a.secondary_name} for ${a.primary_name}($primary) from $a")
	mut intervals := []Interval{}
	for index,primary_interval in a.primary_intervals {
		if primary_interval.intersects(intv) {
			common := primary_interval.intersect(intv)
			secondary_interval:=a.secondary_intervals[index]
			dist := primary_interval.index_of(common.start)
			associated_common_start := secondary_interval.value_at_index(dist)
			associated_common := Interval{associated_common_start,associated_common_start+common.len()+1}
			intervals << associated_common
			outside:= intv.subtract(primary_interval)
			intervals << outside
		}
	}
	if intervals.len == 0 {
		return [intv]
	} else {
		return intervals.filter(it.len() > 0)
	}
}
pub fn (a Association) get_associated_to_intervals(intvs []Interval) []Interval {
	mut intervals := []Interval{}
	for intv in intvs {
		intervals << a.get_associated_to_interval(intv)
	}
	return intervals
}
struct Vector{
	pub mut:
	seed u64
	soil u64
	fertilizer u64
	water u64
	light u64
	temperature u64
	humidity u64
	location u64
}
pub fn (v Vector) to_json(pretty bool) string {
	if pretty {
		return '
		{
			"seed"        : ${v.seed},
			"soil"        : ${v.soil},
			"fertilizer"  : ${v.fertilizer},
			"water"       : ${v.water},
			"light"       : ${v.light},
			"temperature" : ${v.temperature},
			"humidity"    : ${v.humidity},
			"location"    : ${v.location}
		}
		'.trim_indent()
	} else {
		return '{seed:${v.seed},soil:${v.soil},fert:${v.fertilizer},water:${v.water},light:${v.light},temp:${v.temperature},hum:${v.humidity},loc:${v.location}}'
	}
}
struct VectorInterval{
	pub mut:
	seed Interval
	soil_intervals []Interval
	fertilizer_intervals []Interval
	water_intervals []Interval
	light_intervals []Interval
	temperature_intervals []Interval
	humidity_intervals []Interval
	location_intervals []Interval
}
pub fn (v VectorInterval) to_json(pretty bool) string {
	if pretty {
		return '
		{
			"seed"        : ${v.seed},
			"soil"        : ${v.soil_intervals},
			"fertilizer"  : ${v.fertilizer_intervals},
			"water"       : ${v.water_intervals},
			"light"       : ${v.light_intervals},
			"temperature" : ${v.temperature_intervals},
			"humidity"    : ${v.humidity_intervals},
			"location"    : ${v.location_intervals}
		}
		'.trim_indent()
	} else {
		return '{seed:${v.seed},soil:${v.soil_intervals},fert:${v.fertilizer_intervals},water:${v.water_intervals},light:${v.light_intervals},temp:${v.temperature_intervals},hum:${v.humidity_intervals},loc:${v.location_intervals}}'
	}
}
struct Database{
	pub mut:
	seed List
	seed_intervals []Interval
	seed_to_soil Association
	soil_to_fertilizer Association
	fertilizer_to_water Association
	water_to_light Association
	light_to_temperature Association
	temperature_to_humidity Association
	humidity_to_location Association
}
pub fn (db Database) get_vectors() []Vector{
	mut vectors := []Vector{}
	for seed in db.seed.records {
		vectors << db.get_vector(seed)
	}
	return vectors
}
pub fn (db Database) get_vector(seed u64) Vector {
	mut v := Vector{seed:seed}
	v.soil = db.seed_to_soil.get_associated_by_id(seed)
	v.fertilizer = db.soil_to_fertilizer.get_associated_by_id(v.soil)
	v.water = db.fertilizer_to_water.get_associated_by_id(v.fertilizer)
	v.light = db.water_to_light.get_associated_by_id(v.water)
	v.temperature = db.light_to_temperature.get_associated_by_id(v.light)
	v.humidity = db.temperature_to_humidity.get_associated_by_id(v.temperature)
	v.location = db.humidity_to_location.get_associated_by_id(v.humidity)
	return v
}
pub fn (db Database) get_vector_interval(seed_interval Interval) VectorInterval {
	mut v := VectorInterval{seed:seed_interval}
	v.soil_intervals = db.seed_to_soil.get_associated_to_interval(seed_interval).compact()
	v.fertilizer_intervals = db.soil_to_fertilizer.get_associated_to_intervals(v.soil_intervals).compact()
	v.water_intervals = db.fertilizer_to_water.get_associated_to_intervals(v.fertilizer_intervals).compact()
	v.light_intervals = db.water_to_light.get_associated_to_intervals(v.water_intervals).compact()
	v.temperature_intervals = db.light_to_temperature.get_associated_to_intervals(v.light_intervals).compact()
	v.humidity_intervals = db.temperature_to_humidity.get_associated_to_intervals(v.temperature_intervals).compact()
	v.location_intervals = db.humidity_to_location.get_associated_to_intervals(v.humidity_intervals).compact()
	return v
}
pub fn (db Database) get_vectors_of_intervals() []VectorInterval {
	mut vectors := []VectorInterval{}
	for seed_interval in db.seed_intervals {
		vectors << db.get_vector_interval(seed_interval)
	}
	return vectors
}

pub fn condition_input(text string) []string {
	lines := clean_split(text,"\n")
	mut block_lines := [][]string{}
	for line in lines {
		if line.is_blank() {
			block_lines << []string{}
		} else {
			if block_lines.len == 0 {
				block_lines << [line]
			} else {
				block_lines.last() << line
			}
		}
	}
	// println(block_lines)
	return block_lines.map(it.join("\n"))
}
pub fn database_init_from_text(text string) !Database{
	mut db := Database{}
	blocks := condition_input(text)

	for k,block in blocks {
		if k == 0 {
			db.seed = list_create_from_string(block)!
			db.seed_intervals = list_create_intervals_string(block)!
		} else {
			a := create_association_from_string(block)
			// println(a)
			match a.get_name() {
				"seed-to-soil" { db.seed_to_soil = a}
				"soil-to-fertilizer" { db.soil_to_fertilizer = a}
				"fertilizer-to-water" { db.fertilizer_to_water = a}
				"water-to-light" { db.water_to_light = a}
				"light-to-temperature" { db.light_to_temperature = a}
				"temperature-to-humidity" { db.temperature_to_humidity = a}
				"humidity-to-location" { db.humidity_to_location = a}
				else {
					panic("unknown association ${a.get_name()}}")
				}
			}
		}
	}
	return db
}
fn main(){
	mut filename := os.args[1] or {"/home/devlin/Development/adventofcode/2023/05/alfu32/input.txt"}
	data := os.read_file(filename) or { panic("file [$filename] not found")}
	db := database_init_from_text(data)!
	println("part_1: min_location")
	mut min_location := u64(0xFFFFFFFF)
	for vector in db.get_vectors() {
		println("seed : ${vector.seed}, vector: ${vector.to_json(false)}")
		if vector.location < min_location {
			min_location = vector.location
		}
	}
	println("min_location 1: $min_location")
	for vector in db.get_vectors_of_intervals() {
		println("seed : ${vector.seed}, vector: ${vector.to_json(true)}")
		for location_interval in vector.location_intervals {
			if location_interval.start < min_location {
				min_location = location_interval.start
			}
		}
	}
	println("min_location 2: $min_location")
}
