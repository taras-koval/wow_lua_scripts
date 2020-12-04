isPriestPvPEnabled = false
isPriestArenaEnabled = false
isPriestPvEEnabled = false

lastTimeInLos = 0

drResetDelay = 15
lastFearTime = 0
fearDr = 0
lastDisorientTime = 0
disorientDr = 0

lastScreamTime = 0
lastScatterTime = 0
lastRepentanceTime = 0

castingFlag = false
spellUseFlag = false


if (not DiminishingReturnsFrame) then
	DiminishingReturnsFrame = CreateFrame("Frame", "DiminishingReturnsFrame", UIParent)
end

if (not CheckLosFrame) then
	CheckLosFrame = CreateFrame("Frame", "CheckLosFrame", UIParent)
end

if (not AutoDispelPvPFrame) then
	AutoDispelPvPFrame = CreateFrame("Frame", "AutoDispelPvPFrame", UIParent)
end

if (not AutoTrinketPvPFrame) then
	AutoTrinketPvPFrame = CreateFrame("Frame", "AutoTrinketPvPFrame", UIParent)
end

if (not AutoSWDPvPFrame) then
	AutoSWDPvPFrame = CreateFrame("Frame", "AutoSWDPvPFrame", UIParent)
end

if (not InstantSpellsFrame) then
	InstantSpellsFrame = CreateFrame("Frame", "InstantSpellsFrame", UIParent)
end

if (not AutoRotationFrame) then
	AutoRotationFrame = CreateFrame("Frame", "AutoRotationFrame", UIParent)
end


function PriestPvP()
	if (not isPriestPvPEnabled) then
		PriestArenaDisabled()
		PriestPvEDisabled()

		PriestPvPEnabled()
		isPriestPvPEnabled = true
		isPriestArenaEnabled = false
		isPriestPvEEnabled = false
		print("PvP Enabled")
	else
		PriestPvPDisabled()
		isPriestPvPEnabled = false
		print("PvP Disabled")
	end
end

function PriestPvPEnabled()
	DiminishingReturnsFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	DiminishingReturnsFrame:SetScript("OnEvent", DiminishingReturns_OnEvent)
	DiminishingReturnsFrame:SetScript("OnUpdate", DiminishingReturns_OnUpdate)

	CheckLosFrame:SetScript("OnUpdate", CheckLos_OnUpdate)
	AutoDispelPvPFrame:SetScript("OnUpdate", AutoDispelPvP_OnUpdate)
	AutoTrinketPvPFrame:SetScript("OnUpdate", AutoTrinketPvP_OnUpdate)
	AutoSWDPvPFrame:SetScript("OnUpdate", AutoSWDPvP_OnUpdate)

	InstantSpellsFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	InstantSpellsFrame:SetScript("OnEvent", InstantSpells_OnEvent)
	InstantSpellsFrame:SetScript("OnUpdate", InstantSpells_OnUpdate)
end

function PriestPvPDisabled()
	DiminishingReturnsFrame:SetScript("OnUpdate", nil)
	DiminishingReturnsFrame:SetScript("OnEvent", nil)
	DiminishingReturnsFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

	AutoDispelPvPFrame:SetScript("OnUpdate", nil)
	CheckLosFrame:SetScript("OnUpdate", nil)
	AutoTrinketPvPFrame:SetScript("OnUpdate", nil)
	AutoSWDPvPFrame:SetScript("OnUpdate", nil)

	InstantSpellsFrame:SetScript("OnUpdate", nil)
	InstantSpellsFrame:SetScript("OnEvent", nil)
	InstantSpellsFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function PriestArena()

	if (not isPriestArenaEnabled) then
		PriestPvPDisabled()
		PriestPvEDisabled()

		PriestArenaEnabled()
		isPriestPvPEnabled = false
		isPriestArenaEnabled = true
		isPriestPvEEnabled = false
		print("Arena Enabled")
	else
		PriestArenaDisabled()
		isPriestArenaEnabled = false
		print("Arena Disabled")
	end
end

function PriestArenaEnabled()
	DiminishingReturnsFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	DiminishingReturnsFrame:SetScript("OnEvent", DiminishingReturns_OnEvent)
	DiminishingReturnsFrame:SetScript("OnUpdate", DiminishingReturns_OnUpdate)

	AutoSWDPvPFrame:SetScript("OnUpdate", AutoSWDPvP_OnUpdate)
	AutoDispelPvPFrame:SetScript("OnUpdate", AutoDispelPvP_OnUpdate)
end

