#include <unistd.h>
#include <stdlib.h>

#include "pb_common.h"
#include "pb_encode.h"
#include "pb_decode.h"

#include "word-format-test.pb.h"

static bool test_string_encode ( pb_ostream_t * stream ,
                                 const pb_field_t * field ,
                                 void * const * arg )
{
    const char * ts = "this_is~a test-string" ;
    bool s = false ;
    if ( ! pb_encode_tag_for_field ( stream , field ) ) { }
    else if ( ! pb_encode_string ( stream , ( const pb_byte_t * ) ts , strlen ( ts ) ) ) { }
    else { s = true ; }
    return s ;
}

int main ( void )
{
    oneword m = { 2 } ;
    pb_byte_t b [ 3 ] = { 0 } ;
    pb_ostream_t o = pb_ostream_from_buffer ( b , 3 ) ;
    if ( ! pb_encode ( & o , oneword_fields , & m ) ) exit ( 1 ) ;
    write ( 1 , b , o . bytes_written ) ;

    write ( 1 , "\n" , 1 ) ;

    twoword n = { 301 } ;
    pb_byte_t bn [ 4 ] = { 0 } ;
    pb_ostream_t on = pb_ostream_from_buffer ( bn , 4 ) ;
    if ( ! pb_encode ( & on , twoword_fields , & n ) ) exit ( 1 ) ;
    write ( 1 , bn , on . bytes_written ) ;

    write ( 1 , "\n" , 1 ) ;

    threeword p = { 65355 } ; // FIXME outputs a false if given a value other than 0 here
    pb_byte_t pn [ 16 ] = { 0 } ;
    pb_ostream_t op = pb_ostream_from_buffer ( pn , 16 ) ;
    if ( ! pb_encode ( & op , threeword_fields , & p ) ) exit ( 1 ) ;
    write ( 1 , pn , op . bytes_written ) ;

    write ( 1 , "\n" , 1 ) ;

    p . has_value = true ;
    p . value = n ;
    pb_byte_t pn2 [ 16 ] = { 0 } ;
    pb_ostream_t op2 = pb_ostream_from_buffer ( pn2 , 16 ) ;
    if ( ! pb_encode ( & op2 , threeword_fields , & p ) ) exit ( 1 ) ;
    write ( 1 , pn2 , op2 . bytes_written ) ;

    write ( 1 , "\n" , 1 ) ;

    stringmsg q = { { { . encode = test_string_encode } } } ;
    pb_byte_t qn [ 32 ] = { 0 } ;
    pb_ostream_t oq = pb_ostream_from_buffer ( qn , 32 ) ;
    if ( ! pb_encode ( & oq , stringmsg_fields , & q ) ) exit ( 1 ) ;
    write ( 1 , qn , oq . bytes_written ) ;

    return 0 ;
}
