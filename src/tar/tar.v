module tar
import os
import strconv

enum HeaderType {
	gnu
	oldgnu
	posix
	v7
	ustar
}

struct FileInfo {
	name string
	mask int
	uid int
	gid int
	size int
	time int
	chksum int
	typeflag string
	user string
	group string
	contents string
}

const (
	header_size = 512
)

pub fn extract_archive(path string) ! {

	mut bytes := os.read_bytes(path)!
	mut num_files := calculate_file_count(bytes)!
	// println('Files: $num_files')
	mut tmp := u8(1)
	mut index := 0
	// mut num_files := 0
	for {
		// println(bytes[index])
		tmp = bytes[index]
		if tmp == `\0` {
			break
		}
		index += 512
		num_files++
	}
	num_files /= 2

	mut files := []map[string]string{}

	for i in 0..2 {
		num_files = 2
		// println(files)
		mut unpack := unpack_header(bytes)!
		bytes.delete_many(0, 512)
		// mut ctmp := ''

		// block_size := 32
		// mut byte_index := 0
		content_size := int(strconv.parse_int(unpack['size'], 8, 64)!)
		// println(content_size)
		unpack['contents'] = bytes[0..content_size].bytestr()
		// println(unpack)
		bytes.delete_many(0, content_size)
		// println(bytes.bytestr())
		// ctmp = ''
		// println(bytes.bytestr())
		// println(unpack)
		files << unpack
		// println('uh')

		// for file in files {
		// 	println(file['name'])
		// }

		// println('$i, $num_files')

		if i == num_files-1 {
			break
		}
		for bytes.first() == `\0` {
			bytes.delete(0)
		}
		// bytes.delete_many(0, 512)
		// println('Checkpoint: ${bytes.bytestr()}')
	}

	// println('escaped')
	for file in files {
		os.write_file('${os.dir(path)}/${file['name']}', file['contents'])!

		// println(file_info['mask'][4..7])
		// println(int(strconv.parse_int(file['mask'], 8, 16)!))
		mask := int(strconv.parse_int(file['mode'][4..7], 8, 16)!)
		os.chmod('${os.dir(path)}/${file['name']}', mask)!

		// println(strconv.parse_int('14401713273', 8, 64)!)

		time := int(strconv.parse_int(file['mtime'], 8, 64) or {
			eprintln(err)
			exit(1)
		})
		os.utime('${os.dir(path)}/${file['name']}', time, time)!

		uid := int(strconv.parse_int(file['uid'], 8, 16)!)
		gid := int(strconv.parse_int(file['gid'], 8, 16)!)

		if os.getuid() != uid || os.getgid() != gid {
			os.chown('${os.dir(path)}/${file['name']}', file['uid'].int(), file['gid'].int())!
		}
	}

	
}

fn calculate_file_count(bytes []u8) !int {
	mut tmp := bytes.clone()
	mut i := 0
	mut num := 0

	for {
		h := unpack_header(tmp)!
		size := int(strconv.parse_int(h['size'], 8, 64)!)
		tmp.delete_many(0, 512)
		tmp.delete_many(i, i+size)
		if size < 512 {
			tmp.delete_many(i, 512-size)
		}
		if tmp.filter(it != `\0`).len == 0 {
			break
		}
		num++
	}
	return num

}

fn unpack_header(header []u8) !map[string]string {
	h_entries := {
		'name': 100
		'mode': 8
		'uid': 8
		'gid': 8
		'size': 12
		'mtime': 12
		'checksum': 8
		'typeflag': 1
		'linkname': 100
		'magic': 6
		'version': 2
		'uname': 32
		'gname': 32
		'devmajor': 8
		'devminor': 8
		'atime': 12
		'ctime': 12
		'offset': 12
		'longnames': 4
		'unused': 1
		'sparse': 96
		'isextended': 1
		'realsize': 12
		'pad': 17
	}
	mut location := 0

	mut header_map := map[string]string{}

	for n, s in h_entries {
		// header_arr << header[location..location+s].bytestr()
		header_map[n] = header[location..location+s].filter(it != `\0`).bytestr()
		location += s
	}
	return header_map //.filter(it[0].ascii_str() != '\0')
}

// make_archive takes files in an array of strings and prepares them for
// the GNU tar format

pub fn make_archive(output string, files []string) ! {
	mut contents := ''

	// TODO Find a better way to get around an archive with the same name
	if os.exists(output) {
		os.rm(output)!
	}

	mut tar_out := os.open_append(output)!

	for file in files {
		// mut file_type := 0
		contents += add_file(file, mut tar_out)!

		// if os.is_dir(file) {
		// 	// file_type = 
		// 	subfiles := os.ls(file)!
		// 	add_directory(subfiles, mut tar_out)!
		// } else {
		// 	add_file(file, mut tar_out)!
		// }
	}

	// println(contents.len)
	tar_out.write_string(contents)!

	for _ in 0 .. 9216 {
		tar_out.write_string('\0')!
	}
}

