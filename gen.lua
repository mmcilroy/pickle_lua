require 'gen_data'

function to_camel_case( ident )
    function fn( s )
        return string.upper( s:sub( 2,2 ) )
    end
    ident = string.gsub( ident, '_.', fn )
    return string.upper( ident:sub( 1, 1 ) ) .. ident:sub( 2, #ident )
end

function is_primitive_type( msg )
    return msg[ 'type' ] == 'bool' or
           msg[ 'type' ] == 'string' or
           msg[ 'type' ] == 'uint32' or
           msg[ 'type' ] == 'uint64' or
           msg[ 'type' ] == 'fixed32'
end

function is_repeated_type( msg )
    return msg[ 'presence' ] == 'repeated'
end

function gen( str, msg )
    str = string.gsub( str, '$CPP_MESSAGE', cpp_message )
    str = string.gsub( str, '$PROTO_MESSAGE', proto_message )
    if msg ~= nil then
        id = msg[ 'id' ]
        name = msg[ 'name' ]
        proto_type = msg[ 'type' ]
        cpp_type = msg[ 'type' ]
        field = msg[ 'name' ]
        presence = msg[ 'presence' ]
        str = string.gsub( str, '$ID', id )
        str = string.gsub( str, '$NAME', name )
        str = string.gsub( str, '$CPP_TYPE', cpp_type )
        str = string.gsub( str, '$FIELD', field )
        str = string.gsub( str, '$PRESENCE', presence )
        if is_primitive_type( msg ) then
            str = string.gsub( str, '$PROTO_TYPE', proto_type )
        else
            str = string.gsub( str, '$PROTO_TYPE', to_camel_case( proto_type ) )
        end
    end
    io.write( str )
end

function gen_init( msg )
    cpp_message = msg
    proto_message = to_camel_case( msg )
end

function gen_proto( msg )
    io.output( msg .. '.proto' )
    gen_init( msg )

    _header =
        'syntax = "proto2";\n'
    _import =
        'import "$CPP_TYPE.proto";\n'
    _message =
        'message $PROTO_MESSAGE\n' ..
        '{\n'
    _body =
        '    $PRESENCE $PROTO_TYPE $FIELD = $ID;\n'
    _footer =
        '}\n\n'

    gen( _header )
    for k, v in pairs( _G[ msg ] ) do
        if not is_primitive_type( v ) then
            gen( _import, v )
        end
    end
    gen( _message )
    for k, v in pairs( _G[ msg ] ) do
        gen( _body, v )
    end
    gen( _footer )
end

function gen_cpp( msg, child )
    io.output( msg .. '.hpp' )
    gen_init( msg )

    _include =
        '#include "$CPP_TYPE.hpp"\n'
    _class_header =
        '#include "$CPP_MESSAGE.pb.h"\n\n' ..
        'class $CPP_MESSAGE\n' ..
        '{\n' ..
        'friend std::ostream& operator<<( std::ostream&, const $CPP_MESSAGE& );\n' ..
        'public:\n'
    _size_proto = 
        '    size_t size();\n'
    _primitive_field_proto =
        '    bool has_$FIELD() const;\n' ..
        '    void clear_$FIELD();\n' ..
        '    void $FIELD( $CPP_TYPE );\n' ..
        '    $CPP_TYPE $FIELD() const;\n'
    _primitive_repeated_field_proto =
        '    void clear_$FIELD();\n' ..
        '    size_t $FIELD_size() const;\n' ..
        '    void $FIELD( $CPP_TYPE );\n' ..
        '    $CPP_TYPE $FIELD( int ) const;\n'
    _non_primitive_field_proto =
        '    bool has_$FIELD() const;\n' ..
        '    void clear_$FIELD();\n' ..
        '    $CPP_TYPE $FIELD();\n'
    _non_primitive_repeated_field_proto =
        '    void clear_$FIELD();\n' ..
        '    size_t $FIELD_size() const;\n' ..
        '    $CPP_TYPE $FIELD();\n' ..
        '    $CPP_TYPE $FIELD( int );\n'
    _class_footer =
        '};\n' ..
        'inline std::ostream& operator<<( std::ostream& out, const $CPP_MESSAGE& msg )\n' ..
        '{\n' ..
        '    out << msg.pb_.DebugString();\n' ..
        '    return out;\n' ..
        '}\n'

    _size_impl = 
        'inline size_t $CPP_MESSAGE::size()\n' ..
        '{\n' ..
        '    return pb_.ByteSize();\n' ..
        '}\n'
    _primitive_field_impl =
        'inline bool $CPP_MESSAGE::has_$FIELD() const\n' ..
        '{\n' ..
        '   return pb_.has_$FIELD();\n' ..
        '}\n' ..
        'inline void $CPP_MESSAGE::clear_$FIELD()\n' ..
        '{\n' ..
        '    return pb_.clear_$FIELD();\n' ..
        '}\n' ..
        'inline void $CPP_MESSAGE::$FIELD( $CPP_TYPE v )\n' ..
        '{\n' ..
        '    pb_.set_$FIELD( v );\n' ..
        '}\n' ..
        'inline $CPP_TYPE $CPP_MESSAGE::$FIELD() const\n' ..
        '{\n' ..
        '    return pb_.$FIELD();\n' ..
        '}\n'
    _primitive_repeated_field_impl =
        'inline void $CPP_MESSAGE::clear_$FIELD()\n' ..
        '{\n' ..
        '    return pb_.clear_$FIELD();\n' ..
        '}\n' ..
        'inline size_t $CPP_MESSAGE::$FIELD_size() const\n' ..
        '{\n' ..
        '    return pb_.$FIELD_size();\n' ..
        '}\n' ..
        'inline void $CPP_MESSAGE::$FIELD( $CPP_TYPE v )\n' ..
        '{\n' ..
        '    return pb_.add_$FIELD( v );\n' ..
        '}\n' ..
        'inline $CPP_TYPE $CPP_MESSAGE::$FIELD( int i ) const\n' ..
        '{\n' ..
        '    return pb_.$FIELD( i );\n' ..
        '}\n'
    _non_primitive_field_impl =
        'inline bool $CPP_MESSAGE::has_$FIELD() const\n' ..
        '{\n' ..
        '   return pb_.has_$FIELD();\n' ..
        '}\n' ..
        'inline void $CPP_MESSAGE::clear_$FIELD()\n' ..
        '{\n' ..
        '    return pb_.clear_$FIELD();\n' ..
        '}\n' ..
        'inline $CPP_TYPE $CPP_MESSAGE::$FIELD()\n' ..
        '{\n' ..
        '    return $CPP_TYPE( *pb_.mutable_$FIELD() );\n' ..
        '}\n'
    _non_primitive_repeated_field_impl =
        'inline void $CPP_MESSAGE::clear_$FIELD()\n' ..
        '{\n' ..
        '    return pb_.clear_$FIELD();\n' ..
        '}\n' ..
        'inline size_t $CPP_MESSAGE::$FIELD_size() const\n' ..
        '{\n' ..
        '    return pb_.$FIELD_size();\n' ..
        '}\n' ..
        'inline $CPP_TYPE $CPP_MESSAGE::$FIELD()\n' ..
        '{\n' ..
        '    return $CPP_TYPE( *pb_.add_$FIELD() );\n' ..
        '}\n' ..
        'inline $CPP_TYPE $CPP_MESSAGE::$FIELD( int i )\n' ..
        '{\n' ..
        '    return $CPP_TYPE( *pb_.mutable_$FIELD( i ) );\n' ..
        '}\n'

    if child then
        _class_header = _class_header ..
            '    $CPP_MESSAGE( $PROTO_MESSAGE& );\n'
        _class_footer =
            'private:\n' ..
            '    $PROTO_MESSAGE& pb_;\n' ..
            _class_footer ..
            'inline $CPP_MESSAGE::$CPP_MESSAGE( $PROTO_MESSAGE& pb ) : pb_( pb )\n' ..
            '{\n' ..
            '}\n'
    else
        _class_footer =
            'private:\n' ..
            '    $PROTO_MESSAGE pb_;\n' ..
            _class_footer
    end

    for k, v in pairs( _G[ msg ] ) do
        if not is_primitive_type( v ) then
            gen( _include, v )
        end
    end

    gen( _class_header )
    gen( _size_proto )

    for k, v in pairs( _G[ msg ] ) do
        if is_primitive_type( v ) then
            if is_repeated_type( v ) then
                gen( _primitive_repeated_field_proto, v )
            else
                gen( _primitive_field_proto, v )
            end
        else
            if is_repeated_type( v ) then
                gen( _non_primitive_repeated_field_proto, v )
            else
                gen( _non_primitive_field_proto, v )
            end
        end
    end

    gen( _class_footer )
    gen( _size_impl )

    for k, v in pairs( _G[ msg ] ) do
        if is_primitive_type( v ) then
            if is_repeated_type( v ) then
                gen( _primitive_repeated_field_impl, v )
            else
                gen( _primitive_field_impl, v )
            end
        else
            if is_repeated_type( v ) then
                gen( _non_primitive_repeated_field_impl, v )
            else
                gen( _non_primitive_field_impl, v )
            end
        end
    end
end

gen_proto( 'key_value' )
gen_proto( 'packet_header' )
gen_proto( 'message_header' )
gen_proto( 'new_order_single' )

gen_cpp( 'key_value', true )
gen_cpp( 'packet_header', false )
gen_cpp( 'message_header', false )
gen_cpp( 'new_order_single', false )
