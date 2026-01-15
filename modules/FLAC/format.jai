/* libFLAC - Free Lossless Audio Codec library
 * Copyright (C) 2000-2009  Josh Coalson
 * Copyright (C) 2011-2025  Xiph.Org Foundation
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *
 * - Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *
 * - Neither the name of the Xiph.org Foundation nor the names of its
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE FOUNDATION OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/** \file include/FLAC/format.h
 *
 *  \brief
 *  This module contains structure definitions for the representation
 *  of FLAC format components in memory.  These are the basic
 *  structures used by the rest of the interfaces.
 *
 *  See the detailed documentation in the
 *  \link flac_format format \endlink module.
 */

/** \defgroup flac_format FLAC/format.h: format components
 *  \ingroup flac
 *
 *  \brief
 *  This module contains structure definitions for the representation
 *  of FLAC format components in memory.  These are the basic
 *  structures used by the rest of the interfaces.
 *
 *  First, you should be familiar with the
 *  <A HREF="https://xiph.org/flac/format.html">FLAC format</A>.  Many of the values here
 *  follow directly from the specification.  As a user of libFLAC, the
 *  interesting parts really are the structures that describe the frame
 *  header and metadata blocks.
 *
 *  The format structures here are very primitive, designed to store
 *  information in an efficient way.  Reading information from the
 *  structures is easy but creating or modifying them directly is
 *  more complex.  For the most part, as a user of a library, editing
 *  is not necessary; however, for metadata blocks it is, so there are
 *  convenience functions provided in the \link flac_metadata metadata
 *  module \endlink to simplify the manipulation of metadata blocks.
 *
 * \note
 * It's not the best convention, but symbols ending in _LEN are in bits
 * and _LENGTH are in bytes.  _LENGTH symbols are \#defines instead of
 * global variables because they are usually used when declaring byte
 * arrays and some compilers require compile-time knowledge of array
 * sizes when declared on the stack.
 *
 * \{
 */


/*
	Most of the values described in this file are defined by the FLAC
	format specification.  There is nothing to tune here.
*/

/** The largest legal metadata type code. */
FLAC__MAX_METADATA_TYPE_CODE :: 126;

/** The minimum block size, in samples, permitted by the format. */
FLAC__MIN_BLOCK_SIZE :: 16;

/** The maximum block size, in samples, permitted by the format. */
FLAC__MAX_BLOCK_SIZE :: 65535;

/** The maximum block size, in samples, permitted by the FLAC subset for
 *  sample rates up to 48kHz. */
FLAC__SUBSET_MAX_BLOCK_SIZE_48000HZ :: 4608;

/** The maximum number of channels permitted by the format. */
FLAC__MAX_CHANNELS :: 8;

/** The minimum sample resolution permitted by the format. */
FLAC__MIN_BITS_PER_SAMPLE :: 4;

/** The maximum sample resolution permitted by the format. */
FLAC__MAX_BITS_PER_SAMPLE :: 32;

/** The maximum sample resolution permitted by libFLAC.
 *
 * FLAC__MAX_BITS_PER_SAMPLE is the limit of the FLAC format.  However,
 * the reference encoder/decoder used to be limited to 24 bits. This
 * value was used to signal that limit.
 */
FLAC__REFERENCE_CODEC_MAX_BITS_PER_SAMPLE :: 32;

/** The maximum sample rate permitted by the format.  The value is
 *  ((2 ^ 20) - 1)
 */
FLAC__MAX_SAMPLE_RATE :: 1048575;

/** The maximum LPC order permitted by the format. */
FLAC__MAX_LPC_ORDER :: 32;

/** The maximum LPC order permitted by the FLAC subset for sample rates
 *  up to 48kHz. */
FLAC__SUBSET_MAX_LPC_ORDER_48000HZ :: 12;

/** The minimum quantized linear predictor coefficient precision
 *  permitted by the format.
 */
FLAC__MIN_QLP_COEFF_PRECISION :: 5;

/** The maximum quantized linear predictor coefficient precision
 *  permitted by the format.
 */
FLAC__MAX_QLP_COEFF_PRECISION :: 15;

/** The maximum order of the fixed predictors permitted by the format. */
FLAC__MAX_FIXED_ORDER :: 4;

/** The maximum Rice partition order permitted by the format. */
FLAC__MAX_RICE_PARTITION_ORDER :: 15;

/** The maximum Rice partition order permitted by the FLAC Subset. */
FLAC__SUBSET_MAX_RICE_PARTITION_ORDER :: 8;

/** The version string of the release, stamped onto the libraries and binaries.
 *
 * \note
 * This does not correspond to the shared library version number, which
 * is used to determine binary compatibility.
 */
 FLAC__VERSION_STRING: *u8 #elsewhere flac;

/** The vendor string inserted by the encoder into the VORBIS_COMMENT block.
 *  This is a NUL-terminated ASCII string; when inserted into the
 *  VORBIS_COMMENT the trailing null is stripped.
 */
 FLAC__VENDOR_STRING: *u8 #elsewhere flac;

/** The byte string representation of the beginning of a FLAC stream. */
FLAC__STREAM_SYNC_STRING: [4] u8 #elsewhere flac; /* = "fLaC" */

/** The 32-bit integer big-endian representation of the beginning of
 *  a FLAC stream.
 */
FLAC__STREAM_SYNC: u32 #elsewhere flac; /* = 0x664C6143 */

/** The length of the FLAC signature in bits. */
FLAC__STREAM_SYNC_LEN: u32 #elsewhere flac; /* = 32 bits */

/** The length of the FLAC signature in bytes. */
FLAC__STREAM_SYNC_LENGTH :: 4;


/*****************************************************************************
 *
 * Subframe structures
 *
 *****************************************************************************/

/*****************************************************************************/

