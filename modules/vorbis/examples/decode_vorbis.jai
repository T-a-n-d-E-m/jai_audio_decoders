// Read am .ogg Vorbis file and write the raw PCM values out to a file.
// The output can be verified with Audacity using Import->Raw Data
decode_vorbis_file :: (in_file: string, out_file: string) {
	print("Vorbis: %\n", to_string(vorbis_version_string()));

	in_file, in_success := file_open(in_file);
	if !in_success then return;
	defer file_close(*in_file); // The Vorbis callback functions can also be used to close the file when finished.

	out_file, out_success := file_open(out_file, for_writing=true, keep_existing_content=false);
	if !out_success then return;
	defer file_close(*out_file);

	callbacks: ov_callbacks = {read_proc, seek_proc, close_proc, tell_proc};
	vf: OggVorbis_File;
	if ov_open_callbacks(xx *in_file, *vf, null, 0, callbacks) < 0 {
		log("Error opening OGG Vorbis file\n", flags=.ERROR);
		return;
	}

	// Some info about the file
	info := ov_info(*vf, 0);
	print("Info: version:%, channels:%, rate:%\n", info.version, info.channels, info.rate);

	comments := ov_comment(*vf, -1);
	print("Vendor:%\n", to_string(comments.vendor));
	for 0..comments.comments-1 {
		ptr := comments.user_comments[it];
		print("comment:%\n", to_string(ptr));
	}
	print("Decoded length: % samples\n", ov_pcm_total(*vf, -1));

	done := false;
	current_section: s32;
	pcm_out: [4096] u8;
	while !done {
		got := ov_read(*vf, pcm_out.data, pcm_out.count, 0, 2, 1, *current_section);
		if got == 0 {
			done = true;
		} else if got < 0 {
			if got == OV_EBADLINK {
				// Corrupt bitstream. Can't process this file any longer
				log("corrupt bitstream", flags=.ERROR);
				done = true;
			} else {
				// Some other (recoverable) error, don't stop decoding.
			}
		} else {
			// Decode OK - Do something with the samples
			file_write(*out_file, pcm_out.data, got);
		}
	}

	ov_clear(*vf);
}


#scope_file;

read_proc  :: (ptr: *void, size: u64, nmemb: u64, datasource: *void) -> u64 #c_call {
	push_context {
		file := cast(*File) datasource;
		success, got := file_read(file.*, ptr, cast(s64)(size*nmemb));
		if !success {
			// Some error handling would be nice!
			log("read_proc error", flags=.ERROR);
		}

		return xx got;
	}
}

seek_proc  :: (datasource: *void, offset: s64, whence: s32) -> s32 #c_call {
	push_context {
		file := cast(*File) datasource;
		if whence == {
			case 0; /* SEEK_SET */
				file_set_position(file.*, offset);

			case 1; /* SEEK_CUR */
				current := file_current_position(file.*);
				file_set_position(file.*, current - offset);

			case 2; /* SEEK_END */
				size := file_length(file.*);
				file_set_position(file.*, size);
		}

		return xx file_current_position(file.*);
	}
}

tell_proc  :: (datasource: *void) -> s64 #c_call {
	push_context {
		file := cast(*File) datasource;
		return file_current_position(file.*);
	}
}

close_proc :: (datasource: *void) -> s32 #c_call {
	push_context {
		file := cast(*File) datasource;
		file_close(file);

		return 0;
	}
}

#import "vorbis";

#import "Basic"; // for print
#import "File";