function PriestArenaDisabled()
	DiminishingReturnsFrame:SetScript("OnUpdate", nil)
	DiminishingReturnsFrame:SetScript("OnEvent", nil)
	DiminishingReturnsFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

	AutoSWDPvPFrame:SetScript("OnUpdate", nil)
	AutoDispelPvPFrame:SetScript("OnUpdate", nil)
end


function CheckLos_OnUpdate()
	if (IsActiveBattlefieldArena()) then
		if (UnitExists("arena1")) then
			if (LineOfSight("arena1")) then
				lastTimeInLos = GetTime()
				return
			end
		end
	elseif (UnitExists("target") and UnitIsEnemy("player", "target")) then
		if (LineOfSight("target")) then
			lastTimeInLos = GetTime()
			return
		end
	end
end

-- timestamp, subevent, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellID, spellName
-- print(subevent, sourceName, destName, spellName)

function DiminishingReturns_OnEvent(self, event, _, subevent, _, sourceName, _, _, destName, _, _, spellName)
	if (subevent == "SPELL_AURA_REMOVED" or subevent == "SPELL_AURA_REFRESH" ) then
		if (not destName == UnitName("player")) then return end

		if (_IsFearTypeDebuff(spellName)) then
			fearDr = fearDr + 1
			lastFearTime = GetTime()
			return
		end

		if (_IsDisorientTypeDebuff(spellName)) then
			disorientDr = disorientDr + 1
			lastDisorientTime = GetTime()
			return
		end
	end
end

function DiminishingReturns_OnUpdate()
	local now = GetTime()

	if (fearDr > 0) then
		if (now - lastFearTime > drResetDelay) then 
			fearDr = 0 
		end
	end

	if (disorientDr > 0) then
		if (now - lastDisorientTime > drResetDelay) then 
			disorientDr = 0 
		end
	end
end

function InstantSpells_OnEvent(self, event, _, subevent, _, sourceName, _, _, destName, _, _, spellName)
	if (subevent == "SPELL_CAST_SUCCESS") then

		if (UnitIsDeadOrGhost("player")) then return end

		local function IsHotKeyDown()
			if (IsModifierKeyDown()--[[ or IsMouseButtonDown("RightButton")--]]) then return true end
			return false
		end

		-- Shadow fury
		if (spellName == "Неистовство Тьмы") then

			local function JumpForward()
				MoveForwardStart()
				JumpOrAscendStart()
				MoveForwardStop()
			end

			local units = {"arena1", "target"}

			for i = 1, #units do
				if (UnitName(units[i]) == sourceName
					and UnitIsEnemy("player", units[i])
					and GetDistance(units[i]) < 42
					and IsHotKeyDown()
				) then
					JumpForward()
					return
				end
			end
		end

		-- Psychic Scream
		if (spellName == "Ментальный крик") then

			if (UnitBuff("player", "Защита от страха")) then return end


			local function CountPriestDebuffs(unit)
				local debuffs = {"Всепожирающая чума", "Слово Тьмы: Боль", "Прикосновение вампира"}
				local count = 0

				for i = 1, #debuffs do
					if (UnitDebuff(unit, debuffs[i])) then count = count + 1 end
				end
				return count
			end

			local function TimeToUse()
				local now = GetTime()
				if (now - lastTimeInLos > 0 and now - lastTimeInLos < 0.6) then return true end
				if (now - lastScreamTime >= 22.9 and now - lastScreamTime < 23.7) then return true end
				return false
			end

			local units = {"arena1", "target"}

			for i = 1, #units do
				if (UnitName(units[i]) == sourceName and UnitIsEnemy("player", units[i])) then

					if ((TimeToUse() or IsHotKeyDown())
						and GetDistance(units[i]) < 10
						and not LineOfSight(units[i])
					) then
						if (GetSpellCooldown("Защита от страха") == 0) then
							CastSpellByName("Защита от страха")

						elseif (GetSpellCooldown("Слово Тьмы: Смерть") == 0 and UnitMana("player") > 3000) then

							if (UnitBuff("player", "Слово силы: Щит")) then
								if (not UnitDebuff("player", "Ослабленная душа") and CountPriestDebuffs("player") >= 2) then
									CancelUnitBuff("player", "Слово силы: Щит")
									CastSpellByName("Слово Тьмы: Смерть", units[i])
								end
							else
								if (CountPriestDebuffs("player") >= 1) then
									CastSpellByName("Слово Тьмы: Смерть", units[i])
								end
							end
						end
					end

					lastScreamTime = GetTime()
					return
				end
			end
		end

		-- Scatter Shot
		if (spellName == "Дезориентирующий выстрел") then
			-- print(subevent, sourceName, destName, spellName)

			local function TimeToUse()
				local now = GetTime()
				if (now - lastTimeInLos > 0 and now - lastTimeInLos < 0.6) then return true end
				if (now - lastScatterTime >= 29.9 and now - lastScatterTime < 30.7) then return true end
				return false
			end

			local units = {"arena1", "target"}

			for i = 1, #units do
				if (UnitName(units[i]) == sourceName and UnitName("player") == destName) then
					if (TimeToUse() or IsHotKeyDown()) then
						if (GetSpellCooldown("Слово Тьмы: Смерть") == 0 and UnitMana("player") > 3000) then
							CastSpellByName("Слово Тьмы: Смерть", units[i])
						end
					end

					lastScatterTime = GetTime()
					return
				end
			end
		end

		-- Repentance
		if (spellName == "Покаяние") then
			-- print(subevent, sourceName, destName, spellName)

			local function TimeToUse()
				local now = GetTime()
				if (now - lastTimeInLos > 0 and now - lastTimeInLos < 0.6) then return true end
				if (now - lastRepentanceTime >= 59.9 and now - lastRepentanceTime < 60.7) then return true end
				return false
			end

			local units = {"arena1", "target"}

			for i = 1, #units do
				if (UnitName(units[i]) == sourceName and UnitName("player") == destName) then
					if (TimeToUse() or IsHotKeyDown()) then
						if (GetSpellCooldown("Слово Тьмы: Смерть") == 0 and UnitMana("player") > 3000) then
							CastSpellByName("Слово Тьмы: Смерть", units[i])
						end
					end

					lastRepentanceTime = GetTime()
					return
				end
			end
		end

	end
