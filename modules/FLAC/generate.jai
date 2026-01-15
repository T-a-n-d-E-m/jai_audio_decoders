// This only compiles the library, not generate bindings.
// LINUX ONLY! Windows, MacOS and others not implemented.

// @TODO: FLAC supports various optimizations for AVX, SSE etc., which
// should be configurable in here.

// https://github.com/xiph/flac/releases
SRC_PATH :: "src/flac-1.5.0";
LIB_BASE_NAME :: "flac";

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

	with_ogg :: true;

	lib_directory: string;
	extra: [..] string;

	#if OS == {
		case .LINUX;
			lib_directory = "linux";
			array_add(*extra, "-DPACKAGE_VERSION=\"1.5.0\"");
			array_add(*extra, "-DSIZE_T_MAX=0xFFFFFFFFFFFFFFFF");
			array_add(*extra, "-DHAVE_LROUND");
			array_add(*extra, "-DHAVE_PTHREAD");
			array_add(*extra, tprint("-DFLAC__HAS_OGG=%", cast(u32)with_ogg));

		// Not implemented
		case .MACOS;
			return false;
		case .WINDOWS;
			return false;
	}

	source_files: [..] string;
	array_add(*source_files, tprint("%/src/libFLAC/bitmath.c", SRC_PATH));
	array_add(*source_files, tprint("%/src/libFLAC/bitreader.c", SRC_PATH));
	array_add(*source_files, tprint("%/src/libFLAC/bitwriter.c", SRC_PATH));
	array_add(*source_files, tprint("%/src/libFLAC/cpu.c", SRC_PATH));
	array_add(*source_files, tprint("%/src/libFLAC/crc.c", SRC_PATH));
	array_add(*source_files, tprint("%/src/libFLAC/fixed.c", SRC_PATH));
	array_add(*source_files, tprint("%/src/libFLAC/fixed_intrin_avx2.c", SRC_PATH));
	array_add(*source_files, tprint("%/src/libFLAC/fixed_intrin_sse2.c", SRC_PATH));
	array_add(*source_files, tprint("%/src/libFLAC/fixed_intrin_sse42.c", SRC_PATH));
	array_add(*source_files, tprint("%/src/libFLAC/fixed_intrin_ssse3.c", SRC_PATH));
	array_add(*source_files, tprint("%/src/libFLAC/float.c", SRC_PATH));
	array_add(*source_files, tprint("%/src/libFLAC/format.c", SRC_PATH));
	array_add(*source_files, tprint("%/src/libFLAC/lpc.c", SRC_PATH));
	array_add(*source_files, tprint("%/src/libFLAC/lpc_intrin_avx2.c", SRC_PATH));
	array_add(*source_files, tprint("%/src/libFLAC/lpc_intrin_fma.c", SRC_PATH));
	array_add(*source_files, tprint("%/src/libFLAC/lpc_intrin_neon.c", SRC_PATH));
	array_add(*source_files, tprint("%/src/libFLAC/lpc_intrin_sse2.c", SRC_PATH));
	array_add(*source_files, tprint("%/src/libFLAC/lpc_intrin_sse41.c", SRC_PATH));
	array_add(*source_files, tprint("%/src/libFLAC/md5.c", SRC_PATH));
	array_add(*source_files, tprint("%/src/libFLAC/memory.c", SRC_PATH));
	array_add(*source_files, tprint("%/src/libFLAC/metadata_iterators.c", SRC_PATH));
	array_add(*source_files, tprint("%/src/libFLAC/metadata_object.c", SRC_PATH));
	array_add(*source_files, tprint("%/src/libFLAC/ogg_decoder_aspect.c", SRC_PATH));
	array_add(*source_files, tprint("%/src/libFLAC/ogg_encoder_aspect.c", SRC_PATH));
	array_add(*source_files, tprint("%/src/libFLAC/ogg_helper.c", SRC_PATH));
	array_add(*source_files, tprint("%/src/libFLAC/ogg_mapping.c", SRC_PATH));
	array_add(*source_files, tprint("%/src/libFLAC/stream_decoder.c", SRC_PATH));
	array_add(*source_files, tprint("%/src/libFLAC/stream_encoder.c", SRC_PATH));
	array_add(*source_files, tprint("%/src/libFLAC/stream_encoder_framing.c", SRC_PATH));
	array_add(*source_files, tprint("%/src/libFLAC/stream_encoder_intrin_avx2.c", SRC_PATH));
	array_add(*source_files, tprint("%/src/libFLAC/stream_encoder_intrin_sse2.c", SRC_PATH));
	array_add(*source_files, tprint("%/src/libFLAC/stream_encoder_intrin_ssse3.c", SRC_PATH));
	array_add(*source_files, tprint("%/src/libFLAC/window.c", SRC_PATH));

	// OGG is built into the library...
	array_add(*source_files, tprint("%/../../../ogg/src/libogg-1.3.6/src/bitwise.c", SRC_PATH));
	array_add(*source_files, tprint("%/../../../ogg/src/libogg-1.3.6/src/framing.c", SRC_PATH));

	array_add(*extra, tprint("-I%/src/libFLAC/include", SRC_PATH));
	array_add(*extra, tprint("-I%/include", SRC_PATH));

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
