USING: kernel protobuf.tokenize protobuf.codegen ;
IN: protobuf

: protoc ( name str -- )
    tokenize compile ;
