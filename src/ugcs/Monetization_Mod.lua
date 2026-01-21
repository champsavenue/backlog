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
--          * Cash Packs (Tiny → Mega Huge)
--          * Gems Packs (Tiny → Mega Huge)
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
	["2026-01-001"] = { Name = "Gym Towel on Shoulders - Black", ID = 135859105132166, Price = 50, Category = "Accessory", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=135859105132166&w=150&h=150" },
	["2026-01-002"] = { Name = "Gym Towel on Shoulders - Blue", ID = 126722669046975, Price = 50, Category = "Accessory", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=126722669046975&w=150&h=150" },
	["2026-01-003"] = { Name = "Gym Towel on Shoulders - Sky Blue", ID = 136004845471380, Price = 50, Category = "Accessory", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=136004845471380&w=150&h=150" },
	["2026-01-004"] = { Name = "Gym Towel on Shoulders - White", ID = 123023373641597, Price = 50, Category = "Accessory", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=123023373641597&w=150&h=150" },
	["2026-01-005"] = { Name = "Champion’s Money Bag - Black", ID = 71177679450118, Price = 135, Category = "Bag", Priority = 3, Thumbnail = "rbxthumb://type=Asset&Id=71177679450118&w=150&h=150" },
	["2026-01-006"] = { Name = "Champion’s Money Bag - Crimson", ID = 71602118425479, Price = 135, Category = "Bag", Priority = 3, Thumbnail = "rbxthumb://type=Asset&Id=71602118425479&w=150&h=150" },
	["2026-01-007"] = { Name = "Champion’s Money Bag - Crimson", ID = 83259837784051, Price = 135, Category = "Bag", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=83259837784051&w=150&h=150" },
	["2026-01-008"] = { Name = "Champion’s Money Bag - White", ID = 138242302381017, Price = 135, Category = "Bag", Priority = 3, Thumbnail = "rbxthumb://type=Asset&Id=138242302381017&w=150&h=150" },
	["2026-01-009"] = { Name = "Champion’s Money Bag - Red", ID = 101534827666942, Price = 135, Category = "Bag", Priority = 3, Thumbnail = "rbxthumb://type=Asset&Id=101534827666942&w=150&h=150" },
	["2026-01-010"] = { Name = "MMA Training Bag - Blue", ID = 74811127472664, Price = 135, Category = "Bag", Priority = 5, Thumbnail = "rbxthumb://type=Asset&Id=74811127472664&w=150&h=150" },
	["2026-01-011"] = { Name = "Bape Bagpack - Orange", ID = 83349394875796, Price = 135, Category = "Bag", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=83349394875796&w=150&h=150" },
	["2026-01-012"] = { Name = "Bape Bagpack - Black", ID = 134481036690863, Price = 135, Category = "Bag", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=134481036690863&w=150&h=150" },
	["2026-01-013"] = { Name = "Big Metal Chain - Black", ID = 140183743497109, Price = 50, Category = "Chain", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=140183743497109&w=150&h=150" },
	["2026-01-014"] = { Name = "Big Metal Chain - Pink", ID = 103283244902955, Price = 50, Category = "Chain", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=103283244902955&w=150&h=150" },
	["2026-01-015"] = { Name = "Big Metal Chain - Gold", ID = 112043252888144, Price = 50, Category = "Chain", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=112043252888144&w=150&h=150" },
	["2026-01-016"] = { Name = "Diamond & Chain - Black", ID = 81219496918209, Price = 50, Category = "Chain", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=81219496918209&w=150&h=150" },
	["2026-01-017"] = { Name = "Diamond & Chain - Red", ID = 117380896099350, Price = 50, Category = "Chain", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=117380896099350&w=150&h=150" },
	["2026-01-018"] = { Name = "Diamond & Chain  - Gold", ID = 130241189918893, Price = 50, Category = "Chain", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=130241189918893&w=150&h=150" },
	["2026-01-019"] = { Name = "Metal Double Chain - Red", ID = 103462513345692, Price = 50, Category = "Chain", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=103462513345692&w=150&h=150" },
	["2026-01-020"] = { Name = "Metal Double Chain - White", ID = 112667835660803, Price = 50, Category = "Chain", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=112667835660803&w=150&h=150" },
	["2026-01-021"] = { Name = "Metal Double Chain - Silver", ID = 121071765731154, Price = 50, Category = "Chain", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=121071765731154&w=150&h=150" },
	["2026-01-022"] = { Name = "Friday 13th Mask", ID = 80281140527315, Price = 94, Category = "Face", Priority = 10, Thumbnail = "rbxthumb://type=Asset&Id=80281140527315&w=150&h=150" },
	["2026-01-023"] = { Name = "Friday 13th Mask", ID = 115551558688105, Price = 94, Category = "Face", Priority = 10, Thumbnail = "rbxthumb://type=Asset&Id=115551558688105&w=150&h=150" },
	["2026-01-024"] = { Name = "Friday 13th Mask", ID = 99785572021418, Price = 94, Category = "Face", Priority = 10, Thumbnail = "rbxthumb://type=Asset&Id=99785572021418&w=150&h=150" },
	["2026-01-025"] = { Name = "Halloween Mask", ID = 102071790961098, Price = 94, Category = "Face", Priority = 10, Thumbnail = "rbxthumb://type=Asset&Id=102071790961098&w=150&h=150" },
	["2026-01-026"] = { Name = "Halloween Mask", ID = 125161405435561, Price = 94, Category = "Face", Priority = 10, Thumbnail = "rbxthumb://type=Asset&Id=125161405435561&w=150&h=150" },
	["2026-01-027"] = { Name = "Halloween Mask", ID = 118141104004505, Price = 94, Category = "Face", Priority = 10, Thumbnail = "rbxthumb://type=Asset&Id=118141104004505&w=150&h=150" },
	["2026-01-028"] = { Name = "Flamingo glasses", ID = 76090747423006, Price = 90, Category = "Glasses", Priority = 10, Thumbnail = "rbxthumb://type=Asset&Id=76090747423006&w=150&h=150" },
	["2026-01-029"] = { Name = "Futura Black Sunglasses", ID = 124662344921935, Price = 90, Category = "Glasses", Priority = 10, Thumbnail = "rbxthumb://type=Asset&Id=124662344921935&w=150&h=150" },
	["2026-01-030"] = { Name = "Oversize Gold Googles", ID = 72774703642915, Price = 90, Category = "Glasses", Priority = 10, Thumbnail = "rbxthumb://type=Asset&Id=72774703642915&w=150&h=150" },
	["2026-01-031"] = { Name = "Fashion Dark googles", ID = 99308955401193, Price = 90, Category = "Glasses", Priority = 10, Thumbnail = "rbxthumb://type=Asset&Id=99308955401193&w=150&h=150" },
	["2026-01-032"] = { Name = "Boxing Gloves Around Neck - Red", ID = 87235044965685, Price = 50, Category = "Gloves", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=87235044965685&w=150&h=150" },
	["2026-01-033"] = { Name = "Boxing Gloves Around Neck - Black & White", ID = 94644074586888, Price = 50, Category = "Gloves", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=94644074586888&w=150&h=150" },
	["2026-01-034"] = { Name = "Boxing Gloves Around Neck - Black & Yellow", ID = 75078885992255, Price = 50, Category = "Gloves", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=75078885992255&w=150&h=150" },
	["2026-01-035"] = { Name = "MMA Gloves around neck - Black", ID = 115157954314498, Price = 50, Category = "Gloves", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=115157954314498&w=150&h=150" },
	["2026-01-036"] = { Name = "MMA Gloves around neck - Red", ID = 94854809080258, Price = 50, Category = "Gloves", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=94854809080258&w=150&h=150" },
	["2026-01-037"] = { Name = "MMA Gloves around neck - Blue", ID = 139123166526936, Price = 50, Category = "Gloves", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=139123166526936&w=150&h=150" },
	["2026-01-038"] = { Name = "MMA Gloves around neck - Red & Black", ID = 83738698134523, Price = 50, Category = "Gloves", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=83738698134523&w=150&h=150" },
	["2026-01-039"] = { Name = "Red Punk", ID = 117040146974656, Price = 60, Category = "Hair", Priority = 3, Thumbnail = "rbxthumb://type=Asset&Id=117040146974656&w=150&h=150" },
	["2026-01-040"] = { Name = "Goku Saiyan Style - Black", ID = 111227691791884, Price = 60, Category = "Hair", Priority = 3, Thumbnail = "rbxthumb://type=Asset&Id=111227691791884&w=150&h=150" },
	["2026-01-041"] = { Name = "Goku Saiyan Style - Blond", ID = 131337545896181, Price = 60, Category = "Hair", Priority = 3, Thumbnail = "rbxthumb://type=Asset&Id=131337545896181&w=150&h=150" },
	["2026-01-042"] = { Name = "Goku Saiyan Style - Green", ID = 131947130350925, Price = 60, Category = "Hair", Priority = 3, Thumbnail = "rbxthumb://type=Asset&Id=131947130350925&w=150&h=150" },
	["2026-01-043"] = { Name = "Anime Manga Hair – Black", ID = 98652805253402, Price = 60, Category = "Hair", Priority = 3, Thumbnail = "rbxthumb://type=Asset&Id=98652805253402&w=150&h=150" },
	["2026-01-044"] = { Name = "Blond Manga Hair – Anime Boy Style", ID = 107114825650413, Price = 60, Category = "Hair", Priority = 3, Thumbnail = "rbxthumb://type=Asset&Id=107114825650413&w=150&h=150" },
	["2026-01-045"] = { Name = "Anime Manga Hair – Green", ID = 116686673829551, Price = 60, Category = "Hair", Priority = 3, Thumbnail = "rbxthumb://type=Asset&Id=116686673829551&w=150&h=150" },
	["2026-01-046"] = { Name = "Bloodrage Shadow Hair", ID = 70524633525876, Price = 60, Category = "Hair", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=70524633525876&w=150&h=150" },
	["2026-01-047"] = { Name = "Blue Fury Shadow Hair", ID = 115909315445633, Price = 60, Category = "Hair", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=115909315445633&w=150&h=150" },
	["2026-01-048"] = { Name = "Purple Rage Shadow Hair", ID = 95584964331635, Price = 60, Category = "Hair", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=95584964331635&w=150&h=150" },
	["2026-01-049"] = { Name = "Golden Brawler Hair", ID = 96249628392186, Price = 60, Category = "Hair", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=96249628392186&w=150&h=150" },
	["2026-01-050"] = { Name = "Night Brawler Hair", ID = 71091698976615, Price = 60, Category = "Hair", Priority = 3, Thumbnail = "rbxthumb://type=Asset&Id=71091698976615&w=150&h=150" },
	["2026-01-051"] = { Name = "Icy Brawler Hair", ID = 115175684179361, Price = 60, Category = "Hair", Priority = 3, Thumbnail = "rbxthumb://type=Asset&Id=115175684179361&w=150&h=150" },
	["2026-01-052"] = { Name = "Crimson Headband - Black", ID = 119308189747481, Price = 60, Category = "Hair", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=119308189747481&w=150&h=150" },
	["2026-01-053"] = { Name = "Crimson Headband - Dark Grey", ID = 124693175745362, Price = 60, Category = "Hair", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=124693175745362&w=150&h=150" },
	["2026-01-054"] = { Name = "Crimson Headband  - Red", ID = 107267327705749, Price = 60, Category = "Hair", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=107267327705749&w=150&h=150" },
	["2026-01-055"] = { Name = "Fighter Headband - White I Blond", ID = 78010144233021, Price = 60, Category = "Hair", Priority = 3, Thumbnail = "rbxthumb://type=Asset&Id=78010144233021&w=150&h=150" },
	["2026-01-056"] = { Name = "Fighter Headband - White I Black", ID = 91954596636670, Price = 60, Category = "Hair", Priority = 3, Thumbnail = "rbxthumb://type=Asset&Id=91954596636670&w=150&h=150" },
	["2026-01-057"] = { Name = "Fighter Headband - White I Red", ID = 127501133478733, Price = 60, Category = "Hair", Priority = 3, Thumbnail = "rbxthumb://type=Asset&Id=127501133478733&w=150&h=150" },
	["2026-01-058"] = { Name = "Crimson Fighter Headband - Blond", ID = 83764291935412, Price = 60, Category = "Hair", Priority = 3, Thumbnail = "rbxthumb://type=Asset&Id=83764291935412&w=150&h=150" },
	["2026-01-059"] = { Name = "Crimson Fighter Headband - Red", ID = 98499029243590, Price = 60, Category = "Hair", Priority = 3, Thumbnail = "rbxthumb://type=Asset&Id=98499029243590&w=150&h=150" },
	["2026-01-060"] = { Name = "Fighter Headband - Black I Red", ID = 86986938049142, Price = 60, Category = "Hair", Priority = 3, Thumbnail = "rbxthumb://type=Asset&Id=86986938049142&w=150&h=150" },
	["2026-01-061"] = { Name = "Figther Headband - Black I Icy", ID = 131383901818607, Price = 60, Category = "Hair", Priority = 3, Thumbnail = "rbxthumb://type=Asset&Id=131383901818607&w=150&h=150" },
	["2026-01-062"] = { Name = "Fighter Headband - Black I Blond", ID = 136562859504774, Price = 60, Category = "Hair", Priority = 3, Thumbnail = "rbxthumb://type=Asset&Id=136562859504774&w=150&h=150" },
	["2026-01-063"] = { Name = "Hair in the wind - Blue", ID = 74696402447520, Price = 60, Category = "Hair", Priority = 3, Thumbnail = "rbxthumb://type=Asset&Id=74696402447520&w=150&h=150" },
	["2026-01-064"] = { Name = "Hair in the wind - Green", ID = 99030230718140, Price = 60, Category = "Hair", Priority = 3, Thumbnail = "rbxthumb://type=Asset&Id=99030230718140&w=150&h=150" },
	["2026-01-065"] = { Name = "Hair in the wind. - Blond", ID = 90931518524095, Price = 60, Category = "Hair", Priority = 3, Thumbnail = "rbxthumb://type=Asset&Id=90931518524095&w=150&h=150" },
	["2026-01-066"] = { Name = "Spiked Headphones - Crimson", ID = 75185769535170, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=75185769535170&w=150&h=150" },
	["2026-01-067"] = { Name = "Spiked Chapka - Crimson", ID = 127932323149938, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=127932323149938&w=150&h=150" },
	["2026-01-068"] = { Name = "Scarf Hood - Crimson", ID = 92217381526904, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=92217381526904&w=150&h=150" },
	["2026-01-069"] = { Name = "Y2K Bandana Cap - Crimson", ID = 104128087914816, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=104128087914816&w=150&h=150" },
	["2026-01-070"] = { Name = "Y2K Bandana Cap - Blue", ID = 129108674428590, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=129108674428590&w=150&h=150" },
	["2026-01-071"] = { Name = "Y2K White Bandana Cap - White", ID = 76007630829816, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=76007630829816&w=150&h=150" },
	["2026-01-072"] = { Name = "Urban Explorer Cap - Crimson", ID = 72016642028048, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=72016642028048&w=150&h=150" },
	["2026-01-073"] = { Name = "Urban Explorer Cap - Khaki", ID = 72240854810307, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=72240854810307&w=150&h=150" },
	["2026-01-074"] = { Name = "Urban Explorer Cap - Black", ID = 126148496810511, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=126148496810511&w=150&h=150" },
	["2026-01-075"] = { Name = "Y2K Bandana Street Cap - Crimson", ID = 109693798187600, Price = 90, Category = "Hat", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=109693798187600&w=150&h=150" },
	["2026-01-076"] = { Name = "Y2K Bandana Street Cap (Red Emblem)", ID = 130034018841748, Price = 90, Category = "Hat", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=130034018841748&w=150&h=150" },
	["2026-01-077"] = { Name = "Y2K Bandana Street Cap (White Emblem)", ID = 133634661237321, Price = 90, Category = "Hat", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=133634661237321&w=150&h=150" },
	["2026-01-078"] = { Name = "Tribal Balaclava - Crimson", ID = 119793530191556, Price = 90, Category = "Hat", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=119793530191556&w=150&h=150" },
	["2026-01-079"] = { Name = "Survival outgear - Crimson", ID = 122830354260175, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=122830354260175&w=150&h=150" },
	["2026-01-080"] = { Name = "Survival Outgear - White", ID = 90178881079410, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=90178881079410&w=150&h=150" },
	["2026-01-081"] = { Name = "Explorer Headgear - Crimson", ID = 121540551896407, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=121540551896407&w=150&h=150" },
	["2026-01-082"] = { Name = "Explorer Headgear - White", ID = 71689602283078, Price = 0, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=71689602283078&w=150&h=150" },
	["2026-01-083"] = { Name = "Explorer Headgear - Khaki", ID = 71873441024792, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=71873441024792&w=150&h=150" },
	["2026-01-084"] = { Name = "Fashion Fur Cap - Red", ID = 125405758601901, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=125405758601901&w=150&h=150" },
	["2026-01-085"] = { Name = "Fashion Fur Cap - Khaki", ID = 75149652327753, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=75149652327753&w=150&h=150" },
	["2026-01-086"] = { Name = "Fashion Fur Cap - Black", ID = 70810988191177, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=70810988191177&w=150&h=150" },
	["2026-01-087"] = { Name = "Kawaii Kitty Cap - Red", ID = 137508472175121, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=137508472175121&w=150&h=150" },
	["2026-01-088"] = { Name = "Kawaii Kitty Cap - White", ID = 85443532939968, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=85443532939968&w=150&h=150" },
	["2026-01-089"] = { Name = "Kawaii Kitty Cap - Black", ID = 122147447656023, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=122147447656023&w=150&h=150" },
	["2026-01-090"] = { Name = "Bandana Western Hat - Red", ID = 115369385171643, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=115369385171643&w=150&h=150" },
	["2026-01-091"] = { Name = "Bandana Western Hat - Yellow", ID = 90808764063673, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=90808764063673&w=150&h=150" },
	["2026-01-092"] = { Name = "Bandana Western Hat - Blue", ID = 119781520122765, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=119781520122765&w=150&h=150" },
	["2026-01-093"] = { Name = "Spike Headphone - Bronze", ID = 70479868425475, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=70479868425475&w=150&h=150" },
	["2026-01-094"] = { Name = "Spike Headphones - Gold", ID = 130817218305042, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=130817218305042&w=150&h=150" },
	["2026-01-095"] = { Name = "Spiked Headphones - Silver", ID = 80752058449921, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=80752058449921&w=150&h=150" },
	["2026-01-096"] = { Name = "Skull Hoodie - White", ID = 139344641437830, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=139344641437830&w=150&h=150" },
	["2026-01-097"] = { Name = "Skull Hoodie - Red", ID = 119784841676337, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=119784841676337&w=150&h=150" },
	["2026-01-098"] = { Name = "Skull Hoodie - Black", ID = 115395357503878, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=115395357503878&w=150&h=150" },
	["2026-01-099"] = { Name = "Spiked Chapka -White", ID = 116980817607067, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=116980817607067&w=150&h=150" },
	["2026-01-100"] = { Name = "Spiked Chapka - Dark Red", ID = 122092732959879, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=122092732959879&w=150&h=150" },
	["2026-01-101"] = { Name = "Spiked Chapka - Black", ID = 120129702343017, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=120129702343017&w=150&h=150" },
	["2026-01-102"] = { Name = "Devil Horn Hoodie", ID = 109511956335623, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=109511956335623&w=150&h=150" },
	["2026-01-103"] = { Name = "Devil Horn White Hoodie", ID = 79789811463771, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=79789811463771&w=150&h=150" },
	["2026-01-104"] = { Name = "Devil Horn Black Hoodie", ID = 77396240453691, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=77396240453691&w=150&h=150" },
	["2026-01-105"] = { Name = "Kitty White Face Mask", ID = 95119435517066, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=95119435517066&w=150&h=150" },
	["2026-01-106"] = { Name = "Kitty Pink Face Mask", ID = 119964023666134, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=119964023666134&w=150&h=150" },
	["2026-01-107"] = { Name = "Kitty Black Face Mask", ID = 128245315025428, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=128245315025428&w=150&h=150" },
	["2026-01-108"] = { Name = "Scarf Hood - White", ID = 106134350441023, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=106134350441023&w=150&h=150" },
	["2026-01-109"] = { Name = "Scarf Hood - Dark Brown", ID = 104456428909817, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=104456428909817&w=150&h=150" },
	["2026-01-110"] = { Name = "Tribl balaclava - White", ID = 128555533327008, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=128555533327008&w=150&h=150" },
	["2026-01-111"] = { Name = "Tribal balaclava - Red", ID = 113613959894813, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=113613959894813&w=150&h=150" },
	["2026-01-112"] = { Name = "Tribal Baclava - Pink", ID = 133826950047910, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=133826950047910&w=150&h=150" },
	["2026-01-113"] = { Name = "Little Monster hat - Purple", ID = 138227692182148, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=138227692182148&w=150&h=150" },
	["2026-01-114"] = { Name = "Little Monster hat - Black", ID = 86368246373651, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=86368246373651&w=150&h=150" },
	["2026-01-115"] = { Name = "Little Monster hat - Green", ID = 119167533464634, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=119167533464634&w=150&h=150" },
	["2026-01-116"] = { Name = "Safari cat cap - Khaki", ID = 109597958552347, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=109597958552347&w=150&h=150" },
	["2026-01-117"] = { Name = "MMA Fighters Face Cove Cap", ID = 114177416527603, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=114177416527603&w=150&h=150" },
	["2026-01-118"] = { Name = "Sheriff Cowboy hat - Brown", ID = 100739062706721, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=100739062706721&w=150&h=150" },
	["2026-01-119"] = { Name = "Future white Helmet", ID = 82550608435763, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=82550608435763&w=150&h=150" },
	["2026-01-120"] = { Name = "Futura Headphones", ID = 97123099231063, Price = 90, Category = "Headphone", Priority = 3, Thumbnail = "rbxthumb://type=Asset&Id=97123099231063&w=150&h=150" },
	["2026-01-121"] = { Name = "Winged Headphones - Silver", ID = 116017832459401, Price = 90, Category = "Headphone", Priority = 3, Thumbnail = "rbxthumb://type=Asset&Id=116017832459401&w=150&h=150" },
	["2026-01-122"] = { Name = "Winged Headphones - Black", ID = 97760187313866, Price = 90, Category = "Headphone", Priority = 3, Thumbnail = "rbxthumb://type=Asset&Id=97760187313866&w=150&h=150" },
	["2026-01-123"] = { Name = "80's Headphones", ID = 82024952766490, Price = 90, Category = "Headphone", Priority = 3, Thumbnail = "rbxthumb://type=Asset&Id=82024952766490&w=150&h=150" },
	["2026-01-124"] = { Name = "Wing Googles", ID = 89463414496994, Price = 90, Category = "Headphone", Priority = 3, Thumbnail = "rbxthumb://type=Asset&Id=89463414496994&w=150&h=150" },
	["2026-01-125"] = { Name = "Trendy-Motorcycle-Helmet", ID = 90507041848916, Price = 90, Category = "Helmet", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=90507041848916&w=150&h=150" },
	["2026-01-126"] = { Name = "Trendy-Motorcycle-Helmet", ID = 95343467130849, Price = 90, Category = "Helmet", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=95343467130849&w=150&h=150" },
	["2026-01-127"] = { Name = "Trendy-Motorcycle-Helmet", ID = 116737830630643, Price = 90, Category = "Helmet", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=116737830630643&w=150&h=150" },
	["2026-01-128"] = { Name = "Trendy-Motorcycle-Helmet", ID = 70911405389963, Price = 90, Category = "Helmet", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=70911405389963&w=150&h=150" },
	["2026-01-129"] = { Name = "Japanese Kitsune Cat Mask", ID = 102437438466727, Price = 90, Category = "Mask", Priority = 3, Thumbnail = "rbxthumb://type=Asset&Id=102437438466727&w=150&h=150" },
	["2026-01-130"] = { Name = "Metal Face Mask - Silver", ID = 77668635602571, Price = 90, Category = "Mask", Priority = 3, Thumbnail = "rbxthumb://type=Asset&Id=77668635602571&w=150&h=150" },
	["2026-01-131"] = { Name = "Bones Necklace", ID = 80556157190166, Price = 64, Category = "Neck", Priority = 10, Thumbnail = "rbxthumb://type=Asset&Id=80556157190166&w=150&h=150" },
	["2026-01-132"] = { Name = "Bones Necklace", ID = 107415023190429, Price = 64, Category = "Neck", Priority = 10, Thumbnail = "rbxthumb://type=Asset&Id=107415023190429&w=150&h=150" },
	["2026-01-133"] = { Name = "Eye Chain Neck - Silver", ID = 135521376909502, Price = 64, Category = "Neck", Priority = 10, Thumbnail = "rbxthumb://type=Asset&Id=135521376909502&w=150&h=150" },
	["2026-01-134"] = { Name = "Eye Chain Neck -  Black", ID = 114307885243865, Price = 64, Category = "Neck", Priority = 10, Thumbnail = "rbxthumb://type=Asset&Id=114307885243865&w=150&h=150" },
	["2026-01-135"] = { Name = "Eye Chain Neck - Gold", ID = 126392616502794, Price = 64, Category = "Neck", Priority = 10, Thumbnail = "rbxthumb://type=Asset&Id=126392616502794&w=150&h=150" },
	["2026-01-136"] = { Name = "Snake Coil Collar - Dark Brown", ID = 83379088300529, Price = 64, Category = "Neck", Priority = 10, Thumbnail = "rbxthumb://type=Asset&Id=83379088300529&w=150&h=150" },
	["2026-01-137"] = { Name = "Snake Coil Collar - Green", ID = 82954968819660, Price = 64, Category = "Neck", Priority = 10, Thumbnail = "rbxthumb://type=Asset&Id=82954968819660&w=150&h=150" },
	["2026-01-138"] = { Name = "Snake Coil Collar - Black", ID = 126436131749304, Price = 64, Category = "Neck", Priority = 10, Thumbnail = "rbxthumb://type=Asset&Id=126436131749304&w=150&h=150" },
	["2026-01-139"] = { Name = "Hand companion - Skin", ID = 82698040027791, Price = 64, Category = "Shoulder", Priority = 10, Thumbnail = "rbxthumb://type=Asset&Id=82698040027791&w=150&h=150" },
	["2026-01-140"] = { Name = "Hand companion - Red", ID = 98638327230629, Price = 64, Category = "Shoulder", Priority = 10, Thumbnail = "rbxthumb://type=Asset&Id=98638327230629&w=150&h=150" },
	["2026-01-141"] = { Name = "Hand companion - Green", ID = 113840118758335, Price = 64, Category = "Shoulder", Priority = 10, Thumbnail = "rbxthumb://type=Asset&Id=113840118758335&w=150&h=150" },
	["2026-01-142"] = { Name = "Cyber Butterfly Wings", ID = 84439853830177, Price = 135, Category = "Wings", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=84439853830177&w=150&h=150" },
	["2026-01-143"] = { Name = "Crystal Glass Wings", ID = 74355755129710, Price = 135, Category = "Wings", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=74355755129710&w=150&h=150" },
	["2026-01-144"] = { Name = "Ice Vulture Wings", ID = 104028826699710, Price = 135, Category = "Wings", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=104028826699710&w=150&h=150" },
	["2026-01-145"] = { Name = "Deepsea Tentacles", ID = 92842459457127, Price = 135, Category = "Wings", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=92842459457127&w=150&h=150" },
	["2026-01-146"] = { Name = "Flame Phoenix Wings", ID = 117554697498847, Price = 135, Category = "Wings", Priority = 5, Thumbnail = "rbxthumb://type=Asset&Id=117554697498847&w=150&h=150" },
	["2026-01-147"] = { Name = "Silver Angel Wings", ID = 71087294961207, Price = 135, Category = "Wings", Priority = 5, Thumbnail = "rbxthumb://type=Asset&Id=71087294961207&w=150&h=150" },
	["2026-01-148"] = { Name = "MMA Fighter's Champion Belt - Black", ID = 84934153889096, Price = 60, Category = "Waist", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=84934153889096&w=150&h=150" },
	["2026-01-149"] = { Name = "MMA Fighter's Champion Belt - Grey", ID = 82447864846350, Price = 60, Category = "Waist", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=82447864846350&w=150&h=150" },
	["2026-01-150"] = { Name = "MMA Fighter's Champion Belt - white", ID = 132263377488200, Price = 60, Category = "Waist", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=132263377488200&w=150&h=150" },
	["2026-01-151"] = { Name = "MMA Fighter's Champion Belt - Red", ID = 99505840765729, Price = 60, Category = "Waist", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=99505840765729&w=150&h=150" },
	["2026-01-152"] = { Name = "Street-ready Gothic bandana - Black", ID = 98403445680886, Price = 90, Category = "Hat", Priority = 3, Thumbnail = "rbxthumb://type=Asset&Id=98403445680886&w=150&h=150" },
	["2026-01-153"] = { Name = "Champion Fight Headband - Crimson", ID = 97027302334655, Price = 90, Category = "Hat", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=97027302334655&w=150&h=150" },
	["2026-01-154"] = { Name = "Georges Saint-Pierre Fight Headband", ID = 95360006916530, Price = 90, Category = "Hat", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=95360006916530&w=150&h=150" },
	["2026-01-155"] = { Name = "Khabib MMA Warrior Fur Hat", ID = 111541832639860, Price = 90, Category = "Hat", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=111541832639860&w=150&h=150" },
	["2026-01-156"] = { Name = "Bullet Chain Glasses  - Crimson", ID = 77967055684702, Price = 90, Category = "Glasses", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=77967055684702&w=150&h=150" },
	["2026-01-157"] = { Name = "Bullet Chain Glasses - Black", ID = 129887625867067, Price = 90, Category = "Glasses", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=129887625867067&w=150&h=150" },
	["2026-01-158"] = { Name = "Bullet Chain Glasses - Gold", ID = 95484476779125, Price = 90, Category = "Glasses", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=95484476779125&w=150&h=150" },
	["2026-01-159"] = { Name = "Bullet Chain Glasses - Silver", ID = 129555414013636, Price = 90, Category = "Glasses", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=129555414013636&w=150&h=150" },
	["2026-01-160"] = { Name = "Punk Spike Glasses - Bronze", ID = 101192287168175, Price = 90, Category = "Glasses", Priority = 4, Thumbnail = "rbxthumb://type=Asset&Id=101192287168175&w=150&h=150" },
	["2026-01-161"] = { Name = "Punk Spike Glasses - Silver", ID = 135027907953016, Price = 90, Category = "Glasses", Priority = 4, Thumbnail = "rbxthumb://type=Asset&Id=135027907953016&w=150&h=150" },
	["2026-01-162"] = { Name = "Punk Spike Glasses - Gold", ID = 101536491067291, Price = 90, Category = "Glasses", Priority = 4, Thumbnail = "rbxthumb://type=Asset&Id=101536491067291&w=150&h=150" },
	["2026-01-163"] = { Name = "Urban Bandana Scarf - Black", ID = 128488203254182, Price = 50, Category = "Neck", Priority = 3, Thumbnail = "rbxthumb://type=Asset&Id=128488203254182&w=150&h=150" },
	["A"] = { Name = "Colorful-Dreads-Breads", ID = 83795788626582, Price = 60, Category = "Hair", Priority = 3, Thumbnail = "rbxthumb://type=Asset&Id=83795788626582&w=150&h=150" },
	["A1"] = { Name = "Nerds-Glasses", ID = 114623808048803, Price = 90, Category = "Face", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=114623808048803&w=150&h=150" },
	["A2"] = { Name = "Punk Spiked Hair – Black & Red", ID = 102119948007614, Price = 60, Category = "Hair", Priority = 3, Thumbnail = "rbxthumb://type=Asset&Id=102119948007614&w=150&h=150" },
	["B"] = { Name = "Dreads Breads - Black", ID = 113738030334375, Price = 60, Category = "Hair", Priority = 3, Thumbnail = "rbxthumb://type=Asset&Id=113738030334375&w=150&h=150" },
	["B1"] = { Name = "Nerds-Glasses-Red", ID = 74735903599213, Price = 90, Category = "Face", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=74735903599213&w=150&h=150" },
	["B2"] = { Name = "Scarf Hood - Dark Grey", ID = 136178678394338, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=136178678394338&w=150&h=150" },
	["C"] = { Name = "Colorful-Dreads-Breads", ID = 98302594802885, Price = 60, Category = "Hair", Priority = 3, Thumbnail = "rbxthumb://type=Asset&Id=98302594802885&w=150&h=150" },
	["C1"] = { Name = "Nerds-Glasses", ID = 77949725271695, Price = 90, Category = "Face", Priority = 5, Thumbnail = "rbxthumb://type=Asset&Id=77949725271695&w=150&h=150" },
	["C2"] = { Name = "Tribal balaclava - Black", ID = 106805937500041, Price = 90, Category = "Hat", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=106805937500041&w=150&h=150" },
	["D"] = { Name = "Dreads Breads - Black", ID = 101251472607139, Price = 60, Category = "Hair", Priority = 3, Thumbnail = "rbxthumb://type=Asset&Id=101251472607139&w=150&h=150" },
	["D1"] = { Name = "Nerd-Glasses", ID = 85169596622861, Price = 90, Category = "Face", Priority = 5, Thumbnail = "rbxthumb://type=Asset&Id=85169596622861&w=150&h=150" },
	["D2"] = { Name = "MMA Training Bag - Black", ID = 87378104044885, Price = 135, Category = "Bag", Priority = 5, Thumbnail = "rbxthumb://type=Asset&Id=87378104044885&w=150&h=150" },
	["E"] = { Name = "Cowboy Hat - Green", ID = 101474119058173, Price = 90, Category = "Hair", Priority = 3, Thumbnail = "rbxthumb://type=Asset&Id=101474119058173&w=150&h=150" },
	["E1"] = { Name = "MMA Fighter Training Helmet", ID = 100104438861007, Price = 90, Category = "Helmet", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=100104438861007&w=150&h=150" },
	["E2"] = { Name = "Bape Bagpack - Black", ID = 125834338933624, Price = 135, Category = "Bag", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=125834338933624&w=150&h=150" },
	["F"] = { Name = "Cowboy Hat - Brown", ID = 75995119815868, Price = 90, Category = "Hair", Priority = 3, Thumbnail = "rbxthumb://type=Asset&Id=75995119815868&w=150&h=150" },
	["F1"] = { Name = "MMA Fighter Training Helmet - Black & Green", ID = 99713943487010, Price = 90, Category = "Helmet", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=99713943487010&w=150&h=150" },
	["F2"] = { Name = "Dragon Horn Glasses", ID = 120115448345902, Price = 90, Category = "Glasses", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=120115448345902&w=150&h=150" },
	["G"] = { Name = "Cowboy Hat - Blue", ID = 75114177921975, Price = 90, Category = "Hair", Priority = 3, Thumbnail = "rbxthumb://type=Asset&Id=75114177921975&w=150&h=150" },
	["G1"] = { Name = "MMA Fighter Training Helmet - Black & Blue", ID = 81877496476783, Price = 90, Category = "Helmet", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=81877496476783&w=150&h=150" },
	["G2"] = { Name = "Dark Angel Wings", ID = 104789977385309, Price = 135, Category = "Wings", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=104789977385309&w=150&h=150" },
	["H"] = { Name = "Cowboy Hat - Black", ID = 101562313582313, Price = 90, Category = "Hair", Priority = 3, Thumbnail = "rbxthumb://type=Asset&Id=101562313582313&w=150&h=150" },
	["H1"] = { Name = "MMA Fighter Helmet - Black & Red", ID = 107974793938990, Price = 90, Category = "Helmet", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=107974793938990&w=150&h=150" },
	["H2"] = { Name = "Inferno aura", ID = 122976837251185, Price = 135, Category = "Wings", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=122976837251185&w=150&h=150" },
	["I"] = { Name = "Muay Thai Fighter Crown - Black Green", ID = 113747837981544, Price = 90, Category = "Helmet", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=113747837981544&w=150&h=150" },
	["J"] = { Name = "Muay Thai Fighter Crown - White Green", ID = 76373498147951, Price = 90, Category = "Helmet", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=76373498147951&w=150&h=150" },
	["K"] = { Name = "Muay Thai Fighter Crown - White Red", ID = 114656167427986, Price = 90, Category = "Helmet", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=114656167427986&w=150&h=150" },
	["L"] = { Name = "Muay Thai Fighter Crown - Black White", ID = 82139183698439, Price = 90, Category = "Helmet", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=82139183698439&w=150&h=150" },
	["L1"] = { Name = "Y2K Snake Glasses - Red", ID = 138002585775905, Price = 90, Category = "Face", Priority = 5, Thumbnail = "rbxthumb://type=Asset&Id=138002585775905&w=150&h=150" },
	["M"] = { Name = "Motorcycle Helmet - White & Red", ID = 100504804713142, Price = 90, Category = "Helmet", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=100504804713142&w=150&h=150" },
	["M1"] = { Name = "Y2K Snake Glasses - Black", ID = 70454931418771, Price = 90, Category = "Face", Priority = 5, Thumbnail = "rbxthumb://type=Asset&Id=70454931418771&w=150&h=150" },
	["N"] = { Name = "Motorcycle Helmet - Black & Red", ID = 97647774814364, Price = 90, Category = "Helmet", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=97647774814364&w=150&h=150" },
	["O"] = { Name = "Motorcycle Helmet - Black", ID = 96818536482215, Price = 90, Category = "Helmet", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=96818536482215&w=150&h=150" },
	["Q"] = { Name = "Protein-Shaker-White", ID = 122071796353410, Price = 50, Category = "Accessory", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=122071796353410&w=150&h=150" },
	["Q1"] = { Name = "Y2K Snake Glasses - Blue", ID = 108225068022205, Price = 90, Category = "Face", Priority = 5, Thumbnail = "rbxthumb://type=Asset&Id=108225068022205&w=150&h=150" },
	["R"] = { Name = "Protein-Shaker-Red", ID = 98181442625165, Price = 50, Category = "Accessory", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=98181442625165&w=150&h=150" },
	["R1"] = { Name = "Y2K Snake Glasses - Green", ID = 95997013721520, Price = 90, Category = "Face", Priority = 5, Thumbnail = "rbxthumb://type=Asset&Id=95997013721520&w=150&h=150" },
	["S"] = { Name = "Protein-Shaker-Black", ID = 87085165668528, Price = 50, Category = "Accessory", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=87085165668528&w=150&h=150" },
	["T"] = { Name = "Protein-Shaker-Yellow", ID = 102642333841802, Price = 50, Category = "Accessory", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=102642333841802&w=150&h=150" },
	["T1"] = { Name = "Big Metal Chain - Silver", ID = 114922634621014, Price = 50, Category = "Chain", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=114922634621014&w=150&h=150" },
	["U"] = { Name = "Face Bandages - Grey", ID = 120067224049421, Price = 90, Category = "Face", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=120067224049421&w=150&h=150" },
	["V"] = { Name = "Face Bandages - White", ID = 119243634001553, Price = 90, Category = "Face", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=119243634001553&w=150&h=150" },
	["W"] = { Name = "Face Bandages - Black", ID = 112600507634369, Price = 90, Category = "Face", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=112600507634369&w=150&h=150" },
	["X"] = { Name = "Face Bandages - Crimson", ID = 91774845227721, Price = 90, Category = "Face", Priority = 1, Thumbnail = "rbxthumb://type=Asset&Id=91774845227721&w=150&h=150" },
	["Y"] = { Name = "Eye Bandage - Black", ID = 84887382195802, Price = 90, Category = "Face", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=84887382195802&w=150&h=150" },
	["Z"] = { Name = "Eye Bandage. Grey", ID = 138705825312307, Price = 90, Category = "Face", Priority = 2, Thumbnail = "rbxthumb://type=Asset&Id=138705825312307&w=150&h=150" },
}



-- Conversion parameters for cash → gems
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

local UGC_Sorted = {}

local function BuildSortedUGC()
	UGC_Sorted = {}

	for _, data in pairs(UGC_Data) do
		table.insert(UGC_Sorted, data)
	end

	table.sort(UGC_Sorted, function(a, b)
		local pa = tonumber(a.Priority) or 0
		local pb = tonumber(b.Priority) or 0

		if pa ~= pb then
			return pa < pb
		end

		local ca = a.Category or ""
		local cb = b.Category or ""

		if ca ~= cb then
			return ca < cb
		end

		local na = a.Name or ""
		local nb = b.Name or ""

		return na < nb
	end)

	UGC_Data = UGC_Sorted
end

BuildSortedUGC()

return Monetization_Mod