end

function PsychicScreamPvP()

	local function UnitHasImmun(unit)

		local immunBuffs = {
			1719, --[["Безрассудство"--]]
			18499, --[["Ярость берсерка"--]]
			46924, --[["Вихрь клинков"--]]
			642, --[["Божественный щит"--]]
			31224, --[["Плащ Теней"--]]
			19263, --[["Сдерживание"--]]
			45438, --[["Ледяная глыба"--]]
			48707, --[["Антимагический панцирь"--]]
			50334 --[["Берсерк" --]]
		}

		local unitBuffs = _UnitAllBuffIDs(unit)

		for i, v in ipairs(unitBuffs) do
			if (_ExistsInTable(immunBuffs, v)) then
				return true
			end
		end
		return false
	end

	local function UnitInRange(unit)

		local playerSpeed = GetUnitSpeed("player")
		local unitSpeed = GetUnitSpeed(unit)
		local distance = GetDistance(unit)
		local isUnitFacing = ObjectIsFacing(unit)

		--[[if (playerSpeed == 0 and unitSpeed == 0 and distance < 9.5) then return true end

		if (playerSpeed == 0 and unitSpeed > 0 and distance < 6.8 and isUnitFacing == true) then return true end
		if (playerSpeed > 0 and unitSpeed > 0 and distance < 5.3 and isUnitFacing == true) then return true end
		if (playerSpeed > 0 and unitSpeed == 0 and distance < 6.8 and isUnitFacing == true) then return true end

		if (playerSpeed == 0 and unitSpeed > 0 and distance < 9.4 and isUnitFacing == false) then return true end
		if (playerSpeed > 0 and unitSpeed > 0 and distance < 8.7 and isUnitFacing == false) then return true end
		if (playerSpeed > 0 and unitSpeed == 0 and distance < 6.8 and isUnitFacing == false) then return true end--]]

		if (playerSpeed == 0 and unitSpeed == 0 and distance < 11) then return true end
		if ((playerSpeed >= 0 or unitSpeed >= 0) and distance < 9.5) then return true end
		if ((playerSpeed >= 0 or unitSpeed >= 0) and distance < 10.5 and isUnitFacing == false) then return true end
		if (playerSpeed < 4 and distance < 10) then return true end

		return false
	end

	local function UseFear()
		CancelUnitBuff("player", "Слияние с Тьмой")
		if (UnitCastingInfo("player") and not UnitCastingInfo("player") == "Сковывание нежити") then
			SpellStopCasting()
		end
		UseInventoryItem(10)

		CastSpellByName("Ментальный крик")
	end


	if (GetSpellCooldown("Ментальный крик") > 0 or _UnitInControl("player")) then return end
	
	if (IsShiftKeyDown()) --[[SHIFT--]]
	then
		if (GetSpellCooldown("Ментальный крик") > 0) then return end

		local units = {"target", "arena1", "arena2", "arena3"}

		for i = 1, #units do
			if (UnitExists(units[i]) and UnitIsEnemy("player", units[i])) then

				if (UnitInRange(units[i]) 
					and not UnitHasImmun(units[i])
					and not LineOfSight(units[i])
				) then
					UseFear()
				end

			end
		end
		return

	elseif (IsControlKeyDown() or IsAltKeyDown()) --[[CTRL, ALT--]]
	then

		UseFear()

	else --[[WITHOUT MOD--]]
		if (UnitExists("target") and UnitIsEnemy("player", "target"))
		then
			-- Priest
			if (UnitBuff("target", "Защита от страха")) then
				CastSpellByName("Рассеивание заклинаний")
				return
			end

			-- dk
			if (UnitBuff("target", "Перерождение")) then
				if (UnitDebuff("target", 1) == nil or (UnitDebuff("target", 1) == "Страдание" and UnitDebuff("target", 2) == nil)) then
					CastSpellByName("Сковывание нежити", "target")
				end
				return
			end

			-- Others
			if (UnitHasImmun("target") or not UnitInRange("target")) then return end

			-- LOS
			if (not LineOfSight("target"))
			then
				local playerSpeed = GetUnitSpeed("player")
				local targetSpeed = GetUnitSpeed("target")
				local distance = (GetDistance("target"))

				local diff = GetTime() - lastTimeInLos
				local delay = 0.2

				if (targetSpeed == 0 and distance < 2.5) then 
					delay = 0.095
				end

				if (diff > delay) then

					UseFear()

					--[[print("diff - ", diff)
					print("dist - ", GetDistance("target"))--]]
				end
			else
				lastTimeInLos = GetTime()
			end

			return
		end

		UseFear()
	end
