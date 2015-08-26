class = require 'middleclass'

Level = class("Level")

function Level:initialize( width , height , SquareSize)
	self.position = Vector2:new( 0 , 0 )
	self.size = Vector2:new( width , height )
	self.SquareSize = SquareSize
	self.ActualSize = Vector2:new( width * SquareSize , height * SquareSize )
	self.LastColorChangeTime = os.clock()
	self.ColorChangeBuffer = 0.4
	self.BorderSizeReduction = 30
	self.BorderColorReduction = 1.5

	grid = {}

	for WidthCount = 1 , width do
		grid[WidthCount] = {}

		for HeightCount = 1 , height do
			grid[WidthCount][HeightCount] = Tile:new( WidthCount - 1 , HeightCount - 1 , SquareSize )
		end
	end
end 

function Level:draw( PlayX , PlayY )
	for WidthCount = 1 , self.size.x do
		for HeightCount = 1 , self.size.y do
			grid[WidthCount][HeightCount]:draw( self.position.x , self.position.y )
		end
	end

	local TopMargin = ( ( PlayY - self.position.y ) * ( 1 + ( SoundEnergy / 50 ) ) ) / self.BorderSizeReduction
	local BottomMargin = ( ( self.position.y + self.ActualSize.y - PlayY ) * ( 1 + ( SoundEnergy / 50 ) ) ) / self.BorderSizeReduction
	local LeftMargin = ( ( PlayX - self.position.x ) * ( 1 + ( SoundEnergy / 50 ) ) ) / self.BorderSizeReduction
	local RightMargin = ( ( self.position.x + self.ActualSize.x - PlayX ) * ( 1 + ( SoundEnergy / 50 ) ) ) / self.BorderSizeReduction

	local TopLeft = Vector2:new( self.position.x - LeftMargin , self.position.y - TopMargin )
	local TopRight = Vector2:new( self.position.x + self.ActualSize.x + RightMargin , self.position.y - TopMargin )
	local BottomRight = Vector2:new( self.position.x + self.ActualSize.x + RightMargin , self.position.y + self.ActualSize.y + BottomMargin )
	local BottomLeft = Vector2:new( self.position.x - LeftMargin , self.position.y + self.ActualSize.y + BottomMargin )

	love.graphics.setColor( 20 + SoundEnergy / self.BorderColorReduction , 20 + SoundEnergy / self.BorderColorReduction , 50 + ( SoundEnergy / self.BorderColorReduction ) * 2 )
	love.graphics.polygon( "fill" , self.position.x , self.position.y , self.position.x , self.position.y + self.ActualSize.y , BottomLeft.x , BottomLeft.y , TopLeft.x , TopLeft.y )
	love.graphics.polygon( "fill" , self.position.x + self.ActualSize.x , self.position.y , self.position.x + self.ActualSize.x , self.position.y + self.ActualSize.y , BottomRight.x , BottomRight.y , TopRight.x , TopRight.y )
	love.graphics.polygon( "fill" , self.position.x , self.position.y , self.position.x + self.ActualSize.x , self.position.y , TopRight.x , TopRight.y , TopLeft.x , TopLeft.y )
	love.graphics.polygon( "fill" , self.position.x , self.position.y + self.ActualSize.y , self.position.x + self.ActualSize.x , self.position.y + self.ActualSize.y , BottomRight.x , BottomRight.y , BottomLeft.x , BottomLeft.y )
end

function Level:ChangeTileColors()
	if os.clock() >= self.LastColorChangeTime + self.ColorChangeBuffer then
		for Width = 1 , self.size.x do
			for Height = 1 , self.size.y do
				grid[ Width ][ Height ]:ChangeRandomColor()
				self.LastColorChangeTime = os.clock()
			end
		end
	end
end
