-- kjellButtons

function setup()
   DEBUG = true
   viewer.mode = STANDARD
   parameter.action("Disable", function() b:disable() end)
   parameter.action("Enable", function() b:enable() end)
   
   tc = TouchController()
   testCanvas()
   tc:addInstance(canvas)
   
   b = Button(vec2(100, HEIGHT - 100), 30, color(229, 50, 50))
   b:setSprite(asset.documents.Dropbox.material_play)
   b:setCallbackPressed(function() log("Pressed 1") end)
   b:setCallbackReleased(function() log("Released 1") end)
   b:setCallbackHovered(function() log("Hovered 1") end)
   tc:insertInstance(b, 1)
   
   mb = MultiButton(3, vec2(100, HEIGHT - 200), vec2(1, 0), 30, color(165, 0, 255))
   mb:setSprite(asset.documents.Dropbox.material_pause)
   mb:setCallbackPressed(function() log("Pressed 2") end)
   mb:setCallbackReleased(function() log("Released 2") end)
   mb:setCallbackHovered(function() log("Hovered 2") end)
   tc:insertInstance(mb, 2)
   
   sb = SliderButton(vec2(100, HEIGHT - 300), vec2(80, -30), 30, color(0, 0, 255))
   sb:setCallbackPressed(function() log("Pressed 3") end)
   sb:setCallbackReleased(function() log("Released 3") end)
   sb:setCallbackHovered(function() log("Hovered 3") end)
   tc:insertInstance(sb, 3)
end

function draw()
   background(28)
   tc:update()
   canvas:update()
   canvas:draw()
   b:draw()
   mb:draw()
   sb:draw()
end

function touched(touch)
   tc:touched(touch)
end

function testCanvas()
   canvas = PinchPanCanvas()
end