end

function PsychicScreamArena()

	local function UnitHasImmun(unit)
		local immunBuffs = {
			1719, --[["Безрассудство"--]]
			18499, --[["Ярость берсерка"--]]
			46924, --[["Вихрь клинков"--]]
			642, --[["Божественный щит"--]]
			31224, --[["Плащ Теней"--]]
			19263, --[["Сдерживание"--]]
			45438, --[["Ледяная глыба"--]]
			48707, --[["Антимагический панцирь"--]]
			50334, --[["Берсерк" --]]
			49039 --[[Перерождение--]]
		}

		local unitBuffs = _UnitAllBuffIDs(unit)

		for i, v in ipairs(unitBuffs) do
			if (_ExistsInTable(immunBuffs, v)) then
				return true
			end
		end
		return false
	end

	local function UnitInRange(unit)

		local playerSpeed = GetUnitSpeed("player")
		local unitSpeed = GetUnitSpeed(unit)
		local distance = GetDistance(unit)
		local isUnitFacing = ObjectIsFacing(unit)

		if (playerSpeed == 0 and unitSpeed == 0 and distance < 11) then return true end
		if ((playerSpeed >= 0 or unitSpeed >= 0) and distance < 9.5) then return true end
		if ((playerSpeed >= 0 or unitSpeed >= 0) and distance < 10.5 and isUnitFacing == false) then return true end
		if (playerSpeed < 4 and distance < 10) then return true end

		return false
	end

	local function UseFear()
		CancelUnitBuff("player", "Слияние с Тьмой")
		SpellStopCasting()
		UseInventoryItem(10)

		CastSpellByName("Ментальный крик")
	end

	if (_UnitInControl("player") or GetSpellCooldown("Ментальный крик") > 0) then return end

	local units = {}

	if (IsActiveBattlefieldArena()) then
		units = {"arena1", "arena2", "arena3"}
	else
		units = {"target", "focus"}
	end

	if (IsShiftKeyDown()) then
		UseFear()
	else
		for i = 1, #units do
			if (UnitExists(units[i]) and UnitIsEnemy("player", units[i])) then
				if (UnitInRange(units[i]) and not UnitHasImmun(units[i])and not LineOfSight(units[i])) then
					UseFear()
					return
				end
			end
		end
	end
end

