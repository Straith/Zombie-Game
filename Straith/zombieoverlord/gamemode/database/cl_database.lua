local database = {}

local function databaseReceive( tbl )
	database = tbl
end

net.Receive("database", function(len)
	local tbl = net.ReadTable()
	databaseReceive( tbl )
end)

function databaseTable()
	return database
end

function databaseGetValue( name )
	local d = databaseTable()
	return d[name]
end

function inventoryTable()
	return databaseGetValue("inventory") or {}
end

function inventoryHasItem( name, amount)
	if not amount then amount = 1 end
	
	local i = inventoryTable()
	
	if i then
		if i[name] then
			if i[name].amount >= amount then
				return true
			end
		end
	end
	
	return false
end

local SKINS = {}
SKINS.COLORS = {
	lightgrey = Color(131,131,131,180),
	grey = Color(111,111,111,180),
	lowWhite = Color(243,243,243,180),
	goodBlack = Color(41,41,41,230)
}

local function inventoryItemButton( iName, name, amount, desc, model, parent, dist, buttons )
	if not dist then dist = 128 end
	local p = parent:Add("DPanel") -- vgui.Create( "DPanel", parent )
	p:SetSize(64,64)
	
	local mp = vgui.Create( "DModelPanel", p )
	mp:SetSize( p:GetWide(), p:GetTall() )
	mp:SetPos( 0,0 )
	mp:SetModel( model )
	mp:SetAnimSpeed( 0.1 )
	mp:SetAnimated( true )
	mp:SetAmbientLight( Color(50,50,50))
	mp:SetDirectionalLight( BOX_TOP, Color(255,255,255))
	mp:SetCamPos( Vector( dist, dist, dist ) )
	mp:SetLookAt( Vector( 0, 0, 0 ) )
	mp:SetFOV( 20 )
	
	function mp:LayoutEntity(Entity)
		self:RunAnimation()
		Entity:SetSkin(getItems(iName).skin or 0)
		Entity:SetAngles( Angle(0,0,0))
	end
	
	local b = vgui.Create("DButton", p )
	b:SetPos( 0,0)
	b:SetSize( p:GetWide(),p:GetTall() )
	b:SetText("")
	b:SetToolTip( name .. ":\n\n" .. desc)
	
	b.DoClick = function()
		local opt = DermaMenu()
		for k, v in pairs(buttons) do
			opt:AddOption(k, v)
		end
		opt:Open()
	end
	
	b.DoRightClick = function()
		
	end
	
	function b:Paint()
		return true
	end
	
	if amount then
		local l = vgui.Create("DLabel", p)
		l:SetPos(6,4)
		l:SetFont("default")
		l:SetText(amount)
		l:SizeToContents()
	end
	
	return p
end

local function inventoryDrop(item)
	net.Start("inventory_drop")
	net.WriteString(tostring(item))
	net.SendToServer()
end

local function inventoryUse(item)
	net.Start("inventory_use")
	net.WriteString(tostring(item))
	net.SendToServer()
end

function inventoryMenu()
	local w = 506
	local h = 512
	
	local f = vgui.Create("DFrame")
	f:SetSize( w, h )
	f:Center()
	f:SetTitle("Inventory")
	f:SetDraggable(true)
	f:ShowCloseButton(true)
	f:MakePopup()

	local tabs = vgui.Create("DPropertySheet", f)
	tabs:Dock( FILL )
	
	local tab1panel = vgui.Create( "DPanel" )
	tab1panel:SetBackgroundColor(SKINS.COLORS.goodBlack)
	tabs:AddSheet( "Items", tab1panel, "icon16/box.png", false, false, "Stuff here...")
	
	local ps = vgui.Create( "DScrollPanel", tab1panel )
	ps:SetSize( w, h )
	ps:SetPos(0,0 )
	
	local padding = 4
	
	local items = vgui.Create("DIconLayout", ps )
	items:SetSize( w-padding*2, h)
	items:SetPos( padding, padding )
	items:SetSpaceY(padding)
	items:SetSpaceX(padding)
	
	local inventory = inventoryTable()
	
	for k,v in pairs(inventory) do
		local i = getItems(k)
		if i then
			local buttons = {}
			
			buttons["use"] = (function()
				inventoryUse(k)
				f:Close()
			end)
			
			buttons["drop"] = (function()
				inventoryDrop(k)
				f:Close()
			end)
			
			inventoryItemButton( k, i.name .. "(" .. v.amount .. ")", v.amount, i.desc, i.model, items, i.buttonDist, buttons)
		end
	end
end
concommand.Add("inventory", inventoryMenu)