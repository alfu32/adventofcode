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
	mut numbers := regex.regex_opt(r'(\d+)') or {
		println(err)
		panic ("regex [$err] was no good")
	}
	mut entities := []DrawingBlock{}
	lines := txt.split("\n")
	for y,line in lines {
		entity_codes := numbers.find_all_str(line)
		symbols := digits.replace(line,".")
		mut entity_defs:= symbols.split(".").filter(!it.is_blank())
		entity_defs << entity_codes
		for ed in entity_defs {
			x:=line.index(ed) or { panic ( "entity $ed not detected in $line" )}
			entities << DrawingBlock{ x:u32(x+1),y:u32(y+1),content:ed}
		}
	}
	return EngineMap{entities}
}
struct Part{
	pub mut:
		figure DrawingBlock
		codes []DrawingBlock
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
	println(sum_codes)
}
