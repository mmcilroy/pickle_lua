
// g++ -std=c++11 -I. -Ioutput test_schema3.cpp output/*.cc -lprotobuf

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
    virtual void process( message_ptr cmd ) {}

    // called once event has been persisted
    // user must apply event to mutate stage
    virtual void apply( message_ptr evt ) = 0;

    // persist event provided and call persisted once complete
    template< typename H >
    void persist( std::initializer_list< message_ptr > evts, H completionHandler )
    {
        for( auto evt : evts ) {
            apply( evt );
        }

        completionHandler();
    }
};



// ----------------------------------------------------------------------------
class pass_thru_stage : public persistence_stage
{
public:
    void process( send_to_venue_command_ptr cmd )
    {
        message_ptr evt1( new send_to_venue_event );
        message_ptr evt2( new send_to_venue_event );
        evt1->data_ = "evt1";
        evt2->data_ = "evt2";
        cmd->data_ = "cmd";

        persist( { evt1, evt2 }, [ cmd ]() {
            std::cout << "complete: " << cmd->data_ << std::endl;
        } );
    }

    virtual void apply( message_ptr evt )
    {
        std::cout << "apply: " << evt->data_ << std::endl;
    }
};



// ----------------------------------------------------------------------------
int main()
{
    send_to_venue_command_ptr cmd1( new send_to_venue_command );
    pass_thru_stage stage;
    stage.process( cmd1 );
}
