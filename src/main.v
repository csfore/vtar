/*
 * Just an example main file, not necessary for core functionality
*/

// Command to make a file with random contents
// openssl rand -out test_one -base64 $(( 2**16 * 3/4 ))

module main
import tar
import os

fn main() {
	files := ['one', 'two', 'three']
	output := './out.tar'

	tar.make_archive(output, files) or {
		eprintln('err')
		return
	}

	os.cp('./out.tar', './exttest/out.tar')!

	tar_in := './exttest/out.tar'
	tar.extract_archive(tar_in)!
}