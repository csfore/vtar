module vtar
import os

pub fn make_archive(output string, files []string) ! {
	mut contents := ''

	if os.exists(output) {
		os.rm(output)!
	}

	mut tar_out := os.open_append(output)!

	for file in files {

		mut name := os.file_name(file)
		// tmp := name.bytes()

		// for i in tmp {
		// 	println('${i:X}')
		// }

		for _ in name.len .. 100 {
			name += '\0'
		}
		contents += name

		mode := os.inode(file).bitmask()
		contents += '${mode:07o}\0'
		contents += '${os.getuid():07o}\0'
		contents += '${os.getgid():07o}\0'
		contents += '${os.file_size(file):011o}\0'
		contents += '${os.file_last_mod_unix(file):o}\0'

		
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
		
		// TODO get group name instead
		contents += '${username}'
		for _ in username.len .. 33 {
			contents += '\0'
		}

		// TODO add checks for extra header stuff
		for _ in 0 .. 182 {
			contents += '\0'
		}

		// mut header := contents
		// println(header)
		sum := chksum(contents)

		contents = contents.replace('        ', '${sum:06o}\0 ')

		msg := os.read_file(file)!

		contents += os.read_file(file)!
		for _ in msg.len .. 512 {
			contents += '\0'
		}

		// header = ''
		tar_out.write_string(contents)!
		contents = ''
	}

	// println(contents.len)

	for _ in 0 .. 9216 {
		tar_out.write_string('\0')!
	}

	// mut out := output

	// if out == '' {
	// 	out = './out.tar'
	// }

	// os.write_file(out, contents) or {
	// 	eprintln('error')
	// 	return
	// }
}

fn chksum(bytes string) int {
	println(bytes)
	mut sum := 0

	for i in 0 .. bytes.len {
		sum += 0xFF & bytes[i]
	}
	return sum
}