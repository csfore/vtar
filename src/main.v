/*
 * Just an example main file, not necessary for core functionality
*/

// Command to make a file with random contents
// openssl rand -out test_one -base64 $(( 2**16 * 3/4 ))

module main
import vtar

fn main() {
	// files := ['one']
	// output := './out.tar'

	// vtar.make_archive(output, files) or {
	// 	eprintln('err')
	// 	return
	// }
	tar_in := './exttest/out.tar'
	vtar.extract_archive(tar_in)!
}