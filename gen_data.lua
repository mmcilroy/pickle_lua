
packet_header = {
    { id=1, name='protocol', type='fixed32', presence='optional' },
    { id=2, name='version', type='fixed32', presence='optional' },
    { id=3, name='length', type='fixed32', presence='optional' },
    { id=4, name='num_messages', type='fixed32', presence='optional' }
}

message_header = {
    { id=1, name='id', type='uint32', presence='optional' },
    { id=2, name='length', type='uint32', presence='optional' },
    { id=3, name='type', type='uint32', presence='optional' },
    { id=4, name='user', type='string', presence='optional' },
    { id=5, name='sent', type='uint32', presence='optional' },
    { id=6, name='dupe', type='bool', presence='optional' }
}

new_order_single = {
    { id=1, name='clordid', type='string', presence='optional' },
    { id=2, name='security', type='string', presence='optional' },
    { id=3, name='security_id_source', type='string', presence='optional' },
    { id=4, name='security_exchange', type='string', presence='optional' },
    { id=5, name='country', type='string', presence='optional' },
    { id=6, name='currency', type='string', presence='optional' },
    { id=7, name='account', type='string', presence='optional' },
    { id=8, name='side', type='string', presence='optional' },
    { id=9, name='handl_inst', type='string', presence='optional' },
    { id=10, name='exec_inst', type='string', presence='optional' },
    { id=11, name='time_in_force', type='string', presence='optional' },
    { id=12, name='order_capacity', type='string', presence='optional' },
    { id=13, name='order_type', type='string', presence='optional' },
    { id=14, name='order_qty', type='uint32', presence='optional' },
    { id=15, name='order_px', type='uint32', presence='optional' },
    { id=16, name='stop_px', type='uint32', presence='optional' },
    { id=17, name='min_qty', type='uint32', presence='optional' },
    { id=18, name='max_qty', type='uint32', presence='optional' },
    { id=1000, name='appendage', type='key_value', presence='repeated' }
}

key_value = {
    { id=1, name='key', type='string', presence='optional' },
    { id=2, name='val', type='string', presence='optional' }
}