function PsychicHorror()

	function UnitHasImmun(unit)
		local buffs = {
			"Божественный щит",
			"Мастер аур",
			"Плащ Теней",
			"Сдерживание",
			"Ледяная глыба",
			"Антимагический панцирь"
		}

		for i = 1, #buffs do
			if (UnitBuff(unit, buffs[i])) then
				return true
			end
		end

		return false
	end

	local function UsePsychicHorror(unit)

		if (not UnitExists(unit)
			or UnitHasImmun(unit)
			or GetSpellCooldown("Глубинный ужас") > 0
			or GetDistance(unit) > 39
			or _UnitInControl("player")
			or LineOfSight(unit)
		) then
			return
		else
			CancelUnitBuff("player", "Слияние с Тьмой")
			SpellStopCasting()
		end

		if (UnitBuff(unit, "Отражение заклинания") or UnitBuff(unit, "Эффект тотема заземления")) then
			if (GetUnitSpeed("player") == 0) then
				LookAt(unit)
				CastSpellByName("Пытка разума", unit)
			end
			return
		end

		CastSpellByName("Глубинный ужас", unit)
	end

	if (IsShiftKeyDown())
	then
		UsePsychicHorror("focus")
	else
		UsePsychicHorror("target")
	end
end

function Silence()

	local function UnitHasImmun(unit)
		local buffs = {
			"Божественный щит",
			"Мастер аур",
			"Плащ Теней",
			"Сдерживание",
			"Ледяная глыба",
			"Антимагический панцирь"
		}

		for i = 1, #buffs do
			if (UnitBuff(unit, buffs[i])) then
				return true
			end
		end

		return false
	end

	local function HyperSpeedAcceleration()
		local _, duration, enable = GetInventoryItemCooldown(10)
		if (duration == 0 and enable) then
			UseInventoryItem(10)
		end
	end

	if (not UnitExists("target")
		or UnitHasImmun("target")
		or GetDistance("target") > 39
		or _UnitInControl("player")
		or LineOfSight("target")
	) then
		return
	end

	if (UnitBuff("target", "Отражение заклинания") or UnitBuff("target", "Эффект тотема заземления")) then
		if (GetUnitSpeed("player") == 0) then
			LookAt("target")
			CastSpellByName("Пытка разума", "target")
		end
		return
	end

	if (IsShiftKeyDown()) then
		if (not UnitCastingInfo("player") == "Контроль над разумом"
			and GetSpellCooldown("Безмолвие") == 0
			and GetSpellCooldown("Контроль над разумом") == 0
		) then
			CancelUnitBuff("player", "Слияние с Тьмой")
			SpellStopCasting()
		end

		if (GetSpellCooldown("Контроль над разумом") == 0) then
			CastSpellByName("Безмолвие", "target")
			CastSpellByName("Контроль над разумом", "target")
		end
	else
		if (GetSpellCooldown("Безмолвие") == 0) then
			CancelUnitBuff("player", "Слияние с Тьмой")
			SpellStopCasting()
			CastSpellByName("Безмолвие", "target")
		end

		if (UnitBuff("target", "Защита от страха")) then
			HyperSpeedAcceleration()
			CastSpellByName("Рассеивание заклинаний", "target")
		end
	end
end

function SilenceArena()

	function UnitHasImmun(unit)
		local buffs = {
			"Божественный щит",
			"Мастер аур",
			"Плащ Теней",
			"Сдерживание",
			"Ледяная глыба",
			"Антимагический панцирь"
		}

		for i = 1, #buffs do
			if (UnitBuff(unit, buffs[i])) then
				return true
			end
		end

		return false
	end

	local function UseSilence(unit)

		if (not UnitExists(unit)
			or UnitHasImmun(unit)
			or GetSpellCooldown("Безмолвие") > 0
			or GetDistance(unit) > 39
			or _UnitInControl("player")
		) then
			return
		else
			CancelUnitBuff("player", "Слияние с Тьмой")
			SpellStopCasting()
		end

		if (UnitBuff(unit, "Отражение заклинания") or UnitBuff(unit, "Эффект тотема заземления")) then
			if (GetUnitSpeed("player") == 0) then
				LookAt(unit)
				CastSpellByName("Пытка разума", unit)
			end
			return
		end
		
		CastSpellByName("Безмолвие", unit)
	end

	if (IsShiftKeyDown()) then
		UseSilence("focus")
	else
		UseSilence("target")
	end
end

function DispelMagic()

	local function UseDispelMagic(unit)
		if (UnitDebuff(unit, 1)) then
			CastSpellByName("Рассеивание заклинаний", unit)
		end
	end

	if (IsShiftKeyDown()) then
		UseDispelMagic("party1")
	elseif (IsControlKeyDown()) then
		UseDispelMagic("party2")
	else
		UseDispelMagic("player")
	end
end

