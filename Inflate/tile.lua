class = require 'middleclass'

Tile = class("Tile")

function Tile:initialize( RelativeX , RelativeY , size )
	self.RelativePosition = Vector2:new( RelativeX , RelativeY )
	self.PositionInGrid = Vector2:new( RelativeX * size , RelativeY * size )
 	self.size = size
 	self.ColorVariation = 15
 	self.ColorAlter = - 30
 	self:ChangeRandomColor()
end

function Tile:draw( GridX , GridY )
	love.graphics.setColor( self.color:GetRGBA() )
	love.graphics.rectangle( "fill" , GridX + self.PositionInGrid.x , GridY + self.PositionInGrid.y , self.size , self.size )
	love.graphics.setColor( 255 , 255 , 255 , 20 )
	love.graphics.rectangle( "line" , GridX + self.PositionInGrid.x , GridY + self.PositionInGrid.y , self.size , self.size )
end

function Tile:ChangeRandomColor()
	local ColorChange = math.random( self.ColorVariation ) - self.ColorVariation / 2 
	local r , g , b  = self:AlterColors( BackgroundColor:GetRGBA() ) 
 	self.color = Color:new( r + ColorChange , g + ColorChange, b + ColorChange , 200 )
end	

function Tile:AlterColors( r , g , b )
	return r + self.ColorAlter , g + self.ColorAlter , b + self.ColorAlter
end
