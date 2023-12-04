module main

import os
import regex
import arrays

struct DrawingBlock{
	pub mut:
		x u32
		y u32
		content string
}
pub fn (e DrawingBlock) end_anchor() DrawingBlock {
	return DrawingBlock{
		x: u32(e.x+e.content.len-1)
		y: e.y
		content: ''
	}
}
pub fn (e DrawingBlock) str() string {
	return "${if e.is_code() {"code" }else {"part"}};${e.x};${e.y};${e.content}"
}
pub fn (e DrawingBlock) is_code() bool {
	mut rx := regex.regex_opt(r'^(\d+)$') or {
		println(err)
		panic ("regex [$err] was no good")
	}
	return rx.matches_string(e.content)
}
pub fn (a DrawingBlock) is_near(b DrawingBlock) bool {
	return ( ((a.x-b.x )*(a.x-b.x )) <= 1 )  && ( ((a.y-b.y)*(a.y-b.y)) <= 1 )
}
pub fn (a DrawingBlock) is_adjacent(b DrawingBlock) bool {
	ea:=a.end_anchor()
	eb:= b.end_anchor()
	return a.is_near(b) || a.is_near(eb) || b.is_near(ea)
}
struct EngineMap{
	pub mut:
	entities []DrawingBlock
}
pub fn (e EngineMap) get_parts() []Part {
	mut parts := []Part{}
	figures := e.entities.filter(!it.is_code())
	codes := e.entities.filter(it.is_code())
	cl := codes.len*100
	mut uuids := []u64{}
	for fi,figure in figures {
		mut part := Part{
			figure: figure
		}
		/// mut found_code:=false
		for ci,code in codes {
			/// println("$code near $figure == ${code.is_near(figure)}}")
			if code.is_adjacent(figure) {
				uuid:= u64(fi * cl + ci)
				if !(uuid in uuids) {
					part.codes << code
					uuids << uuid
				}
				// found_code=true
				// break
			}
		}
		/// if !found_code {
		/// 	parts << Part {
		/// 		figure:figure
		/// 		code: DrawingBlock{
		/// 			content: 'void'
		/// 		}
		/// 	}
		/// }
		parts << part
	}
	return parts
}
pub fn engine_map_from_string(txt string) EngineMap {
	mut digits := regex.regex_opt(r'\d') or {
		println(err)
		panic ("regex [$err] was no good")
	}
	mut entities := []DrawingBlock{}
	lines := txt.split("\n")
	for y,line in lines {
		mut buf_num:=""
		for x,chr in line.split("") {
			if digits.matches_string(chr) {
				buf_num+=chr
			}else {
				if !buf_num.is_blank() {
					// create code
					entities << DrawingBlock{x:u32(x+1-buf_num.len),y:u32(y+1),content: buf_num}
					buf_num=""
				}
				if chr != '.' {
					entities << DrawingBlock{x:u32(x+1),y:u32(y+1),content: chr}
				}
			}
		}
		if !buf_num.is_blank() {
			// create code
			entities << DrawingBlock{x:u32(line.len-buf_num.len),y:u32(y+1),content: buf_num}
			buf_num=""
		}
	}
	return EngineMap{entities}
}
struct Part{
	pub mut:
		figure DrawingBlock
		codes []DrawingBlock
}
pub fn (p Part) is_gear() bool {
	return p.codes.len == 2
}
pub fn (p Part) gear_power_ratio() u64 {
	if p.is_gear(){
		return  (p.codes[0].content.u64()) * (p.codes[1].content.u64())
	} else {
		return u64(0)
	}
}

fn main(){
	mut filename := os.args[1] or {"/home/devlin/Development/adventofcode/2023/03/alfu32/input.txt"}
	engine_map := os.read_file(filename) or { panic("file [$filename] not found")}
	println (engine_map)

	em:=engine_map_from_string(engine_map)
	println(em.entities.map(it.str()).join("\n"))
	parts := em.get_parts()
	println(parts)
	sum_codes := arrays.fold(parts,u64(0),fn(acc u64,part Part) u64 {
		return acc + arrays.fold(part.codes, u64(0), fn(s u64, code DrawingBlock) u64 {
			return s+code.content.u64()
		})
	})
	println("sum_codes : ${sum_codes}")
	sum_gears := arrays.fold(parts,u64(0),fn(acc u64,part Part) u64 {
		return acc + part.gear_power_ratio()
	})
	println("sum_gears : ${sum_gears}")
}
