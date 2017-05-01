local SuckerGun = RegisterMod( "Sucker Gun",1 );
local SuckerGunItem = Isaac.GetItemIdByName("Sucker Gun")
local SuckerTearVariant = Isaac.GetEntityVariantByName("Tear") -- Cupid's Arrows

-- Custom debug stuff, if not working, try initializing Debug again in case DEBUG was loaded too late
local Debug = _DEBUG or {log = function() return end, logTable = function() return end}

local DMG_MULTIPLIER = 0.5	-- Soy Milk == 0.2
local STICK_DURATION = 5

local FLAG_BOOGER = 1<<47

function SuckerGun:Init()
	Debug = _DEBUG or Debug
end

function SuckerGun:Eval_Cache(play, cache)
	local player = Isaac.GetPlayer(0)
	
	if player:HasCollectible(SuckerGunItem) then
		if cache == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage * DMG_MULTIPLIER
		end
	
		if cache == CacheFlag.CACHE_TEARFLAG then
			player.TearFlags = player.TearFlags +  TearFlags.TEAR_BOOGER
		end
	end
end

function SuckerGun:Post_Player_Effect(player)
	local game = Game()
	local player = Isaac.GetPlayer(0)

	-- player:ClearCostumes()
	
	if player:HasCollectible(SuckerGunItem) then
		local entities = Isaac.GetRoomEntities()
		
		for _, entity in pairs(entities) do
			if entity.FrameCount == 1 and entity.Type == EntityType.ENTITY_TEAR then
				local tear = entity:ToTear()
				-- local tearData = entity:GetData()
                -- if not tearData.SuckerTear then
					-- tearData.SuckerTear = 1
					-- tear:ChangeVariant(SuckerTearVariant)
					-- local scale = tear.BaseDamage  / 6 + 0.4
					-- tear:GetSprite().Scale = Vector(scale, scale)
                -- end
				
				Debug.logTable(_G)
				tear:ChangeVariant(SuckerTearVariant)
			end
		end
	end
end

SuckerGun:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, SuckerGun.Init)
SuckerGun:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, SuckerGun.Eval_Cache)
-- SuckerGun:AddCallback(ModCallbacks.MC_POST_RENDER, SuckerGun.Post_Player_Effect)
SuckerGun:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, SuckerGun.Post_Player_Effect)


-- DEBUG : spawn item on start
function SuckerGun:spawnItem()                               -- Main function that contains all the code
	-- The integer value of the item you wish to spawn (1-519 for default items)
    local itemNumber = Isaac.GetItemIdByName("Sucker Gun")

    local game = Game()                                         -- The game
    local level = game:GetLevel()                               -- The level which we get from the game
    local player = Isaac.GetPlayer(0)                           -- The player
    local pos = Isaac.GetFreeNearPosition(player.Position, 80)  -- Find an empty space near the player
	
	-- Only if on the first floor and only on the first frame 
    if level:GetAbsoluteStage() == 1 and level.EnterDoor == -1 and player.FrameCount == 1 then           
        -- Spawn an item pedestal with the correct item in the spot from earlier
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, itemNumber, pos, pos, player)
    end
end

-- Actually sets it up so the function will be called, it's called too often but oh well
SuckerGun:AddCallback(ModCallbacks.MC_POST_UPDATE, SuckerGun.spawnItem)