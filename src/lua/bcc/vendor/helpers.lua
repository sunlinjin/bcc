function string.starts(String,Start)
  return string.sub(String,1,string.len(Start))==Start
end

function string.ends(String,End)
  return End=='' or string.sub(String,-string.len(End))==End
end

function string.escape(s)
  return s:gsub('[%-%.%+%[%]%(%)%$%^%%%?%*]','%%%1')
end

--- split a string into a list of strings separated by a delimiter.
-- @param s The input string
-- @param re A Lua string pattern; defaults to '%s+'
-- @param plain don't use Lua patterns
-- @param n optional maximum number of splits
-- @return a list-like table
-- @raise error if s is not a string
function string.split(s,re,plain,n)
  local find,sub,append = string.find, string.sub, table.insert
  local i1,ls = 1,{}
  if not re then re = '%s+' end
  if re == '' then return {s} end
  while true do
    local i2,i3 = find(s,re,i1,plain)
    if not i2 then
      local last = sub(s,i1)
      if last ~= '' then append(ls,last) end
      if #ls == 1 and ls[1] == '' then
        return {}
      else
        return ls
      end
    end
    append(ls,sub(s,i1,i2-1))
    if n and #ls == n then
      ls[#ls] = sub(s,i1)
      return ls
    end
    i1 = i3+1
  end
end

function table.count(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function table.bsearch(list, value, mkval)
  local low = 1
  local high = #list
  while low <= high do
    local mid = math.floor((low+high)/2)
    local this = mkval and mkval(list[mid]) or list[mid]
    if this > value then
      high = mid - 1
    elseif this < value then
      low = mid + 1
    else
      return mid
    end
  end
  return nil
end

function table.join(a, b)
  assert(a)
  if b == nil or #b == 0 then
    return a
  end

  local res = {}
  for _, v in ipairs(a) do
    table.insert(res, v)
  end
  for _, v in ipairs(b) do
    table.insert(res, v)
  end
  return res
end

function table.build(iterator_fn, build_fn)
  build_fn = (build_fn or function(arg) return arg end)
  local res = {}
  while true do
    local vars = {iterator_fn()}
    if vars[1] == nil then break end
    table.insert(res, build_fn(vars))
  end
  return res
end

function table.values(T)
  local V = {}
  for k, v in pairs(T) do
    table.insert(V, v)
  end
  return V
end

function table.tuples(T)
  local i = 0
  local n = table.getn(t)
  return function ()
    i = i + 1
    if i <= n then return t[i][1], t[i][2] end
  end
end

getmetatable("").__mod = function(a, b)
  if not b then
    return a
  elseif type(b) == "table" then
    return string.format(a, unpack(b))
  else
    return string.format(a, b)
  end
end

function os.exists(path)
  local f=io.open(path,"r")
  if f~=nil then
    io.close(f)
    return true
  else
    return false
  end
end

function os.spawn(...)
  local cmd = string.format(...)
  local proc = assert(io.popen(cmd))
  local out = proc:read("*a")
  proc:close()
  return out
end

local function logline(...)
  if not log.enabled then
    return
  end

  local c_green = "\27[32m"
  local c_grey = "\27[1;30m"
  local c_clear = "\27[0m"

  local msg = string.format(...)
  local info = debug.getinfo(2, "Sln")
  local line = string.format("%s[%s:%s]%s %s", c_grey,
    info.short_src:match("^.+/(.+)$"), info.currentline, c_clear, info.name)

  io.stderr:write(
    string.format("%s[%s]%s %s: %s\n", c_green,
      os.date("%H:%M:%S"), c_clear, line, msg))
end

log = { info = logline, enabled = true }
