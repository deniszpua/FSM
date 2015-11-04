------------------------------
-- Provide some functions for file path manipulation.
-- Operates properly on filenames, that have no dots in their names except one
-- separating fileanme from extension.
-- @module path
local M = {}

local string = string

if setfenv then
  setfenv(1, M) -- for 5.1
else
  _ENV = M -- for 5.2
end

---------------------------------------------------------------------------
-- Separates filename from file's location
-- Operates properly on filenames, that have no dots in their names except one
-- separating fileanme from extension.
-- @param #string path path to file
-- @return #string path to directory, containing file and filename
--                without extention
function M.extractArgumentsLocation(path)

  -- adding folder path, if absent
  if not string.find(path, '(.*)/(.*)') then
    path = '/' .. path
  end

  -- adding extension, if not present

  if not  string.find(path, '%.lua$') then
    path = path .. '.lua'
  end


  local location, filenameWithExtension, filename =
    string.match(path, '(.*)/(([^/]*).lua)')

  --  extract package name, if present
--  local package, moduleName = string.match(filenameWithExtension, '(.*)[.]([^.]*).lua')
--  if package then
--    location = location .. '/' .. string.gsub(package, '[.]', '/')
--    filename = moduleName
--  end


  return location, filename
end


return M
