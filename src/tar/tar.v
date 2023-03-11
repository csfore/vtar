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

	mut tmp := u8(1)
	mut index := 0
	mut num_files := 0
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

	for _ in 0..num_files {
		mut unpack := unpack_header(bytes)!
		bytes.delete_many(0, 512)
		mut ctmp := ''
		for b in bytes {
			if b == `\0` {
				break
			}
			ctmp += b.ascii_str()
		}
		unpack['contents'] = ctmp
		ctmp = ''
		// println(bytes.bytestr())
		// println(unpack)
		files << unpack
		for bytes.first() == `\0` {
			bytes.delete(0)
		}
		bytes.delete_many(0, 512)
		// println('Checkpoint: ${bytes.bytestr()}')
	}
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