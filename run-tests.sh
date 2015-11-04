


# constructing buildpath
#	project location
	PROJECT_LOCATION=`pwd`

#	add project folders to path

# export LUA_PATH=$LUA_PATH$PROJECT_LOCATION/../lunit/src/?.lua\;$PROJECT_LOCATION/src/main/?.lua\;$PROJECT_LOCATION/test/main/?.lua\;$PROJECT_LOCATION/libs/?.lua\;\;

lua ./libs/simpletest.lua pathfile=$PROJECT_LOCATION/buildpath $PROJECT_LOCATION/test/main.test-fsm.lua $PROJECT_LOCATION/test/main.test-state.lua $PROJECT_LOCATION/test/main/testJsonLoader.lua