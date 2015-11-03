
// g++ -std=c++11 -I. -Ioutput test_schema2.cpp output/*.cc -lprotobuf

#include "send_to_venue_command.hpp"
#include "send_to_client_command.hpp"
#include "send_to_venue_event.hpp"
#include "send_to_client_event.hpp"

typedef std::shared_ptr< send_to_venue_command > send_to_venue_command_ptr;
typedef std::shared_ptr< send_to_client_command > send_to_client_command_ptr;
typedef std::shared_ptr< send_to_venue_event > send_to_venue_event_ptr;
typedef std::shared_ptr< send_to_client_event > send_to_client_event_ptr;



// ----------------------------------------------------------------------------
class stage
{
public:
    virtual void process( message_ptr ) = 0;
};



// ----------------------------------------------------------------------------
class persistence_stage : public stage
{
public:
    // called on receipt of a message
    // user must convert cmd to a series of events and call persist()
    virtual void process( message_ptr cmd ) = 0;

protected:
    // persist event provided and call persisted once complete
    void persist( message_ptr evt, message_ptr cmd )
    {
        apply( evt, cmd );
    }

    // called once event has been persisted
    // user must apply event to mutate stage
    virtual void apply( message_ptr evt, message_ptr cmd ) = 0;
};



// ----------------------------------------------------------------------------
#include <map>
#include <set>

class pass_thru_stage : public persistence_stage
{
public:
    void process( message_ptr cmd )
    {
        std::string type = cmd->message_type();
        if( type == "send_to_venue_command" ) {
            process( std::static_pointer_cast< send_to_venue_command >( cmd ) );
        } else if( type == "send_to_client_command" ) {
            process( std::static_pointer_cast< send_to_client_command >( cmd ) );
        }
    }

protected:
    void process( send_to_venue_command_ptr cmd )
    {
        auto evt = std::make_shared< send_to_venue_event >();
        evt->id( cmd->id() );
        evt->user( cmd->header().user() );

        persist( evt, cmd );
    }

    void process( send_to_client_command_ptr cmd )
    {
        auto evt = std::make_shared< send_to_client_event >();
        evt->id( cmd->id() );

        persist( evt, cmd );
    }

    void apply( message_ptr evt, message_ptr cmd )
    {
        std::string type = cmd->message_type();
        if( type == "send_to_venue_command" ) {
            apply( std::static_pointer_cast< send_to_venue_event >( evt ), std::static_pointer_cast< send_to_venue_command >( cmd ) );
        } else if( type == "send_to_client_command" ) {
            apply( std::static_pointer_cast< send_to_client_event >( evt ), std::static_pointer_cast< send_to_client_command >( cmd ) );
        }
    }

    void apply( send_to_venue_event_ptr evt, send_to_venue_command_ptr cmd )
    {
        // only process the message if it hasnt been acked
        if( acknowledged_by_venue.count( evt->id() ) == 0 )
        {
            bool dupe = false;

            // maintain mapping between id and user
            // if it already exists this is a poss dupe
            if( id_to_client_map.count( evt->id() ) == 0 ) {
                id_to_client_map[ evt->id() ] = evt->user();
            } else {
                dupe = true;
            }

            // send to next stage
            if( cmd )
            {
                cmd->header().dupe( dupe );
                // send to next stage
            }
        }
    }

    void apply( send_to_client_event_ptr evt, send_to_client_command_ptr cmd )
    {
        // only process the message if it hasnt been acked
        if( acknowledged_by_client.count( evt->id() ) == 0 )
        {
            bool dupe = false;

            // keep track of everything already sent
            // set poss dupe if message might have been sent previously
            if( sent_to_client.count( evt->id() ) == 0 ) {
                sent_to_client.insert( evt->id() );
            } else {
                dupe = true;
            }

            if( cmd )
            {
                // set user so the message is sent to the right client
                if( id_to_client_map.count( evt->id() ) > 0 ) {
                    cmd->header().user( id_to_client_map[ evt->id() ] );
                } else {
                    // error! dont know what client to send to
                }

                // send to next stage
                cmd->header().dupe( dupe );
                // send to next stage
            }
        }
    }

private:
    std::map< std::string, std::string > id_to_client_map;
    std::set< std::string > sent_to_client;
    std::set< std::string > acknowledged_by_client;
    std::set< std::string > acknowledged_by_venue;
};



// ----------------------------------------------------------------------------
int main()
{
    pass_thru_stage stage;

    message_ptr cmd1( new send_to_venue_command );
    stage.process( cmd1 );

    message_ptr cmd2( new send_to_client_command );
    stage.process( cmd2 );
}
