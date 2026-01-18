--======================================================================
--  File: ReplicatedStorage/Data_Mods_F/Monetization_Mod.lua
--
--  Description:
--      Defines monetization data for Gamepasses and Developer Products.
--      Provides mappings for product IDs, names, icons, types, and
--      optional amounts. Exposed functions allow retrieval of product
--      metadata and integration with MarketplaceService.
--
--  Author(s): Darkzeb, Exclusible
--
--  Last Modified: 2025-09-29 by Darkzeb
--
--  Version: V2025-09
--
--  Dependencies:
--      - Roblox Services:
--          * MarketplaceService
--
--  Notes:
--      - GP_Data: Gamepasses with Name, ID, Icon, Price
--          * Examples: VIP, x2 ELO, x2 Cash, Exclusive Emotes, x3 Luck
--      - Dev_Data: Developer Products
--          * Cash Packs (Tiny ? Mega Huge)
--          * Gems Packs (Tiny ? Mega Huge)
--          * Starter Pack
--      - Used by Monetization_Handle, Codes_Handle, Shop_Handle
--      - Designed to centralize monetization configuration
--
--======================================================================

local MPS = game:GetService("MarketplaceService")

local Monetization_Mod = {}

local GP_Data = {
	['A'] = {
		['Name'] = "VIP!",
		['ID'] = 1258867472,
		['Icon'] = "rbxassetid://116997996978018",
		['Price'] = 49,
	},

	['B'] = {
		['Name'] = "x2 ELO!",
		['ID'] = 1259176869,
		['Icon'] = "rbxassetid://140028327825184",
		['Price'] = 349,
	},

	['C'] = {
		['Name'] = "x2 Cash!",
		['ID'] = 1258959116,
		['Icon'] = "rbxassetid://111390267501817",
		['Price'] = 199,
	},

	['D'] = {
		['Name'] = "Exclusive Emotes!",
		['ID'] = 1259220957,
		['Icon'] = "rbxassetid://140138999956473",
		['Price'] = 249,
	},

	['E'] = {
		['Name'] = "x3 Luck!",
		['ID'] = 1259133027,
		['Icon'] = "rbxassetid://111648715389151",
		['Price'] = 149,
	},

	['F'] = {
		['Name'] = "x2 Luck!",
		['ID'] = 1259086900,
		['Icon'] = "rbxassetid://113302080319391",
		['Price'] = 99,
	},

}

local Dev_Data = {
	['A'] = {
		['Name'] = "Tiny Cash Pack!",
		['ID'] = 3306903850,
		['Type'] = "Cash", 
		['Amount'] = 480,
		['Price'] = 29
	},

	['B'] = {
		['Name'] = "Small Cash Pack!",
		['ID'] = 3306904087,
		['Type'] = "Cash", 
		['Amount'] = 1680,
		['Price'] = 79
	},

	['C'] = {
		['Name'] = "Large Cash Pack!",
		['ID'] = 3306907044,
		['Type'] = "Cash",
		['Amount'] = 4800,
		['Price'] = 199
	},

	['D'] = {
		['Name'] = "Huge Cash Pack!",
		['ID'] = 3306907389,
		['Type'] = "Cash",
		['Amount'] = 21600, 
		['Price'] = 799
	},

	['E'] = {
		['Name'] = "Mega Huge Cash Pack!",
		['ID'] = 3306908329,
		['Type'] = "Cash",
		['Amount'] = 43200,
		['Price'] = 1499
	},

	['F'] = {
		['Name'] = "Tiny Gems Pack!",
		['ID'] = 3306909205,
		['Type'] = "Gems",
		['Amount'] = 20,
		['Price'] = 29
	},

	['G'] = {
		['Name'] = "Small Gems Pack!",
		['ID'] = 3306909447,
		['Type'] = "Gems",
		['Amount'] = 70,
		['Price'] = 79
	},

	['H'] = {
		['Name'] = "Large Gems Pack!",
		['ID'] = 3306909752,
		['Type'] = "Gems",
		['Amount'] = 200,
		['Price'] = 199
	},

	['I'] = {
		['Name'] = "Huge Gems Pack!",
		['ID'] = 3306910019,
		['Type'] = "Gems",
		['Amount'] = 900,
		['Price'] = 799
	},

	['J'] = {
		['Name'] = "Mega Huge Gems Pack!",
		['ID'] = 3306910278,
		['Type'] = "Gems",
		['Amount'] = 1800,
		['Price'] = 1499
	},

	['K'] = {
		['Name'] = "Starter Pack!",
		['ID'] = 3324331165,
		['Type'] = "StarterPack",
	},
	
	['L'] = {
		['Name'] = "Special Gloves",
		['ID'] = 3393273546,
		['Type'] = "Special Gloves",
	},
}

