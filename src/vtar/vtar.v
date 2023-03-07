module vtar
import os

pub fn make_archive(path string) ! {


	mut contents := ''

	mut name := os.file_name(path)
	// tmp := name.bytes()

	// for i in tmp {
	// 	println('${i:X}')
	// }

	for _ in name.len .. 100 {
		name += '\0'
	}
	contents += name

	mode := os.inode(path).bitmask()
	contents += '0000${mode:o}\0'
	contents += '000${os.getuid():o}\0'
	contents += '000${os.getgid():o}\0'
	contents += '${os.file_size(path):011o}\0'
	contents += '${os.file_last_mod_unix(path):o}\0'

	
	// ${sum:o}
	contents += '        ' // checksum placeholder
	contents += '0'
	for _ in 0..100 {
		contents += '\0'
	}
	contents += 'ustar'
	contents += '  \0'

	username := os.loginname()

	contents += '${username}'
	for _ in username.len .. 32 {
		contents += '\0'
	}

	contents += '${username}'
	for _ in username.len .. 33 {
		contents += '\0'
	}
	for _ in 0 .. 182 {
		contents += '\0'
	}

	sum := chksum(contents)
	// println('${sum:o}')
	contents = contents.replace('        ', '0${sum:o}\0 ')
	// println(contents)

	msg := os.read_file(path)!

	contents += os.read_file(path)!
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

fn chksum(bytes string) int {
	mut sum := 0

	for i in 0 .. bytes.len {
		sum += 0xFF & bytes[i]
	}
	return sum
}