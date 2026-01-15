#load "export.jai";
#load "callback.jai";
#load "format.jai";
#load "metadata.jai";
#load "stream_decoder.jai";
#load "stream_encoder.jai";

FLAC__bool   :: s32;
off_t        :: s64; // @TODO: How big is this on windows? What type does it map too? It is used once in metadata.jai

#scope_module

#if OS == {
	case .WINDOWS;
		flac :: #library "windows/flac";

	case .LINUX;
		flac :: #library "linux/flac";
		#library,system,link_always "m";

	case .MACOS;
		flac :: #library "macos/flac";
}
