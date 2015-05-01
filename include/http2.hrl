%% FRAME TYPES
-define(DATA            , 16#0).
-define(HEADERS         , 16#1).
-define(PRIORITY        , 16#2).
-define(RST_STREAM      , 16#3).
-define(SETTINGS        , 16#4).
-define(PUSH_PROMISE    , 16#5).
-define(PING            , 16#6).
-define(GOAWAY          , 16#7).
-define(WINDOW_UPDATE   , 16#8).
-define(CONTINUATION    , 16#9).

-type frame_type() :: ?DATA
                    | ?HEADERS
                    | ?PRIORITY
                    | ?RST_STREAM
                    | ?SETTINGS
                    | ?PUSH_PROMISE
                    | ?PING
                    | ?GOAWAY
                    | ?WINDOW_UPDATE
                    | ?CONTINUATION.

-define(FT, fun(?DATA) -> "DATA";
               (?HEADERS) -> "HEADERS";
               (?PRIORITY) -> "PRIORITY";
               (?RST_STREAM) -> "RST_STREAM";
               (?SETTINGS) -> "SETTINGS";
               (?PUSH_PROMISE) -> "PUSH_PROMISE";
               (?PING) -> "PING";
               (?GOAWAY) -> "GOAWAY";
               (?WINDOW_UPDATE) -> "WINDOW_UPDATE";
               (?CONTINUATION) -> "CONTINUATION" end
  ).

%% ERROR CODES
-define(NO_ERROR,           16#0).
-define(PROTOCOL_ERROR,     16#1).
-define(INTERNAL_ERROR,     16#2).
-define(FLOW_CONTROL_ERROR, 16#3).
-define(SETTINGS_TIMEOUT,   16#4).
-define(STREAM_CLOSED,      16#5).
-define(FRAME_SIZE_ERROR,   16#6).
-define(REFUSED_STREAM,     16#7).
-define(CANCEL,             16#8).
-define(COMPRESSION_ERROR,  16#9).
-define(CONNECT_ERROR,      16#a).
-define(ENHANCE_YOUR_CALM,  16#b).
-define(INADEQUATE_SECURITY,16#c).
-define(HTTP_1_1_REQUIRED,  16#d).

-type error_code() :: ?NO_ERROR
                    | ?PROTOCOL_ERROR
                    | ?INTERNAL_ERROR
                    | ?FLOW_CONTROL_ERROR
                    | ?SETTINGS_TIMEOUT
                    | ?STREAM_CLOSED
                    | ?FRAME_SIZE_ERROR
                    | ?REFUSED_STREAM
                    | ?CANCEL
                    | ?COMPRESSION_ERROR
                    | ?CONNECT_ERROR
                    | ?ENHANCE_YOUR_CALM
                    | ?INADEQUATE_SECURITY
                    | ?HTTP_1_1_REQUIRED.

%% FLAGS
-define(FLAG_ACK,         16#1 ).
-define(FLAG_END_STREAM,  16#1 ).
-define(FLAG_END_HEADERS, 16#4 ).
-define(FLAG_PADDED,      16#8 ).
-define(FLAG_PRIORITY,    16#20).

-type flag() :: ?FLAG_ACK
              | ?FLAG_END_STREAM
              | ?FLAG_END_HEADERS
              | ?FLAG_PADDED
              | ?FLAG_PRIORITY.

%% These are macros because they're used in guards alot
-define(IS_FLAG(Flags, Flag), Flags band Flag =:= Flag).
-define(NOT_FLAG(Flags, Flag), Flags band Flag =/= Flag).

-type stream_id() :: non_neg_integer().
-record(frame_header, {
    length      :: non_neg_integer(),
    type        :: frame_type(),
    flags = 0   :: non_neg_integer(),
    stream_id   :: stream_id()
    }).

-type frame_header() :: #frame_header{}.

-record(data, {
    data :: binary()
  }).
-type data() :: #data{}.

%% TODO: It's terrible that I have 'header' and 'headers'
%% records. Need to do a refactor of 'header' -> 'frame_header'
-record(headers, {
          priority = undefined :: priority() | undefined,
          block_fragment :: binary()
}).
-type headers() :: #headers{}.

-record(priority, {
    exclusive :: 0 | 1,
    stream_id :: stream_id(),
    weight :: pos_integer()
  }).
-type priority() :: #priority{}.

-record(rst_stream, {
          error_code :: error_code()
}).
-type rst_stream() :: #rst_stream{}.

-record(settings, {header_table_size        = 4096,
                   enable_push              = 1,
                   max_concurrent_streams   = unlimited,
                   initial_window_size      = 65535,
                   max_frame_size           = 16384,
                   max_header_list_size     = unlimited}).
-define(DEFAULT_SETTINGS, #settings{}).
-type settings() :: #settings{}.

-record(push_promise, {
          promised_stream_id :: stream_id(),
          block_fragment :: binary()
}).
-type push_promise() :: #push_promise{}.

-record(ping, {
          opaque_data :: binary()
}).
-type ping() :: #ping{}.

-record(goaway, {
          last_stream_id :: stream_id(),
          error_code :: error_code(),
          additional_debug_data :: binary()
}).
-type goaway() :: #goaway{}.

-record(window_update, {
          window_size_increment :: non_neg_integer()
}).
-type window_update() :: #window_update{}.

-record(continuation, {
          block_fragment :: binary()
}).
-type continuation() :: #continuation{}.

-type payload() :: data()
                 | headers()
                 | settings()
                 | priority()
                 | settings()
                 | push_promise()
                 | ping()
                 | goaway()
                 | window_update()
                 | continuation().

-type frame() :: {frame_header(), payload()}.


-type transport() :: gen_tcp | ssl.
-type socket() :: {transport(), port()}.

-define(PREAMBLE, "PRI * HTTP/2.0\r\n\r\nSM\r\n\r\n").
