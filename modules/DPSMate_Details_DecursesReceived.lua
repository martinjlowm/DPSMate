-- Global Variables
DPSMate.Modules.DetailsDecursesReceived = {}

-- Local variables
local DetailsArr, DetailsTotal, DmgArr, DetailUser, DetailsSelected  = {}, 0, {}, "", 1
local g, g2
local curKey = 1
local db, cbt = {}, 0
local _G = getglobal
local tinsert = table.insert

function DPSMate.Modules.DetailsDecursesReceived:UpdateDetails(obj, key)
	curKey = key
	db, cbt = DPSMate:GetMode(key)
	DetailsUser = obj.user
	DPSMate_Details_DecursesReceived_Title:SetText("Decurses received by "..obj.user)
	DPSMate_Details_DecursesReceived:Show()
	self:ScrollFrame_Update()
	self:SelectCreatureButton(1)
	self:SelectCreatureAbilityButton(1,1)
end

function DPSMate.Modules.DetailsDecursesReceived:EvalTable()
	local b, a, temp, total = {}, {}, {}, 0
	for cat, val in pairs(db) do -- 3 Owner
		temp[cat] = {
			[1] = 0,
			[2] = {},
			[3] = {}
		}
		for ca, va in pairs(val) do -- 42 Ability
			if ca~="i" then
				local ta, tb, CV = {}, {}, 0
				for c, v in pairs(va) do -- 3 Target
					if c==DPSMateUser[DetailsUser][1] then
						for ce, ve in pairs(v) do
							if DPSMateAbility[DPSMate:GetAbilityById(ce)][2]=="Curse" then
								temp[cat][1]=temp[cat][1]+ve
								CV = CV + ve
								local i = 1
								while true do
									if (not tb[i]) then
										tinsert(tb, i, ve)
										tinsert(ta, i, ce)
										break
									else
										if tb[i] < ve then
											tinsert(tb, i, ve)
											tinsert(ta, i, ce)
											break
										end
									end
									i=i+1
								end
							end
						end
						break
					end
				end
				if CV>0 then
					local i = 1
					while true do
						if (not temp[cat][3][i]) then
							tinsert(temp[cat][3], i, {CV, ta, tb})
							tinsert(temp[cat][2], i, ca)
							break
						else
							if temp[cat][3][i][1] < CV then
								tinsert(temp[cat][3], i, {CV, ta, tb})
								tinsert(temp[cat][2], i, ca)
								break
							end
						end
						i=i+1
					end
				end
			end
		end
	end
	for cat, val in pairs(temp) do
		if val[1]>0 then
			local i = 1
			while true do
				if (not b[i]) then
					tinsert(b, i, val)
					tinsert(a, i, cat)
					break
				else
					if b[i][1] < val[1] then
						tinsert(b, i, val)
						tinsert(a, i, cat)
						break
					end
				end
				i=i+1
			end
			total = total + val[1]
		end
	end
	return a, total, b
end

function DPSMate.Modules.DetailsDecursesReceived:ScrollFrame_Update()
	local line, lineplusoffset
	local obj = _G("DPSMate_Details_DecursesReceived_Log_ScrollFrame")
	local path = "DPSMate_Details_DecursesReceived_Log_ScrollButton"
	DetailsArr, DetailsTotal, DmgArr = DPSMate.Modules.DetailsDecursesReceived:EvalTable()
	local len = DPSMate:TableLength(DetailsArr)
	FauxScrollFrame_Update(obj,len,10,24)
	for line=1,14 do
		lineplusoffset = line + FauxScrollFrame_GetOffset(obj)
		if DetailsArr[lineplusoffset] ~= nil then
			_G(path..line.."_Name"):SetText(DPSMate:GetUserById(DetailsArr[lineplusoffset]))
			_G(path..line.."_Value"):SetText(DmgArr[lineplusoffset][1].." ("..string.format("%.2f", 100*DmgArr[lineplusoffset][1]/DetailsTotal).."%)")
			_G(path..line.."_Icon"):SetTexture("Interface\\AddOns\\DPSMate\\images\\dummy")
			if len < 14 then
				_G(path..line):SetWidth(235)
				_G(path..line.."_Name"):SetWidth(125)
			else
				_G(path..line):SetWidth(220)
				_G(path..line.."_Name"):SetWidth(110)
			end
			_G(path..line):Show()
		else
			_G(path..line):Hide()
		end
		_G(path..line.."_selected"):Hide()
	end
