local admins = {
  {"zxc","Xannyoff","0x960000","0x4B0082","0","false"},
  {"zxc","wwwvwwwwwww","0x960000","0x4B0082","0","false"},
  {"null","L3D451R7","0xF8FF00","0x8B0000","0","false"},
  {"null","1maksimgeims1","0xFF0000","0x8B0000","0","false"},
  {"team","zaz0990","0xFF0000","0x32CD32","0","false"},
  {"null","null","0x32FF00","0x000000","0","false"},
  {"null","null","0x32FF00","0x000000","0","false"},
  {"null","null","0x32FF00","0x000000","0","false"},
  {"null","null","0x32FF00","0x000000","0","false"},
  {"null","null","0x32FF00","0x000000","0","false"}
}
 
local com = require("component")
local computer = require("computer")
local unicode = require("unicode")
local fs = require('filesystem')
local event = require("event")
local gpu = com.gpu
local run = true

local w, h = 80, 25
local w2 = w / 2

local function get_time()
  local time_correction = 3
  io.open('/tmp/clock.dt', 'w'):write(''):close()
  return tonumber(string.sub(fs.lastModified('/tmp/clock.dt'), 1, -4)) + time_correction * 3600
end

local function disp_time(t)
  local days = (t / 86400)
  local hrs = (t % 86400) / 3600
  local mins = ((t % 86400) % 3600) / 60
  local sec = (t % 3600) % 60
  if days >= 1 then
    return string.format("%d дн. %02d ч.   ",days,hrs)
  elseif hrs >= 1 then
    return string.format("%02d ч. %02d мин.   ",hrs,mins)
  else
    return string.format("%02d мин. %02d сек.   ",mins,sec)
  end
end

local function save()
  local f = io.open("/home/tbl", "w")  
  f:write("List = {")
  for ind = 1,#admins do
    local w = tonumber(admins[ind][5])
    if ind == #admins then
      f:write(w)
    else
      f:write(w..',')
    end
  end
  f:write("}")
  f:close()
end

if not fs.exists("/home/tbl") then
  save()
end  
dofile("/home/tbl")
local t = {}
local t = List
local start_time = get_time()
for ind = 1,#t do
  if t[ind] == 0 then
    admins[ind][5] = start_time
  else
    admins[ind][5] = t[ind]
  end
end
for ind = 1,#admins do
  computer.removeUser(admins[ind][2])
end
os.execute("cls")
print("Коснитесь экрана")
computer.addUser(({event.pull("touch")})[6])
os.execute("cls")
gpu.setResolution(w, h)
gpu.setBackground(0x000000)
gpu.setForeground(0x333333)
for i = 1,w do
  gpu.set(i,1,"=")
  gpu.set(i,h,"=")
end
for i = 1,h do
  gpu.set(1, i, "||")
  gpu.set(w-1, i, "||")
end
gpu.setForeground(0x66FF00)
gpu.set(w2 - unicode.len("[ CloseAdmins ]")/2,1," ")
gpu.set(w2 - unicode.len("Списосок")/2,3,"Списососк")
local line = 10
for ind = 1,#admins do
  gpu.setForeground(0x2D2D2D)
  gpu.set(10,line,"[")
  gpu.set(11+unicode.len(admins[ind][1]),line,"]")
  gpu.setForeground(tonumber(admins[ind][3]))
  gpu.set(11,line,admins[ind][1])
  gpu.setForeground(tonumber(admins[ind][4]))
  gpu.set(30,line,admins[ind][2])
  line = line + 1
end
 
while run do
  local current_time = get_time()
  local line = 10
  for ind = 1,#admins do
    if computer.addUser(admins[ind][2]) then
      computer.removeUser(admins[ind][2])
      gpu.setForeground(0x00FF00)
      gpu.set(47,line,"online ")
      if admins[ind][6] == "false" then
        admins[ind][5] = current_time
        admins[ind][6] = "true"
      end
    else
      gpu.setForeground(0x2D2D2D)
      gpu.set(47,line,"offline")
      if admins[ind][6] == "true" then
        admins[ind][5] = current_time
        admins[ind][6] = "false"
      end
    end
    gpu.set(57,line,disp_time(current_time-admins[ind][5]))
    line = line + 1
  end
  local e = ({event.pull(5,"key_down")})[4]
  if e == 29 or e == 157 then -- Ctrl Выход
    save()
    gpu.setResolution(w,h)
    gpu.setBackground(0x000000)
    gpu.setForeground(0xFFFFFF)
    os.execute("cls")
    run = false
    os.exit()
  end
end

if run then
  computer.shutdown(false)
end