function AutoDispelPvP_OnUpdate()

	local function IsDebuffDispelTime(unit, debuff)
		local now = GetTime()

		local _, _, _, _, _, duration, expiration = UnitDebuff(unit, debuff)
		local dispelTime = expiration - (duration - 0.6)
		local dispelTimeEnd = expiration - 1
		
		if (now > dispelTime and now < dispelTimeEnd) then return true end
		return false
	end

	local function UseDispelMagic(unit)
		if (GetSpellCooldown("Рассеивание заклинаний") == 0
			and not LineOfSight(unit)
			and not _UnitInControl("player")
			and not (UnitCastingInfo("player") or UnitChannelInfo("player"))
			and GetDistance(unit) < 42
			and UnitMana("player") > 1500
			and not UnitBuff("player", "Слияние с Тьмой")
		) then
			CastSpellByName("Рассеивание заклинаний", unit)
		end
	end

	local units = {"pet"}

	if (IsActiveBattlefieldArena()) then
		if (UnitExists("party2")) then
			units = {"party1", "party2", "pet"--[[, "partypet1", "partypet2"--]]}
		elseif (UnitExists("party1")) then
			units = {"party1", "pet"--[[, "partypet1"--]]}
		end
	end

	if (UnitDebuff("player", "Кровавая метка")) then
		if (IsDebuffDispelTime("player", "Кровавая метка")) then
			UseDispelMagic("player")
			return
		end
	end

	for i = 1, #units do
		if (UnitExists(units[i]) and UnitDebuff(units[i], 1)) then
			local control = _UnitInMagicControl(units[i])
			if (control) then
				if (IsDebuffDispelTime(units[i], control)) then
					UseDispelMagic(units[i])
					return
				end
			end
		end
	end
end

function AutoTrinketPvP_OnUpdate()

	if (GetSpellCooldown("Каждый за себя") > 0 
		or UnitBuff("player", "Слияние с Тьмой")
	) then
		return
	end

	local function IsTrinketTime(debuff)
		local duration, expiration = select(6, UnitDebuff("player", debuff))
		local dispelTimeStart = expiration - (duration - 0.5 )
		local dispelTimeEnd = expiration - 0.5

		local now = GetTime()

		if (now > dispelTimeStart and now < dispelTimeEnd) then
			return true
		end
		return false		
	end

	if (UnitDebuff("player", "Отгрызть")) then
		if (not IsTrinketTime("Отгрызть")) then return end

		local unit = IsActiveBattlefieldArena() and "arena1" or "target"

		if (_UnitHealthInPercent("player") < 35) then
			CastSpellByName("Каждый за себя")
			return
		end

		if (UnitBuff(unit, "Сила поганища") and GetDistance(unit) < 15) then
			CastSpellByName("Каждый за себя")
			return
		end

		if (not UnitBuff(unit, "Сила поганища") and UnitDebuff("player", "Призыв горгульи")) then
			CastSpellByName("Каждый за себя")
			return
		end
	end

	if (UnitDebuff("player", "Перехват")) then
		if (not IsTrinketTime("Перехват")) then return end

		if (_UnitHealthInPercent("player") < 95) then
			CastSpellByName("Каждый за себя")
			return
		end
	end
end

