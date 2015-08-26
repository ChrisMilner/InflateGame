class = require 'middleclass'

Button = class('Button')

function Button:initialize( text , x , y , width , height , color , highlight , textColor , effect )
	self.position = Vector2:new( x , y )
	self.size = Vector2:new( width , height )
	self.center = Vector2:new( self.position.x + self.size.x / 2 , self.position.y + self.size.y / 2 )
	self.color = color
	self.HighlightColor = highlight
	self.CurrentColor = self.color
	self.textColor = textColor
	self.text = text
	self.effect = effect

	self.Pressed = false
	self.PressTime = nil
	self.PressDuration = 0.2
	self.HeightChange = 5
	self.ColorChange = -20

	self.KeyboardSelected = false
end

function Button:draw()
	love.graphics.setColor( self.CurrentColor:GetRGBA() )
	love.graphics.rectangle( "fill" , self.position.x , self.position.y , self.size.x , self.size.y )
	
	love.graphics.setColor( self.textColor:GetRGBA() )
	love.graphics.setFont( SmallFont )
	love.graphics.printf( self.text , self.position.x , self.center.y - SmallFont:getHeight() / 2 , self.size.x , "center" )
end

function Button:update( dt )
	local x , y = love.mouse.getPosition()
	if x >= self.position.x and x <= self.position.x + self.size.x and y >= self.position.y and y <= self.position.y + self.size.y then
		self:Select( false )
	elseif self.KeyboardSelected == false then
		self:Deselect()
	end

	if self.Pressed == true and os.clock() >= self.PressTime + self.PressDuration then
		self.position.y = self.position.y - self.HeightChange
		self.Pressed = false
	end
end

function Button:CheckButtonClick( x , y )
	if x >= self.position.x and x <= self.position.x + self.size.x and y >= self.position.y and y <= self.position.y + self.size.y and self.Pressed == false then
		self:Press()
		self.effect()
	end
end

function Button:Press()
	self.Pressed = true
	self.PressTime = os.clock()
	self.position.y = self.position.y + self.HeightChange
end

function Button:Select( keyboard )
	CurrentMenu:DeselectAllButtons()
	self.CurrentColor = self.HighlightColor

	if keyboard == true then 
		self.KeyboardSelected = true 
	else
		self.KeyboardSelected = false
	end
end

function Button:Deselect()
	self.CurrentColor = self.color
end

function Button:IsSelected()
	return self.CurrentColor == self.HighlightColor
end