local UGC_Data = {
	
	["T1"] = { Name = "Big Metal Chain", ID = 114922634621014, Price = 50, Thumbnail = "rbxthumb://type=Asset&Id=114922634621014&w=150&h=150" },
	["L"] = { Name = "Fighter Crown - Black White", ID = 82139183698439, Price = 90, Thumbnail = "rbxthumb://type=Asset&Id=82139183698439&w=150&h=150" },
	["C1"] = { Name = "Nerd Glasses - Green", ID = 77949725271695, Price = 90, Thumbnail = "rbxthumb://type=Asset&Id=77949725271695&w=150&h=150" },
	["B1"] = { Name = "Nerd Glasses - Red", ID = 74735903599213, Price = 90, Thumbnail = "rbxthumb://type=Asset&Id=74735903599213&w=150&h=150" },
	["A1"] = { Name = "Nerd Glasses", ID = 114623808048803, Price = 90, Thumbnail = "rbxthumb://type=Asset&Id=114623808048803&w=150&h=150" },
	["O"] = { Name = "Motorcycle Helmet - Black", ID = 96818536482215, Price = 90, Thumbnail = "rbxthumb://type=Asset&Id=96818536482215&w=150&h=150" },
	["D2"] = { Name = "Sport Bag Black", ID = 87378104044885, Price = 135, Thumbnail = "rbxthumb://type=Asset&Id=87378104044885&w=150&h=150" },
	["E2"] = { Name = "Bape Black Bagpack", ID = 125834338933624, Price = 135, Thumbnail = "rbxthumb://type=Asset&Id=125834338933624&w=150&h=150" },
	["F2"] = { Name = "Dragon Horn Glasses", ID = 120115448345902, Price = 90, Thumbnail = "rbxthumb://type=Asset&Id=120115448345902&w=150&h=150" },
	["G2"] = { Name = "Black Angel Wings", ID = 104789977385309, Price = 135, Thumbnail = "rbxthumb://type=Asset&Id=104789977385309&w=150&h=150" },
	["H2"] = { Name = "Inferno aura", ID = 122976837251185, Price = 135, Thumbnail = "rbxthumb://type=Asset&Id=122976837251185&w=150&h=150" },
	["N"] = { Name = "Motorcycle Helmet - Black Red", ID = 97647774814364, Price = 90, Thumbnail = "rbxthumb://type=Asset&Id=97647774814364&w=150&h=150" },
	["L1"] = { Name = "Snake Glasses Y2K - Red", ID = 138002585775905, Price = 90, Thumbnail = "rbxthumb://type=Asset&Id=138002585775905&w=150&h=150" },
	["G1"] = { Name = "Training Helmet", ID = 81877496476783, Price = 90, Thumbnail = "rbxthumb://type=Asset&Id=81877496476783&w=150&h=150" },
	["N1"] = { Name = "Snake Glasses Y2K - Gray", ID = 81653947431590, Price = 90, Thumbnail = "rbxthumb://type=Asset&Id=81653947431590&w=150&h=150" },
	["O1"] = { Name = "Snake Glasses Y2K - Orange", ID = 79643861023078, Price = 90, Thumbnail = "rbxthumb://type=Asset&Id=79643861023078&w=150&h=150" },
	["H1"] = { Name = "Training Helmet", ID = 107974793938990, Price = 90, Thumbnail = "rbxthumb://type=Asset&Id=107974793938990&w=150&h=150" },
	["I1"] = { Name = "Snake Glasses Y2K - Purple", ID = 130235233159644, Price = 90, Thumbnail = "rbxthumb://type=Asset&Id=130235233159644&w=150&h=150" },
	["J1"] = { Name = "Snake Glasses Y2K - Pink", ID = 130898687489564, Price = 90, Thumbnail = "rbxthumb://type=Asset&Id=130898687489564&w=150&h=150" },
	["K1"] = { Name = "Snake Glasses Y2K - Yellow", ID = 85537731341001, Price = 90, Thumbnail = "rbxthumb://type=Asset&Id=85537731341001&w=150&h=150" },
	["D1"] = { Name = "Nerd Glasses - Black", ID = 85169596622861, Price = 90, Thumbnail = "rbxthumb://type=Asset&Id=85169596622861&w=150&h=150" },
	["E1"] = { Name = "Training Helmet", ID = 100104438861007, Price = 90, Thumbnail = "rbxthumb://type=Asset&Id=100104438861007&w=150&h=150" },
	["A"] = { Name = "Colorful Dreads Breads", ID = 83795788626582, Price = 60, Thumbnail = "rbxthumb://type=Asset&Id=83795788626582&w=150&h=150" },
	["F1"] = { Name = "Training Helmet", ID = 99713943487010, Price = 90, Thumbnail = "rbxthumb://type=Asset&Id=99713943487010&w=150&h=150" },
	["C"] = { Name = "Colorful Dreads Breads", ID = 98302594802885, Price = 60, Thumbnail = "rbxthumb://type=Asset&Id=98302594802885&w=150&h=150" },
	["B"] = { Name = "Dreads Breads", ID = 113738030334375, Price = 60, Thumbnail = "rbxthumb://type=Asset&Id=113738030334375&w=150&h=150" },
	["E"] = { Name = "Cowboy Hat", ID = 101474119058173, Price = 90, Thumbnail = "rbxthumb://type=Asset&Id=101474119058173&w=150&h=150" },
	["D"] = { Name = "Dreads Breads", ID = 101251472607139, Price = 60, Thumbnail = "rbxthumb://type=Asset&Id=101251472607139&w=150&h=150" },
	["G"] = { Name = "Cowboy Hat", ID = 75114177921975, Price = 90, Thumbnail = "rbxthumb://type=Asset&Id=75114177921975&w=150&h=150" },
	["F"] = { Name = "Cowboy Hat", ID = 75995119815868, Price = 90, Thumbnail = "rbxthumb://type=Asset&Id=75995119815868&w=150&h=150" },
	["I"] = { Name = "Fighter Crown - Black Green", ID = 113747837981544, Price = 90, Thumbnail = "rbxthumb://type=Asset&Id=113747837981544&w=150&h=150" },
	["H"] = { Name = "Cowboy Hat", ID = 101562313582313, Price = 90, Thumbnail = "rbxthumb://type=Asset&Id=101562313582313&w=150&h=150" },
	["K"] = { Name = "Fighter Crown - Red White", ID = 114656167427986, Price = 90, Thumbnail = "rbxthumb://type=Asset&Id=114656167427986&w=150&h=150" },
	["J"] = { Name = "Fighter Crown - White Green", ID = 76373498147951, Price = 90, Thumbnail = "rbxthumb://type=Asset&Id=76373498147951&w=150&h=150" },
	["M"] = { Name = "Motorcycle Helmet - White Red", ID = 100504804713142, Price = 90, Thumbnail = "rbxthumb://type=Asset&Id=100504804713142&w=150&h=150" },
	["A2"] = { Name = "Punk Spiked Hair – Black & Red Riot Style", ID = 102119948007614, Price = 60, Thumbnail = "rbxthumb://type=Asset&Id=102119948007614&w=150&h=150" },
	["B2"] = { Name = "Dark Grey Scarf Hood", ID = 136178678394338, Price = 90, Thumbnail = "rbxthumb://type=Asset&Id=136178678394338&w=150&h=150" },
	["C2"] = { Name = "Black balaclava", ID = 106805937500041, Price = 90, Thumbnail = "rbxthumb://type=Asset&Id=106805937500041&w=150&h=150" },
	["Q"] = { Name = "Protein Shaker - White", ID = 122071796353410, Price = 50, Thumbnail = "rbxthumb://type=Asset&Id=122071796353410&w=150&h=150" },
	["P"] = { Name = "Motorcycle Helmet", ID = 82603511834308, Price = 90, Thumbnail = "rbxthumb://type=Asset&Id=82603511834308&w=150&h=150" },
	["S"] = { Name = "Protein Shaker - Black", ID = 87085165668528, Price = 50, Thumbnail = "rbxthumb://type=Asset&Id=87085165668528&w=150&h=150" },
	["R"] = { Name = "Protein Shaker - Red", ID = 98181442625165, Price = 50, Thumbnail = "rbxthumb://type=Asset&Id=98181442625165&w=150&h=150" },
	["U"] = { Name = "Face Bandages", ID = 120067224049421, Price = 90, Thumbnail = "rbxthumb://type=Asset&Id=120067224049421&w=150&h=150" },
	["T"] = { Name = "Protein Shaker - Yellow", ID = 102642333841802, Price = 50, Thumbnail = "rbxthumb://type=Asset&Id=102642333841802&w=150&h=150" },
	["W"] = { Name = "Face Bandages", ID = 112600507634369, Price = 90, Thumbnail = "rbxthumb://type=Asset&Id=112600507634369&w=150&h=150" },
	["V"] = { Name = "Face Bandages", ID = 119243634001553, Price = 90, Thumbnail = "rbxthumb://type=Asset&Id=119243634001553&w=150&h=150" },
	["Y"] = { Name = "Eye Bandage", ID = 84887382195802, Price = 90, Thumbnail = "rbxthumb://type=Asset&Id=84887382195802&w=150&h=150" },
	["X"] = { Name = "Face Bandages", ID = 91774845227721, Price = 90, Thumbnail = "rbxthumb://type=Asset&Id=91774845227721&w=150&h=150" },
	["M1"] = { Name = "Snake Glasses Y2K - Black", ID = 70454931418771, Price = 90, Thumbnail = "rbxthumb://type=Asset&Id=70454931418771&w=150&h=150" },
	["Z"] = { Name = "Eye Bandage", ID = 138705825312307, Price = 90, Thumbnail = "rbxthumb://type=Asset&Id=138705825312307&w=150&h=150" },
	["S1"] = { Name = "Black Gold VVS Chain Diamonds", ID = 138617591743408, Price = 50, Thumbnail = "rbxthumb://type=Asset&Id=138617591743408&w=150&h=150" },
	["R1"] = { Name = "Snake Glasses Y2K - Green", ID = 95997013721520, Price = 90, Thumbnail = "rbxthumb://type=Asset&Id=95997013721520&w=150&h=150" },
	["Q1"] = { Name = "Snake Glasses Y2K - Blue", ID = 108225068022205, Price = 90, Thumbnail = "rbxthumb://type=Asset&Id=108225068022205&w=150&h=150" },
	["P1"] = { Name = "Snake Glasses Y2K - Light Blue", ID = 91544116053373, Price = 90, Thumbnail = "rbxthumb://type=Asset&Id=91544116053373&w=150&h=150" },
}


