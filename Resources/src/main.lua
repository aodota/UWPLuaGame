
cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")
cc.FileUtils:getInstance():addSearchPath("../../../res/")



require "config"
require "cocos.init"



local function main()
    local scene = display.newScene("Hello UWP Lua")
    display.runScene(scene)

    local label = cc.Label:createWithSystemFont("Hello UWP Lua", "Arial", 32)
    label:setPosition(cc.p(display.cx, display.cy))
    scene:addChild(label)
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
