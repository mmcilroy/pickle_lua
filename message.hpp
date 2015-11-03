#pragma once

#include <cstdint>
#include <string>
#include <memory>
#include <iostream>
typedef uint32_t uint32;
typedef uint64_t uint64;
using namespace std;

class message
{
public:
    string data_;



    message( string type ) :
        type_( type )
    {
    }

    // identifies the concrete message type
    string message_type()
    {
        return type_;
    }

    // serialize to a buffer
    virtual void encode( char*, size_t ) const = 0;

    // decode from a buffer
    virtual void decode( const char*, size_t ) = 0;

private:
    string type_;
};

typedef std::shared_ptr< message > message_ptr;
