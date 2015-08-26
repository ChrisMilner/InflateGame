class = require 'middleclass'

DeathScreen = class('DeathScreen')

function DeathScreen:initialize()
	self.TitlePosition = Vector2:new( XCenter - XScreen / 3 , YCenter - YScreen / 2.5 )
	self.InstructionPosition = Vector2:new( 0 , YCenter + YScreen / 4 )
	self.StatPosition = Vector2:new( 0 , YCenter - YScreen / 6 )

	self.ScaleReduction = 400
	self.ColorReduction = 0.5
	self.TitleColor = SoundEnergy / self.ColorReduction
	self.TitleScale = SoundEnergy / self.ScaleReduction

	self.VignetteData = love.image.newImageData( XScreen , YScreen )
	self.VignetteAlpha = 0
	self.VignetteAlphaChangeRate = 3
	self:CalculateVignette()
end

function DeathScreen:draw()
	love.graphics.setColor( 0 , 0 , 0 , self.VignetteAlpha )
	love.graphics.draw( self.Vignette )
	
	love.graphics.setColor( 255 - self.TitleColor , 255 - self.TitleColor , 255 , self.VignetteAlpha )
	love.graphics.setFont( LargeFont )
	love.graphics.push()
	love.graphics.translate( XCenter , self.TitlePosition.y )
	love.graphics.scale( 1 + self.TitleScale )
	love.graphics.printf( "YOU LOST" , - XCenter , 0 , XScreen , "center" )
	love.graphics.pop()

	love.graphics.setColor( 255 , 255 , 255 , self.VignetteAlpha )
	love.graphics.setFont( SmallFont )
	love.graphics.printf( "Press [ Space ] to retry!" , self.InstructionPosition.x , self.InstructionPosition.y , XScreen , "center" )
	love.graphics.printf( "Press [ Esc ] to return to the menu!" , self.InstructionPosition.x , self.InstructionPosition.y + 50 , XScreen , "center" )

	if EndlessMode == false then
		love.graphics.printf( "You lasted " .. RoundNumber - 1 .. " Rounds!" , self.StatPosition.x , self.StatPosition.y , XScreen , "center" )
	else 
		love.graphics.printf( "You lasted " .. RoundNum( EndlessTime , 2 ) .. "s!" , self.StatPosition.x , self.StatPosition.y , XScreen , "center" )
	end
end

function DeathScreen:update( dt )
	self.TitleColor = SoundEnergy / self.ColorReduction
	self.TitleScale = SoundEnergy / self.ScaleReduction
	self.VignetteAlpha = math.min( self.VignetteAlpha + self.VignetteAlphaChangeRate , 255 )
end

function DeathScreen:CalculateVignette()
	self.VignetteData:mapPixel( function( x , y , r , g , b , a )  
								local dist = GetHypotenuse( x - XCenter , y - YCenter )
								local radius = GetHypotenuse( XCenter , YCenter ) 
								a = math.min( 55 + ( dist / radius ) * 200 , 255 )
								return 0 , 0 , 100 , a
							end )
	self.Vignette = love.graphics.newImage( self.VignetteData )
end
