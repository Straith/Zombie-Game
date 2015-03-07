GM.Name = "Zombie Overlord"
GM.Author = "Rysoft"
GM.Email = "admin@rysoft.com"
GM.Website = "www.rysoft.com"

team.SetUp(0, "Survivors", Color(255, 255, 255) )
team.SetUp(1, "Zombie Overlord", Color(0, 255, 0) )

function GM:Initialize()
	self.BaseClass.Initialize( self )
end