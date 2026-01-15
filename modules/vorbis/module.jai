#load "codec.jai";
#load "vorbisenc.jai";
#load "vorbisfile.jai";

#scope_module

#if OS == {
	case .WINDOWS;
		vorbis :: #library "windows/vorbis";

	case .LINUX;
		vorbis :: #library "linux/vorbis";
		#library,system,link_always "m"; // @TODO: can't this be done when the library is built

	case .MACOS;
		vorbis :: #library "macos/vorbis";
}
