// Read a .flac file and write the raw PCM values out to a file.
// The output can be verified with Audacity using Import->Raw Data
decode_flac_file :: (in_filename: string, out_filename: string) {
	// Print some decoder information
	print("FLAC version      :%\n", to_string(FLAC__VERSION_STRING));
	print("FLAC vender       :%\n", to_string(FLAC__VENDOR_STRING));
	print("Ogg FLAC supported: %\n", FLAC_API_SUPPORTS_OGG_FLAC);

	files: In_Out;

	in_file, in_success := file_open(in_filename);
	if !in_success then return;
	files.in = in_file;
	defer file_close(*files.in);

	out_file, out_success := file_open(out_filename, for_writing=true, keep_existing_content=false);
	if !out_success then return;
	files.out = out_file;
	defer file_close(*files.out);

	decoder := FLAC__stream_decoder_new();
	defer FLAC__stream_decoder_delete(decoder);

	FLAC__stream_decoder_set_md5_checking(decoder, 1);
	init_status := FLAC__stream_decoder_init_stream(decoder, read_proc, seek_proc, tell_proc, length_proc, eof_proc, write_proc, metadata_proc, error_proc, *files);
	if init_status != .FLAC__STREAM_DECODER_INIT_STATUS_OK {
		log("FLAC__stream_decoder_init_stream() failed: %: %", init_status, FLAC__StreamDecoderInitStatusString[init_status], flags=.ERROR);
		return;
	}

	ok := FLAC__stream_decoder_process_until_end_of_stream(decoder);
	if !ok {
		state := FLAC__stream_decoder_get_state(decoder);
		log("FLAC__stream_decoder_process_until_end_of_stream() failed: %: %", state, FLAC__StreamDecoderStateString[state], flags=.ERROR);
	}
}


#scope_file;

In_Out :: struct {
	in: File;
	out: File;
}

read_proc :: (decoder: *FLAC__StreamDecoder, buffer: *u8, bytes: *u64, client_data: *void) -> FLAC__StreamDecoderReadStatus #c_call {
	push_context {
		in_out := cast(*In_Out) client_data;
		file := cast(*File) *in_out.in;

		requested_bytes := bytes.*;
		success, got := file_read(file.*, buffer, xx requested_bytes);
		if !success then return .FLAC__STREAM_DECODER_READ_STATUS_ABORT;
		bytes.* = xx got;
		if xx got == requested_bytes {
			return .FLAC__STREAM_DECODER_READ_STATUS_CONTINUE;
		} else {
			return .FLAC__STREAM_DECODER_READ_STATUS_END_OF_STREAM;
		}
	}
}

seek_proc :: (decoder: *FLAC__StreamDecoder, absolute_byte_offset: u64, client_data: *void) -> FLAC__StreamDecoderSeekStatus #c_call {
	push_context {
		in_out := cast(*In_Out) client_data;
		file := cast(*File) *in_out.in;

		file_set_position(file.*, xx absolute_byte_offset);
		return .FLAC__STREAM_DECODER_SEEK_STATUS_OK;
	}
}

tell_proc :: (decoder: *FLAC__StreamDecoder, absolute_byte_offset: *u64, client_data: *void) -> FLAC__StreamDecoderTellStatus #c_call {
	push_context {
		in_out := cast(*In_Out) client_data;
		file := cast(*File) *in_out.in;

		current_position := file_current_position(file.*);
		absolute_byte_offset.* = xx current_position;
		return .FLAC__STREAM_DECODER_TELL_STATUS_OK;
	}
}

length_proc :: (decoder: *FLAC__StreamDecoder, stream_length: *u64, client_data: *void) -> FLAC__StreamDecoderLengthStatus #c_call {
	push_context {
		in_out := cast(*In_Out) client_data;
		file := cast(*File) *in_out.in;

		length := file_length(file.*);
		stream_length.* = xx length;
		return .FLAC__STREAM_DECODER_LENGTH_STATUS_OK;
	}
}

eof_proc :: (decoder: *FLAC__StreamDecoder, client_data: *void) -> FLAC__bool #c_call {
	push_context {
		in_out := cast(*In_Out) client_data;
		file := cast(*File) *in_out.in;

		length := file_length(file.*);
		current_position := file_current_position(file.*);
		return xx (current_position >= length);
	}
}

write_proc :: (decoder: *FLAC__StreamDecoder, frame: *FLAC__Frame, buffer: **s32, client_data: *void) -> FLAC__StreamDecoderWriteStatus #c_call {
	push_context {
		in_out := cast(*In_Out) client_data;
		file := cast(*File) *in_out.out;

		for 0..frame.header.blocksize-1 {
			L := buffer[0];
			R : *s32;
			// There could be more than 2 channels, but here we're just using two.
			if channels == 1 {
				// Mono - duplicate to make two channels.
				R = buffer[0];
			} else {
				// Stereo
				R = buffer[1];
			}

			file_write(file, *L[it], bps/8);
			file_write(file, *R[it], bps/8);
		}

		return .FLAC__STREAM_DECODER_WRITE_STATUS_CONTINUE;
		// or ..
		//return FLAC__STREAM_DECODER_WRITE_STATUS_ABORT;
		// ... if there was an error
	}
}

// The metadata callback sets these for the write callback to use.
channels: u32;
bps: u32;

metadata_proc :: (decoder: *FLAC__StreamDecoder, metadata: *FLAC__StreamMetadata, client_data: *void) #c_call {
	push_context {
		if metadata.type == .FLAC__METADATA_TYPE_STREAMINFO {
			print("total samples: %\n", metadata.data.stream_info.total_samples);
			print("sample rate  : %\n", metadata.data.stream_info.sample_rate);
			print("channels     : %\n", metadata.data.stream_info.channels);
			print("bps          : %\n", metadata.data.stream_info.bits_per_sample);

			channels = metadata.data.stream_info.channels;
			bps = metadata.data.stream_info.bits_per_sample;
		}
	}
}

error_proc :: (decoder: *FLAC__StreamDecoder, status: FLAC__StreamDecoderErrorStatus, client_data: *void) #c_call {
	push_context {
		log("FLAC decode error: %", status, flags=.ERROR);
	}
}

#import "FLAC";

#import "Basic"; // for print
#import "File";