-- Conversion parameters for cash ? gems
local Conversion_Settings = {
	RATE = 1 / 20,    -- 1 gem = 20 cash
	FEE = 0.15,       -- 15% commission
}

function Monetization_Mod.Get_Conversion_Settings()
	return Conversion_Settings
end

local function Get_Player_Data(Plr, Key)
	local PD = Plr:FindFirstChild("Player_Data")
	if(PD ~= nil and PD:FindFirstChild(Key) ~= nil)then
		return PD:FindFirstChild(Key).Value
	end
	return nil
end

local function Get_Data(Is_GP)
	if(Is_GP)then
		return GP_Data
	end
	return Dev_Data
end

local function Get_ID_From_Name(Is_GP, Name)
	local Data = Get_Data(Is_GP)

	for Key, Item_Data in next, Data do
		if(Item_Data ~= nil and Item_Data['Name'] ~= nil and Item_Data['Name'] == Name 
			and Item_Data['ID'] ~= nil)then

			return Item_Data['ID']
		end
	end

	return nil
end

local function Get_Key_From_Name(Is_GP, Name)
	local Data = Get_Data(Is_GP)

	for Key, Item_Data in next, Data do
		if(Item_Data ~= nil and Item_Data['Name'] ~= nil and Item_Data['Name'] == Name)then
			return Key
		end
	end

	return nil
