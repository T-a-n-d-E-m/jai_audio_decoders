/********************************************************************
 *                                                                  *
 * THIS FILE IS PART OF THE OggVorbis SOFTWARE CODEC SOURCE CODE.   *
 * USE, DISTRIBUTION AND REPRODUCTION OF THIS LIBRARY SOURCE IS     *
 * GOVERNED BY A BSD-STYLE SOURCE LICENSE INCLUDED WITH THIS SOURCE *
 * IN 'COPYING'. PLEASE READ THESE TERMS BEFORE DISTRIBUTING.       *
 *                                                                  *
 * THE OggVorbis SOURCE CODE IS (C) COPYRIGHT 1994-2007             *
 * by the Xiph.Org Foundation https://xiph.org/                     *
 *                                                                  *
 ********************************************************************

 function: stdio-based convenience library for opening/seeking/decoding

 ********************************************************************/

/* The function prototypes for the callbacks are basically the same as for
 * the stdio functions fread, fseek, fclose, ftell.
 * The one difference is that the FILE * arguments have been replaced with
 * a void * - this is to be used as a pointer to whatever internal data these
 * functions might need. In the stdio case, it's just a FILE * cast to a void *
 *
 * If you use other functions, check the docs for these functions and return
 * the right values. For seek_func(), you *MUST* return -1 if the stream is
 * unseekable
 */
ov_callbacks :: struct {
	read_proc  : #type (ptr: *void, size: u64, nmemb: u64, datasource: *void) -> u64 #c_call;
	seek_proc  : #type (datasource: *void, offset: s64, whence: s32) -> s32 #c_call;
	close_proc : #type (datasource: *void) -> s32 #c_call;
	tell_proc  : #type (datasource: *void) -> s64 #c_call;
}

/* @TODO: Make Jai versions of these?
#ifndef OV_EXCLUDE_STATIC_CALLBACKS

/* a few sets of convenient callbacks, especially for use under
 * Windows where ov_open_callbacks() should always be used instead of
 * ov_open() to avoid problems with incompatible crt.o version linking
 * issues. */

static s32 _ov_header_fseek_wrap(FILE *f,s64 off,s32 whence){
  if(f==NULL)return(-1);

#ifdef __MINGW32__
  return fseeko64(f,off,whence);
#elif defined (_WIN32)
  return _fseeki64(f,off,whence);
#else
  return fseek(f,off,whence);
#endif
}

/* These structs below (OV_CALLBACKS_DEFAULT etc) are defined here as
 * static data. That means that every file which includes this header
 * will get its own copy of these structs whether it uses them or
 * not unless it #defines OV_EXCLUDE_STATIC_CALLBACKS.
 * These static symbols are essential on platforms such as Windows on
 * which several different versions of stdio support may be linked to
 * by different DLLs, and we need to be certain we know which one
 * we're using (the same one as the main application).
 */

static ov_callbacks OV_CALLBACKS_DEFAULT = {
  (size_t (*)(void *, size_t, size_t, void *))  fread,
  (s32 (*)(void *, s64, s32))           _ov_header_fseek_wrap,
  (s32 (*)(void *))                             fclose,
  (s64 (*)(void *))                            ftell
};

static ov_callbacks OV_CALLBACKS_NOCLOSE = {
  (size_t (*)(void *, size_t, size_t, void *))  fread,
  (s32 (*)(void *, s64, s32))           _ov_header_fseek_wrap,
  (s32 (*)(void *))                             NULL,
  (s64 (*)(void *))                            ftell
};

static ov_callbacks OV_CALLBACKS_STREAMONLY = {
  (size_t (*)(void *, size_t, size_t, void *))  fread,
  (s32 (*)(void *, s64, s32))           NULL,
  (s32 (*)(void *))                             fclose,
  (s64 (*)(void *))                            NULL
};

static ov_callbacks OV_CALLBACKS_STREAMONLY_NOCLOSE = {
  (size_t (*)(void *, size_t, size_t, void *))  fread,
  (s32 (*)(void *, s64, s32))           NULL,
  (s32 (*)(void *))                             NULL,
  (s64 (*)(void *))                            NULL
};

#endif
*/

NOTOPEN   :: 0;
PARTOPEN  :: 1;
OPENED    :: 2;
STREAMSET :: 3;
INITSET   :: 4;

OggVorbis_File :: struct {
	datasource: *void; /* Pointer to a FILE *, etc. */
	seekable: s32;
	offset: s64;
	end: s64;
	oy: ogg_sync_state;

	/* If the FILE handle isn't seekable (eg, a pipe), only the current stream appears */
	links: s32;
	offsets: *s64;
	dataoffsets: *s64;
	serialnos: *s64;
	pcmlengths: *s64; /* overloaded to maintain binary compatibility; x2 size, stores both beginning and end values */
	vi: *vorbis_info;
	vc: *vorbis_comment;

	/* Decoding working state local storage */
	pcm_offset: s64;
	ready_state: s32;
	current_serialno: s64;
	current_link: s32;

	bittrack: float64;
	samptrack: float64;

	os: ogg_stream_state; /* take physical pages, weld into a logical stream of packets */
	vd: vorbis_dsp_state; /* central working state for the packet->PCM decoder */
	vb: vorbis_block; /* local working space for packet->PCM decode */

	callbacks: ov_callbacks;
}