/** An enumeration of the available entropy coding methods. */
FLAC__EntropyCodingMethodType :: enum {
	FLAC__ENTROPY_CODING_METHOD_PARTITIONED_RICE :: 0;
	/**< Residual is coded by partitioning into contexts, each with it's own
	 * 4-bit Rice parameter. */

	 FLAC__ENTROPY_CODING_METHOD_PARTITIONED_RICE2 :: 1;
	/**< Residual is coded by partitioning into contexts, each with it's own
	 * 5-bit Rice parameter. */
}

/** Maps a FLAC__EntropyCodingMethodType to a C string.
 *
 *  Using a FLAC__EntropyCodingMethodType as the index to this array will
 *  give the string equivalent.  The contents should not be modified.
 */
FLAC__EntropyCodingMethodTypeString: [] *u8;


/** Contents of a Rice partitioned residual
 */
FLAC__EntropyCodingMethod_PartitionedRiceContents :: struct {
	parameters: *u32;
	/**< The Rice parameters for each context. */

	raw_bits: *u32;
	/**< Widths for escape-coded partitions.  Will be non-zero for escaped
	 * partitions and zero for unescaped partitions.
	 */

	capacity_by_order: u32;
	/**< The capacity of the \a parameters and \a raw_bits arrays
	 * specified as an order, i.e. the number of array elements
	 * allocated is 2 ^ \a capacity_by_order.
	 */
}

/** Header for a Rice partitioned residual.  (c.f. <A HREF="https://xiph.org/flac/format.html#partitioned_rice">format specification</A>)
 */
FLAC__EntropyCodingMethod_PartitionedRice :: struct {
	order: u32;
	/**< The partition order, i.e. # of contexts = 2 ^ \a order. */

	contents: *FLAC__EntropyCodingMethod_PartitionedRiceContents;
	/**< The context's Rice parameters and/or raw bits. */

}

FLAC__ENTROPY_CODING_METHOD_PARTITIONED_RICE_ORDER_LEN: u32 #elsewhere flac; /**< == 4 (bits) */
FLAC__ENTROPY_CODING_METHOD_PARTITIONED_RICE_PARAMETER_LEN: u32 #elsewhere flac; /**< == 4 (bits) */
FLAC__ENTROPY_CODING_METHOD_PARTITIONED_RICE2_PARAMETER_LEN: u32 #elsewhere flac; /**< == 5 (bits) */
FLAC__ENTROPY_CODING_METHOD_PARTITIONED_RICE_RAW_LEN: u32 #elsewhere flac; /**< == 5 (bits) */

FLAC__ENTROPY_CODING_METHOD_PARTITIONED_RICE_ESCAPE_PARAMETER: u32 #elsewhere flac;
/**< == (1<<FLAC__ENTROPY_CODING_METHOD_PARTITIONED_RICE_PARAMETER_LEN)-1 */
FLAC__ENTROPY_CODING_METHOD_PARTITIONED_RICE2_ESCAPE_PARAMETER: u32 #elsewhere flac;
/**< == (1<<FLAC__ENTROPY_CODING_METHOD_PARTITIONED_RICE2_PARAMETER_LEN)-1 */

/** Header for the entropy coding method.  (c.f. <A HREF="https://xiph.org/flac/format.html#residual">format specification</A>)
 */
FLAC__EntropyCodingMethod :: struct {
	type: FLAC__EntropyCodingMethodType;
	data : union {
		partitioned_rice: FLAC__EntropyCodingMethod_PartitionedRice;
	}
}

FLAC__ENTROPY_CODING_METHOD_TYPE_LEN: u32 #elsewhere flac; /**< == 2 (bits) */

/*****************************************************************************/

/** An enumeration of the available subframe types. */
FLAC__SubframeType :: enum {
	FLAC__SUBFRAME_TYPE_CONSTANT :: 0; /**< constant signal */
	FLAC__SUBFRAME_TYPE_VERBATIM :: 1; /**< uncompressed signal */
	FLAC__SUBFRAME_TYPE_FIXED :: 2; /**< fixed polynomial prediction */
	FLAC__SUBFRAME_TYPE_LPC :: 3; /**< linear prediction */
}

/** Maps a FLAC__SubframeType to a C string.
 *
 *  Using a FLAC__SubframeType as the index to this array will
 *  give the string equivalent.  The contents should not be modified.
 */
FLAC__SubframeTypeString: [4] *u8 #elsewhere flac;


/** CONSTANT subframe.  (c.f. <A HREF="https://xiph.org/flac/format.html#subframe_constant">format specification</A>)
 */
FLAC__Subframe_Constant :: struct {
	value: s64; /**< The constant signal value. */
}

/** An enumeration of the possible verbatim subframe data types. */
FLAC__VerbatimSubframeDataType :: enum {
	FLAC__VERBATIM_SUBFRAME_DATA_TYPE_INT32; /**< verbatim subframe has 32-bit int */
	FLAC__VERBATIM_SUBFRAME_DATA_TYPE_INT64; /**< verbatim subframe has 64-bit int */
}


/** VERBATIM subframe.  (c.f. <A HREF="https://xiph.org/flac/format.html#subframe_verbatim">format specification</A>)
 */
FLAC__Subframe_Verbatim :: struct {
	data : union {
		int32: *s32; /**< A s32 pointer to verbatim signal. */
		int64: *s64; /**< A s64 pointer to verbatim signal. */
	}
	data_type: FLAC__VerbatimSubframeDataType;
}


/** FIXED subframe.  (c.f. <A HREF="https://xiph.org/flac/format.html#subframe_fixed">format specification</A>)
 */
FLAC__Subframe_Fixed :: struct {
	entropy_coding_method: FLAC__EntropyCodingMethod;
	/**< The residual coding method. */

	order: u32;
	/**< The polynomial order. */

	warmup: [FLAC__MAX_FIXED_ORDER] s64;
	/**< Warmup samples to prime the predictor, length == order. */

	residual: *s32;
	/**< The residual signal, length == (blocksize minus order) samples. */
}