// fn add_main(file string, mut output os.File) ! {
// 	if os.is_dir(file) {
// 		add_directory(file, mut output)!
// 	}
// 	add_file(file, mut output)
// }

fn add_directory(directory string, mut output os.File) !string {
	// files := []string{}
	// pfiles := &files
	// println(path)
	mut contents := ''
	mut name := os.dir(directory) + '/'
	// println(name)
	for _ in name.len .. 100 {
		name += '\0'
	}
	mut attr := C.stat{}
	unsafe { C.stat(&char(name.str), &attr) }
	// println(attr)
	contents += '$name'
	mode := '${attr.st_mode:o}'[1..5]
	// println('${mode:07o}')
	contents += '${mode}\0'
	contents += '${attr.st_uid:07o}\0'
	contents += '${attr.st_gid:07o}\0'
	contents += '00000000000\0'
	contents += '${attr.st_mtime:o}\0'
	contents += '        ' // checksum placeholder
	contents += '5\0'
	for _ in 0..100 {
		contents += '\0'
	}
	contents += 'ustar'
	contents += '  \0'
	username := os.loginname()!

	contents += '${username}'
	for _ in username.len .. 32 {
		contents += '\0'
	}
	
	// TODO get group name instead
	contents += '${username}'
	for _ in username.len .. 33 {
		contents += '\0'
	}

	for _ in 0 .. 182 {
		contents += '\0'
	}
	dump(contents)
	return contents
	// println(name.bytes())
	// println(path)
	// for file in path {
	// 	if os.is_dir(file) {
	// 		add_directory(subfiles, mut output)!
	// 	}
	// 	add_file(file, mut output)!
	// }
	// os.walk(path, fn [mut output] (file string) {
	// 	add_file(file, mut output) or {
	// 		eprintln('err')
	// 		return
	// 	}
	// })
}



fn add_file(path string, mut tar_out os.File) !string {
	mut contents := ''
	mut files := [path]

	// for files.len > 0 {
		
	// }

	for file in files {
		mut attr := C.stat{}
		unsafe { C.stat(&char(file.str), &attr) }
		// println(attr)
		// println('${attr.st_mode:o}'[1..6])
		mut mode := '${attr.st_mode:o}'

		mut name := file
		// mut dir_check := false
		if os.is_dir(file) {
			contents += add_directory(file, mut tar_out)!
			// dir_check = true
			// files.clear()
			mut pfiles := &files
			os.walk(file, fn [mut pfiles] (file string) {
				println(file)
				pfiles << file
			})
			// println(files)
			if files.len == 0 {
				return contents
			}
			new_file := files[0]
			// dump(contents)
			files.delete(0)
			contents += add_file(new_file, mut tar_out)!
			// for i, j in files {
			// 	files[i] = '$file' + j
			// }
			mode = '${mode[1..5]:07}'
		} else if os.is_file(file) {
			mode = mode[1..6]
		}
		println(files)
		// mut contents := ''
		// mut name := file

		// if file_type == 5 {
		// 	name = file
		// }
		

		for _ in name.len .. 100 {
			name += '\0'
		}
		contents += name

		
		println(mode)
		contents += '${mode:07}\0'
		contents += '${attr.st_uid:07o}\0'
		contents += '${attr.st_gid:07o}\0'
		contents += '${attr.st_size:011o}\0'
		contents += '${attr.st_mtime:o}\0'

		contents += '        ' // checksum placeholder
		contents += '0'
		// if file_type == 0 {
		// 	contents += '0'
		// } else if file_type == 5 {
		// 	contents += '5'
		// }
		for _ in 0..100 {
			contents += '\0'
		}
		contents += 'ustar'
		contents += '  \0'

		username := os.loginname()!

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

		sum := chksum(contents)

		contents = contents.replace('        ', '${sum:06o}\0 ')
		// println(contents)
		if os.is_dir(file) {
			continue
		}
		msg := os.read_file(file)!

		contents += msg

		for _ in msg.len .. 512 {
			contents += '\0'
		}

		// if file_type == 0 {
			// msg := os.read_file(file)!
			// contents += os.read_file(file)!
			// for _ in msg.len .. 512 {
			// 	contents += '\0'
			// }
	}
	return contents

	// println(files)
	

	// 	// header = ''
	// // }
	// tar_out.write(contents.bytes())!
}

fn chksum(bytes string) int {
	mut sum := 0

	for i in 0 .. bytes.len {
		sum += 0xFF & bytes[i]
	}
	return sum
}