end

function DPSMate.Modules.DetailsDecursesReceived:SelectCreatureButton(i)
	local line, lineplusoffset
	local obj = _G("DPSMate_Details_DecursesReceived_LogTwo_ScrollFrame")
	i = i or obj.index
	obj.index = i
	local path = "DPSMate_Details_DecursesReceived_LogTwo_ScrollButton"
	local len = DPSMate:TableLength(DmgArr[i][2])
	FauxScrollFrame_Update(obj,len,10,24)
	for line=1,14 do
		lineplusoffset = line + FauxScrollFrame_GetOffset(obj)
		if DmgArr[i][2][lineplusoffset] ~= nil then
			local ability = DPSMate:GetAbilityById(DmgArr[i][2][lineplusoffset])
			_G(path..line.."_Name"):SetText(ability)
			_G(path..line.."_Value"):SetText(DmgArr[i][3][lineplusoffset][1].." ("..string.format("%.2f", 100*DmgArr[i][3][lineplusoffset][1]/DmgArr[i][1]).."%)")
			_G(path..line.."_Icon"):SetTexture(DPSMate.BabbleSpell:GetSpellIcon(strsub(ability, 1, (strfind(ability, "%(") or 0)-1) or ability))
			if len < 14 then
				_G(path..line):SetWidth(235)
				_G(path..line.."_Name"):SetWidth(125)
			else
				_G(path..line):SetWidth(220)
				_G(path..line.."_Name"):SetWidth(110)
			end
			_G(path..line):Show()
		else
			_G(path..line):Hide()
		end
		_G(path..line.."_selected"):Hide()
	end
	for p=1, 14 do
		_G("DPSMate_Details_DecursesReceived_Log_ScrollButton"..p.."_selected"):Hide()
	end
	_G(path.."1_selected"):Show()
	DPSMate.Modules.DetailsDecursesReceived:SelectCreatureAbilityButton(i, 1)
	_G("DPSMate_Details_DecursesReceived_Log_ScrollButton"..i.."_selected"):Show()
end

function DPSMate.Modules.DetailsDecursesReceived:SelectCreatureAbilityButton(i, p)
	local line, lineplusoffset
	local obj = _G("DPSMate_Details_DecursesReceived_LogThree_ScrollFrame")
	i = i or _G("DPSMate_Details_DecursesReceived_LogTwo_ScrollFrame").index
	p = p or obj.index
	obj.index = p
	local path = "DPSMate_Details_DecursesReceived_LogThree_ScrollButton"
	local len = DPSMate:TableLength(DmgArr[i][3][p][2])
	FauxScrollFrame_Update(obj,len,10,24)
	for line=1,14 do
		lineplusoffset = line + FauxScrollFrame_GetOffset(obj)
		if DmgArr[i][3][p][2][lineplusoffset] ~= nil then
			local ability = DPSMate:GetAbilityById(DmgArr[i][3][p][2][lineplusoffset])
			_G(path..line.."_Name"):SetText(ability)
			_G(path..line.."_Value"):SetText(DmgArr[i][3][p][3][lineplusoffset].." ("..string.format("%.2f", 100*DmgArr[i][3][p][3][lineplusoffset]/DmgArr[i][3][p][1]).."%)")
			_G(path..line.."_Icon"):SetTexture(DPSMate.BabbleSpell:GetSpellIcon(strsub(ability, 1, (strfind(ability, "%(") or 0)-1) or ability))
			if len < 14 then
				_G(path..line):SetWidth(235)
				_G(path..line.."_Name"):SetWidth(125)
			else
				_G(path..line):SetWidth(220)
				_G(path..line.."_Name"):SetWidth(110)
			end
			_G(path..line):Show()
		else
			_G(path..line):Hide()
		end
		_G(path..line.."_selected"):Hide()
	end
	for i=1, 14 do
		_G("DPSMate_Details_DecursesReceived_LogTwo_ScrollButton"..i.."_selected"):Hide()
	end
	_G("DPSMate_Details_DecursesReceived_LogTwo_ScrollButton"..p.."_selected"):Show()
end