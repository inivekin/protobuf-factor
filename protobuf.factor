USING: kernel protobuf.tokenize protobuf.codegen ;
IN: protobuf

! wire-types
CONSTANT: +varint+ 0
CONSTANT: +64bit+ 1
CONSTANT: +length-delimited+ 2
CONSTANT: +start-group+ 3
CONSTANT: +end-group+ 4
CONSTANT: +32bit+ 5

: message-type>wire-type ( message-type -- wire-type )
    {
        { +int32+ [ +varint+ ] }
        { +int64+ [ +varint+ ] }
        { +uint32+ [ +varint+ ] }
        { +uint64+ [ +varint+ ] }
        { +sint32+ [ +varint+ ] }
        { +sint64+ [ +varint+ ] }
        { +bool+ [ +varint+ ] }
        { +enum+ [ +varint+ ] }

        { +fixed64+ [ +64bit+ ] }
        { +sfixed64+ [ +64bit+ ] }
        { +double+ [ +64bit+ ] }

        { +string+ [ +length-delimited+ ] }
        { +bytes+ [ +length-delimited+ ] }
        { +embedded-messages+ [ +length-delimited+ ] }
        { +packed-repeated-fields+ [ +length-delimited+ ] }

        { +fixed32+ [ +32bit+ ] }
        { +sfixed32+ [ +32bit+ ] }
        { +float+ [ +32bit+ ] }
    } case ;

! --------  decoding stuff ------------ !
: (read-b128-varint) ( orig byte -- bitarray ? )
    integer>bit-array 8 f pad-tail [ but-last append ] [ last ] bi ;

: read-b128-varint ( word -- int )
    ! read until msb is not 1, then append the 7 other bits (reversed)
    ! assumes a binary stream
    [ integer>bit-array  8 f pad-tail but-last ]
    [ 0x80 bitand zero? not ] bi ! is there more than the current byte needed?
    ! why can't when* instead of if ?
    [ [ read1 dup [ (read-b128-varint) ] [ drop f ] if ] loop ] when bit-array>integer ;

: 4word-format ( orig -- orig bytes )
    read1 read-b128-varint ! length is always varint
    read ;
    
: word-format ( test tag -- test value )
    3 bitand {
        { +varint+ [ read1 read-b128-varint ] }
        { +64bit+ [ "implement 2word format" throw ] }
        { +length-delimited+ [ 4word-format ] }
        { +32bit+ [ "implement 8word format" throw ] } ! fixed-length 32bit, groups are deprecated
        [ "invalid word-format" throw ]
    } case ;

: proto-normalise-type ( message-type value -- value )
    swap {
        { +uint32+ [ ] }
        { +string+ [ >string ] }
        { +bytes+ [ ] }
        [ "unhandled message-type" throw ]
    } case ;

:: proto-normalise ( message-name protodef tag value -- key-value )
    tag message-name protodef def>> at at first2 value proto-normalise-type 2array ;  

! always starts with a tag/key/field-number as a varint with embedded wire type
: begin-iter ( -- tag value )
    read1 read-b128-varint ! have the tag
    [ -3 shift ] ! removes wire-type
    [ word-format ]  bi ! keeps tag and gets value
    ;

! needs the object to field mapping, will produce an object out
: (decode) ( bytes message-name protodef -- bytes )
    [ begin-iter proto-normalise ] 2curry binary swap with-byte-reader ;


! --------  encoding stuff ------------ !
: (write-b128-varint) ( int -- ? )
    dup 0x7F bitand swap over = [ write1 f ] [ 0x80 bitor write1 t ] if ;

: write-b128-varint ( word -- )
    [ dup (write-b128-varint) ] [ -7 shift ] while drop ;

: begin-write-iter ( message-type tag value -- )
    [ message-type>wire-type ] 2dip pick
    {
        { +varint+ [ [ 3 shift bitor write-b128-varint ] [ write-b128-varint ] bi* ] }
        { +64bit+ [ "implement 2word format encoding" throw ] }
        { +length-delimited+ [ [ 3 shift bitor write-b128-varint ] [ dup length write-b128-varint [ write1 ] each ] bi* ] }
        [ "unhandled wire-type" throw ]
    } case ;

: value-set? ( slot -- ? )
    value>> +unset+ = not ;

! :: encode-slot ( protodef object object-name slot -- )
: encode-slot ( slot -- )
    second dup value-set?
    [ dup [ type>> ] [ tag>> ] [ value>> ] tri begin-write-iter ] when drop ; 

! : (encode) ( protodef object -- )
: (encode) ( object -- )
    ! dup tuple>array first [ props>> "slots" of ] [ unparse ] bi [ encode-slot ] each
    <mirror> >alist [ encode-slot ] each ;
    ! iterate over the objects fields - for a field:
        ! if set, get the wire-type, the tag and value
        ! then write

: instantiate-proto ( filepath -- protodef )
    utf8 file-contents tokenize ;



