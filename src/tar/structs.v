/*
 * NOT CURRENTLY USED
**/

module tar

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