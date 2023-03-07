module main

struct GNU_Header {
	name		[100]u8
	mode		[8]u8
	uid			[8]u8
	gid			[8]u8
	size		[12]u8
	mtime		[12]u8
	checksum	[8]u8
	typeflag	[1]u8
	linkname	[100]u8
	magic		[6]u8
	version		[2]u8
	uname		[32]u8
	gname		[32]u8
	devmajor	[8]u8
	devminor	[8]u8
	atime		[12]u8
	ctime		[12]u8
	offset		[12]u8
	longnames	[4]u8
	unused		[1]u8
	sparse		[4]Sparse
	isextended	[1]u8
	realsize	[12]u8
	pad			[17]u8
}

struct Sparse {
	offset		[12]u8
	numbytes	[12]u8
}

/* tar Header Block, from POSIX 1003.1-1990.  */

/* POSIX header.  */

// struct POSIX_Header {                              /* byte offset */
//   char name[100];               /*   0 */
//   char mode[8];                 /* 100 */
//   char uid[8];                  /* 108 */
//   char gid[8];                  /* 116 */
//   char size[12];                /* 124 */
//   char mtime[12];               /* 136 */
//   char chksum[8];               /* 148 */
//   char typeflag;                /* 156 */
//   char linkname[100];           /* 157 */
//   char magic[6];                /* 257 */
//   char version[2];              /* 263 */
//   char uname[32];               /* 265 */
//   char gname[32];               /* 297 */
//   char devmajor[8];             /* 329 */
//   char devminor[8];             /* 337 */
//   char prefix[155];             /* 345 */
//                                 /* 500 */
// };

const (
	tmagic 		= "ustar"
	tmaglen 	= 6
	tversion 	= "00"
	tverslen 	= 2

	regtype 	= '0'
	aregtype 	= '\0'
	lnktype 	= '1'
	symtype 	= '2'
	chrtype 	= '3'
	blktype 	= '4'
	dirtype 	= '5'
	fifotype 	= '6'
	conttype	= '7'

	xhdtype		= 'x'
	xgltype		= 'g'

	tsuid 		= 04000
	tsgid 		= 02000
	tsvtx 		= 01000

	turead 		= 00400
	tuwrite 	= 00200
	tuexec		= 00100
	tgread 		= 00040
	tgwrite 	= 00020
	tgexec 		= 00010
	toread 		= 00004
	toexec 		= 00001
)
// #define TMAGIC   "ustar"        /* ustar and a null */
// #define TMAGLEN  6
// #define TVERSION "00"           /* 00 and no null */
// #define TVERSLEN 2

// /* Values used in typeflag field.  */
// #define REGTYPE  '0'            /* regular file */
// #define AREGTYPE '\0'           /* regular file */
// #define LNKTYPE  '1'            /* link */
// #define SYMTYPE  '2'            /* reserved */
// #define CHRTYPE  '3'            /* character special */
// #define BLKTYPE  '4'            /* block special */
// #define DIRTYPE  '5'            /* directory */
// #define FIFOTYPE '6'            /* FIFO special */
// #define CONTTYPE '7'            /* reserved */

// #define XHDTYPE  'x'            /* Extended header referring to the
//                                    next file in the archive */
// #define XGLTYPE  'g'            /* Global extended header */

// /* Bits used in the mode field, values in octal.  */
// #define TSUID    04000          /* set UID on execution */
// #define TSGID    02000          /* set GID on execution */
// #define TSVTX    01000          /* reserved */
//                                 /* file permissions */
// #define TUREAD   00400          /* read by owner */
// #define TUWRITE  00200          /* write by owner */
// #define TUEXEC   00100          /* execute/search by owner */
// #define TGREAD   00040          /* read by group */
// #define TGWRITE  00020          /* write by group */
// #define TGEXEC   00010          /* execute/search by group */
// #define TOREAD   00004          /* read by other */
// #define TOWRITE  00002          /* write by other */
// #define TOEXEC   00001          /* execute/search by other */