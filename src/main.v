module main
// import os
import vtar

// struct TarHeader {
// 	name string
// 	mode int
// 	uid int
// 	gid int
// 	size int
// 	mtime int
// 	chksum int
// 	typeflag string
// 	user string
// 	group string
// }

fn main() {
	path := './one'

	vtar.make_archive(path) or {
		eprintln('err')
		return
	}
}