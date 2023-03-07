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
	files := ['one', 'two']
	output := './out.tar'

	vtar.make_archive(output, files) or {
		eprintln('err')
		return
	}
}