/** LPC subframe.  (c.f. <A HREF="https://xiph.org/flac/format.html#subframe_lpc">format specification</A>)
 */
FLAC__Subframe_LPC :: struct {
	entropy_coding_method: FLAC__EntropyCodingMethod;
	/**< The residual coding method. */

	order: u32;
	/**< The FIR order. */

	qlp_coeff_precision: u32;
	/**< Quantized FIR filter coefficient precision in bits. */

	quantization_level: s32;
	/**< The qlp coeff shift needed. */

	qlp_coeff: [FLAC__MAX_LPC_ORDER] s32;
	/**< FIR filter coefficients. */

	warmup: [FLAC__MAX_LPC_ORDER] s64;
	/**< Warmup samples to prime the predictor, length == order. */

	residual: *s32;
	/**< The residual signal, length == (blocksize minus order) samples. */
}

FLAC__SUBFRAME_LPC_QLP_COEFF_PRECISION_LEN: u32 #elsewhere flac; /**< == 4 (bits) */
FLAC__SUBFRAME_LPC_QLP_SHIFT_LEN: u32 #elsewhere flac; /**< == 5 (bits) */


/** FLAC subframe structure.  (c.f. <A HREF="https://xiph.org/flac/format.html#subframe">format specification</A>)
 */
FLAC__Subframe :: struct {
	type: FLAC__SubframeType;
	data : union {
		constant: FLAC__Subframe_Constant;
		fixed: FLAC__Subframe_Fixed;
		lpc: FLAC__Subframe_LPC;
		verbatim: FLAC__Subframe_Verbatim;
	}
	wasted_bits: u32;
}

/** == 1 (bit)
 *
 * This used to be a zero-padding bit (hence the name
 * FLAC__SUBFRAME_ZERO_PAD_LEN) but is now a reserved bit.  It still has a
 * mandatory value of \c 0 but in the future may take on the value \c 0 or \c 1
 * to mean something else.
 */
FLAC__SUBFRAME_ZERO_PAD_LEN: u32 #elsewhere flac;
FLAC__SUBFRAME_TYPE_LEN: u32 #elsewhere flac; /**< == 6 (bits) */
FLAC__SUBFRAME_WASTED_BITS_FLAG_LEN: u32 #elsewhere flac; /**< == 1 (bit) */

FLAC__SUBFRAME_TYPE_CONSTANT_BYTE_ALIGNED_MASK: u32 #elsewhere flac; /**< = 0x00 */
FLAC__SUBFRAME_TYPE_VERBATIM_BYTE_ALIGNED_MASK: u32 #elsewhere flac; /**< = 0x02 */
FLAC__SUBFRAME_TYPE_FIXED_BYTE_ALIGNED_MASK: u32 #elsewhere flac; /**< = 0x10 */
FLAC__SUBFRAME_TYPE_LPC_BYTE_ALIGNED_MASK: u32 #elsewhere flac; /**< = 0x40 */

/*****************************************************************************/


/*****************************************************************************
 *
 * Frame structures
 *
 *****************************************************************************/

/** An enumeration of the available channel assignments. */
FLAC__ChannelAssignment :: enum {
	FLAC__CHANNEL_ASSIGNMENT_INDEPENDENT :: 0; /**< independent channels */
	FLAC__CHANNEL_ASSIGNMENT_LEFT_SIDE   :: 1; /**< left+side stereo */
	FLAC__CHANNEL_ASSIGNMENT_RIGHT_SIDE  :: 2; /**< right+side stereo */
	FLAC__CHANNEL_ASSIGNMENT_MID_SIDE    :: 3; /**< mid+side stereo */
}

/** Maps a FLAC__ChannelAssignment to a C string.
 *
 *  Using a FLAC__ChannelAssignment as the index to this array will
 *  give the string equivalent.  The contents should not be modified.
 */
FLAC__ChannelAssignmentString : [4] *u8 #elsewhere flac;

/** An enumeration of the possible frame numbering methods. */
FLAC__FrameNumberType :: enum {
	FLAC__FRAME_NUMBER_TYPE_FRAME_NUMBER; /**< number contains the frame number */
	FLAC__FRAME_NUMBER_TYPE_SAMPLE_NUMBER; /**< number contains the sample number of first sample in frame */
}

/** Maps a FLAC__FrameNumberType to a C string.
 *
 *  Using a FLAC__FrameNumberType as the index to this array will
 *  give the string equivalent.  The contents should not be modified.
 */
 FLAC__FrameNumberTypeString: [2] *u8 #elsewhere flac;


/** FLAC frame header structure.  (c.f. <A HREF="https://xiph.org/flac/format.html#frame_header">format specification</A>)
 */
FLAC__FrameHeader :: struct {
	blocksize: u32;
	/**< The number of samples per subframe. */

	sample_rate: u32;
	/**< The sample rate in Hz. */

	channels: u32;
	/**< The number of channels (== number of subframes). */

	channel_assignment: FLAC__ChannelAssignment;
	/**< The channel assignment for the frame. */

	bits_per_sample: u32;
	/**< The sample resolution. */

	number_type: FLAC__FrameNumberType;
	/**< The numbering scheme used for the frame.  As a convenience, the
	 * decoder will always convert a frame number to a sample number because
	 * the rules are complex. */

	number : union {
		frame_number: u32;
		sample_number: u64;
	}
	/**< The frame number or sample number of first sample in frame;
	 * use the \a number_type value to determine which to use. */

	crc: u8;
	/**< CRC-8 (polynomial = x^8 + x^2 + x^1 + x^0, initialized with 0)
	 * of the raw frame header bytes, meaning everything before the CRC byte
	 * including the sync code.
	 */
}

