module main

fn test_scd(){

	lines := "
		seeds: 79 14 55 13

		seed-to-soil map:
		50 98 2
		52 50 48

		soil-to-fertilizer map:
		0 15 37
		37 52 2
		39 0 15

		fertilizer-to-water map:
		49 53 8
		0 11 42
		42 0 7
		57 7 4

		water-to-light map:
		88 18 7
		18 25 70

		light-to-temperature map:
		45 77 23
		81 45 19
		68 64 13

		temperature-to-humidity map:
		0 69 1
		1 0 69

		humidity-to-location map:
		60 56 37
		56 93 4
	".trim_indent()
	println(lines)
	db := database_init_from_text(lines) or {
		println(err)
		Database{}
	}
	println(db)
	for seed in db.seed.records {
		println("seed : $seed, vector: ${db.get_vector(seed).to_json(false)}")
	}
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
