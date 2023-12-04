module main

import arrays

fn test_scd(){

	engine_map := "
		467..114..................
		...*......................
		..35..633.................
		......#...................
		617*......................
		.....+.58.................
		..592.....................
		......755.................
		...$.*....................
		.664.598..................
		..........................
		...$.........*.........*..
		.664..........23.......598
	".trim_indent()
	em:=engine_map_from_string(engine_map)
	println(em.entities.map(it.str()).join("\n"))
	parts := em.get_parts()
	println(parts)
	sum_codes := arrays.fold(parts,u64(0),fn(acc u64,part Part) u64 {
		return acc + arrays.fold(part.codes, u64(0), fn(s u64, code DrawingBlock) u64 {
			return s+code.content.u64()
		})
	})
	for part in parts {
		println("$part is_gear : ${part.is_gear()}, power_ratio : ${part.gear_power_ratio()}")
	}
	println(sum_codes)

	assert sum_codes == 4361 + 664 + 598 + 23

	sum_gears := arrays.fold(parts,u64(0),fn(acc u64,part Part) u64 {
		return acc + part.gear_power_ratio()
	})
	assert sum_gears == 467835
}
