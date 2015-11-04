


# constructing buildpath
#	project location
	PROJECT_LOCATION=`pwd`

#	add project folders to path

export LUA_PATH=$LUA_PATH$PROJECT_LOCATION/libs/?.lua\;$PROJECT_LOCATION/src/?.lua\;$PROJECT_LOCATION/test/?.lua\;\;
TEST_MODULES="'main.test-fsm.lua main.test-state.lua main.testJsonLoader.lua'"
lua -e "local M = require(\"testing.simpletest\") M.main($TEST_MODULES)"