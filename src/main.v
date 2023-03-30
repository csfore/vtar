/*
* Just an example main file, not necessary for core functionality
*/

// Command to make a file with random contents
// openssl rand -out test_one -base64 $(( 2**16 * 3/4 ))

module main

import tar
import os

fn main() {
	files := ['test/']
	output := './out.tar'
	mut attr := C.stat{}
	unsafe { C.stat(&char(files[0].str), &attr) }
	// println('${attr}')
	// println('${attr.st_mode:o}')

	tar.make_archive(output, files) or {
		eprintln('err ${err}')
		return
	}

	// os.cp('./out.tar', './exttest/out.tar')!

	// tar_in := './exttest/out.tar'
	// tar.extract_archive(tar_in)!
}
