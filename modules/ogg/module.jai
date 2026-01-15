
ogg_iovec_t :: struct {
	iov_base: *void;
	iov_len : s64;
}

oggpack_buffer :: struct {
	endbyte: s64;
	endbit : s32;

	buffer : *u8;
	ptr    : *u8;
	storage: s64;
}

ogg_page :: struct {
	header    : *u8;
	header_len: s64;
	body      : *u8;
	body_len  : s64;
}

ogg_stream_state :: struct {
	body_data    : *u8; /* bytes from packet bodies */
	body_storage : s64; /* storage elements allocated */
	body_fill    : s64; /* elements stored; fill mark */
	body_returned: s64; /* elements of fill returned */


	lacing_vals    : *s32; /* The values that will go to the segment table */
	granule_vals   : *s64; /* granulepos values for headers. Not compact this way, but it is simple coupled to the lacing fifo */
	lacing_storage : s64;
	lacing_filli   : s64;
	lacing_packet  : s64;
	lacing_returned: s64;

	header     : [282] u8; /* working space for header encode */
	header_fill: s32;

	e_o_s   : s32; /* set when we have buffered the last packet in the logical bitstream */
	b_o_s   : s32; /* set after we've written the initial page of a logical bitstream */
	serialno: s64;
	pageno  : s64;
	packetno: s64; /* sequence number for decode; the framing knows where there's a hole in the data, but we need coupling so that the codec (which is in a separate abstraction layer) also knows about the gap */ granulepos: s64;
}

ogg_packet :: struct {
	packet: *u8;
	bytes: s64;
	b_o_s: s64;
	e_o_s: s64;

	granulepos: s64;

	packetno: s64;     /* sequence number for decode; the framing
	                      knows where there's a hole in the data,
	                      but we need coupling so that the codec
	                      (which is in a separate abstraction
	                      layer) also knows about the gap */
}

ogg_sync_state :: struct {
	data: *u8;
	storage: s32;
	fill: s32;
	returned: s32;

	unsynced: s32;
	headerbytes: s32;
	bodybytes: s32;
}

oggpack_writeinit  :: (b: *oggpack_buffer) #foreign ogg;
oggpack_writecheck :: (b: *oggpack_buffer) -> s32 #foreign ogg;
oggpack_writetrunc :: (b: *oggpack_buffer, bits: s64) #foreign ogg;
oggpack_writealign :: (b: *oggpack_buffer)  #foreign ogg;
oggpack_writecopy  :: (b: *oggpack_buffer, source: *void, bits: s64) #foreign ogg;
oggpack_reset      :: (b: *oggpack_buffer)  #foreign ogg;
oggpack_writeclear :: (b: *oggpack_buffer)  #foreign ogg;
oggpack_readinit   :: (b: *oggpack_buffer, buf: *u8, bytes: s32) #foreign ogg;
oggpack_write      :: (b: *oggpack_buffer, value: u64, bits: s32)  #foreign ogg;
oggpack_look       :: (b: *oggpack_buffer, bits: s32) -> s64 #foreign ogg;
oggpack_look1      :: (b: *oggpack_buffer) -> s64 #foreign ogg;
oggpack_adv        :: (b: *oggpack_buffer, bits: s32)  #foreign ogg;
oggpack_adv1       :: (b: *oggpack_buffer)  #foreign ogg;
oggpack_read       :: (b: *oggpack_buffer, bits: s32) -> s64 #foreign ogg;
oggpack_read1      :: (b: *oggpack_buffer) -> s64 #foreign ogg;
oggpack_bytes      :: (b: *oggpack_buffer) -> s64 #foreign ogg;
oggpack_bits       :: (b: *oggpack_buffer) -> s64 #foreign ogg;
oggpack_get_buffer :: (b: *oggpack_buffer) -> *u8 #foreign ogg;

oggpackB_writeinit  :: (b: *oggpack_buffer)  #foreign ogg;
oggpackB_writecheck :: (b: *oggpack_buffer) -> s32  #foreign ogg;
oggpackB_writetrunc :: (b: *oggpack_buffer, bits: s64)  #foreign ogg;
oggpackB_writealign :: (b: *oggpack_buffer)  #foreign ogg;
oggpackB_writecopy  :: (b: *oggpack_buffer, source: *void, bits: s64)  #foreign ogg;
oggpackB_reset      :: (b: *oggpack_buffer)  #foreign ogg;
oggpackB_writeclear :: (b: *oggpack_buffer)  #foreign ogg;
oggpackB_readinit   :: (b: *oggpack_buffer, buf: *u8, bytes: s32)  #foreign ogg;
oggpackB_write      :: (b: *oggpack_buffer, value: u64, bits: s32)  #foreign ogg;
oggpackB_look       :: (b: *oggpack_buffer, bits: s32) -> s64 #foreign ogg;
oggpackB_look1      :: (b: *oggpack_buffer) -> s64 #foreign ogg;
oggpackB_adv        :: (b: *oggpack_buffer, bits: s32)  #foreign ogg;
oggpackB_adv1       :: (b: *oggpack_buffer)  #foreign ogg;
oggpackB_read       :: (b: *oggpack_buffer, bits: s32) -> s64 #foreign ogg;
oggpackB_read1      :: (b: *oggpack_buffer) -> s64 #foreign ogg;
oggpackB_bytes      :: (b: *oggpack_buffer) -> s64 #foreign ogg;
oggpackB_bits       :: (b: *oggpack_buffer) -> s64 #foreign ogg;
oggpackB_get_buffer :: (b: *oggpack_buffer) -> *u8 #foreign ogg;