FLAC__FRAME_HEADER_SYNC : u32 #elsewhere flac; /**< == 0x3ffe; the frame header sync code */
FLAC__FRAME_HEADER_SYNC_LEN : u32 #elsewhere flac; /**< == 14 (bits) */
FLAC__FRAME_HEADER_RESERVED_LEN : u32 #elsewhere flac; /**< == 1 (bits) */
FLAC__FRAME_HEADER_BLOCKING_STRATEGY_LEN : u32 #elsewhere flac; /**< == 1 (bits) */
FLAC__FRAME_HEADER_BLOCK_SIZE_LEN : u32 #elsewhere flac; /**< == 4 (bits) */
FLAC__FRAME_HEADER_SAMPLE_RATE_LEN : u32 #elsewhere flac; /**< == 4 (bits) */
FLAC__FRAME_HEADER_CHANNEL_ASSIGNMENT_LEN : u32 #elsewhere flac; /**< == 4 (bits) */
FLAC__FRAME_HEADER_BITS_PER_SAMPLE_LEN : u32 #elsewhere flac; /**< == 3 (bits) */
FLAC__FRAME_HEADER_ZERO_PAD_LEN : u32 #elsewhere flac; /**< == 1 (bit) */
FLAC__FRAME_HEADER_CRC_LEN : u32 #elsewhere flac; /**< == 8 (bits) */


/** FLAC frame footer structure.  (c.f. <A HREF="https://xiph.org/flac/format.html#frame_footer">format specification</A>)
 */
 FLAC__FrameFooter :: struct {
	 crc: u16;
	/**< CRC-16 (polynomial = x^16 + x^15 + x^2 + x^0, initialized with
	 * 0) of the bytes before the crc, back to and including the frame header
	 * sync code.
	 */
}

FLAC__FRAME_FOOTER_CRC_LEN : u32 #elsewhere flac; /**< == 16 (bits) */


/** FLAC frame structure.  (c.f. <A HREF="https://xiph.org/flac/format.html#frame">format specification</A>)
 */
FLAC__Frame :: struct {
	header: FLAC__FrameHeader;
	subframes: [FLAC__MAX_CHANNELS] FLAC__Subframe;
	footer: FLAC__FrameFooter;
}

/*****************************************************************************/


/*****************************************************************************
 *
 * Meta-data structures
 *
 *****************************************************************************/

/** An enumeration of the available metadata block types. */
FLAC__MetadataType :: enum {
	FLAC__METADATA_TYPE_STREAMINFO :: 0;
	/**< <A HREF="https://xiph.org/flac/format.html#metadata_block_streaminfo">STREAMINFO</A> block */

	FLAC__METADATA_TYPE_PADDING :: 1;
	/**< <A HREF="https://xiph.org/flac/format.html#metadata_block_padding">PADDING</A> block */

	FLAC__METADATA_TYPE_APPLICATION :: 2;
	/**< <A HREF="https://xiph.org/flac/format.html#metadata_block_application">APPLICATION</A> block */

	FLAC__METADATA_TYPE_SEEKTABLE :: 3;
	/**< <A HREF="https://xiph.org/flac/format.html#metadata_block_seektable">SEEKTABLE</A> block */

	FLAC__METADATA_TYPE_VORBIS_COMMENT :: 4;
	/**< <A HREF="https://xiph.org/flac/format.html#metadata_block_vorbis_comment">VORBISCOMMENT</A> block (a.k.a. FLAC tags) */

	FLAC__METADATA_TYPE_CUESHEET :: 5;
	/**< <A HREF="https://xiph.org/flac/format.html#metadata_block_cuesheet">CUESHEET</A> block */

	FLAC__METADATA_TYPE_PICTURE :: 6;
	/**< <A HREF="https://xiph.org/flac/format.html#metadata_block_picture">PICTURE</A> block */

	FLAC__METADATA_TYPE_UNDEFINED :: 7;
	/**< marker to denote beginning of undefined type range; this number will increase as new metadata types are added */

	FLAC__MAX_METADATA_TYPE :: FLAC__MAX_METADATA_TYPE_CODE;
	/**< No type will ever be greater than this. There is not enough room in the protocol block. */
}

/** Maps a FLAC__MetadataType to a C string.
 *
 *  Using a FLAC__MetadataType as the index to this array will
 *  give the string equivalent.  The contents should not be modified.
 */
FLAC__MetadataTypeString: [9] *u8 #elsewhere flac;


/** FLAC STREAMINFO structure.  (c.f. <A HREF="https://xiph.org/flac/format.html#metadata_block_streaminfo">format specification</A>)
 */
FLAC__StreamMetadata_StreamInfo :: struct {
	min_blocksize, max_blocksize: u32;
	min_framesize, max_framesize: u32;
	sample_rate: u32;
	channels: u32;
	bits_per_sample: u32;
	total_samples: u64;
	md5sum: [16] u8;
}

FLAC__STREAM_METADATA_STREAMINFO_MIN_BLOCK_SIZE_LEN : u32 #elsewhere flac; /**< == 16 (bits) */
FLAC__STREAM_METADATA_STREAMINFO_MAX_BLOCK_SIZE_LEN : u32 #elsewhere flac; /**< == 16 (bits) */
FLAC__STREAM_METADATA_STREAMINFO_MIN_FRAME_SIZE_LEN : u32 #elsewhere flac; /**< == 24 (bits) */
FLAC__STREAM_METADATA_STREAMINFO_MAX_FRAME_SIZE_LEN : u32 #elsewhere flac; /**< == 24 (bits) */
FLAC__STREAM_METADATA_STREAMINFO_SAMPLE_RATE_LEN : u32 #elsewhere flac; /**< == 20 (bits) */
FLAC__STREAM_METADATA_STREAMINFO_CHANNELS_LEN : u32 #elsewhere flac; /**< == 3 (bits) */
FLAC__STREAM_METADATA_STREAMINFO_BITS_PER_SAMPLE_LEN : u32 #elsewhere flac; /**< == 5 (bits) */
FLAC__STREAM_METADATA_STREAMINFO_TOTAL_SAMPLES_LEN : u32 #elsewhere flac; /**< == 36 (bits) */
FLAC__STREAM_METADATA_STREAMINFO_MD5SUM_LEN : u32 #elsewhere flac; /**< == 128 (bits) */

