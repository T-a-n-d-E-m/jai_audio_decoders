// This only compiles the library, not generate bindings.
// LINUX ONLY! Windows, MacOS and others not implemented.

// https://github.com/xiph/ogg/releases
SRC_PATH :: "src/libogg-1.3.6";
LIB_BASE_NAME :: "ogg";

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
			lib_directory = "linux";

		case .WINDOWS;
			lib_directory = "windows";
			array_add(*extra, "/Dextern=__declspec(dllexport)");

		case .MACOS;
			return false;
	}

	source_files: [..] string;
	array_add(*source_files, tprint("%/src/bitwise.c", SRC_PATH));
	array_add(*source_files, tprint("%/src/framing.c", SRC_PATH));

	array_add(*extra, tprint("-I%/include/", SRC_PATH));

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