function AutoSWDPvP_OnUpdate()

	local units = {"target", "focus"}

	if (IsActiveBattlefieldArena()) then
		if (UnitExists("arena3")) then
			units = {"arena1", "arena2", "arena3"--[[, "arenapet1", "arenapet2", "arenapet3"--]]}
		elseif (UnitExists("arena2")) then
			units = {"arena1", "arena2", "arenapet1", "arenapet2"}
		else
			units = {"arena1", "arenapet1"}
		end
	end

	local function UseSWD(unit)

		local function SWDReady()
			local _, cooldownDuration = GetSpellCooldown("Слово Тьмы: Смерть")
			if (cooldownDuration == 0) then return true end
			if ((UnitCastingInfo("player") or UnitChannelInfo("player")) and cooldownDuration <= 1.5) then return true end
			return false
		end

		local function SWDCanInteract(unit)
			if (GetDistance(unit) < 38 and not LineOfSight(unit)) then return true end
			return false
		end

		if (	SWDReady() 
			and SWDCanInteract(unit)
			and	_UnitCastingProgress("player") < 90
			and not _UnitInControl("player")
			and not UnitIsDeadOrGhost("player")
			and UnitIsEnemy("player", unit)
			and not UnitBuff("player", "Слияние с Тьмой")
		) then
			SpellStopCasting()
			CastSpellByName("Слово Тьмы: Смерть", unit)
		end
	end

	for i = 1, #units do
		if (UnitCastingInfo(units[i])) then
			local spell = UnitCastingInfo(units[i])

			if (spell == "Превращение") then
				if (GetDistance(units[i]) < 34 and disorientDr < 2 and _UnitCastingProgress(units[i]) > 85) then
					UseSWD(units[i])
					return
				end
			end

			if (spell == "Соблазн") then
				if (_IsUnitTargetingPlayer(units[i])) then
					if (GetDistance(units[i]) < 34 and fearDr < 1 and _UnitCastingProgress(units[i]) > 60) then
						UseSWD(units[i])
						return
					end
				end
			end

			if (spell == "Сглаз") then
				if (GetDistance(units[i]) < 35 and disorientDr < 1 and _UnitCastingProgress(units[i]) > 85)	then

					if (UnitBuff("player", "Слово силы: Щит")) then
						if (not UnitDebuff("player", "Ослабленная душа") and UnitDebuff("player", "Огненный шок")) then
							CancelUnitBuff("player", "Слово силы: Щит")
						else
							return
						end
					end

					if (UnitDebuff("player", "Огненный шок") or UnitDebuff("player", "Порча") or UnitDebuff("player", "Жертвенный огонь")) then
						-- CancelUnitBuff("player", "Облик тьмы")
						UseSWD(units[i])
						return
					end
				end
			end

			if (spell == "Страх" or spell == "Вой ужаса") then
				if (GetDistance(units[i]) < 23 and fearDr < 2 and not UnitBuff("player", "Защита от страха") and _UnitCastingProgress(units[i]) > 85) then

					if (UnitBuff("player", "Слово силы: Щит")) then
						if ((UnitDebuff("player", "Порча") or UnitDebuff("player", "Жертвенный огонь"))
							and not UnitDebuff("player", "Ослабленная душа")) then
							CancelUnitBuff("player", "Слово силы: Щит")
						elseif (UnitDebuff("player", "Порча") and UnitDebuff("player", "Жертвенный огонь")) then
							CancelUnitBuff("player", "Слово силы: Щит")
						else
							return
						end
					end

					if (spell == "Вой ужаса" and GetDistance(UseSWD(units[i])) > 11) then return end

					if (UnitDebuff("player", "Огненный шок") or UnitDebuff("player", "Порча") or UnitDebuff("player", "Жертвенный огонь")) then

						--[[if (fearDr < 1) then
							CancelUnitBuff("player", "Облик тьмы")
						end--]]

						UseSWD(units[i])
						return
					end
				end
			end

		end
	end
end

function PriestPvE()
	if (not isPriestPvEEnabled) then
		PriestPvPDisabled()
		PriestArenaDisabled()

		PriestPvEEnabled()
		isPriestPvPEnabled = false
		isPriestArenaEnabled = false
		isPriestPvEEnabled = true
		print("PvE Enabled")
	else
		PriestPvEDisabled()
		isPriestPvEEnabled = false
		print("PvE Disabled")
	end
end

function PriestPvEEnabled()
	AutoRotationFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	AutoRotationFrame:SetScript("OnEvent", AutoRotation_OnEvent)
	AutoRotationFrame:SetScript("OnUpdate", AutoRotation_OnUpdate)
end

function PriestPvEDisabled()
	AutoRotationFrame:SetScript("OnUpdate", nil)
	AutoRotationFrame:SetScript("OnEvent", nil)
	AutoRotationFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function AutoRotation_OnEvent(self, event, _, subevent, _, sourceName, _, _, destName, _, _, spellName)
	if (sourceName == UnitName("player")) then

		if (spellName == "Прикосновение вампира") then
			if (subevent == "SPELL_CAST_START") then
				castingFlag = true
			end
			if (subevent == "SPELL_CAST_FAILED" 
				or subevent == "SPELL_AURA_APPLIED"
				or subevent == "SPELL_AURA_REFRESH"
			) then
				castingFlag = false
			end
			return
		end

		if (spellName == "Слово Тьмы: Боль" 
			or spellName == "Всепожирающая чума"
			or spellName == "Слияние с Тьмой"
			or spellName == "Слово силы: Щит"
		) then
			if (subevent == "SPELL_CAST_SUCCESS") then
				spellUseFlag = true
			end
			if (subevent == "SPELL_AURA_APPLIED") then
				spellUseFlag = false
			end
			return
		end

		if (spellName == "Пытка разума" and destName == UnitName("target")) then
			if (subevent == "SPELL_CAST_SUCCESS") then
				castingFlag = true
				spellUseFlag = true
			end
			if (subevent == "SPELL_AURA_APPLIED") then
				spellUseFlag = false
			end
			if (subevent == "SPELL_AURA_REMOVED" or subevent == "SPELL_CAST_FAILED") then
				castingFlag = false
			end
			return
		end

		if (spellName == "Исчадие Тьмы") then
			if (subevent == "SPELL_CAST_SUCCESS") then
				spellUseFlag = true
			end
			if (subevent == "SPELL_SUMMON") then
				spellUseFlag = false
			end
			return
		end
		
	end