/* Ogg BITSTREAM PRIMITIVES: encoding **************************/

ogg_stream_packetin     :: (os: *ogg_stream_state, op: *ogg_packet) -> s32 #foreign ogg;
ogg_stream_iovecin      :: (os: *ogg_stream_state, iov: *ogg_iovec_t, count: s32, e_o_s: s64, granulepos: s64) -> s32 #foreign ogg;
ogg_stream_pageout      :: (os: *ogg_stream_state, og: *ogg_page) -> s32 #foreign ogg;
ogg_stream_pageout_fill :: (os: *ogg_stream_state, og: *ogg_page, nfill: s32) -> s32 #foreign ogg;
ogg_stream_flush        :: (os: *ogg_stream_state, og: *ogg_page) -> s32 #foreign ogg;
ogg_stream_flush_fill   :: (os: *ogg_stream_state, og: *ogg_page, nfill: s32) -> s32 #foreign ogg;

/* Ogg BITSTREAM PRIMITIVES: decoding **************************/

ogg_sync_init    :: (oy: *ogg_sync_state) -> s32     #foreign ogg;
ogg_sync_clear   :: (oy: *ogg_sync_state) -> s32     #foreign ogg;
ogg_sync_reset   :: (oy: *ogg_sync_state) -> s32     #foreign ogg;
ogg_sync_destroy :: (oy: *ogg_sync_state) -> s32     #foreign ogg;
ogg_sync_check   :: (oy: *ogg_sync_state) -> s32     #foreign ogg;

ogg_sync_buffer       :: (oy: *ogg_sync_state, size: s64) -> *s8 #foreign ogg;
ogg_sync_wrote        :: (oy: *ogg_sync_state, bytes: s64) -> s32 #foreign ogg;
ogg_sync_pageseek     :: (oy: *ogg_sync_state, og: *ogg_page) -> s64 #foreign ogg;
ogg_sync_pageout      :: (oy: *ogg_sync_state, og: *ogg_page) -> s32 #foreign ogg;
ogg_stream_pagein     :: (os: *ogg_stream_state, og: *ogg_page) -> s32 #foreign ogg;
ogg_stream_packetout  :: (os: *ogg_stream_state, op: *ogg_packet) -> s32 #foreign ogg;
ogg_stream_packetpeek :: (os: *ogg_stream_state, op: *ogg_packet) -> s32 #foreign ogg;

/* Ogg BITSTREAM PRIMITIVES: general ***************************/

ogg_stream_init           :: (os: *ogg_stream_state, serialno: s32) -> s32     #foreign ogg;
ogg_stream_clear          :: (os: *ogg_stream_state) -> s32     #foreign ogg;
ogg_stream_reset          :: (os: *ogg_stream_state) -> s32     #foreign ogg;
ogg_stream_reset_serialno :: (os: *ogg_stream_state, serialno: s32) -> s32     #foreign ogg;
ogg_stream_destroy        :: (os: *ogg_stream_state) -> s32     #foreign ogg;
ogg_stream_check          :: (os: *ogg_stream_state) -> s32     #foreign ogg;
ogg_stream_eos            :: (os: *ogg_stream_state) -> s32     #foreign ogg;

ogg_page_checksum_set :: (og: *ogg_page)     #foreign ogg;

ogg_page_version :: (og: *ogg_page) -> s32     #foreign ogg;
ogg_page_continued :: (og: *ogg_page) -> s32     #foreign ogg;
ogg_page_bos :: (og: *ogg_page) -> s32     #foreign ogg;
ogg_page_eos :: (og: *ogg_page) -> s32     #foreign ogg;
ogg_page_granulepos :: (og: *ogg_page) -> s64 #foreign ogg;
ogg_page_serialno :: (og: *ogg_page) -> s32     #foreign ogg;
ogg_page_pageno :: (og: *ogg_page) -> s64    #foreign ogg;
ogg_page_packets :: (og: *ogg_page) -> s32     #foreign ogg;

ogg_packet_clear :: (op: *ogg_packet)     #foreign ogg;

#if OS == {
	case .WINDOWS; ogg :: #library "windows/ogg";
	case .LINUX;   ogg :: #library "linux/ogg";
	case .MACOS;   ogg :: #library "macos/ogg";
}