/** The total stream length of the STREAMINFO block in bytes. */
FLAC__STREAM_METADATA_STREAMINFO_LENGTH :: 34;

/** FLAC PADDING structure.  (c.f. <A HREF="https://xiph.org/flac/format.html#metadata_block_padding">format specification</A>)
 */
 FLAC__StreamMetadata_Padding :: struct {
	dummy: s32;
	/**< Conceptually this is an empty struct since we don't store the
	 * padding bytes.  Empty structs are not allowed by some C compilers,
	 * hence the dummy.
	 */
 }


/** FLAC APPLICATION structure.  (c.f. <A HREF="https://xiph.org/flac/format.html#metadata_block_application">format specification</A>)
 */
FLAC__StreamMetadata_Application :: struct {
	id: [4] u8;
	data: *u8;
}

FLAC__STREAM_METADATA_APPLICATION_ID_LEN : u32 #elsewhere flac; /**< == 32 (bits) */

/** SeekPoint structure used in SEEKTABLE blocks.  (c.f. <A HREF="https://xiph.org/flac/format.html#seekpoint">format specification</A>)
 */
FLAC__StreamMetadata_SeekPoint :: struct {
	sample_number: u64;
	/**<  The sample number of the target frame. */

	stream_offset: u64;
	/**< The offset, in bytes, of the target frame with respect to
	* beginning of the first frame. */

	frame_samples: u32;
	/**< The number of samples in the target frame. */
}

FLAC__STREAM_METADATA_SEEKPOINT_SAMPLE_NUMBER_LEN : u32 #elsewhere flac; /**< == 64 (bits) */
FLAC__STREAM_METADATA_SEEKPOINT_STREAM_OFFSET_LEN : u32 #elsewhere flac; /**< == 64 (bits) */
FLAC__STREAM_METADATA_SEEKPOINT_FRAME_SAMPLES_LEN : u32 #elsewhere flac; /**< == 16 (bits) */

/** The total stream length of a seek point in bytes. */
FLAC__STREAM_METADATA_SEEKPOINT_LENGTH :: 18;

/** The value used in the \a sample_number field of
 *  FLAC__StreamMetadataSeekPoint used to indicate a placeholder
 *  point (== 0xffffffffffffffff).
 */
FLAC__STREAM_METADATA_SEEKPOINT_PLACEHOLDER : u64 #elsewhere flac;


/** FLAC SEEKTABLE structure.  (c.f. <A HREF="https://xiph.org/flac/format.html#metadata_block_seektable">format specification</A>)
 *
 * \note From the format specification:
 * - The seek points must be sorted by ascending sample number.
 * - Each seek point's sample number must be the first sample of the
 *   target frame.
 * - Each seek point's sample number must be unique within the table.
 * - Existence of a SEEKTABLE block implies a correct setting of
 *   total_samples in the stream_info block.
 * - Behavior is undefined when more than one SEEKTABLE block is
 *   present in a stream.
 */
FLAC__StreamMetadata_SeekTable :: struct {
	num_points: u32;
	points: *FLAC__StreamMetadata_SeekPoint;
}


/** Vorbis comment entry structure used in VORBIS_COMMENT blocks.  (c.f. <A HREF="https://xiph.org/flac/format.html#metadata_block_vorbis_comment">format specification</A>)
 *
 *  For convenience, the APIs maintain a trailing NUL character at the end of
 *  \a entry which is not counted toward \a length, i.e.
 *  \code strlen(entry) == length \endcode
 */
FLAC__StreamMetadata_VorbisComment_Entry :: struct {
	length: u32;
	entry: *u8;
}

FLAC__STREAM_METADATA_VORBIS_COMMENT_ENTRY_LENGTH_LEN : u32 #elsewhere flac; /**< == 32 (bits) */


/** FLAC VORBIS_COMMENT structure.  (c.f. <A HREF="https://xiph.org/flac/format.html#metadata_block_vorbis_comment">format specification</A>)
 */
FLAC__StreamMetadata_VorbisComment :: struct {
	vendor_string: FLAC__StreamMetadata_VorbisComment_Entry;
	num_comments: u32;
	comments: *FLAC__StreamMetadata_VorbisComment_Entry;
}

FLAC__STREAM_METADATA_VORBIS_COMMENT_NUM_COMMENTS_LEN: u32 #elsewhere flac; /**< == 32 (bits) */


/** FLAC CUESHEET track index structure.  (See the
 * <A HREF="https://xiph.org/flac/format.html#cuesheet_track_index">format specification</A> for
 * the full description of each field.)
 */
FLAC__StreamMetadata_CueSheet_Index :: struct {
	offset: u64;
	/**< Offset in samples, relative to the track offset, of the index
	 * point.
	 */

	 number: u8;
	/**< The index point number. */
}

FLAC__STREAM_METADATA_CUESHEET_INDEX_OFFSET_LEN: u32 #elsewhere flac; /**< == 64 (bits) */
FLAC__STREAM_METADATA_CUESHEET_INDEX_NUMBER_LEN: u32 #elsewhere flac; /**< == 8 (bits) */
FLAC__STREAM_METADATA_CUESHEET_INDEX_RESERVED_LEN: u32 #elsewhere flac; /**< == 3*8 (bits) */


/** FLAC CUESHEET track structure.  (See the
 * <A HREF="https://xiph.org/flac/format.html#cuesheet_track">format specification</A> for
 * the full description of each field.)
 */
