module vtar
import os
import strconv

enum HeaderType {
	gnu
	oldgnu
	posix
	v7
	ustar
}

pub fn extract_archive(path string) ! {
	bytes := os.read_bytes(path)!
	// println(bytes)
	// mut position := 0

	mut tmp := []string{}
	// mut file := [][]string{}

	for ch in bytes {
		// println(header_pos)
		if ch == `\0` {
			if tmp.last() != '.' {
				tmp << '.'
				continue
			}
			continue
		}
		tmp << ch.ascii_str()
		// println(tmp)
	}
	mut file := tmp.join('').split('.')
	file.insert(12, '|')
	// println(file)
	file_info := {
		'name':		file[0]
		'mask':		file[1]
		'uid':		file[2]
		'gid':		file[3]
		'size':		file[4]
		'time':		file[5]
		'chksum':	file[6]
		'typeflag':	file[8]
		'user':		file[9]
		'group':	file[10]
		'contents':	file[11]
	}
	// println(file_info)
	os.write_file('${os.dir(path)}/${file_info['name']}', file_info['contents'])!

	// println(file_info['mask'][4..7])

	mask := int(strconv.parse_int(file_info['mask'][4..7], 8, 16)!)
	os.chmod('${os.dir(path)}/${file_info['name']}', mask)!

	time := int(strconv.parse_int(file_info['time'], 8, 64)!)
	os.utime('${os.dir(path)}/${file_info['name']}', time, time)!

	uid := int(strconv.parse_int(file_info['uid'], 8, 16)!)
	gid := int(strconv.parse_int(file_info['gid'], 8, 16)!)

	if os.getuid() != uid || os.getgid() != gid {
		os.chown('${os.dir(path)}/${file_info['name']}', file_info['uid'].int(), file_info['gid'].int())!
	}
	
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

		mut name := os.file_name(file)

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

		contents += '        ' // checksum placeholder
		contents += '0'
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
}

fn chksum(bytes string) int {
	mut sum := 0

	for i in 0 .. bytes.len {
		sum += 0xFF & bytes[i]
	}
	return sum
}