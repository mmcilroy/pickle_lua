message_header = {
    { id=1, name='type', type='uint32', presence='optional' },
    { id=2, name='sent', type='uint32', presence='optional' },
    { id=3, name='user', type='string', presence='optional' },
    { id=4, name='dupe', type='bool', presence='optional' }
}

key_value = {
    { id=1, name='key', type='string', presence='optional' },
    { id=2, name='val', type='string', presence='optional' }
}

send_to_venue_command = {
    { id=1, name='header', type='message_header', presence='optional' },
    { id=2, name='data', type='key_value', presence='optional' },
    { id=3, name='type', type='string', presence='optional' },
    { id=4, name='id', type='string', presence='optional' }
}

send_to_client_command = {
    { id=1, name='header', type='message_header', presence='optional' },
    { id=2, name='data', type='key_value', presence='optional' },
    { id=3, name='type', type='string', presence='optional' },
    { id=4, name='id', type='string', presence='optional' }
}

send_to_venue_event = {
    { id=1, name='user', type='string', presence='optional' },
    { id=2, name='id', type='string', presence='optional' }
}

send_to_client_event = {
    { id=2, name='id', type='string', presence='optional' }
}

schema = {
    { name='message_header', parent=false },
    { name='key_value', parent=false },
    { name='send_to_venue_command', parent=true },
    { name='send_to_client_command', parent=true },
    { name='send_to_venue_event', parent=true },
    { name='send_to_client_event', parent=true }
}
