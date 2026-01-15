// This only compiles the library, not generate bindings.
// LINUX ONLY! Windows, MacOS and others not implemented.

// https://github.com/xiph/vorbis/releases
SRC_PATH :: "src/libvorbis-1.3.7";
LIB_BASE_NAME :: "vorbis";

#run,stallable {
	set_build_options_dc(.{do_output=false});
	options := get_build_options();
	args := options.compile_time_command_line;
	if !compile_library(args) {
		compiler_set_workspace_status(.FAILED);
	}
}

compile_library :: (args: [] string) -> bool {
	compile_debug := array_find(args, "-debug");

	lib_directory: string;
	extra: [..] string;

	#if OS == {
		case .LINUX;
			// Silence a bunch of warnings
			lib_directory = "linux";
			array_add(*extra, tprint("-Wno-int-conversion"));
			array_add(*extra, tprint("-Wno-pointer-sign"));
			array_add(*extra, tprint("-Wno-implicit-function-declaration"));
			array_add(*extra, tprint("-Wno-braced-scalar-init"));
			array_add(*extra, tprint("-Wno-incompatible-pointer-types"));
			array_add(*extra, tprint("-Wno-excess-initializers"));

		// Not implemented
		case .MACOS;
			return false;
		case .WINDOWS;
			return false;
	}

	source_files: [..] string;
	array_add(*source_files, tprint("%/lib/analysis.c", SRC_PATH));
	array_add(*source_files, tprint("%/lib/bitrate.c", SRC_PATH));
	array_add(*source_files, tprint("%/lib/block.c", SRC_PATH));
	array_add(*source_files, tprint("%/lib/codebook.c", SRC_PATH));
	array_add(*source_files, tprint("%/lib/envelope.c", SRC_PATH));
	array_add(*source_files, tprint("%/lib/floor0.c", SRC_PATH));
	array_add(*source_files, tprint("%/lib/floor1.c", SRC_PATH));
	array_add(*source_files, tprint("%/lib/info.c", SRC_PATH));
	array_add(*source_files, tprint("%/lib/lookup.c", SRC_PATH));
	array_add(*source_files, tprint("%/lib/lpc.c", SRC_PATH));
	array_add(*source_files, tprint("%/lib/lsp.c", SRC_PATH));
	array_add(*source_files, tprint("%/lib/mapping0.c", SRC_PATH));
	array_add(*source_files, tprint("%/lib/mdct.c", SRC_PATH));
	array_add(*source_files, tprint("%/lib/psy.c", SRC_PATH));
	array_add(*source_files, tprint("%/lib/registry.c", SRC_PATH));
	array_add(*source_files, tprint("%/lib/res0.c", SRC_PATH));
	array_add(*source_files, tprint("%/lib/sharedbook.c", SRC_PATH));
	array_add(*source_files, tprint("%/lib/smallft.c", SRC_PATH));
	array_add(*source_files, tprint("%/lib/synthesis.c", SRC_PATH));
	array_add(*source_files, tprint("%/lib/vorbisenc.c", SRC_PATH));
	array_add(*source_files, tprint("%/lib/vorbisfile.c", SRC_PATH));
	array_add(*source_files, tprint("%/lib/window.c", SRC_PATH));

	// OGG is built into the library...
	array_add(*source_files, tprint("%/../../../ogg/src/libogg-1.3.6/src/bitwise.c", SRC_PATH));
	array_add(*source_files, tprint("%/../../../ogg/src/libogg-1.3.6/src/framing.c", SRC_PATH));

	array_add(*extra, tprint("-I%/include/", SRC_PATH));
	array_add(*extra, tprint("-I%/lib/", SRC_PATH));

	make_directory_if_it_does_not_exist(lib_directory, recursive=true);
	lib_path := tprint("%/%", lib_directory, LIB_BASE_NAME);

	success := true;
	success &&= Build_Cpp.build_cpp_dynamic_lib(lib_path, ..source_files, debug=compile_debug, extra=extra);
	success &&= Build_Cpp.build_cpp_static_lib(lib_path, ..source_files, debug=compile_debug, extra=extra);

	if !success then return false;

	return true;
}

#import "Basic";
#import "Compiler";
#import "File";
Build_Cpp :: #import "BuildCpp";
