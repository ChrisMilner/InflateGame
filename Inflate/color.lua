class = require 'middleclass'

Color = class('Color')

function Color:initialize( r , g , b , a )
	self.r = r
	self.g = g
	self.b = b
	self.a = a
end

function Color:GetRGBA()
	return self.r , self.g , self.b , self.a
end

function Color:Alter( r , g , b , a )
	self.r = self.r + r
	self.g = self.g + g
	self.b = self.b + b
	self.a = self.a + a
end