ov_clear :: (vf: *OggVorbis_File) -> s32 #foreign vorbis;
ov_fopen :: (path: *u8, vf: *OggVorbis_File) -> s32 #foreign vorbis;
//ov_open :: (f: *FILE,vf: *OggVorbis_File,initial: *u8,ibytes: s64) -> s32 #foreign vorbis;
ov_open_callbacks :: (datasource: *void, vf: *OggVorbis_File, initial: *u8, ibytes: s64, callbacks: ov_callbacks) -> s32 #foreign vorbis;

//ov_test :: (f: *FILE, vf: *OggVorbis_File,initial: *u8,ibytes: s64) -> s32 #foreign vorbis;
ov_test_callbacks :: (datasource: *void, vf: *OggVorbis_File, initial: *u8, ibytes: s64, callbacks: ov_callbacks) -> s32 #foreign vorbis;
ov_test_open :: (vf: *OggVorbis_File) -> s32 #foreign vorbis;

ov_bitrate :: (vf: *OggVorbis_File,i: s32) -> s64 #foreign vorbis;
ov_bitrate_instant :: (vf: *OggVorbis_File) -> s64 #foreign vorbis;
ov_streams :: (vf: *OggVorbis_File) -> s64 #foreign vorbis;
ov_seekable :: (vf: *OggVorbis_File) -> s64 #foreign vorbis;
ov_serialnumber :: (vf: *OggVorbis_File,i: s32) -> s64 #foreign vorbis;

ov_raw_total :: (vf: *OggVorbis_File,i: s32) -> s64 #foreign vorbis;
ov_pcm_total :: (vf: *OggVorbis_File,i: s32) -> s64 #foreign vorbis;
ov_time_total :: (vf: *OggVorbis_File,i: s32) -> float64 #foreign vorbis;

ov_raw_seek :: (vf: *OggVorbis_File,pos: s64) -> s32 #foreign vorbis;
ov_pcm_seek :: (vf: *OggVorbis_File,pos: s64) -> s32 #foreign vorbis;
ov_pcm_seek_page :: (vf: *OggVorbis_File,pos: s64) -> s32 #foreign vorbis;
ov_time_seek :: (vf: *OggVorbis_File,pos: float64) -> s32 #foreign vorbis;
ov_time_seek_page :: (vf: *OggVorbis_File,pos: float64) -> s32 #foreign vorbis;

ov_raw_seek_lap :: (vf: *OggVorbis_File,pos: s64) -> s32 #foreign vorbis;
ov_pcm_seek_lap :: (vf: *OggVorbis_File,pos: s64) -> s32 #foreign vorbis;
ov_pcm_seek_page_lap :: (vf: *OggVorbis_File,pos: s64) -> s32 #foreign vorbis;
ov_time_seek_lap :: (vf: *OggVorbis_File,pos: float64) -> s32 #foreign vorbis;
ov_time_seek_page_lap :: (vf: *OggVorbis_File,pos: float64) -> s32 #foreign vorbis;

ov_raw_tell :: (vf: *OggVorbis_File) -> s64 #foreign vorbis;
ov_pcm_tell :: (vf: *OggVorbis_File) -> s64 #foreign vorbis;
ov_time_tell :: (vf: *OggVorbis_File) -> float64 #foreign vorbis;

ov_info :: (vf: *OggVorbis_File,link: s32) -> *vorbis_info #foreign vorbis;
ov_comment :: (vf: *OggVorbis_File,link: s32) -> *vorbis_comment #foreign vorbis;

ov_read_float :: (vf: *OggVorbis_File,pcm_channels: ***float32,samples: s32, bitstream: *s32) -> s64 #foreign vorbis;
ov_read_filter_proc :: #type (pcm: **float32, channels: s64, samples: s64, filter_param: *void) #c_call;
ov_read_filter :: (vf: *OggVorbis_File, buffer: *u8, length: s32, bigendianp: s32, word: s32, sgned: s32, bitstream: *s32, filter: ov_read_filter_proc, filter_param: *void) -> s64 #foreign vorbis;
ov_read :: (vf: *OggVorbis_File,buffer: *u8,length: s32, bigendianp: s32,word: s32,sgned: s32,bitstream: *s32) -> s64 #foreign vorbis;
ov_crosslap :: (vf1: *OggVorbis_File,vf2: *OggVorbis_File) -> s32 #foreign vorbis;

ov_halfrate :: (vf: *OggVorbis_File,flag: s32) -> s32 #foreign vorbis;
ov_halfrate_p :: (vf: *OggVorbis_File) -> s32 #foreign vorbis;