FLAC__StreamMetadata_CueSheet_Track :: struct {
	offset: u64;
	/**< Track offset in samples, relative to the beginning of the FLAC audio stream. */

	number: u8;
	/**< The track number. */

	isrc: [13] s8;
	/**< Track ISRC.  This is a 12-digit alphanumeric code plus a trailing \c NUL byte */

	__bitfield: u8; // see members below
	//u32 type:1;
	/**< The track type: 0 for audio, 1 for non-audio. */

	//u32 pre_emphasis:1;
	/**< The pre-emphasis flag: 0 for no pre-emphasis, 1 for pre-emphasis. */

	num_indices: u8;
	/**< The number of track index points. */

	indices: *FLAC__StreamMetadata_CueSheet_Index;
	/**< NULL if num_indices == 0, else pointer to array of index points. */
}

FLAC__STREAM_METADATA_CUESHEET_TRACK_OFFSET_LEN : u32 #elsewhere flac; /**< == 64 (bits) */
FLAC__STREAM_METADATA_CUESHEET_TRACK_NUMBER_LEN : u32 #elsewhere flac; /**< == 8 (bits) */
FLAC__STREAM_METADATA_CUESHEET_TRACK_ISRC_LEN : u32 #elsewhere flac; /**< == 12*8 (bits) */
FLAC__STREAM_METADATA_CUESHEET_TRACK_TYPE_LEN : u32 #elsewhere flac; /**< == 1 (bit) */
FLAC__STREAM_METADATA_CUESHEET_TRACK_PRE_EMPHASIS_LEN : u32 #elsewhere flac; /**< == 1 (bit) */
FLAC__STREAM_METADATA_CUESHEET_TRACK_RESERVED_LEN : u32 #elsewhere flac; /**< == 6+13*8 (bits) */
FLAC__STREAM_METADATA_CUESHEET_TRACK_NUM_INDICES_LEN : u32 #elsewhere flac; /**< == 8 (bits) */


/** FLAC CUESHEET structure.  (See the
 * <A HREF="https://xiph.org/flac/format.html#metadata_block_cuesheet">format specification</A>
 * for the full description of each field.)
 */
FLAC__StreamMetadata_CueSheet :: struct {
	media_catalog_number: [129] s8;
	/**< Media catalog number, in ASCII printable characters 0x20-0x7e.  In
	 * general, the media catalog number may be 0 to 128 bytes long; any
	 * unused characters should be right-padded with NUL characters.
	 */

	lead_in: u64;
	/**< The number of lead-in samples. */

	is_cd: FLAC__bool;
	/**< \c true if CUESHEET corresponds to a Compact Disc, else \c false. */

	num_tracks: u32;
	/**< The number of tracks. */

	tracks: *FLAC__StreamMetadata_CueSheet_Track;
	/**< NULL if num_tracks == 0, else pointer to array of tracks. */

}

FLAC__STREAM_METADATA_CUESHEET_MEDIA_CATALOG_NUMBER_LEN : u32 #elsewhere flac; /**< == 128*8 (bits) */
FLAC__STREAM_METADATA_CUESHEET_LEAD_IN_LEN : u32 #elsewhere flac; /**< == 64 (bits) */
FLAC__STREAM_METADATA_CUESHEET_IS_CD_LEN : u32 #elsewhere flac; /**< == 1 (bit) */
FLAC__STREAM_METADATA_CUESHEET_RESERVED_LEN : u32 #elsewhere flac; /**< == 7+258*8 (bits) */
FLAC__STREAM_METADATA_CUESHEET_NUM_TRACKS_LEN : u32 #elsewhere flac; /**< == 8 (bits) */


/** An enumeration of the PICTURE types (see FLAC__StreamMetadataPicture and id3 v2.4 APIC tag). */
FLAC__StreamMetadata_Picture_Type :: enum {
	FLAC__STREAM_METADATA_PICTURE_TYPE_OTHER :: 0; /**< Other */
	FLAC__STREAM_METADATA_PICTURE_TYPE_FILE_ICON_STANDARD :: 1; /**< 32x32 pixels 'file icon' (PNG only) */
	FLAC__STREAM_METADATA_PICTURE_TYPE_FILE_ICON :: 2; /**< Other file icon */
	FLAC__STREAM_METADATA_PICTURE_TYPE_FRONT_COVER :: 3; /**< Cover (front) */
	FLAC__STREAM_METADATA_PICTURE_TYPE_BACK_COVER :: 4; /**< Cover (back) */
	FLAC__STREAM_METADATA_PICTURE_TYPE_LEAFLET_PAGE :: 5; /**< Leaflet page */
	FLAC__STREAM_METADATA_PICTURE_TYPE_MEDIA :: 6; /**< Media (e.g. label side of CD) */
	FLAC__STREAM_METADATA_PICTURE_TYPE_LEAD_ARTIST :: 7; /**< Lead artist/lead performer/soloist */
	FLAC__STREAM_METADATA_PICTURE_TYPE_ARTIST :: 8; /**< Artist/performer */
	FLAC__STREAM_METADATA_PICTURE_TYPE_CONDUCTOR :: 9; /**< Conductor */
	FLAC__STREAM_METADATA_PICTURE_TYPE_BAND :: 10; /**< Band/Orchestra */
	FLAC__STREAM_METADATA_PICTURE_TYPE_COMPOSER :: 11; /**< Composer */
	FLAC__STREAM_METADATA_PICTURE_TYPE_LYRICIST :: 12; /**< Lyricist/text writer */
	FLAC__STREAM_METADATA_PICTURE_TYPE_RECORDING_LOCATION :: 13; /**< Recording Location */
	FLAC__STREAM_METADATA_PICTURE_TYPE_DURING_RECORDING :: 14; /**< During recording */
	FLAC__STREAM_METADATA_PICTURE_TYPE_DURING_PERFORMANCE :: 15; /**< During performance */
	FLAC__STREAM_METADATA_PICTURE_TYPE_VIDEO_SCREEN_CAPTURE :: 16; /**< Movie/video screen capture */
	FLAC__STREAM_METADATA_PICTURE_TYPE_FISH :: 17; /**< A bright coloured fish */
	FLAC__STREAM_METADATA_PICTURE_TYPE_ILLUSTRATION :: 18; /**< Illustration */
	FLAC__STREAM_METADATA_PICTURE_TYPE_BAND_LOGOTYPE :: 19; /**< Band/artist logotype */
	FLAC__STREAM_METADATA_PICTURE_TYPE_PUBLISHER_LOGOTYPE :: 20; /**< Publisher/Studio logotype */
	FLAC__STREAM_METADATA_PICTURE_TYPE_UNDEFINED;
}

