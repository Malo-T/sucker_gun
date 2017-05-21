local SuckerGun = RegisterMod( "Sucker Gun",1 );

CollectibleType.SUCKER_GUN = Isaac.GetItemIdByName("Sucker Gun")
TearVariant.SUCKER = Isaac.GetEntityVariantByName("SuckerTear") -- Cupid's Arrows
EffectVariant.SUCKER_DECAL = Isaac.GetEntityVariantByName("SuckerTearParticle")

-- Custom debug stuff, if not working, try initializing Debug again in case DEBUG was loaded too late
local Debug = _DEBUG or {log = function() return end, logTable = function() return end}

local DMG_MULTIPLIER = 0.5	-- Soy Milk == 0.2
local STICK_DURATION = 5

function SuckerGun:Init()
	Debug = _DEBUG or Debug
end
SuckerGun:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, SuckerGun.Init)

-- TODO handle overrides like Ludovico (take out Ludo from the itempool?)
function SuckerGun:Eval_Cache(player, cacheFlag)	
	if player:HasCollectible(CollectibleType.SUCKER_GUN) then
		if cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage * DMG_MULTIPLIER
		end
	
		if cacheFlag == CacheFlag.CACHE_TEARFLAG then
			player.TearFlags = SuckerGun:OverrideTearFlagsExceptions(player.TearFlags)
			player.TearFlags = player.TearFlags + TearFlags.TEAR_BOOGER
		end
	end
end
SuckerGun:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, SuckerGun.Eval_Cache)

function SuckerGun:On_Damage(entity, amount, flag, source, countdown)
	if type(source) == "Entity" then
		if source.Type == EntityType.ENTITY_TEAR and source.Variant == TearVariant.SUCKER then
			source:GetSprite():Stop()
		end
	end
end
SuckerGun:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, SuckerGun.On_Damage)

function SuckerGun:Post_Player_Effect(player)
	if player:HasCollectible(CollectibleType.SUCKER_GUN) then
		local entities = Isaac.GetRoomEntities()
		
		for _, entity in pairs(entities) do
			if entity.Type == EntityType.ENTITY_TEAR then
				local tear = entity:ToTear()
				if not SuckerGun:IsTearVariantException(tear) then				
					local data = tear:GetData()
					local animScale
					
					if tear.Variant ~= TearVariant.SUCKER then
						tear:ChangeVariant(TearVariant.SUCKER)
						data.Scale = tear.Scale
						animScale = SuckerGun:GetAnimScale(data.Scale)
						tear:SetSpriteFrame("RegularTear".. animScale, 1)
						tear.SpriteRotation = tear.PosDisplacement:GetAngleDegrees()
					else
						if data.Scale ~= tear.Scale then
							data.Scale = tear.Scale
							tear.SpriteScale = Vector(data.Scale, data.Scale)
							
							animScale = SuckerGun:GetAnimScale(data.Scale)
							tear:GetSprite():Play("RegularTear".. animScale, true)
							tear.SpriteRotation = tear.PosDisplacement:GetAngleDegrees()
						end
						if (tear.Height > -5 or tear:CollidesWithGrid()) and not data.Collided then
							animScale = SuckerGun:GetAnimScale(data.Scale)
							SuckerGun:SpawnDecal(player, tear, animScale)
							
							data.Collided = true
							tear.Visible = false
						end	
					end
				end
			end
		end
	end
end
SuckerGun:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, SuckerGun.Post_Player_Effect)

local PROTECTED_VARIANTS = {
		TearVariant.EXPLOSIVO,
		TearVariant.BOBS_HEAD
	}
function SuckerGun:IsTearVariantException(tear)
	local currentVariant = tear.Variant
	for _, variant in pairs(PROTECTED_VARIANTS) do
		if currentVariant == variant then
			return true
		end
	end
	return false
end

local PROTECTED_TEARFLAGS = {
		TearFlags.TEAR_LUDOVICO
	}
function SuckerGun:OverrideTearFlagsExceptions(tearFlags)
	local cleanedFlags = tearFlags
	for _, flag in pairs(PROTECTED_TEARFLAGS) do
		cleanedFlags = cleanedFlags | flag
		cleanedFlags = cleanedFlags ~ flag
	end
	return cleanedFlags
end

-- Spawn an arrow as an effect
-- TODO : keep the same aspect
function SuckerGun:SpawnDecal(player, tear, animScale)
	-- Debug.log(animScale)
	
	local decal = Isaac.Spawn(
		EntityType.ENTITY_EFFECT,
		EffectVariant.SUCKER_DECAL,
		EffectVariant.EFFECT_NULL,
		tear.Position, 
		Vector(0, 0),
		player
	):ToEffect()
	
	decal.SpriteScale = Vector(tear.Scale, tear.Scale)
	decal.PositionOffset = tear.PositionOffset
	decal.SpriteRotation = tear.SpriteRotation
	
	decal:SetColor(tear:GetColor(), 0, 0, false, false)
	decal:SetTimeout(5)
	decal:GetSprite():Play("Gib".. animScale)
end

function SuckerGun:GetAnimScale(scale)
	local animScale = math.floor(scale*10)
	if animScale < 1 then
		animScale = 1 
	elseif animScale > 13 then
		animScale = 13
	end
	return animScale
end

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
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, 329, Isaac.GetFreeNearPosition(player.Position, 80), Isaac.GetFreeNearPosition(player.Position, 80), player)
    end
end

-- Actually sets it up so the function will be called, it's called too often but oh well
SuckerGun:AddCallback(ModCallbacks.MC_POST_UPDATE, SuckerGun.spawnItem)