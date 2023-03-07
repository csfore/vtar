module main
import os

struct TarHeader {
	name string
	mode int
	uid int
	gid int
	size int
	mtime int
	chksum int
	typeflag string
	user string
	group string
}
//  
fn main() {

	// println('${1678117114:o}')
	// println(i)
	mut name := 'one'
	msg := 'hello'

	// size := os.file_size()

	header := TarHeader{
		name: name
		mode: 0000644
		uid: 0001000
		gid: 0001000
		size: 00000000005
		mtime: 1678117114
		chksum: 011100
		typeflag: 'ustar'
		user: 'csfore'
		group: 'csfore'
	}

	make_contents(header, msg)
	// mode := '0000644'
	// id := os.getuid()
	// println('$name $mode $id')
	// contents := '$name 0000644\ 0001750\ 0001750\ 00000000005\ 14401404372\ 011100\ 0\ ustar\ csfore\ csfore\ hello\ '
	// os.write_file('./out.tar', contents)!
}

fn make_contents(header TarHeader, msg string) {
	mut contents := ''

	mut name := header.name
	// tmp := name.bytes()

	// for i in tmp {
	// 	println('${i:X}')
	// }

	for _ in name.len .. 100 {
		name += '\0'
	}
	contents += name

	contents += '0000${header.mode}\0'
	contents += '000${header.uid:o}\0'
	contents += '000${header.gid:o}\0'
	contents += '${header.size:011o}\0'
	contents += '${header.mtime:o}\0'
	contents += '0${header.chksum}\0 '
	contents += '0'
	for _ in 0..100 {
		contents += '\0'
	}
	contents += '${header.typeflag}'
	contents += '  \0'

	contents += '${header.user}'
	for _ in header.user.len .. 32 {
		contents += '\0'
	}
	contents += '${header.group}'
	for _ in header.group.len .. 33 {
		contents += '\0'
	}
	for _ in 0 .. 182 {
		contents += '\0'
	}

	contents += msg
	for _ in msg.len .. 512 {
		contents += '\0'
	}

	// println(contents.len)

	for _ in 0 .. 9216 {
		contents += '\0'
	}

	os.write_file('./out.tar', contents) or {
		eprintln('error')
		return
	}
}
// fn to_octal(x int) !int {
// 	mut conv := x
// 	mut arr := []string{}

// 	for conv > 0 {
// 		arr << (conv % 8).str()
// 		conv /= 8
// 	}
// 	arr.reverse_in_place()
// 	return arr.join('').int()
// }