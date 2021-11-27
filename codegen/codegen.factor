USING: kernel io protobuf.tokenize sequences ;
IN: protobuf.codegen

ERROR: invalid-top-level-object obj ;

: generate-message ( obj -- seq )
    ! TODO(kevinc)
    drop { }
    ;

: generate-enum-mapping ( assoc -- str )
    >hashtable [ ] curry unparse ;

: initialize-enum-symbol ( obj -- )
    [ name>> ] [ map>> generate-enum-mapping ] bi " " glue
    " initialize" append write nl ;

: generate-enum-symbol ( str -- )
    "SYMBOL: " prepend write nl ; 

: generate-enum ( obj -- )
    dup name>> generate-enum-symbol initialize-enum-symbol ;

: generate-top-level-defs ( seq -- )
    [
        {
            { [ dup enum? ] [ generate-enum ] }
            { [ dup message? ] [ generate-message  [ write ] each ] }
            ! TODO(kevinc) service?
            [ invalid-top-level-object ]
        } cond
    ] each ;
    
: generate-vocab-details ( str -- )
    "USING: kernel ;" write nl
    "IN: " prepend write nl nl ;

! top level definitions
: proto-descriptor-output ( str obj -- )
    [ generate-vocab-details ] [ def>> generate-top-level-defs ] bi* ;

: compile ( name obj -- )
    over ".factor" append utf8 [ proto-descriptor-output ] with-file-writer ;
