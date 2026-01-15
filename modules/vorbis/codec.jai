/********************************************************************
 *                                                                  *
 * THIS FILE IS PART OF THE OggVorbis SOFTWARE CODEC SOURCE CODE.   *
 * USE, DISTRIBUTION AND REPRODUCTION OF THIS LIBRARY SOURCE IS     *
 * GOVERNED BY A BSD-STYLE SOURCE LICENSE INCLUDED WITH THIS SOURCE *
 * IN 'COPYING'. PLEASE READ THESE TERMS BEFORE DISTRIBUTING.       *
 *                                                                  *
 * THE OggVorbis SOURCE CODE IS (C) COPYRIGHT 1994-2001             *
 * by the Xiph.Org Foundation https://xiph.org/                     *

 ********************************************************************

 function: libvorbis codec headers

 ********************************************************************/

#import "ogg";

vorbis_info :: struct {
	version: s32;
	channels: s32;
	rate: s64;

  /* The below bitrate declarations are *hints*.
     Combinations of the three values carry the following implications:

     all three set to the same value:
       implies a fixed rate bitstream
     only nominal set:
       implies a VBR stream that averages the nominal bitrate.  No hard
       upper/lower limit
     upper and or lower set:
       implies a VBR bitstream that obeys the bitrate limits. nominal
       may also be set to give a nominal rate.
     none set:
       the coder does not care to speculate.
  */

  bitrate_upper: s64;
  bitrate_nominal: s64;
  bitrate_lower: s64;
  bitrate_window: s64;

  codec_setup: *void;
}

/* vorbis_dsp_state buffers the current vorbis audio
   analysis/synthesis state.  The DSP state belongs to a specific
   logical bitstream ****************************************************/
vorbis_dsp_state :: struct {
	analysisp: s32;
	vi: *vorbis_info;

	pcm: **float32;
	pcmret: **float32;
	pcm_storage: s32;
	pcm_current: s32;
	pcm_returned: s32;

	preextrapolate: s32;
	eofflag: s32;

	lW: s64;
	W: s64;
	nW: s64;
	centerW: s64;

	granulepos: s64;
	sequence: s64;

	glue_bits: s64;
	time_bits: s64;;
	floor_bits: s64;
	res_bits: s64;

	backend_state: *void;
}

vorbis_block :: struct {
  /* necessary stream state for linking to the framing abstraction */
	pcm: **float32;       /* this is a pointer into local storage */
	opb: oggpack_buffer;

	lW: s64;
	W: s64;
	nW: s64;
	pcmend: s32;
	mode: s32;

	eofflag: s32;
	granulepos: s64;
	sequence: s64;
	vd: *vorbis_dsp_state; /* For read-only access of configuration */

	/* local storage to avoid remallocing; it's up to the mapping to structure it */
	localstore: *void;
	localtop: s64;
	localalloc: s64;
	totaluse: s64;
	reap: *alloc_chain;

	/* bitmetrics for the frame */
	glue_bits: s64;
	time_bits: s64;
	floor_bits: s64;
	res_bits: s64;

	internal: *void;
}

/* vorbis_block is a single block of data to be processed as part of
the analysis/synthesis stream; it belongs to a specific logical
bitstream, but is independent from other vorbis_blocks belonging to
that logical bitstream. *************************************************/

alloc_chain :: struct {
	ptr: *void;
	next: *alloc_chain;
};

/* vorbis_info contains all the setup information specific to the
   specific compression/decompression mode in progress (eg,
   psychoacoustic settings, channel setup, options, codebook
   etc). vorbis_info and substructures are in backends.h.
*********************************************************************/

/* the comments are not part of vorbis_info so that vorbis_info can be
   static storage */
vorbis_comment :: struct {
	/* unlimited user comment fields.  libvorbis writes 'libvorbis'
     whatever vendor is set to in encode */
	user_comments: **u8;
	comment_lengths: *s32;
	comments: s32;
	vendor: *u8;
}


/* libvorbis encodes in two abstraction layers; first we perform DSP
   and produce a packet (see docs/analysis.txt).  The packet is then
   coded into a framed OggSquish bitstream by the second layer (see
   docs/framing.txt).  Decode is the reverse process; we sync/frame
   the bitstream and extract individual packets, then decode the
   packet back into PCM audio.

   The extra framing/packetizing is used in streaming formats, such as
   files.  Over the net (such as with UDP), the framing and
   packetization aren't necessary as they're provided by the transport
   and the streaming layer is not used */

/* Vorbis PRIMITIVES: general ***************************************/

