MultiButton = class(Button)

MULTIBUTTON_OVERLAP = 0.2
MULTIBUTTON_MAX_ANGLE = math.pi / 6

function MultiButton:init(modes, pos, dir, radius, shade)
   Button.init(self, pos, radius, shade)
   self.modes = modes
   self:setDir(dir)
   self.expanded = false
   self.mode = 1
end

function MultiButton:setDir(dir)
   self.dir = dir:normalize()
   self.spine =
   self.dir * (self.modes - 1) * 2 * self.radius * (1 - MULTIBUTTON_OVERLAP)
   local modePos = {}
   for i = 1, self.modes do
      modePos[i] = self.spine * (i - 1) / (self.modes - 1)
   end
   self.modePos = modePos
end

function MultiButton:setSprite(sprite, mode)
   self.sprite = sprite
end

function MultiButton:isExpanded()
   return self.expanded
end

function MultiButton:expand()
   self.expanded = true
end

function MultiButton:collapse()
   self.expanded = false
   self.mode = self.modeSelected
end

function MultiButton:getPosMode(mode)
   return self.modePos[mode]
end

function MultiButton:drawExpandedButton()
   pushMatrix()
   pushStyle()
   translate(self.pos.x, self.pos.y)
   -- Draw spine
   lineCapMode(ROUND)
   stroke(self.scheme[BUTTON_IDLE])
   strokeWidth(2 * self.radius)
   line(0, 0, self.spine.x, self.spine.y)
   -- Draw selection
   ellipseMode(RADIUS)
   fill(self.scheme[BUTTON_HOVERED])
   noStroke()
   local posSelection = self:getPosMode(self.modeSelected)
   ellipse(posSelection.x, posSelection.y, self.radius)
   popStyle()
   popMatrix()
end

function MultiButton:draw()
   self:updateTimer()
   if self:isExpanded() then
      self:drawExpandedButton()
   else
      self:drawButton()
   end
end

function MultiButton:updateExpanded(touchx)
   if touchx.state == BEGAN and self:isExpanded() and not self:touchedSpine(touchx) then
      -- Check whether to collapse
      self:collapse()
      self.currentTouch = nil
      return true
   elseif not self:isExpanded() then
      -- Check whether to expand
      local stopHovering = touchx.state == CHANGED
      and not self:touchedButton(touchx)
      and self:isHovered()
      if stopHovering then
         local vec = touchx.pos - self.pos
         local angle = vec:angleBetween(self.dir)
         log("Stopped at angle", math.round(math.deg(angle)))
         if math.abs(angle) <= MULTIBUTTON_MAX_ANGLE then
            log("EXPAND")
            self:expand()
         end
      end
   end
   -- Update selected mode based on clamped scalar projection
   local vec = touchx.pos - self.pos
   local unitScalar = vec:dot(self.dir) / self.spine:len()
   local unitScalarClamped = math.max(0, math.min(1, unitScalar))
   self.modeSelected = math.round(unitScalarClamped * (self.modes - 1) + 1)
end

function MultiButton:touchedSpine(touchx)
   -- Check touch distance to clamped projection on spine
   local vec = touchx.pos - self.pos
   local unitScalar = vec:dot(self.dir) / self.spine:len()
   local unitScalarClamped = math.max(0, math.min(1, unitScalar))
   local projectionClamped = self.pos + unitScalarClamped * self.spine
   return touchx.pos:dist(projectionClamped) <= self.radius
end

function MultiButton:isTouched(touchx)
   if self:isExpanded() then
      if self:touchedSpine(touchx) then
         return true, false
      else
         return true, true
      end
   end
   return self:touchedButton(touchx)
end

function MultiButton:touched(touchx, context)
   if not self:isEnabled() then return end
   if not self:isValidTouchx(touchx) then return end
   local collapsed = self:updateExpanded(touchx)
   if collapsed then return end
   self:updateState(touchx)
end