end

local function Get_Player_Owned_Gamepasses_Keys(Plr)
	local Owned_GP_Keys = Get_Player_Data(Plr, "Owned Gamepasses") or ""
	return string.split(Owned_GP_Keys, ",")
end

local function Player_Owns_Gamepass(Plr, Key)
	local Owned_Keys = Get_Player_Owned_Gamepasses_Keys(Plr)
	if(Owned_Keys ~= nil and #Owned_Keys > 0 and table.find(Owned_Keys, Key) ~= nil)then
		return true
	end

	return false
end


function Monetization_Mod.Get_Player_Owned_Gamepasses_Keys(Plr)
	return Get_Player_Owned_Gamepasses_Keys(Plr)
end

function Monetization_Mod.Get_All_Gamepass_Data()
	return GP_Data
end

function Monetization_Mod.Get_All_Dev_Product_Data()
	return Dev_Data
end

function Monetization_Mod.Get_All_UGC_Data()
	return UGC_Data
end

function Monetization_Mod.Get_ID_From_Name(Is_GP, Name)
	return Get_ID_From_Name(Is_GP, Name)
end

function Monetization_Mod.Get_ID_From_Key(Is_GP, Key)
	if(Is_GP)then
		local Data_V = GP_Data[Key]
		if(Data_V ~= nil and Data_V['ID'] ~= nil)then
			return Data_V['ID']
		end
	else
		local Data_V = Dev_Data[Key]
		if(Data_V ~= nil and Data_V['ID'] ~= nil)then
			return Data_V['ID']
		end
	end

	return -1
end


function Monetization_Mod.Get_Key_From_Name(Is_GP, Name)
	return Get_Key_From_Name(Is_GP, Name)
end

function Monetization_Mod.Get_Key_From_ID(Is_GP, ID)
	local Data = Get_Data(Is_GP)

	for Key, Item_Data in next, Data do
		if(Item_Data ~= nil and Item_Data['ID'] ~= nil and Item_Data['ID'] == ID)then
			return Key
		end
	end

	return nil
end

function Monetization_Mod.Get_Data_From_Key(Is_GP, Key)
	if(Is_GP)then
		return GP_Data[Key]
	end
	return Dev_Data[Key]
end

function Monetization_Mod.Does_Player_Own_Gamepass(Plr, Name)
	local GP_Key = Get_Key_From_Name(true, Name)
	return Player_Owns_Gamepass(Plr, GP_Key)
end

function Monetization_Mod.Does_Player_Own_Gamepass_Key(Plr, Key)
	return Player_Owns_Gamepass(Plr, Key)
end

function Monetization_Mod.Hard_Gamepass_Check(Plr, GP_ID)
	local function Async()
		local Data = nil
		local success, errormessage = pcall(function()
			Data = MPS:UserOwnsGamePassAsync(Plr.UserId, GP_ID)
		end)

		if(success and Data ~= nil)then
			return Data
		end
		return nil
	end

	for i = 1, 3 do
		local D = Async()
		if(D ~= nil)then
			return D
		end
	end

	return false
end

local function Compile_Cash_Boost_Amounts(Plr)
	local Vals = {
		['A'] = Dev_Data['A']['Amount'],
		['B'] = Dev_Data['B']['Amount'],
		['C'] = Dev_Data['C']['Amount'],
		['D'] = Dev_Data['D']['Amount'],
		['E'] = Dev_Data['E']['Amount']
	}
	return Vals
end

function Monetization_Mod.Get_Cash_Boost_Amount(Plr)
	return Compile_Cash_Boost_Amounts(Plr)
end

function Monetization_Mod.Prompt_Suggested_Cash_Boost(Plr, Needed_Amount)
	local Boost_Data = Compile_Cash_Boost_Amounts(Plr)
	local Boost_Key = "A"
	local Current_Dif, Current_Max = math.huge, -1

	for Key, Amount in next, Boost_Data do
		local Dif = math.abs(Amount - Needed_Amount)
		if((Amount >= Needed_Amount or Amount >= Current_Max) and Dif < Current_Dif)then
			Boost_Key = Key
			Current_Dif = Dif
			Current_Max = Amount
		end
	end

	return Dev_Data[Boost_Key]
end

function Monetization_Mod.Get_Cash_Pack_Amount(Key)
	local Cash_Data = Dev_Data[Key]
	if(Cash_Data ~= nil and Cash_Data['Amount'] ~= nil)then
		return Cash_Data['Amount']
	end
	return 0
end

function Monetization_Mod.Get_Gems_Pack_Amount(Key)
	local Gems_Data = Dev_Data[Key]
	if(Gems_Data ~= nil and Gems_Data['Amount'] ~= nil)then
		return Gems_Data['Amount']
	end
	return 0
end

function Monetization_Mod.Get_Cash_Pack_Price(Key)
	local Cash_Data = Dev_Data[Key]
	if(Cash_Data ~= nil and Cash_Data['Amount'] ~= nil)then
		return Cash_Data['Price']
	end
	return 0
end

function Monetization_Mod.Get_Gems_Pack_Price(Key)
	local Gems_Data = Dev_Data[Key]
	if(Gems_Data ~= nil and Gems_Data['Amount'] ~= nil)then
		return Gems_Data['Price']
	end
	return 0
end


function Monetization_Mod.Get_Cash_Multi(Plr)
	local Multi = 1

	local Owned_x2_Cash = Player_Owns_Gamepass(Plr, "C") or (Plr.Player_Data.Cash2x.Value == true)
	if(Owned_x2_Cash)then
		Multi += 1
	end

	local Owned_VIP = Player_Owns_Gamepass(Plr, "A") or (Plr.Player_Data.Vip.Value == true)
	if(Owned_VIP)then
		Multi += 0.1
	end

	return Multi
end

function Monetization_Mod.Get_Elo_Multi(Plr)
	local Multi = 1

	local Owned_x2_Elo = Player_Owns_Gamepass(Plr, "B")
	if(Owned_x2_Elo)then
		Multi += 1
	end

	return Multi
end

function Monetization_Mod.Get_Luck_Multi(Plr)
	local Multi = 1

	local Owned_x2_Luck = Player_Owns_Gamepass(Plr, "F")
	if(Owned_x2_Luck)then
		Multi += 1
	end

	local Owned_x3_Luck = Player_Owns_Gamepass(Plr, "E")
	if(Owned_x3_Luck)then
		Multi += 2
	end

	local Friends_Count = Plr:GetAttribute("Friends_Count") or 0
	Multi += Friends_Count * 0.1

	return Multi
end

function Monetization_Mod.Get_ID_From_Key_UGC( Key)------------By Adnan
	local Data_V = UGC_Data[Key]
	if(Data_V ~= nil and Data_V['ID'] ~= nil)then
		return Data_V['ID']
	end
	return -1
end

function Monetization_Mod.Get_UGC_Key_From_ID_UGC(ID)----------By Adnan
	for key, item in pairs(UGC_Data) do
		if item.ID == ID then
			return key
		end
	end
	return nil
end

return Monetization_Mod
