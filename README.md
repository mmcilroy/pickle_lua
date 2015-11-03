# pickle_lua
Auto generate protobuf, c++ wrappers and lua bindings from metadata

lua gen.lua -s schema -o output -p package

protoc --cpp_out=. *.proto
