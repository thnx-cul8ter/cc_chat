if not fs.exists("/json.lua") then
    shell.run("wget https://raw.githubusercontent.com/rxi/json.lua/master/json.lua json.lua")
end
local version=1.1
local request = http.get("https://raw.githubusercontent.com/thnx-cul8ter/cc_chat/main/version.txt")
local on=true
if tonumber(request.readAll()) > version then
	print("update found")
	os.sleep(1)
	shell.run("rm chat.lua")
	shell.run("wget https://raw.githubusercontent.com/thnx-cul8ter/cc_chat/main/chat.lua")
	on=false
	print("done updateing, please rerun chat")
end
local json=dofile("json.lua")
mod=peripheral.wrap("back")
mod.open(8088)
local input=function()
    while true do
    print("enter a command")
        local inp=io.read()
        if inp=="send" then
            local msg={}
            print("who do you want to send to")
            msg.name=io.read()
            print("type message here")
            msg.message=os.getComputerLabel()..": "..io.read()
            mod.transmit(8088,8088,json.encode(msg))
        elseif inp=="exit" then
            on=false
        else
            print("not a valid command")
        end
    end
end
local output=function()
	while true do
        local _,_,freq,_,message=os.pullEvent("modem_message")
        if freq==8088 then
            message=json.decode(message)
            if message.name==os.getComputerLabel() or message.name=="all" then
                print(message.message)
            end
        end
   end
end
while on do
    parallel.waitForAny(input,output)
end
