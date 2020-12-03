
function tprint(tbl)

	local indent = 0 

	for k, v in pairs(tbl) do
		formatting = string.rep("  ", indent) .. k .. ": "

		if type(v) == "table" then
			print(formatting)
			tprint(v, indent + 1)
		elseif (type(v) == 'boolean') then
			print(formatting .. tostring(v))		
		else
			print(formatting .. v)
		end
	end
end

function round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

--[[function ggwp()

	local target = LineOfSight("player", "target")

	if target
	then
		return true
	else
		return false
	end

end


local interval = 60;
local f = CreateFrame("Frame");

f.FrameSinceLastUpdade = 0;

f:SetScript("OnUpdate", function(self, _)

	self.FrameSinceLastUpdade = self.FrameSinceLastUpdade + 1

	if self.FrameSinceLastUpdade >= interval then

		print(GetTime(), 123, 60)

		ggwp()

		print( ggwp() )

		self.FrameSinceLastUpdade = 0
	end;
end)--]]


-----------------------------


--[[count = 0

function ggwp22()

	if (not LineOfSight("player", "target"))
	then
		count = count + 1
	else
		count = 0
	end

	return count
end


local interval = 0;

local f = CreateFrame("Frame");
f.FrameSinceLastUpdade = 0;

f:SetScript("OnUpdate", function(self, _)
	self.FrameSinceLastUpdade = self.FrameSinceLastUpdade + 1

	if (self.FrameSinceLastUpdade >= interval) then
	
		local function fear()
			if (not LineOfSight("target") and GetDistance("target") < 11)
			then
				CastSpellByName("Ментальный крик")
			end
		end


		--Пример использования
		if (UnitExists("target") == 1 and ggwp22() >= 200) 
		then
			fear()
		end

		self.FrameSinceLastUpdade = 0
	end

end)--]]



----------------------


local time = GetTime()

function test()

	print("speed - ", GetUnitSpeed("player"))
	print("distance - ", GetDistance("target"))

	if (UnitExists("target") and UnitIsEnemy("player", "target")) then

		if (not LineOfSight("target") and GetDistance("target") < 8)
		then
			local diff = GetTime() - time

			if (diff > 0.095 and GetSpellCooldown("Ментальный крик") == 0) then
				CastSpellByName("Ментальный крик")
			end
		else
			time = GetTime()
		end
	else
		CastSpellByName("Ментальный крик")
	end
end


-- local time = GetTime()