end

function AutoRotation_OnUpdate()

	if (GetUnitSpeed("player") > 0) then
		castingFlag = false
		return
	end

	if (not UnitExists("target")
		or not UnitIsEnemy("player", "target")
		or UnitName("player") == UnitName("target")
		or not UnitAffectingCombat("player")
		or UnitMana("player") < 2000
		or UnitBuff("player", "Слияние с Тьмой")
		or UnitCastingInfo("player")
		or UnitChannelInfo("player")
		or GetDistance("target") > 39
		or castingFlag == true
		or spellUseFlag == true
	) then
		return
	end


	local function VampiricTouch()
		if (_PlayerDotOnUnit("target", "Прикосновение вампира")) then return end
		if (GetSpellCooldown("Прикосновение вампира") == 0) then
			CastSpellByName("Прикосновение вампира", "target")
		end
	end

	local function ShadowWordPain()
		if (_PlayerDotOnUnit("target", "Слово Тьмы: Боль")) then return end
		local _, countShadowWeaving = _PlayerBuffOnUnit("player", "Плетение Тьмы")
		if (GetSpellCooldown("Слово Тьмы: Боль") == 0 and countShadowWeaving == 5) then
			CastSpellByName("Слово Тьмы: Боль", "target")
		end
	end

	local function DevouringPlague()
		if (_PlayerDotOnUnit("target", "Всепожирающая чума")) then return end
		if (_PlayerDotOnUnit("target", "Прикосновение вампира")
			and _PlayerDotOnUnit("target", "Прикосновение вампира") > 75) then return end
		if (GetSpellCooldown("Всепожирающая чума") == 0) then
			CastSpellByName("Всепожирающая чума", "target")
		end
	end

	local function Shadowfiend()
		if (GetSpellCooldown("Исчадие Тьмы") == 0) then
			if (UnitBuff("player", "Сумеречные огни") and UnitBuff("player", "Почерпнутая сила")) then
				CastSpellByName("Исчадие Тьмы", "target")
				return
			end
			if ((UnitBuff("player", "Сумеречные огни") or UnitBuff("player", "Почерпнутая сила"))
				and _UnitManaInPercent("player") < 70) then
				CastSpellByName("Исчадие Тьмы", "target")
				return
			end
		end
	end

	local function MindFlay()
		if (GetSpellCooldown("Пытка разума") == 0) then
			_LookAtTarget()
			CastSpellByName("Пытка разума", "target")
		end
	end

	local function HyperSpeedAcceleration()
		_, duration, enable = GetInventoryItemCooldown(10)
		if (enable) then
			if (duration == 0) then
				if (_PlayerBuffOnUnit("player", "Сумеречные огни") 
					and _PlayerBuffOnUnit("player", "Сумеречные огни") < 25) then
					UseInventoryItem(10)
					return
				end
				if (_PlayerBuffOnUnit("player", "Почерпнутая сила") 
					and _PlayerBuffOnUnit("player", "Почерпнутая сила") < 25) then
					UseInventoryItem(10)
					return
				end
			end
		end
	end

	local function Dispersion()
		if (GetSpellCooldown("Слияние с Тьмой") == 0) then
			if ((_UnitHealthInPercent("player") < 35 or _UnitManaInPercent("player") < 35)
				and not UnitBuff("player", "Сумеречные огни")
				and not UnitBuff("player", "Почерпнутая сила")
				and not UnitBuff("player", "Гиперскоростное ускорение")
			) then
				CastSpellByName("Слияние с Тьмой")
			end
		end
	end

	local function PowerWordShield()
		if (GetSpellCooldown("Слово силы: Щит") == 0) then
			if (_UnitHealthInPercent("player") < 65 
				and not UnitBuff("player", "Слово силы: Щит") 
				and not UnitDebuff("player", "Ослабленная душа")
			) then
				CastSpellByName("Слово силы: Щит", "player")
			end
		end
	end


	Dispersion()
	PowerWordShield()
	HyperSpeedAcceleration()
	VampiricTouch()
	ShadowWordPain()
	DevouringPlague()
	Shadowfiend()
	MindFlay()
end