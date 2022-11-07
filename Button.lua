Button = class()

BUTTON_DISABLED = 0
BUTTON_IDLE = 1
BUTTON_HELD = 2
BUTTON_HOVERED = 3

function Button:init(pos, radius, shade)
   self.pos = pos
   self.radius = radius
   self.state = BUTTON_IDLE
   self.hoverTime = 0.5
   self:setColorScheme(shade)
end

function Button:setSprite(sprite)
   self.sprite = sprite
end

-- Test states
function Button:isEnabled()
   return self.state ~= BUTTON_DISABLED
end

function Button:isIdle()
   return self.state == BUTTON_IDLE
end

function Button:isHeld()
   return self.state == BUTTON_HELD or self.state == BUTTON_HOVERED
end

function Button:isHovered()
   return self.state == BUTTON_HOVERED
end

-- Set states
function Button:enable()
   log("Current state:", self.state)
   self.state = self:isEnabled() and self.state or BUTTON_IDLE
   log("New state:", self.state)
   return self.state
end

function Button:disable()
   self.state = BUTTON_DISABLED
   self.currentTouch = nil
   return self.state
end

function Button:setIdle()
   self.state = BUTTON_IDLE
end

function Button:setHeld()
   self.state = BUTTON_HELD
end

function Button:setHovered()
   self.state = BUTTON_HOVERED
end

-- Callbacks
function Button:setSubject(subject)
   self.subject = subject
end

function Button:resetSubject(subject)
   self.subject = nil
end

function Button:setCallbackPressed(callback)
   self.callbackPressed = callback
end

function Button:resetCallbackPressed()
   self.callbackPressed = nil
end

function Button:doCallbackPressed()
   if self.callbackPressed then self.callbackPressed(self.subject) end
end

function Button:setCallbackReleased(callback)
   self.callbackReleased = callback
end

function Button:resetCallbackReleased()
   self.callbackReleased = nil
end

function Button:doCallbackReleased()
   if self.callbackReleased then self.callbackReleased(self.subject) end
end

function Button:setCallbackHovered(callback)
   self.callbackHovered = callback
end

function Button:resetCallbackHovered()
   self.callbackHovered = nil
end

function Button:doCallbackHovered()
   if self.callbackHovered and self:isHovered() then
      self.callbackHovered(self.subject)
   end
end

-- Drawing and appearance
function Button:setColorScheme(shade, hovered, disabled)
   -- Shades
   shade = shade or color(255)
   local shade75, shade50
   shade75 = hovered or 0.75 * shade
   shade75.a = 255
   shade50 = disabled or 0.50 * shade
   shade50.a = 255
   -- Scheme
   local scheme = {}
   scheme[BUTTON_IDLE] = shade
   scheme[BUTTON_HELD] = shade
   scheme[BUTTON_HOVERED] = hovered or shade75
   scheme[BUTTON_DISABLED] = disabled or shade50
   self.scheme = scheme
   -- Sprites
   local schemeSprite = {}
   schemeSprite[BUTTON_IDLE] = color(255)
   schemeSprite[BUTTON_HELD] = color(255)
   schemeSprite[BUTTON_HOVERED] = color(255)
   schemeSprite[BUTTON_DISABLED] = color(127)
   self.schemeSprite = schemeSprite
end

function Button:drawButton()
   pushMatrix()
   pushStyle()
   translate(self.pos.x, self.pos.y)
   ellipseMode(RADIUS)
   fill(self.scheme[self.state])
   noStroke()
   ellipse(0, 0, self.radius)
   if self.sprite then
      spriteMode(RADIUS)
      tint(self.schemeSprite[self.state])
      sprite(self.sprite, 0, 0, 0.6 * self.radius)
   end
   popStyle()
   popMatrix()
end

function Button:draw()
   self:updateTimer()
   self:drawButton()
end

-- Interaction
function Button:updateTimer()
   if self.timer then
      self.timer = self.timer + DeltaTime
      if self.timer >= self.hoverTime then
         self:doCallbackHovered()
         self.timer = nil
      end
   end
end

function Button:isValidTouchx(touchx)
   self.currentTouch = self.currentTouch or touchx
   if touchx ~= self.currentTouch then return false end
   return true
end

function Button:touchedButton(touchx)
   return touchx.pos:dist(self.pos) <= self.radius
end

function Button:isTouched(touchx)
   return self:touchedButton(touchx)
end

function Button:updateState(touchx)
   if touchx.state == BEGAN then
      -- Pressed
      self:doCallbackPressed()
      self.timer = 0
   end
   if touchx.state == ENDED or touchx.state == CANCELLED then
      -- Released
      if self:isHovered() then
         self:doCallbackReleased()
      end
      self:setIdle()
      self.currentTouch = nil
   elseif self:touchedButton(touchx) then
      -- Hovered
      self:setHovered()
   else
      -- Held
      self:setHeld()
      self.timer = nil
   end
end

function Button:touched(touchx, context)
   if not self:isEnabled() then return end
   if not self:isValidTouchx(touchx) then return end
   self:updateState(touchx)
end
