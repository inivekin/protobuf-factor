USING: protobuf.tokenize multiline namespaces tools.test ;
IN: protobuf.tokenize-tests

SYMBOL: simple-test-proto
simple-test-proto [ [=[
syntax = "proto3";

// simple test enum
enum testEnum_ {
    zero = 0;
    O_1_NE = 1; // comments
    tw_2_o = 2;
    ThRe_3_E = 3;
    four_4 = 4;
}

/* simple test message */
message test_Message {
    int32 signed_int = 1;
    repeated uint64 unsigned_bigboy = 2;
    oneof choices{
        /* oneof test */ testEnum_ primary = 3;
        string secondary = 4;
    }; // pointless semicolon
}
]=] ] initialize 

{
    T{ protobuf f
        3
        V{
            T{ enum f "testEnum_"
                V{
                    { "zero" 0 }
                    { "O_1_NE" 1 }
                    { "tw_2_o" 2 }
                    { "ThRe_3_E" 3 }
                    { "four_4" 4 }
                }
            }
            T{ message f "test_Message"
                V{
                    T{ field f f "int32" "signed_int" 1 }
                    T{ field f t "uint64" "unsigned_bigboy" 2 }
                    T{ oneof f "choices"
                        V{
                            T{ field f f T{ identifier f f V{ } "testEnum_" } "primary" 3 }
                            T{ field f f "string" "secondary" 4 }
                        }
                    }
                }
            }
        }
    }
}
[ simple-test-proto get tokenize ] unit-test

! { B{ 0x08 0xBB 0xFF 0xFF 0xFF 0xFF 0xFF 0xFF 0xFF 0xFF 0x01 0xA4 0x01 0x00 0x00 0x00 0x00 0x00 0x00 0x18 0x02 } }
! [ simple-test-proto [ write ] with-protobuf-writer ] unit-test


