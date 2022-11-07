SliderButton = class(Button)

function SliderButton:init(posSpine, spine, radius, shade)
   Button.init(self, posSpine, radius, shade)
   self.posSpine = posSpine
   self.spine = spine
   self.value = 0
end

function SliderButton:drawSpine()
   pushMatrix()
   pushStyle()
   translate(self.posSpine.x, self.posSpine.y)
   lineCapMode(ROUND)
   stroke(self.scheme[BUTTON_DISABLED])
   strokeWidth(2 * self.radius)
   line(0, 0, self.spine.x, self.spine.y)
   popStyle()
   popMatrix()
end

function SliderButton:draw()
   self:drawSpine()
   Button.draw(self)
end

function SliderButton:touchedSpine(touchx)
   -- Check touch distance to clamped projection on spine
   local vec = touchx.pos - self.posSpine
   local unitScalar = vec:dot(self.spine:normalize()) / self.spine:len()
   local unitScalarClamped = math.max(0, math.min(1, unitScalar))
   local projectionClamped = self.posSpine + unitScalarClamped * self.spine
   return touchx.pos:dist(projectionClamped) <= self.radius
end

function SliderButton:isTouched(touchx)
   return self:touchedSpine(touchx)
end

function SliderButton:updateValue(touchx)
   local vec = touchx.pos - self.posSpine
   local unitScalar = vec:dot(self.spine:normalize()) / self.spine:len()
   self.value = math.max(0, math.min(1, unitScalar))
end

function SliderButton:touched(touchx, context)
   if not self:isEnabled() then return end
   if not self:isValidTouchx(touchx) then return end
   self:updateValue(touchx)
   self.pos = self.posSpine + self.spine * self.value
   self:updateState(touchx)
end
