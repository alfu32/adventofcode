module main

import arrays

pub fn test_clean_input_1(){
	println("test")

	lines := &{
		"1abc2" : u32(12),
		"pqr3stu8vwx" : 38,
		"a1b2c3d4e5f" : 15,
		"treb7uchet" : 77,
	}
	println(lines.keys())
	clean := clean_input(lines.keys(),numbers_query)
	for c in clean { println(c.to_csv())}
	sum := arrays.fold[DebugItem,u32](clean,0,fn(a u32,c DebugItem) u32 { return a+c.value})
	println(clean)
	println(sum)
}

pub fn test_clean_input_2(){
	println("test")
	lines := &{
		"two1nine": u32(29),
		"eightwothree":83,
		"abcone2threexyz":13,
		"xtwone3four":24,
		"4nineeightseven2":42,
		"zoneight234":14,
		"7pqrstsixteen":76,
	}
	println(lines.keys())
	clean := clean_input(lines.keys(),literals_query)
	for c in clean { println(c.to_csv())}
	sum := arrays.fold[DebugItem,u32](clean,0,fn(a u32,c DebugItem) u32 { return a+c.value})
	println(clean)
	println(sum)
}

pub fn test_clean_input_3(){
	println("test")
	lines := &{
		"5ffour295": u32(55),
		"m9qvkqlgfhtwo3seven4seven":97,
		"2vdqng1sixzjlkjvq":26,
		"5twonineeight3onefive":55,
		"2three2seveneightseven":27,
		"eightsevenfive3bcptwo":82,
		"five8six":56,
	}
	println(lines.keys())
	clean := clean_input(lines.keys(),literals_query)
	for c in clean { println(c.to_csv())}
	sum := arrays.fold[DebugItem,u32](clean,0,fn(a u32,c DebugItem) u32 { return a+c.value})
	println(clean)
	println(sum)
}