/** Maps a FLAC__StreamMetadata_Picture_Type to a C string.
 *
 *  Using a FLAC__StreamMetadata_Picture_Type as the index to this array
 *  will give the string equivalent.  The contents should not be
 *  modified.
 */
FLAC__StreamMetadata_Picture_TypeString: [22] *u8 #elsewhere flac;

/** FLAC PICTURE structure.  (See the
 * <A HREF="https://xiph.org/flac/format.html#metadata_block_picture">format specification</A>
 * for the full description of each field.)
 */
FLAC__StreamMetadata_Picture :: struct {
	type: FLAC__StreamMetadata_Picture_Type;
	/**< The kind of picture stored. */

	mime_type: *u8;
	/**< Picture data's MIME type, in ASCII printable characters
	 * 0x20-0x7e, NUL terminated.  For best compatibility with players,
	 * use picture data of MIME type \c image/jpeg or \c image/png.  A
	 * MIME type of '-->' is also allowed, in which case the picture
	 * data should be a complete URL.  In file storage, the MIME type is
	 * stored as a 32-bit length followed by the ASCII string with no NUL
	 * terminator, but is converted to a plain C string in this structure
	 * for convenience.
	 */

	description: *u8;
	/**< Picture's description in UTF-8, NUL terminated.  In file storage,
	 * the description is stored as a 32-bit length followed by the UTF-8
	 * string with no NUL terminator, but is converted to a plain C string
	 * in this structure for convenience.
	 */

	 width: u32;
	/**< Picture's width in pixels. */

	height: u32;
	/**< Picture's height in pixels. */

	depth: u32;
	/**< Picture's color depth in bits-per-pixel. */

	colors: u32;
	/**< For indexed palettes (like GIF), picture's number of colors (the
	 * number of palette entries), or \c 0 for non-indexed (i.e. 2^depth).
	 */

	 data_length: u32;
	/**< Length of binary picture data in bytes. */

	data: *u8;
	/**< Binary picture data. */

}

FLAC__STREAM_METADATA_PICTURE_TYPE_LEN : u32 #elsewhere flac; /**< == 32 (bits) */
FLAC__STREAM_METADATA_PICTURE_MIME_TYPE_LENGTH_LEN : u32 #elsewhere flac; /**< == 32 (bits) */
FLAC__STREAM_METADATA_PICTURE_DESCRIPTION_LENGTH_LEN : u32 #elsewhere flac; /**< == 32 (bits) */
FLAC__STREAM_METADATA_PICTURE_WIDTH_LEN : u32 #elsewhere flac; /**< == 32 (bits) */
FLAC__STREAM_METADATA_PICTURE_HEIGHT_LEN : u32 #elsewhere flac; /**< == 32 (bits) */
FLAC__STREAM_METADATA_PICTURE_DEPTH_LEN : u32 #elsewhere flac; /**< == 32 (bits) */
FLAC__STREAM_METADATA_PICTURE_COLORS_LEN : u32 #elsewhere flac; /**< == 32 (bits) */
FLAC__STREAM_METADATA_PICTURE_DATA_LENGTH_LEN : u32 #elsewhere flac; /**< == 32 (bits) */


/** Structure that is used when a metadata block of unknown type is loaded.
 *  The contents are opaque.  The structure is used only internally to
 *  correctly handle unknown metadata.
 */
FLAC__StreamMetadata_Unknown :: struct {
	data: *u8;
}


/** FLAC metadata block structure.  (c.f. <A HREF="https://xiph.org/flac/format.html#metadata_block">format specification</A>)
 */
FLAC__StreamMetadata :: struct {
	type: FLAC__MetadataType;
	/**< The type of the metadata block; used determine which member of the
	 * \a data union to dereference.  If type >= FLAC__METADATA_TYPE_UNDEFINED
	 * then \a data.unknown must be used. */

	is_last: FLAC__bool;
	/**< \c true if this metadata block is the last, else \a false */

	length: u32;
	/**< Length, in bytes, of the block data as it appears in the stream. */

	data : union {
		stream_info: FLAC__StreamMetadata_StreamInfo;
		padding: FLAC__StreamMetadata_Padding;
		application: FLAC__StreamMetadata_Application;
		seek_table: FLAC__StreamMetadata_SeekTable;
		vorbis_comment: FLAC__StreamMetadata_VorbisComment;
		cue_sheet: FLAC__StreamMetadata_CueSheet;
		picture: FLAC__StreamMetadata_Picture;
		unknown: FLAC__StreamMetadata_Unknown;
	}
	/**< Polymorphic block data; use the \a type value to determine which
	 * to use. */
}

FLAC__STREAM_METADATA_IS_LAST_LEN : u32 #elsewhere flac; /**< == 1 (bit) */
FLAC__STREAM_METADATA_TYPE_LEN : u32 #elsewhere flac; /**< == 7 (bits) */
FLAC__STREAM_METADATA_LENGTH_LEN : u32 #elsewhere flac; /**< == 24 (bits) */

/** The total stream length of a metadata block header in bytes. */
FLAC__STREAM_METADATA_HEADER_LENGTH :: 4;

/*****************************************************************************/


/*****************************************************************************
 *
 * Utility functions
 *
 *****************************************************************************/

/** Tests that a sample rate is valid for FLAC.
 *
 * \param sample_rate  The sample rate to test for compliance.
 * \retval FLAC__bool
 *    \c true if the given sample rate conforms to the specification, else
 *    \c false.
 */
 FLAC__format_sample_rate_is_valid :: (sample_rate: u32) -> FLAC__bool #foreign flac;