function PsychicScream()
	-- print(not LineOfSight("target"), " ", GetDistance("target"));

	local buffsList = {
		"Безрассудство", --[[1719--]]
		"Ярость берсерка", --[[18499--]]
		"Вихрь клинков",
		"Божественный щит", --[[642--]]
		"Плащ Теней",  --[[31224--]]
		"Сдерживание", --[[19263--]]
		"Ледяная глыба", --[[45438--]]
		"Перерождение", --[[49039--]]
		"Антимагический панцирь", --[[48707--]]
		50334 --[[Берсерк--]]
	}

	local buffs, ids, i = {}, {}, 1;

	local function InRange(unit)
		if (not UnitExists(unit)) then return false end
		if (GetUnitSpeed("player") == 0 and GetDistance(unit) < 11) then return true end
		if (GetUnitSpeed("player") < 4 and GetDistance(unit) < 10) then return true end
		if (GetUnitSpeed("player") > 4 and GetDistance(unit) < 8.8) then return true end
		return false
	end

	local function UseFear()
		CancelUnitBuff("player", "Слияние с Тьмой")

		if (not UnitCastingInfo("player") == "Сковывание нежити") then
			SpellStopCasting()
		end

		UseInventoryItem(10);
		CastSpellByName("Ментальный крик")
	end

	--[[SHIFT--]]
	if (IsShiftKeyDown())
	then
		UseFear()

	--[[CTRL--]]
	elseif (IsControlKeyDown())
	then
		local units = {"target", "arena1", "arena2", "arena3"}

		for i = 1, #units do
			if (UnitExists(units[i]) and UnitIsEnemy("player", units[i]))
			then
				if (InRange(units[i]) and not LineOfSight(units[i])) then
					UseFear()
				end
			end
		end

		return

	--[[WITHOUT MOD--]]
	else
		if (UnitExists("target") and UnitIsEnemy("player", "target"))
		then

			-- Priest
			if (UnitBuff("target", "Защита от страха"))
			then
				CastSpellByName("Рассеивание заклинаний")
				return
			end

			-- dk
			if ((UnitBuff("target", "Перерождение") and UnitDebuff("target", 1) == nil) or
				(UnitBuff("target", "Перерождение") and UnitDebuff("target", 1) == "Страдание" and UnitDebuff("target", 2) == nil)) 
			then
				CastSpellByName("Сковывание нежити", "target")
				return
			end

			-- Others
			local buff, _, _, _, _, _, _, _, _, _, id = UnitBuff("target", i)

			while (buff) do
				buffs[#buffs + 1] = buff;
				ids[#ids + 1] = id;

				i = i + 1;
				buff, _, _, _, _, _, _, _, _, _, id = UnitBuff("target", i)
			end

			for i = 1, #buffsList do
				for j = 1, #buffs do
					if (buffsList[i] == buffs[j] or buffsList[i] == ids[j]) then return end
				end
			end

			if (not LineOfSight("target") and InRange("target"))
			then
				local diff = GetTime() - time

				if (diff > 0.19 and GetSpellCooldown("Ментальный крик") == 0) then
					UseFear()
					--[[print(diff)
					print(GetDistance("target"))
					print(GetUnitSpeed("player"))--]]
				end
			else
				time = GetTime()
			end

			return
		end

		if (GetSpellCooldown("Ментальный крик") == 0) then
			UseFear()
		end
	end

end

function PsychicScreamSoloq()

	local function InRange(unit)
		if (not UnitExists(unit)) then return false end
		if (GetUnitSpeed("player") == 0 and GetDistance(unit) < 11) then return true end
		if (GetUnitSpeed("player") < 4 and GetDistance(unit) < 10) then return true end
		if (GetUnitSpeed("player") > 4 and GetDistance(unit) < 8.8) then return true end
		return false
	end

	local function UseFear()
		SpellStopCasting()
		CancelUnitBuff("player", "Слияние с Тьмой")
		UseInventoryItem(10);
		CastSpellByName("Ментальный крик")
	end

	if ((not UnitExists("arena1") and not UnitExists("arena2") and not UnitExists("arena3")) 
		or IsShiftKeyDown()) 
	then 
		UseFear()
		return
	end

	if ((inRange("arena1") and not LineOfSight("arena1")) or 
		(inRange("arena2") and not LineOfSight("arena2")) or 
		(inRange("arena3") and not LineOfSight("arena3"))) 
	then
		UseFear()
	end

end

function PsychicHorror()

	local buffs = {
		"Божественный щит",
		"Длань защиты",
		"Плащ Теней",
		"Сдерживание",
		"Ледяная глыба",
		"Антимагический панцирь"
	}

	local silence = {
		"Безмолвие",
		"Удушение",
		"Глушащий выстрел",
		"Антимагия",
		"Запрет чар"
	}

	local function UsePsychicHorror(unit)
		if (not UnitExists(unit)) then return end

		for i = 1, #buffs do
			if (UnitBuff(unit, buffs[i])) then return end
		end

		for i = 1, #silence do
			if (UnitDebuff("player", silence[i])) then return end
		end

		CancelUnitBuff("player", "Слияние с Тьмой")
		SpellStopCasting()

		if (UnitBuff(unit, "Отражение заклинания") or UnitBuff(unit, "Эффект тотема заземления")) 
		then
			if (GetUnitSpeed("player") == 0) 
			then
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

	local buffs = {
		"Божественный щит",
		"Мастер аур",
		"Плащ Теней",
		"Сдерживание",
		"Ледяная глыба",
		"Антимагический панцирь"
	}

	local silence = {
		"Безмолвие",
		"Удушение",
		"Глушащий выстрел",
		"Антимагия",
		"Запрет чар"
	}

	local function UseSilence(unit)
		if (not UnitExists(unit) or GetSpellCooldown("Безмолвие") > 0) then return end

		for i = 1, #buffs do
			if (UnitBuff(unit, buffs[i])) then
				return
			end
		end

		for i = 1, #silence do
			if (UnitDebuff("player", silence[i])) then 
				return
			end
		end

		CancelUnitBuff("player", "Слияние с Тьмой")
		SpellStopCasting()

		if (UnitBuff(unit, "Отражение заклинания") or UnitBuff(unit, "Эффект тотема заземления")) 
		then
			if (GetUnitSpeed("player") == 0) 
			then
				LookAt(unit)
				CastSpellByName("Пытка разума", unit)
			end

			return
		end

		--[[if (not LineOfSight(unit)) then
			UseInventoryItem(10);
		end--]]

		if (UnitBuff(unit, "Защита от страха")) then
			CastSpellByName("Рассеивание заклинаний", unit)
		end

		CastSpellByName("Безмолвие", unit)
	end

	local function UseSilenceShackl()
		if (not UnitExists("target")) then return end

		if (UnitBuff("target", "Антимагический панцирь")) then 
			return
		end

		if (GetSpellCooldown("Безмолвие") == 0) then
			CancelUnitBuff("player", "Слияние с Тьмой")
		end

		--[[if (not LineOfSight("target")) then
			UseInventoryItem(10);
		end--]]

		if (not UnitCastingInfo("player")) then
			CastSpellByName("Безмолвие", "target")
			CastSpellByName("Контроль над разумом", "target")
		end
	end


	--[[if (GetSpellCooldown("Безмолвие") > 0) then
		return
	end--]]

	if (IsShiftKeyDown()) 
	then
		-- UseSilence("focus")
		UseSilenceShackl("target")
	elseif (IsControlKeyDown()) 
	then
		UseSilence("focus")
		-- UseSilenceShackl("target")
	else
		UseSilence("target")
	end
end

function Silence2()

	local buffs = {
		"Божественный щит",
		"Мастер аур",
		"Плащ Теней",
		"Сдерживание",
		"Ледяная глыба",
		"Антимагический панцирь"
	}

	local function UseSilence(unit)
		if (not UnitExists(unit)) then return end

		LookAt(unit)

		if (UnitBuff(unit, "Отражение заклинания") or UnitBuff(unit, "Эффект тотема заземления")) 
		then

			CastSpellByName("Пытка разума", unit)
			return
		end

		for i = 1, #buffs do
			if (UnitBuff(unit, buffs[i])) then 
				return
			end
		end

		CancelUnitBuff("player", "Слияние с Тьмой")
		SpellStopCasting()

		if (UnitBuff(unit, "Защита от страха")) then
			CastSpellByName("Рассеивание заклинаний", unit)
		end

		UseInventoryItem(10);

		CastSpellByName("Безмолвие", unit)
	end

	if (IsShiftKeyDown())
	then
		UseSilence("focus")
	else
		UseSilence("target")
	end
end

function AutoDispel()

	local units = {--[["player", --]]"party1", "party2", "pet"--[[, "partypet1"--]]}

	local debuffs = {
		"Ментальный крик", "Безмолвие", "Сковывание нежити", "Ненасытная стужа",
		"Превращение", "Кольцо льда", "Холод", "Дыхание дракона", "Глубокая заморозка",
		"Молот правосудия", "Покаяние",
		"Страх", "Соблазн", "Вой ужаса",--[["Запрет чар", --]]
		"Хватка земли",
		"Гнев деревьев", 
		"Удушение", "Кровавая метка", --[["Ледяные оковы",--]]
		"Глушащий выстрел", "Эффект замораживающей стрелы", "Эффект замораживающей ловушки"
	}
	
	local function AutoDispelHandler()

		if (UnitIsDeadOrGhost("party1") or UnitIsDeadOrGhost("party2")) then return end

		-- Spam five times per second
		local timeRemains = round(GetTime() % 0.2, 2)

		for i = 1, #units do
			-- Unit has any debuff
			if (UnitDebuff(units[i], 1)) then

				for j = 1, #debuffs do
					if(UnitDebuff(units[i], debuffs[j])) then

						local _, _, _, _, _, duration, expiration = UnitDebuff(units[i], debuffs[j])
						local dispelTime = expiration - (duration - 0.5)
						local dispelTimeEnd = expiration - 1.5

						if (GetTime() > dispelTime
							and GetTime() < dispelTimeEnd
							and timeRemains == 0
							and not (UnitCastingInfo("player") or UnitChannelInfo("player"))
							and GetSpellCooldown("Рассеивание заклинаний") == 0
							and UnitMana("player") > 2000
							and UnitInRange(units[i])
							and not UnitIsEnemy("player", units[i])) 
						then
							CastSpellByName("Рассеивание заклинаний", units[i])
						end

					end
				end
			end
		end
	end

	if (not AutoDispelFrame) 
	then
		AutoDispelFrame = CreateFrame("Frame", "AutoDispelFrame", UIParent);
	end

	if (not AutoDispelFrame:GetScript("OnUpdate")) 
	then
		AutoDispelFrame:SetScript("OnUpdate", AutoDispelHandler)
		print("dispel +")
	else
		AutoDispelFrame:SetScript("OnUpdate", nil)
		print("dispel -")
	end
end

function AutoSWD()

	local units = {"target", "focus", "arena1", "arena2", "arenapet1", "arenapet2"}
	local spells = {"Превращение", "Соблазн", "Сглаз"--[[, "Страх"--]]}

	local function AutoSWDHandler()

		if (UnitIsDeadOrGhost("party1") or UnitIsDeadOrGhost("party2")) then return end

		-- Spam ten times per second
		--[[local timeRemains = round(GetTime() % 0.1, 2)--]]

		for i = 1, #units do
			if (UnitCastingInfo(units[i]) and UnitIsEnemy("player", units[i])) then

				local spell, _, _, _, startTime, endTime, _, _, interrupt = UnitCastingInfo(units[i])

				for j = 1, #spells do
					if (spells[j] == spell) then

						local finish = endTime / 1000 - GetTime()
						local duration = (endTime - startTime) / 1000
						local percentProgress = 100 - (finish * 100 / duration)

						local _, cooldownDuration = GetSpellCooldown("Слово Тьмы: Смерть")

						if (cooldownDuration < 2 
							and percentProgress >= 75
							--[[and timeRemains == 0--]]) 
						then

							-- SpellStopCasting()
							CastSpellByName("Слово Тьмы: Смерть", units[i])

						end

					end
				end

			end

		end
	end

	if (not AutoSWDFrame) 
	then
		AutoSWDFrame = CreateFrame("Frame", "AutoSWDFrame", UIParent);
	end

	if (not AutoSWDFrame:GetScript("OnUpdate")) 
	then
		AutoSWDFrame:SetScript("OnUpdate", AutoSWDHandler)
		print("swd +")
	else
		AutoSWDFrame:SetScript("OnUpdate", nil)
		print("swd -")
	end
end