vorbis_info_init :: (vi: *vorbis_info) -> void     #foreign vorbis;
vorbis_info_clear :: (vi: *vorbis_info) -> void     #foreign vorbis;
vorbis_info_blocksize :: (vi: *vorbis_info, zo: s32) -> int      #foreign vorbis;
vorbis_comment_init :: (vc: *vorbis_comment) -> void     #foreign vorbis;
vorbis_comment_add :: (vc: *vorbis_comment, comment: *u8) -> void     #foreign vorbis;
vorbis_comment_add_tag :: (vc: *vorbis_comment, tag: *u8, contents: *u8) -> void     #foreign vorbis;
vorbis_comment_query :: (vc: *vorbis_comment, tag: *u8, count: s32) -> *u8 #foreign vorbis;
vorbis_comment_query_count :: (vc: *vorbis_comment, tag: *u8) -> int      #foreign vorbis;
vorbis_comment_clear :: (vc: *vorbis_comment) -> void     #foreign vorbis;

vorbis_block_init :: (v: *vorbis_dsp_state, vb: *vorbis_block) -> int      #foreign vorbis;
vorbis_block_clear :: (vb: *vorbis_block) -> int      #foreign vorbis;
vorbis_dsp_clear :: (v: *vorbis_dsp_state) -> void     #foreign vorbis;
vorbis_granule_time :: (v: *vorbis_dsp_state, granulepos: s64) -> float64   #foreign vorbis;

vorbis_version_string :: () -> *u8 #foreign vorbis;

/* Vorbis PRIMITIVES: analysis/DSP layer ****************************/

vorbis_analysis_init :: (v: *vorbis_dsp_state,vi: *vorbis_info) -> int      #foreign vorbis;
vorbis_commentheader_out :: (vc: *vorbis_comment, op: *ogg_packet) -> int      #foreign vorbis;
vorbis_analysis_headerout :: (v: *vorbis_dsp_state, vc: *vorbis_comment, op: *ogg_packet, op_comm: *ogg_packet, op_code: *ogg_packet) -> int      #foreign vorbis;
vorbis_analysis_buffer :: (v: *vorbis_dsp_state,vals: s32) -> **float #foreign vorbis;
vorbis_analysis_wrote :: (v: *vorbis_dsp_state,vals: s32) -> int      #foreign vorbis;
vorbis_analysis_blockout :: (v: *vorbis_dsp_state,vb: *vorbis_block) -> int      #foreign vorbis;
vorbis_analysis :: (vb: *vorbis_block,op: *ogg_packet) -> int      #foreign vorbis;

vorbis_bitrate_addblock :: (vb: *vorbis_block) -> int      #foreign vorbis;
vorbis_bitrate_flushpacket :: (v: *vorbis_dsp_state, op: *ogg_packet) -> int      #foreign vorbis;

/* Vorbis PRIMITIVES: synthesis layer *******************************/
vorbis_synthesis_idheader :: (op: *ogg_packet) -> int      #foreign vorbis;
vorbis_synthesis_headerin :: (vi: *vorbis_info,vc: *vorbis_comment, op: *ogg_packet) -> int      #foreign vorbis;

vorbis_synthesis_init :: (v: *vorbis_dsp_state,vi: *vorbis_info) -> int      #foreign vorbis;
vorbis_synthesis_restart :: (v: *vorbis_dsp_state) -> int      #foreign vorbis;
vorbis_synthesis :: (vb: *vorbis_block,op: *ogg_packet) -> int      #foreign vorbis;
vorbis_synthesis_trackonly :: (vb: *vorbis_block,op: *ogg_packet) -> int      #foreign vorbis;
vorbis_synthesis_blockin :: (v: *vorbis_dsp_state,vb: *vorbis_block) -> int      #foreign vorbis;
vorbis_synthesis_pcmout :: (v: *vorbis_dsp_state, pcm: ***float32) -> int      #foreign vorbis;
vorbis_synthesis_lapout :: (v: *vorbis_dsp_state ,pcm: ***float32) -> int      #foreign vorbis;
vorbis_synthesis_read :: (v: *vorbis_dsp_state, samples: s32) -> int      #foreign vorbis;
vorbis_packet_blocksize :: (vi: *vorbis_info, op: *ogg_packet) -> s64     #foreign vorbis;

vorbis_synthesis_halfrate :: (v: *vorbis_info, flag: s32) -> int      #foreign vorbis;
vorbis_synthesis_halfrate_p :: (v: *vorbis_info) -> int      #foreign vorbis;

/* Vorbis ERRORS and return codes ***********************************/

OV_FALSE      :: -1;
OV_EOF        :: -2;
OV_HOLE       :: -3;

OV_EREAD      :: -128;
OV_EFAULT     :: -129;
OV_EIMPL      :: -130;
OV_EINVAL     :: -131;
OV_ENOTVORBIS :: -132;
OV_EBADHEADER :: -133;
OV_EVERSION   :: -134;
OV_ENOTAUDIO  :: -135;
OV_EBADPACKET :: -136;
OV_EBADLINK   :: -137;
OV_ENOSEEK    :: -138;