/** Tests that a blocksize at the given sample rate is valid for the FLAC
 *  subset.
 *
 * \param blocksize    The blocksize to test for compliance.
 * \param sample_rate  The sample rate is needed, since the valid subset
 *                     blocksize depends on the sample rate.
 * \retval FLAC__bool
 *    \c true if the given blocksize conforms to the specification for the
 *    subset at the given sample rate, else \c false.
 */
 FLAC__format_blocksize_is_subset :: (blocksize: u32, sample_rate: u32) -> FLAC__bool #foreign flac;

/** Tests that a sample rate is valid for the FLAC subset.  The subset rules
 *  for valid sample rates are slightly more complex since the rate has to
 *  be expressible completely in the frame header.
 *
 * \param sample_rate  The sample rate to test for compliance.
 * \retval FLAC__bool
 *    \c true if the given sample rate conforms to the specification for the
 *    subset, else \c false.
 */
 FLAC__format_sample_rate_is_subset :: (sample_rate: u32) -> FLAC__bool #foreign flac;

/** Check a Vorbis comment entry name to see if it conforms to the Vorbis
 *  comment specification.
 *
 *  Vorbis comment names must be composed only of characters from
 *  [0x20-0x3C,0x3E-0x7D].
 *
 * \param name       A NUL-terminated string to be checked.
 * \assert
 *    \code name != NULL \endcode
 * \retval FLAC__bool
 *    \c false if entry name is illegal, else \c true.
 */
 FLAC__format_vorbiscomment_entry_name_is_legal :: (name: *u8) -> FLAC__bool #foreign flac;

/** Check a Vorbis comment entry value to see if it conforms to the Vorbis
 *  comment specification.
 *
 *  Vorbis comment values must be valid UTF-8 sequences.
 *
 * \param value      A string to be checked.
 * \param length     A the length of \a value in bytes.  May be
 *                   \c (u32)(-1) to indicate that \a value is a plain
 *                   UTF-8 NUL-terminated string.
 * \assert
 *    \code value != NULL \endcode
 * \retval FLAC__bool
 *    \c false if entry name is illegal, else \c true.
 */
 FLAC__format_vorbiscomment_entry_value_is_legal :: (value: *u8, length: u32) -> FLAC__bool #foreign flac;

/** Check a Vorbis comment entry to see if it conforms to the Vorbis
 *  comment specification.
 *
 *  Vorbis comment entries must be of the form 'name=value', and 'name' and
 *  'value' must be legal according to
 *  FLAC__format_vorbiscomment_entry_name_is_legal() and
 *  FLAC__format_vorbiscomment_entry_value_is_legal() respectively.
 *
 * \param entry      An entry to be checked.
 * \param length     The length of \a entry in bytes.
 * \assert
 *    \code value != NULL \endcode
 * \retval FLAC__bool
 *    \c false if entry name is illegal, else \c true.
 */
 FLAC__format_vorbiscomment_entry_is_legal :: (entry: *u8, length: u32) -> FLAC__bool #foreign flac;

/** Check a seek table to see if it conforms to the FLAC specification.
 *  See the format specification for limits on the contents of the
 *  seek table.
 *
 * \param seek_table  A pointer to a seek table to be checked.
 * \assert
 *    \code seek_table != NULL \endcode
 * \retval FLAC__bool
 *    \c false if seek table is illegal, else \c true.
 */
 FLAC__format_seektable_is_legal :: (seek_table: *FLAC__StreamMetadata_SeekTable) -> FLAC__bool #foreign flac;

/** Sort a seek table's seek points according to the format specification.
 *  This includes a "unique-ification" step to remove duplicates, i.e.
 *  seek points with identical \a sample_number values.  Duplicate seek
 *  points are converted into placeholder points and sorted to the end of
 *  the table.
 *
 * \param seek_table  A pointer to a seek table to be sorted.
 * \assert
 *    \code seek_table != NULL \endcode
 * \retval u32
 *    The number of duplicate seek points converted into placeholders.
 */
 FLAC__format_seektable_sort :: (seek_table: *FLAC__StreamMetadata_SeekTable) -> u32 #foreign flac;

/** Check a cue sheet to see if it conforms to the FLAC specification.
 *  See the format specification for limits on the contents of the
 *  cue sheet.
 *
 * \param cue_sheet  A pointer to an existing cue sheet to be checked.
 * \param check_cd_da_subset  If \c true, check CUESHEET against more
 *                   stringent requirements for a CD-DA (audio) disc.
 * \param violation  Address of a pointer to a string.  If there is a
 *                   violation, a pointer to a string explanation of the
 *                   violation will be returned here. \a violation may be
 *                   \c NULL if you don't need the returned string.  Do not
 *                   free the returned string; it will always point to static
 *                   data.
 * \assert
 *    \code cue_sheet != NULL \endcode
 * \retval FLAC__bool
 *    \c false if cue sheet is illegal, else \c true.
 */
 FLAC__format_cuesheet_is_legal :: (cue_sheet: *FLAC__StreamMetadata_CueSheet, check_cd_da_subset: FLAC__bool, violation: **u8) -> FLAC__bool #foreign flac;

/** Check picture data to see if it conforms to the FLAC specification.
 *  See the format specification for limits on the contents of the
 *  PICTURE block.
 *
 * \param picture    A pointer to existing picture data to be checked.
 * \param violation  Address of a pointer to a string.  If there is a
 *                   violation, a pointer to a string explanation of the
 *                   violation will be returned here. \a violation may be
 *                   \c NULL if you don't need the returned string.  Do not
 *                   free the returned string; it will always point to static
 *                   data.
 * \assert
 *    \code picture != NULL \endcode
 * \retval FLAC__bool
 *    \c false if picture data is illegal, else \c true.
 */
 FLAC__format_picture_is_legal :: (picture: *FLAC__StreamMetadata_Picture, violation: **u8) -> FLAC__bool #foreign flac;
