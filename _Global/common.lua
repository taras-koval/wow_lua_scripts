function _tprint(tbl)
	local indent = 0 

	for k, v in pairs(tbl) do
		formatting = string.rep("  ", indent) .. k .. ": "

		if (type(v) == "table") then
			print(formatting)
			tprint(v, indent + 1)
		elseif (type(v) == 'boolean') then
			print(formatting .. tostring(v))		
		else
			print(formatting .. v)
		end
	end
end

function _round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

function _ternary(cond, t, f)
	if cond then return t else return f end
end

local controlAuras = {
	-- Fear
	{"Страх", "Вой ужаса", "Соблазн", "Ментальный крик", "Устрашающий крик", "Ослепление",
		"Изгнание зла", "Отпугивание зверя"},

	-- Disorient
	{"Превращение", "Дыхание дракона", "Сглаз", "Покаяние", "Ошеломление", "Парализующий удар",
		"Эффект замораживающей ловушки", "Эффект замораживающей стрелы", "Укус виверны", 
		"Ненасытная стужа", "Сковывание нежити"},

	-- Silence
	{"Безмолвие", "Запрет чар", "Удушение", "Гаррота - немота", "Антимагия - немота", "Волшебный поток",
		"Удар щитом", "Немота - Щит храмовника", "Пинок - немота", "Шок Пустоты", "Глушащий выстрел",
		"Обет молчания - немота"},

	-- Horror
	{--[["Глубинный ужас", --]]"Лик смерти"},

	-- Stun
	{"Оглушить", "Калечение", "Перехват", "Оглушающий удар", "Ударная волна", "Глубокая заморозка", 
		"Неистовство тьмы", "Эффект Инфернала", "Демонический прыжок", "Отгрызть", "Гнев небес", "Накинуться",
		"Молот правосудия", "Устрашение", "Кокон", "Ультразвук", "Удар по почкам", "Громовая поступь"},

	-- RandomStun
	{"Сотрясение", "Оглушение каменного когтя", "Печать справедливости", "Реванш - оглушение"},

	-- OpenerStun
	{"Подлый трюк", "Наскок"},

	-- Special
	{"Смерч", "Контроль над разумом", "Дезориентирующий выстрел", 
		"Наскок и оглушение", "Спячка", "Изгнание"}
}

local roots = {
	-- Root
	{"Кольцо льда", "Холод", "Гнев деревьев", "Хватка земли", "Ядовитая паутина", "Сеть", "Шип"},

	-- RandomRoot
	{"Улучшенное подрезание сухожилий", "Обморожение", "Разрушенная преграда"},

	-- Special
	{"Ледяные оковы"}
}

function _test()

	

end

function pm(cond)
	if (cond) then print("+") else print("-") end
end

function ShowGCD()
	print("Палец ", GetSpellCooldown("Прикосновение вампира"))
	print("Боль_ ", GetSpellCooldown("Слово Тьмы: Боль"))
	print("Чума_ ", GetSpellCooldown("Всепожирающая чума"))
	print("Пытка ", GetSpellCooldown("Пытка разума"))
	print("Пет__ ", GetSpellCooldown("Исчадие Тьмы"))
	print("Щит__ ", GetSpellCooldown("Слово силы: Щит"))
end


function _LookAtTarget()
	if (not UnitExists("target")) then return end
	if (not IsMouseButtonDown("RightButton")) then LookAt("target") end
end

function _IsFearTypeDebuff(debuff)
	for i = 1, #controlAuras[1] do
		if (controlAuras[1][i] == debuff) then return true end
	end
	return false
end

function _IsDisorientTypeDebuff(debuff)
	for i = 1, #controlAuras[2] do
		if (controlAuras[2][i] == debuff) then return true end
	end
	return false
end

function _UnitInControl(unit)
	for key, value in pairs(controlAuras) do
		for k, v in pairs(value) do
			if (UnitDebuff(unit, v)) then return true end
		end
	end
	return false
