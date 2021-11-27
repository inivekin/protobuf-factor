#include <unistd.h>
#include <stdlib.h>

#include "pb_common.h"
#include "pb_encode.h"
#include "pb_decode.h"

#include "simple-proto-test.pb.h"

bool primary ( pb_ostream_t * o , const pb_field_t * f , void * const * arg )
{
    uint64_t i = 420 ;
    return pb_write ( o , ( uint8_t * ) & i , sizeof ( uint64_t ) ) ;
}

int main ( void )
{
    test_Message m = { -69 , { { . encode =  primary } , NULL } , test_Message_primary_tag , { testEnum__tw_2_o } } ;
    pb_byte_t b [ 50 ] = { 0 } ;
    pb_ostream_t o = pb_ostream_from_buffer ( b , 50 ) ;
    if ( ! pb_encode( & o , test_Message_fields , & m ) ) exit ( 1 ) ;
    write ( 1 , b , o . bytes_written ) ;
    return 0 ;
}
