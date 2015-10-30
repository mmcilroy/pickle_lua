#include <cstdint>
#include <iostream>
typedef uint32_t uint32;
typedef uint64_t uint64;
using namespace std;

#include "new_order_single.hpp"

int main()
{
    new_order_single nos;
    nos.clordid( "12345" );
    nos.order_qty( 999 );

    {
        key_value kv = nos.appendage();
        kv.key( "1" );
        kv.val( "one" );
    }

    {
        key_value kv = nos.appendage();
        kv.key( "2" );
        kv.val( "two" );
    }

    std::cout << nos.size() << std::endl;
    std::cout << nos << std::endl;
    std::cout << nos.has_clordid() << std::endl;
    std::cout << nos.has_security() << std::endl;
}