end

function _UnitInMagicControl(unit)

	local function CheckInTable(t)
		for key, value in pairs(t) do
			for k, v in pairs(value) do
				local debuffName, _, _, _, debuffType = UnitDebuff(unit, v)
				if (debuffName and debuffType == "Magic") then 
					return debuffName
				end
			end
		end
		return false
	end

	local control = CheckInTable(controlAuras)
	if control then return control end

	local root = CheckInTable(roots)
	if root then return root end

	return false
end

function _UnitCastingDuration(unit)
	local startTimeMS, endTimeMS = select(5, UnitCastingInfo(unit))
	if (startTimeMS) then return (endTimeMS - startTimeMS) / 1000 end
	return 0
end

function _UnitChannelDuration(unit)
	local startTimeMS, endTimeMS = select(5, UnitChannelInfo(unit))
	if (startTimeMS) then return (endTimeMS - startTimeMS) / 1000 end
	return 0
end

function _UnitCastingOrChannelDuration(unit)
	return _ternary(_UnitCastingDuration(unit), 
		_UnitCastingDuration(unit), _UnitChannelDuration(unit))
end

function _UnitCastingProgress(unit)
	local startTimeMS, endTimeMS = select(5, UnitCastingInfo(unit))
	if (startTimeMS) then 
		local finish = endTimeMS / 1000 - GetTime()
		local duration = (endTimeMS - startTimeMS) / 1000
		return 100 - (finish * 100 / duration) 
	end
	return 0
end

function _UnitChannelProgress(unit)
	local startTimeMS, endTimeMS = select(5, UnitChannelInfo(unit))
	if (startTimeMS) then 
		local finish = endTimeMS / 1000 - GetTime()
		local duration = (endTimeMS - startTimeMS) / 1000
		return 100 - (finish * 100 / duration) 
	end
	return 0
end

function _UnitCastingOrChannelProgress(unit)
	return _ternary(_UnitCastingProgress(unit), 
		_UnitCastingProgress(unit), _UnitChannelProgress(unit))
end

function _PlayerBuffOnUnit(unit, buff)
	local count, _, duration, expirationTime = select(4, UnitAura(unit, buff, nil, "PLAYER|HELPFUL"))
	if (duration) then 
		local timeProgress = GetTime() - (expirationTime - duration)
		return timeProgress / duration * 100, count
	end
	return false
end

function _PlayerDotOnUnit(unit, dot)
	local count, _, duration, expirationTime = select(4, UnitAura(unit, dot, nil, "PLAYER|HARMFUL"))
	if (duration) then 
		local timeProgress = GetTime() - (expirationTime - duration)
		return timeProgress / duration * 100, count
	end
	return false
end

function _UnitHealthInPercent(unit)
	if (not UnitExists(unit) or UnitIsDeadOrGhost(unit)) then return 0 end
	return UnitHealth(unit) / UnitHealthMax(unit) * 100
end

function _UnitManaInPercent(unit)
	if (not UnitExists(unit) or UnitIsDeadOrGhost(unit)) then return 0 end
	return UnitMana(unit) / UnitManaMax(unit) * 100
end

function _IsUnitTargetingPlayer(unit)
	if (UnitExists(unit)) then
		local unit_target = unit .. "target"
		if (UnitIsUnit(unit_target, "player")) then return true end
	end
	return false
end

function _UnitAllBuffs(unit)
	local buffs, n = {}, 1
	repeat
		buffs[n] = UnitBuff(unit, n)
		n = n + 1 
	until not buffs[n - 1]
	return buffs
end

function _UnitAllBuffIDs(unit)
	local buffs, n = {}, 1
	repeat
		buffs[n] = select(11, UnitBuff(unit, n))
		n = n + 1
	until not buffs[n - 1]
	return buffs
end

function _ExistsInTable(t, el)
	for i, v in ipairs(t) do
		if (v == el) then
			return true
		end
	end
	return false
end