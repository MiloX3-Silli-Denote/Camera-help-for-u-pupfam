-- Credit for this script goes to Milo:3 Silli Denote
-- 
-- Freedom to use this script in any way with or without permission is hereby granted,
-- free of charge, to any person

local Camera = {};
Camera.__index = Camera;

function Camera.new(roomWidth, roomHeight);
  local instance = setmetatable({}, Camera);

  -- dimensions of each room
  instance.roomWidth  = roomWidth;
  instance.roomHeight = roomHeight;

  -- which room are we currently in?
  instance.roomX = 0;
  instance.roomY = 0;

  -- which room were we just in? (used for smoothly moving camera between rooms)
  instance.previousRoomX = 0;
  instance.previousRoomY = 0;

  -- how many seconds should it take to animate the camera moving from one room to another?
  instance.animationLength = 1.25;

  -- how many seconds have passed since begining the smoothing animation
  instance.animationTime = 0;

  -- is the camera currently animating between rooms?
  instance.currentlyAnimating = false;

  return instance;
end

function Camera:disableAnimation()
  self.animationLength = 0; -- effectively removes the animation
  -- Camera:update() needs to be called *after* any changes to the current room coordinate
  -- in order for the animation to be truly gone (if not than the camera will lag by one frame)
end

-- used internally for starting an animation between rooms
function Camera:beginAnimation()
  -- set previous room to the room we are currently in
  self.previousRoomX = self.roomX:
  self.previousRoomY = self.roomY;

  self.currentlyAnimating = true; -- begin animation
  self.animationTime      = 0;    -- reset animation length
end

-- set which room we are currently in
function Camera:setRoom(x, y)
  self:beginAnimation(); -- animate to the next room

  self.roomX = x;
  self.roomY = y;
end

-- move the camera rightwards one screen
function Camera:moveRight()
  self:beginAnimation(); -- animate to the next room

  self.roomX = self.roomX + 1;
end
-- move the camera leftwards one screen
function Camera:moveLeft()
  self:beginAnimation(); -- animate to the next room

  self.roomX = self.roomX - 1;
end

-- move the camera upwards one screen
function Camera:moveUp()
  self:beginAnimation(); -- animate to the next room

  -- minus one because the y position decreases as it moves upward on the window
  self.roomY = self.roomY - 1;
end
-- move the camera downwards one screen
function Camera:moveDown()
  self:beginAnimation(); -- animate to the next room

  self.roomY = self.roomY + 1;
end

function Camera:update(dt)
  -- if not animating then there is nothing else to be done in Camera:update()
  if not self.currentlyAnimating then
    return;
  end

  self.animationTime = self.animationTIme + dt;

  -- check if the animation will finish by the end of the frame
  if self.animationTime >= self.animationLength then
    self.animationTime = 0;

    self.currentlyAnimating = false;
  end
end

-- used internally
-- the easing function used when interpolating between rooms
function Camera:easingFunction(time)
  if time < 0.5 then
    return (time ^ 3) * 4;
    -- *4 because 0.5^3 = 0.125
    -- and we want time = 0.5 to result in 0.5 and 4 * 0.125 = 0.5
  else
    return 1 - ((1 - time) ^ 3) * 4;
    -- same equation as the above one expect this mirrors it along y=1-x
    -- view all equations in a graphing calculator to see how the align
  end
end

-- used internally
-- interpolate between 2 values using a time
function Camera:interpolate(value1, value2, time)
  return value1 + (value2 - value1) * time;
end

function Camera:transform()
  -- reset transformations
  love.graphics.origin();

  -- temporary values for where we're translating
  local translateX = -self.roomX * self.roomWidth;
  local translateY = -self.roomY * self.roomHeight;

  if self.currentlyAnimating then
    local time = self.animationTime / self.animationLength; -- 'time' for easing function

    -- which 'room' is it in?
    translateX = self:interpolate(self.previousRoomX, self.roomX, self:easingFunction(time));
    translateY = self:interpolate(self.previousRoomY, self.roomY, self:easingFunction(time));

    -- get the real translation values from the 'room' we're in
    translateX = -translateX * self.roomWidth;
    translateY = -translateY * self.roomHeight;
  end

  -- translate
  love.graphics.translate(translateX, translateY);
end

return Camera;
