USING: protobuf protobuf.tokenize multiline namespaces tools.test ;
IN: protobuf-tests

! word-format tests
! always results in a tag-value pair 
! may be recursive with submessages
{ 1 2 } [ B{ 8 2 } binary [ begin-iter ] with-byte-reader ] unit-test

{ 300 301 } [ B{ 0xe0 0x12 0xad 0x02 } binary [ begin-iter ] with-byte-reader ] unit-test

{ 2 "this_is~a test-string" } [ B{ 0x12 0x15 0x74 0x68 0x69 0x73 0x5f 0x69 0x73 0x7e 0x61 0x20 0x74 0x65 0x73 0x74 0x2d 0x73 0x74 0x72 0x69 0x6e 0x67 } binary [ begin-iter ] with-byte-reader >string ] unit-test

{ B{ 8 } } [ binary [ 8 write-b128-varint ] with-byte-writer ] unit-test
{ B{ 0xac 0x02 } } [ binary [ 300 write-b128-varint ] with-byte-writer ] unit-test
{ B{ 0xe0 0x12 0xad 0x02 } } [ binary [ +uint32+ 300 301 begin-write-iter ] with-byte-writer ] unit-test

! to load some test protobuf symbols before tests run
! SYMBOL: word-format-test-def
! word-format-test-def [=[
! syntax = "proto3";
! 
! message oneword {
!     uint32 value = 1;
!     string second = 2;
! }
! 
! message twoword {
!     uint32 value = 300;
! }
! 
! // message stringmsg {
!     // string value = 2;
! // }
! 
! message threeword {
!     twoword value = 1000;
! }
! ]=] tokenize set

! ----- testing seems to need special assistance with runtime created objects
! { { "second" "this is a test string" } }
! [
!     ! load up the proto descriptor
!     word-format-test-def get DEFER: oneword new
!     ! set only one of the attribute values
!     dup second>> "this is a test string" >>value drop
!     ! encode the object
!     binary swap [ (encode) ] curry with-byte-writer
!     ! at this point the object is protobuf encoded
!     
!     ! TODO decoding needs a with-default-values option for unset values
!     pick "oneword" swap (decode)
! ] unit-test


