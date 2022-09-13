local tbSeriesColor	= {
	[Env.SERIES_NONE]	= "white",
	[Env.SERIES_METAL]	= "gold",
	[Env.SERIES_WOOD]	= "wood",
	[Env.SERIES_WATER]	= "water",
	[Env.SERIES_FIRE]	= "fire",
	[Env.SERIES_EARTH]	= "earth",
};

local function Add1(value1, value2, bEx2)
	if type(value1) == "table" then
		value1 = value1.nPoint;
	end
	if type(value2) == "table" then
		value2 = value2.nPoint;
	end
	if (not value2) or (value1 == value2) then
		local str = "";
		if (value1 > 0) then
			str = "+";
		elseif (value1 < 0) then
			value1 = -value1;
			str = "-";
		end
		str = str..value1;
		return str;
	else
		if (value1 * value2 < 0) then
			assert(false);
			return;
		end
		local str = "";
		if (value2 > 0) then
			str = "+";
		elseif (value2 < 0) then
			value1 = -value1;
			value2 = -value2;
			str = "-";
		end
		return string.format("%s%s%s%s", str, value1, (bEx2 == 1) and "→" or " đến ", value2);
	end
end

local function Add2(value1, value2, bEx2)
	if type(value1) == "table" then
		value1 = value1.nPoint;
	end
	if type(value2) == "table" then
		value2 = value2.nPoint;
	end
	if (not value2) or (value1 == value2) then
		local str = "";
		if (value1 > 0) then
			str = "-";
		elseif (value1 < 0) then
			value1 = -value1;
			str = "+";
		end
		str = str..value1;
		return str;
	else
		if (value1 * value2 < 0) then
			assert(false);
			return;
		end
		local str = "";
		if (value2 > 0) then
			str = "-";
		elseif (value2 < 0) then
			value1 = -value1;
			value2 = -value2;
			str = "+";
		end
		return string.format("%s%s%s%s", str, value1, (bEx2 == 1) and "→" or " đến ", value2);
	end
end

local function Add3(value1, value2, bEx2)
	if type(value1) == "table" then
		value1 = value1.nPoint;
	end
	if type(value2) == "table" then
		value2 = value2.nPoint;
	end
	if (not value2) or (value1 == value2) then
		local str = "";
		if (value1 > 0) then
			str = "Tăng cường";
		elseif (value1 < 0) then
			str = "Suy yếu";
		end
		str = str..value1;
		return str;
	else
		if (value1 * value2 < 0) then
			assert(false);
			return;
		end
		local str = "";
		if (value2 > 0) then
			str = "Tăng cường";
		elseif (value2 < 0) then
			value1 = -value1;
			value2 = -value2;
			str = "Suy yếu";
		end
		return string.format("%s%s%s%s", str, value1, (bEx2 == 1) and "→" or " đến ", value2);
	end
end

local function Add4(value1, value2, bEx2)
	if type(value1) == "table" then
		value1 = value1.nPoint;
	end
	if type(value2) == "table" then
		value2 = value2.nPoint;
	end
	if (not value2) or (value1 == value2) then
		return tostring(value1);
	end
	return string.format("%s%s%s", value1, (bEx2 == 1) and "→" or " đến ", value2);
end

local function Add5(value1, value2, bEx2)
	if type(value1) == "table" then
		value1 = value1.nPoint;
	end
	if type(value2) == "table" then
		value2 = value2.nPoint;
	end
	if (not value2) or (value1 == value2) then
		local str = "";
		if (value1 > 0) then
			str = "Khuếch đại";
		elseif (value1 < 0) then
			value1 = -value1;
			str = "Thu nhỏ";
		end
		str = str..value1;
		return str;
	else
		if (value1 * value2 < 0) then
			assert(false);
			return;
		end
		local str = "";
		if (value2 > 0) then
			str = "Khuếch đại";
		elseif (value2 < 0) then
			value1 = -value1;
			value2 = -value2;
			str = "Thu nhỏ";
		end
		return string.format("%s%s%s%s", str, value1, (bEx2 == 1) and "→" or " đến ", value2);
	end
end

local function Add6(value1, value2, bEx2)
	if type(value1) == "table" then
		value1 = value1.nPoint;
	end
	if type(value2) == "table" then
		value2 = value2.nPoint;
	end
	if (not value2) or (value1 == value2) then
		local str = "";
		if (value1 > 0) then
			str = "Thu nhỏ";
		elseif (value1 < 0) then
			value1 = -value1;
			str = "Khuếch đại";
		end
		str = str..value1;
		return str;
	else
		if (value1 * value2 < 0) then
			assert(false);
			return;
		end
		local str = "";
		if (value2 > 0) then
			str = "Thu nhỏ";
		elseif (value2 < 0) then
			value1 = -value1;
			value2 = -value2;
			str = "Khuếch đại";
		end
		return string.format("%s%s%s%s", str, value1, (bEx2 == 1) and "→" or " đến ", value2);
	end
end

local function ChangeMagicTableToValue(tbMagic)
	if not tbMagic then
		return nil;
	end
	for i = 2, 4 do
		if tbMagic[i] and type(tbMagic[i]) == "table" then
			tbMagic[i] = tbMagic[i].nPoint;
		end
	end
	return tbMagic;
end

local function Frame2Sec(value)
	if type(value) == "table" then
		value = value.nPoint;
	end
	return math.floor(value / Env.GAME_FPS * 10) / 10; 
end

--毒伤时间转化为次数
local function Frame2Times(value)
	return math.floor(value *2 / Env.GAME_FPS ) + 1;
end

--五行印点数转换为比例
local function v2p(value)
	local nP2 = KFightSkill.GetSetting().SeriesTrimParam2;
	local nP3 = KFightSkill.GetSetting().SeriesTrimParam3;
	local nMaxPer = KFightSkill.GetSetting().SeriesTrimMax;
	--me.nLevel实际上是指目标的等级
	return math.min(nMaxPer, math.floor(10000*value/( nP2 * me.nLevel + nP3 ))/100);
end

local function Frame2Sec2(value)
	if type(value) == "table" then
		if value.nType == 1 then
			local nValue = math.floor(value.nPoint / Env.GAME_FPS * 10) / 10;
			if nValue >= 0 then
				return "+" .. nValue .. " giây ";
			else
				return "-" .. -nValue .. " giây ";
			end
		elseif value.nType == 2 then
			if value.nPoint>= 0 then
				return "+" .. value.nPoint .. "%";
			else
				return "-" .. -value.nPoint .. "%";
			end
		elseif value.nType == 3 then
			return "trở thành " .. value.nPoint .. " giây ";
		end
	else
		local nNo = math.floor(value / Env.GAME_FPS * 10) / 10;
		if (nNo >= 0) then
			return "+" .. nNo .. " giây ";
		else
			return "-" .. -nNo .. " giây ";
		end;
	end
	return "Chưa biết";
end;

local function GetSkillName(value)
	if type(value) == "table" then
		value = value.nPoint;
	end
	local szName = KFightSkill.GetSkillName(value);
	local tbTrueName = Lib:SplitStr(szName, "&");
	return tbTrueName[1];
end

local function EnchantType(value)
	--print("nType = ", value)
	local tbS1 = {"+","Khuếch đại","trở thành "};
	local tbS2 = {"-","Thu nhỏ","trở thành "};
	local tbE = {"","%",""};
	
	local szEnh = ""
	if value.nPoint>=0 then
		szEnh = tbS1[value.nType]..math.abs(value.nPoint)..tbE[value.nType];
	else
		szEnh = tbS2[value.nType]..math.abs(value.nPoint)..tbE[value.nType];
	end
	return szEnh;
end

local function EnchantTypeV(value)
	--print("nType = ", value)
	local tbS1 = {"+","Khuếch đại","trở thành "};
	local tbS2 = {"-","Thu nhỏ","trở thành "};
	local tbE = {"","%",""};
	
	local szEnh = ""
	if value.nPoint>=0 then
		szEnh = tbS1[value.nType]..math.abs(value.nPoint)..tbE[value.nType];
	else
		szEnh = tbS2[value.nType]..math.abs(value.nPoint)..tbE[value.nType];
	end
	return szEnh;
end
local function EnchantTypeP(value)
	--print("nType = ", value)
	local tbS1 = {"+","Khuếch đại","trở thành "};
	local tbS2 = {"-","Thu nhỏ","trở thành "};
	local tbE = {"%","%","%"};
	
	local szEnh = ""
	if value.nPoint>=0 then
		szEnh = tbS1[value.nType]..math.abs(value.nPoint)..tbE[value.nType];
	else
		szEnh = tbS2[value.nType]..math.abs(value.nPoint)..tbE[value.nType];
	end
	return szEnh;
end

local function GetSkillNameByParam(value1)
	local tbRandomSkill = Lib:LoadTabFile("setting\\fightskill\\randomskill.txt");
	local szMsg = "";
	for i = 1,#tbRandomSkill do 
		--print(i , tbRandomSkill[i].nFactionId , #tbRandomSkill)
		if tonumber(tbRandomSkill[i].nFactionId) == me.nFaction then
			if tonumber(tbRandomSkill[i].nRouteId) == me.nRouteId then
				if tonumber(tbRandomSkill[i].nIndex) == value1 then
					szMsg = KFightSkill.GetSkillName(tonumber(tbRandomSkill[i].nSkillId));
					break;
				end
			end
		elseif tonumber(tbRandomSkill[i].nFactionId) == 0 and 
			tonumber(tbRandomSkill[i].nRouteId) == 0 and 
			tonumber(tbRandomSkill[i].nIndex) == value1 then
				szMsg = KFightSkill.GetSkillName(tonumber(tbRandomSkill[i].nSkillId));
				break;
		end
	end
	szMsg = "" and szMsg or "Chưa rõ";
	return szMsg;
end;

local tbParamToLevel = {
	"Cấp 10",
	"Cấp 30",
	"Cấp 40",
	"Cấp 50",
	"Cấp 60",
	"Cấp 70",
	"Cấp 90",
	"Cấp 100",
	"Cấp 110",
	"Cấp 120",
	"Mật tịch-Sơ",
	"Mật tịch-Trung",
	"Mật tịch-Cao",
};

local function CastSkill(nSkillId, nLevel)
	local str = "Bao gồm";
	local tbSkillInfo = KFightSkill.GetSkillInfo(nSkillId, nLevel);
	local nActualLevel = me.GetSkillLevel (nSkillId);
	local nSkillLevel = nLevel;
	if (nSkillLevel > nActualLevel) then
		nSkillLevel = nActualLevel;
	end

	if (nSkillLevel < 0) then
		nSkillLevel = 0;
	end
	--填成63就不显示最高多少级了...
	if nLevel >= 63 then
		str = str.."<color=green>["..tbSkillInfo.szName.."]<color>: <color=gold>"..nSkillLevel.."cấp <color>";
	else
		str = str.."<color=green>["..tbSkillInfo.szName.."]<color>: <color=gold>"..nSkillLevel.."cấp <color>, ".."Tối đa <color=gold>"..nLevel.."cấp <color>";
	end
	return str;
end

local function GetIgnoreAttackDesc(tbSkillInfo)
	if (tbSkillInfo.nLevel > 6) then
		return;
	end;

	local szMsg = "Hóa giải đòn tấn công của người chơi <color=gold>cấp %s và quan hàm thấp hơn<color> với xác suất nhất định";
	local szLevel = tostring(tbSkillInfo.nLevel + 1);
	szMsg = string.format(szMsg, szLevel);

	return szMsg;
end;

local function EnchantDesc(tbMagic)
	if (not tbMagic) then
		return "";
	end;

	local szClassName = SkillEnchant:GetNameById(tbMagic[1]);
	local tbData = SkillEnchant:GetClass(szClassName);
	if (not tbData) then
		return "";
	end;

	local tbDesc = {};
	local szDesc = "";
	for _, tb in pairs(tbData.tbEnchantData) do
		for szName, tbMgc in pairs(tb.magic) do
			if (type(tbMgc) == "table") then
				local tbData = {};
				tbData[1] = tb.RelatedSkillId;
				if (tbMgc.value1) then
					local tbPoint1 = {};
					for _, tbP in pairs(tbMgc.value1[2]) do
						tbPoint1[#tbPoint1 + 1] = {tbP[1], tbP[2]};
					end;
					tbData[2] = {};
					tbData[2].nType = tbMgc.value1[1];
					tbData[2].nPoint = Lib.Calc:Link(tbMagic[2], tbPoint1);
				end;

				if (tbMgc.value2) then
					local tbPoint2 = {};
					for _, tbP in pairs(tbMgc.value2[2]) do
						tbPoint2[#tbPoint2 + 1] = {tbP[1], tbP[2]};
					end;
					tbData[3] = {};
					tbData[3].nType = tbMgc.value2[1];
					tbData[3].nPoint = Lib.Calc:Link(tbMagic[2], tbPoint2);
				end;

				if (tbMgc.value3) then
					local tbPoint3 = {};
					for _, tbP in pairs(tbMgc.value3[2]) do
						tbPoint3[#tbPoint3 + 1] = {tbP[1], tbP[2]};
					end;
					tbData[4] = {};
					tbData[4].nType = tbMgc.value3[1];
					tbData[4].nPoint = Lib.Calc:Link(tbMagic[2], tbPoint3);
				end;
			
				local szMsg, nGroupId, nNum = FightSkill:GetMagicDesc(szName, tbData, nil, nil, true);
				if (szMsg and szMsg ~= "") then
					tbDesc[#tbDesc+1] = {tb.RelatedSkillId, nGroupId, nNum, szMsg};
					--if (szDesc ~= "") then
					--	szDesc = szDesc .. "\n";
					--end;
					--szDesc = szDesc .. szMsg;
				end;
			end;
		end;
	end;
	local function _sort(a, b)
		if (a[1] ~= b[1]) then
			return a[1]<b[1];
		end
		if (a[2] ~= b[2]) then
			return a[2]<b[2];
		end
		return a[3] < b[3];
	end
	table.sort(tbDesc, _sort);
	for i=1, #tbDesc do
		szDesc = szDesc..tbDesc[i][4]..(i ~= #tbDesc and "\n" or "");
	end
	return szDesc;
end;

local tbSkillParam1_Desc = {
			"Tốc độ xung kích của <color=orange>%s<color>: <color=gold>%s<color>",
			"Cự ly di chuyển nhanh của <color=orange>%s<color>: <color=gold>%s%%<color>",
		}

local function SkillParam1(tbMagic1)
	if tbMagic1 and type(tbMagic1[1]) == "table" then
		tbMagic1[1] = tbMagic1[1].nPoint;
	end
	if tbMagic1 and type(tbMagic1[2]) == "table" then
		tbMagic1[2] = tbMagic1[2].nPoint;
	end
	local nNo = 0;
	if (tbMagic1 and tbMagic1[1] == 41)  then --天王
		nNo = 1;
	elseif (tbMagic1[1] == 64) then
		nNo = 2;
	end;
	if (nNo ~= 0) then
		local szSkillName = GetSkillName(tbMagic1[1]);
		return string.format(
					tbSkillParam1_Desc[nNo],
					szSkillName,
					Add1(tbMagic1[2])
				);
	end;
	return "";
end;

local function MissileRange(tbMagic1)
	--[[local nNo = 0;
	for i = 2, 4 do
		if tbMagic1[i] and type(tbMagic1[i]) == "table" then
			tbMagic1[i] = tbMagic1[i].nPoint;
		end
	end
	
	
	if (tbMagic1[2]) then
		nNo = 2;
	end;
	if (tbMagic1[4]) then
		nNo = 4;
	end;
	if (nNo ~= 0) then
		return string.format(
					"<color=orange>%s<color>的效果范围：<color=gold>%s格<color>",
					GetSkillName(tbMagic1[1]),
					Add1(tbMagic1[nNo])
				);
	end;]]
	tbMagic1 = ChangeMagicTableToValue(tbMagic1);
	assert(tbMagic1[4]);
	local nNo = tbMagic1[2] and 2 or 4;
	local szMsg = ""
	szMsg = string.format(
				"Phạm vị <color=orange>%s<color>-%s: <color=gold>%s ô<color>",
				GetSkillName(tbMagic1[1]),
				((nNo == 4) and "Sát thương" or "Hiệu quả"),
				Add1(tbMagic1[nNo])
			);
	return szMsg;--..(tbMagic1[3] or 0);
end;

local function AddedwithEnemyCount(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
	if type(tbMagic1[2]) == "table" then
		tbMagic1[2] = tbMagic1[2].nPoint;
	end
	local szMsg = "Mỗi lần thêm 1 kẻ địch sẽ tăng những thuộc tính sau, ";
	szMsg = szMsg.."Cộng dồn tối đa <color=gold>"..tbMagic1[2].."<color>".."Hiệu quả\n";
	local tbInfo = nil;
	if (tbMagic1[2] > 0) then
		tbInfo	= KFightSkill.GetSkillInfo(tbMagic1[1], tbSkillInfo.nLevel);
	else
		tbMagic1[2]	= 0;
	end
	if (not tbInfo) then
		return;
	end

	local szClassName = tbInfo.szClassName;
	local tbSkill = assert(FightSkill.tbClass[szClassName], "Skill{"..szClassName.."} not found!");
	local tbMsg = {};
	tbSkill:GetDescAboutLevel(tbMsg, tbInfo);
	szMsg = szMsg .. table.concat(tbMsg, "\n").."\n";
	szMsg = string.gsub(szMsg, "Duy trì: <color=gold>%d*.*%d* giây<color>\n", "");
	szMsg = string.gsub(szMsg, "<color=white>Duy trì: <color><color=gold>%d*giây<color>\n", "");--以后的技能tips中的持续时间格式
	return szMsg;
end;



FightSkill.ENCHANT_DESCS =
{
	[1] =--技能设置1
	{
		{"missile_ablility", {"<color=orange>%s<color> có <color=gold>%s%%<color> xuyên suốt mục tiêu", {"getskillname", 1},  2}},
		{"skill_param1_v",
					function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
			 			return SkillParam1(tbMagic1);
					end
		},
		{"missile_range",
					function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
			 				return MissileRange(tbMagic1);
					end
		},
		--{"<color=orange>%s<color>的冲刺速度：<color=gold>%s<color>", {"getskillname", 1}, {"add1", 2}}},
		{"skill_maxmissile",
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				tbMagic1 = ChangeMagicTableToValue(tbMagic1);
				if (tbMagic1[2] == 0) then
					return "";
				end
				return string.format("Bố trí tối đa của <color=orange>%s<color>: <color=gold>+%s<color>", GetSkillName(tbMagic1[1]), tbMagic1[2]);
			end
		},
		{"missile_speed_v", {"Tốc độ bay của <color=orange>%s<color>: <color=gold>%s<color>", {"getskillname", 1}, {"add1", 2}}},
		{"skill_missilenum_v",{"Số lượng của <color=orange>%s<color>: <color=gold>%s<color>", {"getskillname", 1}, {"add1", 2}}},
		{"skill_mintimepercast_v", {"Giãn cách thi triển <color=orange>%s<color>: <color=gold>%s<color>", {"getskillname", 1}, {"frame2sec2", 2}}},
		{"skill_mintimepercastonhorse_v", {"Giãn cách cưỡi ngựa thi triển <color=orange>%s<color>: <color=gold>%s<color>", {"getskillname", 1}, {"frame2sec2", 2}}},
		
		{"missile_lifetime_v", function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				tbMagic1 = ChangeMagicTableToValue(tbMagic1);
				if (tbMagic1[2] == 0) then
					return "";
				end
				return string.format("Thời gian duy trì của <color=orange>%s<color>: <color=gold>Tăng %s giây<color>", GetSkillName(tbMagic1[1]), Frame2Sec(tbMagic1[2]));
			end
		},
		{"skill_attackradius", {"Cự ly thi triển của <color=orange>%s<color>: <color=gold>%s<color>", {"getskillname", 1}, {"add1", 2}}},
		{"keephide", {"Sử dụng <color=orange>%s<color> không bị mất ẩn thân", {"getskillname", 1}}},
		{"skill_cost_v", {"Tiêu hao kỹ năng <color=orange>%s<color>: <color=gold>%s<color>", {"getskillname", 1}, {"enchanttypev", 2}}},
		{"missile_hitcount", {"Số người tác dụng của mỗi chiêu thức <color=orange>%s<color>: <color=gold>%s<color>", {"getskillname", 1}, {"enchanttypev", 2}}},
		{"skill_cost_buff1layers_v",
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				tbMagic1 = ChangeMagicTableToValue(tbMagic1);
				local szMsg = (tbMagic1[4] ==0) and "Cần tốn" or "Sẽ trừ";
				szMsg = string.format("Khi thi triển <color=orange>%s<color> %s <color=gold>tầng %s<color> <color=green>[%s]<color>",  GetSkillName(tbMagic1[1]), szMsg, tbMagic1[3], GetSkillName(tbMagic1[2]));
				return szMsg;
			end
		},
	},
	[2] =--立即生效
	{
		{"appenddamage_p", {"Tấn công cơ bản của <color=orange>%s<color>: <color=gold>%s<color>", {"getskillname", 1}, {"enchanttypep", 2}}},
		{"state_drag_attack", function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				tbMagic1 = ChangeMagicTableToValue(tbMagic1);
				return string.format("<color=orange>%s<color>-Giật lại: <color=gold>%s%%<color>, khoảng cách lớn nhất <color=gold>%d<color>",
					GetSkillName(tbMagic1[1]), 
					tbMagic1[2], 
					tbMagic1[3]*tbMagic1[4]);
			end
		},
		{"state_knock_attack", function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				tbMagic1 = ChangeMagicTableToValue(tbMagic1);
				return string.format("<color=orange>%s<color>-Đánh lui: <color=gold>%s%%<color>, khoảng cách đánh lui <color=gold>%d<color>", 
					GetSkillName(tbMagic1[1]), 
					tbMagic1[2],
					tbMagic1[3]*tbMagic1[4]);
			end
		},
		{"state_slowall_attack", {"Xác suất làm chậm của <color=orange>%s<color>: <color=gold>%s%%<color>, duy trì<color=gold>%s giây<color>", {"getskillname", 1}, {"add1", 2}, { "frame2sec", 3}}},
		{"state_palsy_attack", {"Xác suất gây tê liệt của <color=orange>%s<color>: <color=gold>%s%%<color>, duy trì <color=gold>%s giây<color>", {"getskillname", 1}, {"add1", 2}, { "frame2sec", 3}}},
		{"state_fixed_attack", {"<color=orange>%s<color>-Định thân: <color=gold>%s%%<color>, duy trì <color=gold>%s giây<color>", {"getskillname", 1}, {"add1", 2},{"frame2sec", 3}}},	
		{"state_zhican_attack", {"Tỷ lệ chí tàn của <color=orange>%s<color>: <color=gold>%s%%<color>, duy trì <color=gold>%s giây<color>", {"getskillname", 1}, {"add1", 2},{"frame2sec", 3}}},	
	},
	[3] =--状态属性
	{
		{"allspecialstateresistrate", {"Khiến <color=orange>%s<color> tăng thêm tỷ lệ chịu trạng thái bất lợi: <color=gold>%s<color>", {"getskillname", 1}, {"add2", 2}}},
		{"allspecialstateresisttime", {"Khiến <color=orange>%s<color> tăng thêm thời gian chịu trạng thái bất lợi: <color=gold>%s<color>", {"getskillname", 1}, {"add2", 2}}},
		{"damage_inc_p", {"Khiến <color=orange>%s<color> tăng thêm sát thương gây ra: <color=gold>%s%%<color>", {"getskillname", 1}, {"add5", 2}}},
		{"skilldamageptrim", {"<color=orange>%s<color> kèm theo tấn công cơ bản: <color=gold>%s%%<color>", {"getskillname", 1}, {"add1", 2}}},
		{"fastwalkrun_p", {"Khiến <color=orange>%s<color> tăng thêm tốc độ di chuyển: <color=gold>%s%%<color>", {"getskillname", 1}, {"add1", 2}}},
		{"lifereplenish_p", {"Khiến <color=orange>%s<color> tăng thêm xác suất hồi phục sinh lực: <color=gold>%s%%<color>", {"getskillname", 1}, {"add1", 2}}},
		{"redeivedamage_dec_p2", {"<color=orange>%s<color> khiến mục tiêu chịu sát thương Ngũ Hành: <color=gold>%s%%<color>", {"getskillname", 1}, {"add6", 2}}},
		{"allseriesstateresisttime", {"<color=orange>%s<color>-kháng thời gian ngũ hành: <color=gold>%s<color>", {"getskillname", 1}, {"add1", 2}}},
		{"state_hurt_resisttime", {"<color=orange>%s<color>-kháng thời gian thọ thương: <color=gold>%s<color>", {"getskillname", 1}, {"add1", 2}}},
		{"state_weak_resisttime", {"<color=orange>%s<color>-kháng thời gian suy yếu: <color=gold>%s<color>", {"getskillname", 1}, {"add1", 2}}},
		{"state_burn_resisttime", {"<color=orange>%s<color>-kháng thời gian bỏng: <color=gold>%s<color>", {"getskillname", 1}, {"add1", 2}}},
		{"state_stun_resisttime", {"<color=orange>%s<color>-kháng thời gian choáng: <color=gold>%s<color>", {"getskillname", 1}, {"add1", 2}}},
		{"state_slowall_resisttime", {"<color=orange>%s<color>-kháng thời gian làm chậm: <color=gold>%s<color>", {"getskillname", 1}, {"add1", 2}}},
		{"damage_all_resist", {"Kháng tất cả của <color=orange>%s<color>: <color=gold>%s<color>", {"getskillname", 1}, {"add1", 2}}},
		{"fastmanareplenish_v", {"<color=orange>%s<color> mỗi nửa giây hồi phục nội lực: <color=gold>%s<color>", {"getskillname", 1}, {"enchanttypev", 2}}},
		{"fastlifereplenish_v", {"<color=orange>%s<color> mỗi nửa giây hồi phục sinh lực: <color=gold>%s<color>", {"getskillname", 1}, {"enchanttypev", 2}}},
		{"replenishlifebymaxhp_p", {"<color=orange>%s<color> mỗi nửa giây hồi phục sinh lực: <color=gold>%s<color>", {"getskillname", 1}, {"enchanttypev", 2}}},
		{"lifemax_p", {"Sinh lực tối đa của <color=orange>%s<color>: <color=gold>%s%%<color>", {"getskillname", 1}, {"add1", 2}}},
		{"manamax_p", {"Nội lực tối đa của <color=orange>%s<color>: <color=gold>%s%%<color>", {"getskillname", 1}, {"add1", 2}}},
		{"ignoreskill", {"Xác suất né tránh hoàn toàn của <color=orange>%s<color>: <color=gold>%s%%<color>", {"getskillname", 1}, {"add1", 2}}},
		{"autoskill", 
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				tbMagic1 = ChangeMagicTableToValue(tbMagic1);
				local tbAutoInfo	= KFightSkill.GetAutoInfo(tbMagic1[2], tbMagic1[3]);
				tbSkillInfo = KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
				local szClassName	= (tbSkillInfo and tbSkillInfo.szClassName) or "default";
				local szMsg = FightSkill.tbClass[szClassName]:GetAutoDesc(tbAutoInfo, tbSkillInfo);
				return string.format("%s tăng thêm hiệu quả tự thi triển:\n%s", GetSkillName(tbMagic1[1]), szMsg);
			end,
		},
		{"autoskill2", 
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				tbMagic1 = ChangeMagicTableToValue(tbMagic1);
				local tbAutoInfo	= KFightSkill.GetAutoInfo(tbMagic1[2], tbMagic1[3]);
				tbSkillInfo = KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
				local szClassName	= (tbSkillInfo and tbSkillInfo.szClassName) or "default";
				local szMsg = FightSkill.tbClass[szClassName]:GetAutoDesc2(tbAutoInfo, tbSkillInfo);
				return string.format("%s tăng thêm hiệu quả tự thi triển:\n%s", GetSkillName(tbMagic1[1]), szMsg);
			end,
		},
	},
	[4] = --技能设置2
	{
		{"superposemagic", {"Số lần <color=orange>%s<color> có thể cộng dồn: <color=gold>%s lần<color>", {"getskillname", 1}, {"add1", 2}}},
		{"skill_statetime", {"Thời gian duy trì <color=orange>%s<color>: <color=gold>Tăng %s giây<color>", {"getskillname", 1}, {"frame2sec", 2}}},
	}
}
FightSkill.MAGIC_DESCS =
{	--数字索引必须连续...
	 --技能设置
	[1] =
	{
		--{"missile_range", {"技能碰撞范围<color=orange>%s/%s/%s<color>", 1, 2,3}},
		--{"missile_range", {"技能碰撞范围：<color=gold>%s格<color>\n技能范围：<color=gold>%s格<color>\n"}},
		{ "skill_cost_buff1layers_v", 
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				local szMsg = (tbMagic1[3] ==0) and "Tiêu hao " or "Trừ ";
				szMsg = string.format("<color=blue>Trạng thái yêu cầu:<color> <color=gold>%s%s tầng <color> <color=green>[%s]<color>", szMsg, tbMagic1[2],GetSkillName(tbMagic1[1]));
				return szMsg;
			end
		},
		{ "skill_cost_buff2layers_v", 
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				local szMsg = (tbMagic1[3] ==0) and "Tiêu hao " or "Trừ ";
				szMsg = string.format("<color=blue>Trạng thái yêu cầu:<color> <color=gold>%s%s tầng <color> <color=green>[%s]<color>", szMsg, tbMagic1[2],GetSkillName(tbMagic1[1]));
				return szMsg;
			end
		},
		{ "skill_cost_buff3layers_v", 
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				local szMsg = (tbMagic1[3] ==0) and "Tiêu hao " or "Trừ ";
				szMsg = string.format("<color=blue>Trạng thái yêu cầu:<color> <color=gold>%s%s tầng <color> <color=green>[%s]<color>", szMsg, tbMagic1[2],GetSkillName(tbMagic1[1]));
				return szMsg;
			end
		},
		--保持隐身
		{ "keephide",
			 function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
			 	if (tbMagic1[1] == 1) then
					return string.format("Kỹ năng này không phá vỡ trạng thái ẩn thân");
				end
			end
		},
		--攻击力基础&五行相克属性
		{ "seriesdamage_r",
			function(tbMagic, tbSkillInfo, tbMagic2, bEx2)
				local szMsg = "";
				local szSeries = "";
				--[[if (tbMagic[1] == 0) then
					return "";
				end
				szMsg = string.format("五行相克：<color=gold>%s<color>", tbMagic[1]);
				if(tbSkillInfo.nSeries ~= 0) then
					-- or 后面的部分用于出错保护
					szSeries	= string.format("<color=gold>(<color><color=%s>%s<color><color=gold>)<color>", 
							tbSeriesColor[tbSkillInfo.nSeries] or "",
							Env.SERIES_NAME[tbSkillInfo.nSeries] or tostring(tbSkillInfo.nSeries));
				end]]
				if(tbSkillInfo.nSeries ~= 0) then
					szMsg = string.format("Kỹ năng Ngũ Hành: ");
					-- or 后面的部分用于出错保护
					szSeries	= string.format("<color=%s>%s<color>", 
							tbSeriesColor[tbSkillInfo.nSeries] or "",
							Env.SERIES_NAME[tbSkillInfo.nSeries] or tostring(tbSkillInfo.nSeries));
					szMsg = szMsg..szSeries;
				end
				return szMsg;
			end
		},
		{ "seriesenhance_r", { "Tấn công người chơi khắc hệ, trị tương khắc của kỹ năng: <color=gold>%s<color>" , { "add1", 1 } } },
		
	},
	--立即生效属性
	[2] = 
	{
		--命中类属性
		{ "attackrating_v", { "Điểm đánh trúng: <color=gold>%s điểm<color>", { "add1", 1 } } },
		{ "attackrating_p", { "Điểm đánh trúng: <color=gold>%s%%<color>", { "add1", 1 } } },
		--忽略闪避类属性
		{ "ignoredefense_p", { "Bỏ qua né tránh đối thủ: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "ignoredefense_v", { "Bỏ qua né tránh đối thủ: <color=gold>%s<color>", { "add1", 1 } } },
		--召唤稻草人转伤害
		{ "magic_calldummy",
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				return string.format("Tỷ lệ người chơi bị thương: <color=gold>%s%%<color><enter>Tỷ lệ quái bị thương: <color=gold>%s%%<color>",
					tbMagic1[2]/10 * 4,
					tbMagic1[2]/10);
			end
		},
		--吸血吸内,作为状态属性居然也可生效...
		{ "steallife_p",
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				local szMsg = (tbMagic1[2] < 100) and (Add4(tbMagic1[2], tbMagic2 and tbMagic2[2], bEx2).."% gây cho ") or "";
				szMsg = szMsg.."Gây sát thương"..((tbMagic1[1] >= 0) and " hồi " or " tiêu hao ").."sinh lực: <color=gold>";
				szMsg = szMsg..((tbMagic1[1] >= 0) and Add1( tbMagic1[1],  tbMagic2 and tbMagic2[1], bEx2) or Add1(-tbMagic1[1],  tbMagic2 and -tbMagic2[1], bEx2)).."%<color>";
				return szMsg;
			end
		},
		{ "stealmana_p",
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				local szMsg = (tbMagic1[2] < 100) and (Add4(tbMagic1[2], tbMagic2 and tbMagic2[2], bEx2).."% gây cho ") or "";
				szMsg = szMsg.."Gây sát thương"..((tbMagic1[1] >= 0) and " hồi " or " tiêu hao ").."nội lực: <color=gold>";
				szMsg = szMsg..((tbMagic1[1] >= 0) and Add1( tbMagic1[1],  tbMagic2 and tbMagic2[1], bEx2) or Add1(-tbMagic1[1],  tbMagic2 and -tbMagic2[1], bEx2)).."%<color>";
				return szMsg;
			end
		},
		{ "stealstamina_p",
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				local szMsg = (tbMagic1[2] < 100) and (Add4(tbMagic1[2], tbMagic2 and tbMagic2[2], bEx2).."% gây cho ") or "";
				szMsg = szMsg.."Gây sát thương"..((tbMagic1[1] >= 0) and " hồi " or " tiêu hao ").."thể lực: <color=gold>";
				szMsg = szMsg..((tbMagic1[1] >= 0) and Add1( tbMagic1[1],  tbMagic2 and tbMagic2[1], bEx2) or Add1(-tbMagic1[1],  tbMagic2 and -tbMagic2[1], bEx2)).."%<color>";
				return szMsg;
			end
		},
		
		--五行伤害百分比类属性
		{ "physicsenhance_p",
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				if (tbMagic1[1] == 0) then
					return "";
				end
				return string.format("Vật công: <color=gold>%s%%<color>", Add1(tbMagic1[1], tbMagic2 and tbMagic2[1], bEx2));
			end
		},
		--五行伤害点数类属性,除普攻外不区分内外功
		{ "physicsdamage_v", { "Vật công: <color=gold>+%s - %s điểm<color>", 1, 3 } },--已经修改为内外功系通用
		{ "physicsenhance_v", { "Vật công: <color=gold>+%s - %s điểm<color>", 1, 3 } },--由于不可以和physicsenhance_p共存,不再使用
		--{ "poisondamage_v", { "毒攻攻击：<color=gold>增加%s点/半秒<color>，持续<color=gold>%s秒<color>", 1 ,{ "frame2sec", 2}} },
		{ "poisondamage_v", { "Độc công: <color=gold>%s điểm<color> x <color=gold>%s lần<color>", {"add1", 1} ,{ "frame2times", 2}} },
		{ "colddamage_v", { "Băng công: <color=gold>+%s - %s điểm<color>", 1, 3 } },
		{ "firedamage_v", { "Hỏa công: <color=gold>+%s - %s điểm<color>", 1, 3 } },
		{ "lightingdamage_v", { "Lôi công: <color=gold>+%s - %s điểm<color>", 1, 3 } },
		{ "magicdamage_v", { "Tấn công ngũ hành: <color=gold>+%s - %s điểm<color>", 1, 3 } },
		--发挥基础攻击力
		{ "appenddamage_p",
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				local szMsg = "";
				local nAppend = tbSkillInfo.nAppenDamageP or tbMagic1[1];
				if  tbSkillInfo.IsOpenFloatDamage == 1 then
					szMsg = "";
				elseif (nAppend == 0) then
					szMsg = "<color=gray>Không bị ảnh hưởng bởi đánh thường<color>";
				else
					szMsg = string.format("Phát huy lực tấn công cơ bản: <color=gold>%s%%<color>", nAppend);
					if tbSkillInfo.bIsPhysical == 1 then
						szMsg = szMsg.."Ngoại công";
					elseif tbSkillInfo.bIsPhysical == 0 then
						szMsg = szMsg.."Nội công";
					end
				end
				return szMsg;
			end
		},
		{ "floatdamage_p",
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				local szMsg = "";
				local nAppendMin, nAppendMax = tbSkillInfo.nFloatDamageMinP, tbSkillInfo.nFloatDamageMaxP;
				if tbSkillInfo.IsOpenFloatDamage == 0 then
					szMsg = "";
				elseif (nAppendMin == 0) and (nAppendMax == 0) then
					szMsg = "<color=gray>Không bị ảnh hưởng bởi đánh thường<color>";
				else
					if nAppendMin ~= nAppendMax then
						szMsg = string.format("Tấn công cơ bản: <color=gold>%s%% đến %s%%<color>", nAppendMin/10, nAppendMax/10);
					else
						szMsg = string.format("Phát huy lực tấn công cơ bản: <color=gold>%s%%<color>", nAppendMin/10);
					end
					if tbSkillInfo.bIsPhysical == 1 then
						szMsg = szMsg.."Ngoại công";
					elseif tbSkillInfo.bIsPhysical == 0 then
						szMsg = szMsg.."Nội công";
					end
				end
				return szMsg;
			end
		},
		--冲刺后加攻击力
		{ "runattack_damageadded",  { "Tấn công sau mỗi lần chạm mục tiêu: <color=gold>%s%%<color>", { "add1", 1 } } },
		--百分比掉血
		{ "reducepercentonmaxhp_p",
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				local szMsg = "";
				if tbMagic1[1] > 0 then
					szMsg = szMsg.."Khấu trừ sinh lực tối đa "..tbMagic1[1].."%";
					szMsg = szMsg..(tbMagic1[2]+tbMagic1[3] > 0 and "\n" or "");
				end
				if  tbMagic1[2] > 0 then 
					szMsg = szMsg.."Khấu trừ nội lực tối đa "..tbMagic1[2].."%";
					szMsg = szMsg..(tbMagic1[3] > 0 and "\n" or "");
				end
				if  tbMagic1[3] > 0 then 
					szMsg = szMsg.."Khấu trừ thể lực tối đa "..tbMagic1[3].."%";
				end
				return string.format("<color=red>%s<color>", szMsg);
			end
		},
		{ "reducepercentoncurhp_p",
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				local szMsg = "";
				if tbMagic1[1] > 0 then
					szMsg = szMsg.."Khấu trừ sinh lực hiện tại "..tbMagic1[1].."%";
					szMsg = szMsg..(tbMagic1[2]+tbMagic1[3] > 0 and "\n" or "");
				end
				if  tbMagic1[2] > 0 then 
					szMsg = szMsg.."Khấu trừ nội lực hiện tại "..tbMagic1[2].."%";
					szMsg = szMsg..(tbMagic1[3] > 0 and "\n" or "");
				end
				if  tbMagic1[3] > 0 then 
					szMsg = szMsg.."Khấu trừ thể lực hiện tại "..tbMagic1[3].."%";
				end
				return string.format("<color=red>%s<color>", szMsg);
			end
		},
		{ "wastemanap",  { "Hút nội lực mục tiêu: <color=gold>%s%%<color>", 1 } },
		
		--造成五行状态
		{ "state_hurt_attack", { "Xác suất làm thọ thương: <color=gold>%s%%<color>, duy trì <color=gold>%s giây<color>",1,{ "frame2sec", 2} } },
		{ "state_weak_attack", { "Xác suất làm suy yếu: <color=gold>%s%%<color>, duy trì <color=gold>%s giây<color>", 1,{ "frame2sec", 2} } },
		--{ "state_slowall_attack", { "造成迟缓的几率：<color=gold>%s%%<color>，持续<color=gold>%s秒<color>", 1,{ "frame2sec", 2} } },
		{ "state_slowall_attack",
			 function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
			 	local nRate = tbMagic1[1];
			 	local szInfo = string.format("Xác suất làm chậm: <color=gold>%s%%<color>, duy trì <color=gold>%s giây<color>",
			 		nRate, Frame2Sec(tbMagic1[2]));

			 	return szInfo;
			end
		},
		{ "state_burn_attack", { "Xác suất gây bỏng: <color=gold>%s%%<color>, duy trì <color=gold>%s giây<color>", 1,{ "frame2sec", 2} } },
		{ "state_stun_attack", { "Xác suất gây choáng: <color=gold>%s%%<color>, duy trì <color=gold>%s giây<color>", 1,{ "frame2sec", 2} } },
		--造成负面状态
		{ "state_fixed_attack", { "Xác suất gây bất động: <color=gold>%s%%<color>, duy trì <color=gold>%s giây<color>", 1,{ "frame2sec", 2}  } },
		{ "state_palsy_attack", { "Xác suất gây tê liệt: <color=gold>%s%%<color>, duy trì <color=gold>%s giây<color>", 1,{ "frame2sec", 2}  } },
		{ "state_slowrun_attack", { "Xác suất gây giảm tốc độ chạy: <color=gold>%s%%<color>, duy trì <color=gold>%s giây<color>", 1,{ "frame2sec", 2}  } },
		{ "state_freeze_attack", { "Xác suất gây đóng băng: <color=gold>%s%%<color>, duy trì <color=gold>%s giây<color>", 1,{ "frame2sec", 2}  } },
		{ "state_confuse_attack",  { "Xác suất gây hỗn loạn: <color=gold>%s%%<color>, duy trì <color=gold>%s giây<color>", 1,{ "frame2sec", 2}  } },
		--击退属性,参数2是击退时间,参数3是击退速度,参数3上限为32
		{ "state_knock_attack",
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				return string.format("Xác suất gây tấn công đẩy lùi: <color=gold>%s%%<color>, cự ly đánh lui <color=gold>%s<color>",
					tbMagic1[1],
					tbMagic1[2] * tbMagic1[3]);
			end
		},
		--拉回属性,参数2是时间,参数3是速度
		--如果是一般的拉回(拉回到角色位置),速度=距离/时间,最大32,如果技能距离较远,有可能时间*32<距离,导致拉回停止
		--如果是missile_drage,速度就是实际移动速度,最大32
		{ "state_drag_attack",
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				return string.format("Tỷ lệ bị giật lại: <color=gold>%s%%<color>, khoảng cách lớn nhất <color=gold>%s<color>",
					tbMagic1[1],
					tbMagic1[2] * tbMagic1[3]);
			end
		},
		{ "state_silence_attack",  { "Xác suất gây bất lực: <color=gold>%s%%<color>, duy trì <color=gold>%s giây<color>", 1,{ "frame2sec", 2}  } },
		{ "state_zhican_attack",  { "Tỷ lệ tạo thành chí tàn: <color=gold>%s%%<color>, duy trì <color=gold>%s giây<color>", 1,{ "frame2sec", 2}  } },
		{ "state_float_attack",  { "Tỷ lệ tạo thành phù không: <color=gold>%s%%<color>, duy trì <color=gold>%s giây<color>", 1,{ "frame2sec", 2}  } },
		--根据距离加成攻击效果
		{ "addmagicbydist",
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				local tbState = {
					[0]	= "Thọ thương",
					[1] = "Suy yếu",
					[2] = "Làm chậm",
					[3] = "Bỏng",
					[4] = "Choáng",
					[5] = "Bất động ",
					[6] = "Tê liệt",
					[7] = "Giảm tốc",
					[8] = "Đóng băng",
					[9] = "Hỗn loạn",
					[10] = "Đánh lui",
					[11] = "Lôi kéo",
					[12] = "Bất lực",
					[13] = "Chí tàn",
					[14] = "Phù không",
					};
				return string.format("<color=gold>%s<color>Thời gian: <color=gold>(Khoảng cách 2 bên /%s)%%<color>, tối đa không vượt quá <color=gold>%s%%<color>",
					tbState[tbMagic1[1]], tbMagic1[2] / 100, math.floor(tbMagic1[3] / tbMagic1[2] * 100));
			end
		},
		--内力护盾
		{ "removeshield",  { "Hủy hộ thuẫn nội lực"} },
		{ "clearhide",  { "Hủy ẩn thân"} },
		{ "staticmagicshieldcur_p",  { "Tiêu hao 85%% nội lực hiện tại chuyển hóa thành hộ thuẫn tương đương với <color=gold>%s%%<color> nội lực tiêu hao để kháng sát thương, thời gian duy trì: <color=gold>%s giây<color>", 1, { "frame2sec", 2}  } },
		{ "staticmagicshieldmax_p",  { "Tạo thành hộ thuẫn <color=gold>nội lực tối đa x%s%%<color> kháng sát thương, thời gian duy trì: <color=gold>%s giây<color>", 1, { "frame2sec", 2}  } },
		
		--立刻影响其他技能
		--改变已有的buff叠加层数,到0层会删除
		{ "change_bufflayers_v",  { "<color=gold>%s tầng<color> <color=green>[%s]<color>", {"add1", 2}, {"getskillname", 1}}},
		{ "change_bufflayers_p",
			 function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
			 	local szMsg = ""
				if tbMagic1[2] == 0 then
					return "";
				end
				szMsg = (tbMagic1[2]>0) and "+" or "-";
				szMsg = "<color=gold>"..szMsg.."<color=green>["..GetSkillName(tbMagic1[1]).."]<color> số tầng xếp chồng kỹ năng hiện tại-<color=gold>"..tbMagic1[2].."%<color>";
				return szMsg;
			end
		},
		--回复技能使用次数
		{ "recover_usepoint", 
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				return string.format(
					"<color=orange>%s<color>可用次数回复：<color=gold>%s<color>",
					GetSkillName(tbMagic1[1]),
					tbMagic1[2]/100
				);
			end
		},
		{ "reducenextcasttime_p",  { "Khiến thời gian chờ <color=gold>%s<color>: <color=gold>%s%%<color>", { "getskillname", 1 }, { "add2", 2 } } },
		{ "reducenextcasttime_p2",  { "Khiến thời gian chờ <color=gold>%s<color>: <color=gold>%s%%<color>", { "getskillname", 1 }, { "add2", 2 } } },
		{ "reducenextcasttime_p3",  { "Khiến thời gian chờ <color=gold>%s<color>: <color=gold>%s%%<color>", { "getskillname", 1 }, { "add2", 2 } } },
		{ "reducenextcasttime_v",  { "Khiến thời gian chờ <color=gold>%s<color>: <color=gold>giảm %s giây<color>", { "getskillname", 1 }, { "frame2sec", 2 } } },
		{ "reducenextcasttime_v2",  { "Khiến thời gian chờ <color=gold>%s<color>: <color=gold>giảm %s giây<color>", { "getskillname", 1 }, { "frame2sec", 2 } } },
		{ "reducenextcasttime_v3",  { "Khiến thời gian chờ <color=gold>%s<color>: <color=gold>giảm %s giây<color>", { "getskillname", 1 }, { "frame2sec", 2 } } },
		--偷技能
		{"stealstate", {"Ngẫu nhiên đánh cắp 1 trạng thái hỗ trợ <color=gold>cấp %s cao nhất<color> của kẻ địch không phải quái vật\nTiếp tục thi triển trạng thái đánh cắp cho mục tiêu là bản thân hoặc đồng đội.", 3}},
		{"stealskillstate", {"Đã đánh cắp trạng thái thành công, tiếp tục thi triển trạng thái đánh cắp"}},
		
		--即死
		{ "suddendeath",  { "Mục tiêu bị trạng thái này sau <color=gold>%s giây<color> sẽ có tỷ lệ <color=gold>%s%%<color> bị trọng thương tức thì", { "frame2sec", 2}, 1 } },
		--立刻回复生命内力,但是不会考虑当前血量上限等因素..
		{ "immediatereplbymaxstate_p",
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				local szMsg = "";
				if tbMagic1[1] > 0 then
					szMsg = szMsg.."Lập tức hồi phục sinh lực tối đa<color=gold>"..tbMagic1[1].."%<color>";
					szMsg = szMsg..(tbMagic1[2]+tbMagic1[3] > 0 and "\n" or "");
				end
				if  tbMagic1[2] > 0 then 
					szMsg = szMsg.."Lập tức hồi phục nội lực tối đa<color=gold>"..tbMagic1[2].."%<color>";
					szMsg = szMsg..(tbMagic1[3] > 0 and "\n" or "");
				end
				if  tbMagic1[3] > 0 then 
					szMsg = szMsg.."Lập tức hồi phục thể lực tối đa<color=gold>"..tbMagic1[3].."%<color>";
				end
				return szMsg;
			end
		},
		--立刻回复生命内力,但是不会考虑当前血量上限等因素..
		{ "life_v",  { "Sinh lực hiện tại: <color=gold>%s điểm<color>", { "add1", 1 } } },
		{ "mana_v",  { "Nội lực hiện tại: <color=gold>%s điểm<color>", { "add1", 1 } } },
		{ "stamina_v",  { "Hồi phục thể lực: <color=gold>%s điểm<color>", { "add1", 1 } } },
		--复活
		{ "revive",
			function(tbMagic, tbSkillInfo, tbMagic2, bEx2)
				return string.format(
					"Xác suất <color=gold>%s%%<color> hồi sinh và hồi phục sinh lực <color=gold>%s%%<color>, nội lực <color=gold>%s%%<color>, thể lực <color=gold>%s%%<color>",
					KFightSkill.GetMissileRate(tbSkillInfo.nId, tbSkillInfo.nLevel),
					Add4(tbMagic[1], tbMagic2 and tbMagic2[1], bEx2),
					Add4(tbMagic[2], tbMagic2 and tbMagic2[2], bEx2),
					Add4(tbMagic[3], tbMagic2 and tbMagic2[3], bEx2)
				);
			end
		},
	},
	[3] = --立即生效后本身再以状态属性作用
	{
		--清cd..
		{ "clear_cd",  { "清除所有武功的施展间隔，且施展武功无间隔"} },
		
		{ "ignorecurse",  { "Xác suất <color=gold>%s%%<color> giải <color=gold>%s bùa<color> và miễn nhiễm bùa", 1, 3 } },
		{ "ignoreinitiative",
			function(tbMagic, tbSkillInfo, tbMagic2, bEx2)
				return string.format(
					--"以<color=gold>%s%%的<color>几率随机清除<color=gold>%s个主动辅助技能<color>并使其不能再获得已清除的技能",
					"Xóa <color=gold>%s<color> trạng thái hỗ trợ chủ động đồng thời khiến đối tượng không thể nhận lại kỹ năng đã bị xóa",
					--KFightSkill.GetMissileRate(tbSkillInfo.nId, tbSkillInfo.nLevel),
					Add4(tbMagic[1], tbMagic2 and tbMagic2[1], bEx2)
				);
			end
		},
		--技能的非基础攻击力部分加成
		{ "skill_appendskill",  { "%s", { "castskill", 1, 2} } },
		{ "skill_appendskill2",  { "%s", { "castskill", 1, 2} } },
		{ "skill_appendskill3",  { "%s", { "castskill", 1, 2} } },
		{ "skill_appendskill4",  { "%s", { "castskill", 1, 2} } },
		{ "skill_appendskill5",  { "%s", { "castskill", 1, 2} } },
		{ "skill_appendskill6",  { "%s", { "castskill", 1, 2} } },
	},
	[4] = --状态属性
	{
		--持续伤害
		--参数1是发挥基础攻击,参数2是调用技能id,参数3是作用次数
		--{ "timingdamage",  { "每半秒持续伤害：<color=gold>%s%%<color>", 1 } },
		{ "timingdamage",
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				local szMsg = "";
				szMsg = string.format("Sát thương duy trì mỗi nửa giây: <color=gold>%s%%<color>", tbMagic1[1]);
				if tbSkillInfo.bIsPhysical == 1 then
					szMsg = szMsg.."Ngoại công";
				elseif tbSkillInfo.bIsPhysical == 0 then
					szMsg = szMsg.."Nội công";
				end
				return szMsg;
			end
		},
		--加潜能
		{ "strength_v",  { "Sức mạnh: <color=gold>%s điểm<color>", { "add1", 1 } } },
		{ "dexterity_v",  { "Thân pháp: <color=gold>%s điểm<color>", { "add1", 1 } } },
		{ "vitality_v",  { "Ngoại công: <color=gold>%s điểm<color>", { "add1", 1 } } },
		{ "energy_v",  { "Nội công: <color=gold>%s điểm<color>", { "add1", 1 } } },
		--攻击力基础&五行相克属性
		{ "seriesenhance",
			function(tbMagic, tbSkillInfo, tbMagic2, bEx2)
				if (tbMagic[1] == 0) then
					return "";
				end
				return string.format("Cường hóa ngũ hành tương khắc: <color=gold>%s<color> điểm", Add1(tbMagic[1], tbMagic2 and tbMagic2[1], bEx2));
			end
		},
		{ "seriesabate",
			function(tbMagic, tbSkillInfo, tbMagic2, bEx2)
				if (tbMagic[1] == 0) then
					return "";
				end
				return string.format("Nhược hóa ngũ hành tương khắc: <color=gold>%s<color> điểm", Add1(tbMagic[1], tbMagic2 and tbMagic2[1], bEx2));
			end
		},
		--命中类属性
		{ "attackratingenhance_v", { "Điểm đánh trúng: <color=gold>%s điểm<color>", { "add1", 1 } } },
		{ "attackratingenhance_p", { "Điểm đánh trúng: <color=gold>%s%%<color>", { "add1", 1 } } },
		--忽略闪避类属性
		{ "ignoredefenseenhance_p", { "Bỏ qua né tránh đối thủ: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "ignoredefenseenhance_v", { "Bỏ qua né tránh đối thủ: <color=gold>%s<color>", { "add1", 1 } } },
		--出招动作属性
		{ "attackspeed_v",  { "Tốc đánh ngoại công: <color=gold>%s<color>", { "add1", 1 } } },
		{ "castspeed_v",  { "Tốc đánh nội công: <color=gold>%s<color>", { "add1", 1 } } },
		
		--五行伤害百分比类属性
		{ "addphysicsdamage_p", { "Vật công ngoại: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "add_physicpoisondamage_p",
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				local szMsg = string.format("Độc công ngoại: <color=gold>%s%%<color>", Add1(tbMagic1[1], tbMagic2 and tbMagic2[1], bEx2));
				if (tbMagic1[2] > 0) then
					--szMsg = szMsg.."<color=gold>/半秒<color>，持续<color=gold>"..frame2sec(tbMagic1[2]).."秒<color>";
					szMsg = szMsg.."×<color=gold>"..Frame2Times(tbMagic1[2]).." lần<color>";
				end
				return szMsg;
			end
		},
		{ "add_physiccolddamage_p", { "Băng công ngoại: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "add_physicfiredamage_p", { "Hỏa công ngoại: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "add_physiclightdamage_p", { "Lôi công ngoại: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "addphysicsmagic_p", { "Vật công nội: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "add_magicpoisondamage_p",
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				local szMsg = string.format("Độc công nội: <color=gold>%s%%<color>", Add1(tbMagic1[1], tbMagic2 and tbMagic2[1], bEx2));
				if (tbMagic1[2] > 0) then
					--szMsg = szMsg.."<color=gold>/半秒<color>，持续<color=gold>"..frame2sec(tbMagic1[2]).."秒<color>";
					szMsg = szMsg.."×<color=gold>"..Frame2Times(tbMagic1[2]).." lần<color>";
				end
				return szMsg;
			end
		},
		{ "add_magiccolddamage_p", { "Băng công nội: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "add_magicfiredamage_p", { "Hỏa công nội: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "add_magiclightdamage_p", { "Lôi công nội: <color=gold>%s%%<color>", { "add1", 1 } } },
		--五行伤害点数属性
		{ "addphysicsdamage_v", { "Vật công ngoại: <color=gold>%s điểm<color>", { "add1", 1 } } },
		--{ "addpoisondamage_v", { "外功系毒攻攻击：<color=gold>%s点/半秒<color>，持续<color=gold>%s秒<color>", { "add1", 1 },{ "frame2sec", 2} } },
		{ "addpoisondamage_v", { "Độc công ngoại: <color=gold>%s điểm<color>, duy trì <color=gold>%s giây<color>", { "add1", 1 },{ "frame2times", 2} } },
		{ "addcolddamage_v", { "Băng công ngoại: <color=gold>%s điểm<color>", { "add1", 1 } } },
		{ "addfiredamage_v", { "Hỏa công ngoại: <color=gold>%s điểm<color>", { "add1", 1 } } },
		{ "addlightingdamage_v", { "Lôi công ngoại: <color=gold>%s điểm<color>", { "add1", 1 } } },
		{ "addphysicsmagic_v", { "Vật công nội: <color=gold>%s điểm<color>", { "add1", 1 } } },
		--{ "addpoisonmagic_v", { "内功系毒攻攻击：<color=gold>%s点/半秒<color>，持续<color=gold>%s秒<color>", { "add1", 1 },{ "frame2sec", 2} } },
		{ "addpoisonmagic_v", { "Độc công nội: <color=gold>%s điểm<color>, duy trì <color=gold>%s giây<color>", { "add1", 1 },{ "frame2times", 2} } },
		{ "addcoldmagic_v", { "Băng công nội: <color=gold>%s điểm<color>", { "add1", 1 } } },
		{ "addfiremagic_v", { "Hỏa công nội: <color=gold>%s điểm<color>", { "add1", 1 } } },
		{ "addlightingmagic_v", { "Lôi công nội: <color=gold>%s điểm<color>", { "add1", 1 } } },
		{ "poisontimeenhance_p",  { "Số lần độc công gây ra: <color=gold>%s%%<color>", { "add1", 1 } } },
		--武器攻击点数
		{ "weapondamagemin_v",  { "Tấn công ngoại tối thiểu: <color=gold>%s điểm<color>", { "add1", 1 } } },
		{ "weapondamagemax_v",  { "Tấn công ngoại tối đa: <color=gold>%s điểm<color>", { "add1", 1 } } },
		{ "weaponmagicmin_v",  { "Tấn công nội tối thiểu: <color=gold>%s điểm<color>", { "add1", 1 } } },
		{ "weaponmagicmax_v",  { "Tấn công nội tối đa: <color=gold>%s điểm<color>", { "add1", 1 } } },
		{ "weaponbasedamagetrim",  { "Tấn công cơ bản của vũ khí: <color=gold>%s điểm<color>", { "add1", 1 } } },
		--攻击五行转换
		{ "magic_turnphysicaldammage", { "Tấn công thường chuyển hóa thành tấn công ngũ hành: <color=gold>%s%%<color>", { "add1", 1 } } },
		--各种攻击力加成
		{ "skilldamageptrim",  { "Phát huy lực tấn công cơ bản: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "skillselfdamagetrim",  { "Phát huy lực tấn công kỹ năng: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "damage_inc_p", 			{ "Sát thương gây ra: <color=gold>%s%%<color>", { "add5", 1 } } },
		{ "attackenhancebycostmana_p",
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				return string.format("Tăng tổng lực tấn công <color=gold>(Phần trăm nội lực hiện tại * %s%%)<color>",
					tbMagic1[1]);
			end
		},
		{ "ignoreresist_p", {"Tỷ lệ bỏ qua kháng <color=gold>%s%%<color>: <color=gold>%s%%<color>", 1, { "add1", 2 }}},
		{ "npcdamageadded",
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				local szMsg = "Sát thương quái: <color=gold>"..Add1(tbMagic1[1], tbMagic2 and tbMagic2[1], bEx2).."%<color>";
			 	if (tbMagic1[1] < -300) then
					szMsg = "Sát thương quái giảm đến <color=gold>1<color>";
				end
				return szMsg;
			end
		},
		--会心几率和会心伤害
		{ "deadlystrikeenhance_r", { "Chí mạng: <color=gold>%s<color>", { "add1", 1 } } },
		{ "deadlystrikedamageenhance_p", { "Tấn công khi đánh chí mạng: <color=gold>%s%%<color>", { "add1", 1 } } },
		--反弹
		{ "meleedamagereturn_v",  { "Phản đòn cận chiến: <color=gold>%s điểm<color>", { "add1", 1 } } },
		{ "meleedamagereturn_p",  { "Phản đòn cận chiến: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "rangedamagereturn_v",  { "Phản đòn tầm xa: <color=gold>%s điểm<color>", { "add1", 1 } } },
		{ "rangedamagereturn_p",  { "Phản đòn tầm xa: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "poisondamagereturn_v",  { "Phản đòn khi bị sát thương độc: <color=gold>%s điểm<color>", { "add1", 1 } } },
		{ "poisondamagereturn_p",  { "Phản đòn khi bị sát thương độc: <color=gold>%s%%<color>", { "add1", 1 } } },
		--传染
		{ "poison2decmana_p",  { "Khiến mục tiêu bị độc sát với xác suất <color=gold>%s%%<color> tổn thất nội lực, duy trì <color=gold>#f2-giây<color>", 1 } },
		
		--吸血吸内
		{ "steallifeenhance_p",
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				local szMsg = (tbMagic1[2] < 100) and (Add4(tbMagic1[2], tbMagic2 and tbMagic2[2], bEx2).."% gây cho ") or "";
				szMsg = szMsg.."Gây sát thương "..((tbMagic1[1] >= 0) and "hồi" or "tiêu hao").." sinh lực: <color=gold>";
				szMsg = szMsg..((tbMagic1[1] >= 0) and Add1( tbMagic1[1],  tbMagic2 and tbMagic2[1], bEx2) or Add1(-tbMagic1[1],  tbMagic2 and -tbMagic2[1], bEx2)).."%<color>";
				return szMsg;
			end
		},
		{ "stealmanaenhance_p",
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				local szMsg = (tbMagic1[2] < 100) and (Add4(tbMagic1[2], tbMagic2 and tbMagic2[2], bEx2).."% gây cho ") or "";
				szMsg = szMsg.."Gây sát thương "..((tbMagic1[1] >= 0) and "hồi" or "tiêu hao").." nội lực: <color=gold>";
				szMsg = szMsg..((tbMagic1[1] >= 0) and Add1( tbMagic1[1],  tbMagic2 and tbMagic2[1], bEx2) or Add1(-tbMagic1[1],  tbMagic2 and -tbMagic2[1], bEx2)).."%<color>";
				return szMsg;
			end
		},
		{ "stealstaminaenhance_p",
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				local szMsg = (tbMagic1[2] < 100) and (Add4(tbMagic1[2], tbMagic2 and tbMagic2[2], bEx2).."% gây cho ") or "";
				szMsg = szMsg.."Gây sát thương "..((tbMagic1[1] >= 0) and "hồi" or "tiêu hao").." thể lực: <color=gold>";
				szMsg = szMsg..((tbMagic1[1] >= 0) and Add1( tbMagic1[1],  tbMagic2 and tbMagic2[1], bEx2) or Add1(-tbMagic1[1],  tbMagic2 and -tbMagic2[1], bEx2)).."%<color>";
				return szMsg;
			end
		},
		--生命内力体力
		{ "lifemax_v",  { "Sinh lực tối đa: <color=gold>%s điểm<color>", { "add1", 1 } } },
		{ "lifemax_p",
			 function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
			 	local nLifeMax = tbMagic1[1];
				return string.format("Sinh lực tối đa: <color=gold>Tăng %s%%<color>", nLifeMax);
			 end
		},
		{ "addmaxhpbymaxmp_p",  { "Sinh lực tối đa: <color=gold>Nội lực tối đa*%s%%<color>", { "add1", 1 } } },
		{ "lifemax_permillage",
			 function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
			 	local nLifeMax_p = math.floor(tbMagic1[1]*10)/100;
				return string.format("Sinh lực tối đa: <color=gold>Tăng %s%%<color>", nLifeMax_p);
			 end
		},
		{ "manamax_v",  { "Nội lực tối đa: <color=gold>%s điểm<color>", { "add1", 1 } } },
		{ "manamax_p",
			 function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
			 	local nManaMax = tbMagic1[1];
				return string.format("Nội lực tối đa: <color=gold>Tăng %s%%<color>", nManaMax);
			 end
		},
		{ "manamax_permillage",
			 function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
			 	local nManaMax_p = math.floor(tbMagic1[1]*10)/100;
				return string.format("Nội lực tối đa: <color=gold>Tăng %s%%<color>", nManaMax_p);
			 end
		},
		{ "staminamax_v",  { "Thể lực tối đa: <color=gold>%s điểm<color>", { "add1", 1 } } },
		{ "staminamax_p",  { "Thể lực tối đa: <color=gold>%s%%<color>", { "add1", 1 } } },
		--生命内力体力回复
		{ "lifereplenish_v",  { "Mỗi 5 giây hồi phục sinh lực: <color=gold>%s điểm<color>", { "add1", 1 } } },
		{ "fastlifereplenish_v",
			 function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
			 	local nLifeUp = 0;
			 	if (not tbSkillInfo) then
			 		nLifeUp = tbMagic1[1];
			 	else
			 		nLifeUp = tbMagic1[1];
			 	end
				return string.format("Mỗi nửa giây hồi phục sinh lực: <color=gold>%s điểm<color>", Add1(nLifeUp, tbMagic2 and tbMagic2[1], bEx2));
			 end
		},
		{ "replenishlifebymaxhp_p",
			 function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
			 	local nLifeUp = 0;
				local nLifeUpTrue = tbMagic1[3];
			 	if (not tbSkillInfo) then
			 		nLifeUp = tbMagic1[1];
			 	else
			 		nLifeUp = tbMagic1[1];
			 	end
				if nLifeUpTrue == 0 then
					nLifeUpTrue = math.floor(me.nCurLife * nLifeUp / 1000);
					return string.format("Sinh lực hồi phục mỗi nửa giây: <color=gold>%s%%*Sinh lực tối đa<color>", Add1(nLifeUp/10));
					--return string.format("每半秒生命回复：<color=gold>%s<color>",Add1(nLifeUpTrue));
				else
					nLifeUpTrue = math.floor(nLifeUpTrue * nLifeUp / 1000);
					return string.format("Sinh lực hồi phục mỗi nửa giây: <color=gold>%s<color>",Add1(nLifeUpTrue));
				end
			 end
		},
		{ "manareplenish_v",  { "Mỗi 5 giây hồi phục nội lực: <color=gold>%s điểm<color>", { "add1", 1 } } },
		{ "fastmanareplenish_v",  { "Mỗi nửa giây hồi phục nội lực: <color=gold>%s điểm<color>", { "add1", 1 } } },
		{ "staminareplenish_v",  { "Mỗi 5 giây hồi phục thể lực: <color=gold>%s điểm<color>", { "add1", 1 } } },
		{ "faststaminareplenish_v",  { "Mỗi nửa giây hồi phục thể lực: <color=gold>%s điểm<color>", { "add1", 1 } } },
		{ "lifepotion_v",  { "Mỗi nửa giây hồi phục sinh lực: <color=gold>%s điểm<color>, duy trì <color=gold>%s giây<color>", { "add1", 1 },{ "frame2sec", 2} } },
		{ "manapotion_v",  { "Mỗi nửa giây hồi phục nội lực: <color=gold>%s điểm<color>, duy trì <color=gold>%s giây<color>", { "add1", 1 },{ "frame2sec", 2} } },
		{ "lifegrow_v",  { "Mỗi nửa giây hồi phục sinh lực: <color=gold>%s điểm<color>, duy trì <color=gold>%s giây<color>", { "add1", 1 },{ "frame2sec", 2} } },
		{ "managrow_v",  { "Mỗi nửa giây hồi phục nội lực: <color=gold>%s điểm<color>, duy trì <color=gold>%s giây<color>", { "add1", 1 },{ "frame2sec", 2} } },
		{ "staminagrow_v", { "Thể lực hồi phục mỗi nửa giây: <color=gold>%s điểm<color>, duy trì <color=gold>%s giây<color>", { "add1", 1 },{ "frame2sec", 2} } },
		{ "damage2addmana_p",  { "Sát thương phải chịu chuyển thành hồi phục nội lực: <color=gold>%s%%<color>", { "add1", 1 } } },
		--闪避
		{ "adddefense_v", { "Né tránh: <color=gold>%s điểm<color>", { "add1", 1 } } },
		{ "adddefense_p", { "Né tránh: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "armordefense_v",  { "Né tránh: <color=gold>%s điểm<color>", { "add1", 1 } } },--马用的都是这个,没任何区别.....
		--五行抗性
		{ "damage_all_resist",  { "Kháng tất cả: <color=gold>%s<color>", { "add1", 1 } } },
		{ "damage_series_resist",
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				local tbResist = { "Kháng vật công", "Kháng hỏa công", "Kháng băng công", "Kháng lôi công", "Kháng độc công" };
				local szResist = tbResist[tbMagic1[3] + 1];
				if not szResist then
					return string.format("Kháng ngũ hành tương ứng: <color=gold>%s<color>", Add1(tbMagic1[1], tbMagic2 and tbMagic2[1], bEx2));
				end
				return string.format("%s: <color=gold>%s<color>", szResist, Add1(tbMagic1[1], tbMagic2 and tbMagic2[1], bEx2));
			end
		},
		{ "damage_physics_resist",  { "Kháng vật công: <color=gold>%s<color>", { "add1", 1 } } },
		{ "damage_poison_resist",  { "Kháng độc công: <color=gold>%s<color>", { "add1", 1 } } },
		{ "damage_cold_resist",  { "Kháng băng công: <color=gold>%s<color>", { "add1", 1 } } },
		{ "damage_fire_resist",  { "Kháng hỏa công: <color=gold>%s<color>", { "add1", 1 } } },
		{ "damage_light_resist",  { "Kháng lôi công: <color=gold>%s<color>", { "add1", 1 } } },
		{ "damage_return_receive_p",  { "Sát thương phản đòn phải chịu: <color=gold>%s%%<color>", { "add1", 1 } } },--修改了反弹伤害抗性的描述
		--回复效率
		{ "lifereplenish_p",  { "Hiệu suất hồi phục sinh lực: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "manareplenish_p",  { "Hiệu suất hồi phục nội lực: <color=gold>%s%%<color>", { "add1", 1 } } },
		--该属性只对按比例伤害有效（内力，体力无效），与redeivedamage_dec_p或redeivedamage_dec_p2一起使用，该状态没有tip描述
		{ "percentreducelife_percent", 	{ "Chịu sát thương giảm sinh lực theo tỉ lệ: <color=gold>%s%%<color>", { "add5", 1 } } },--正数为放大
		--额外的防御
		{ "redeivedamage_dec_p", 	{ "Sát thương phải chịu: <color=gold>%s%%<color>", { "add6", 1 } } },
		{ "redeivedamage_dec_p2", 	{ "Sát thương ngũ hành: <color=gold>%s%%<color>", { "add6", 1 } } },
		--令dmg为原伤害,ris_p=1.7*防御方抗性/(200+攻击方等级*10+防御方抗性),防御方抗性不计五行相克和忽抗
		--当自身defence_level属性值大于等于目标defence_level属性值时
		--伤害放大公式为dmg=dmg*(1-ris_p*DefenceLevelConstValue/100)/(1-ris_p)
		{ "defence_level",  { "Kháng động sát: <color=gold>%s<color>\n<color=gray>  Tấn công địch có kháng động sát nhỏ hơn hoặc bằng bản thân, nếu mở rộng sát thương càng hiệu quả hơn.<color>", { "add1", 1 }} },
		--无敌
		{ "prop_invincibility",  { "<color=gold>Không chịu ảnh hưởng kỹ năng sát thương<color>" } },
		--会心防御
		{ "cri_resist", { "Chí mạng nhận được: <color=gold>%s<color>",  { "add2", 1 }  } },
		{ "defencedeadlystrikedamagetrim",  { "Chịu sát thương chí mạng: <color=gold>%s%%<color>", { "add2", 1 } } },
		--各种护盾
		{ "manashield_p",  { "Khi nội lực lớn hơn 15%% dùng nội lực hút sát thương: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "dynamicmagicshieldbymaxhp_p",
			 function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				local szMsg = string.format("Hóa giải <color=gold>%d%%<color> sát thương, giá trị tối đa là <color=gold>%s%%*Sinh lực tối đa<color>",
				tbMagic1[2],
				tbMagic1[1]/10);
			 	return szMsg;
			end
		},
		{ "dynamicmagicshield_v",
			 function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				local szMsg = "Hóa giải sát thương: <color=gold>"..Add1(tbMagic1[1], tbMagic2 and tbMagic2[1], bEx2).." điểm<color>";
			 	if (tbMagic1[2] < 99)  then
					szMsg = szMsg..", không vượt quá sát thương ban đầu<color=gold>"..tbMagic1[2].."%<color>";
				end
				if (tbMagic1[1] >100000) then
					szMsg = "Hóa giải <color=gold>"..tbMagic1[2].."%<color> sát thương"
				end
				return szMsg;
			end
		},
		{ "posionweaken",
			 function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				local szMsg = "Hóa giải sát thương độc: <color=gold>"..Add1(tbMagic1[1], tbMagic2 and tbMagic2[1], bEx2).." điểm<color>";
			 	if (tbMagic1[2] < 99) then
					szMsg = szMsg..", không vượt quá sát thương ban đầu<color=gold>"..tbMagic1[2].."%<color>";
				end
				if (tbMagic1[1] >100000) then
					szMsg = "Hóa giải <color=gold>"..tbMagic1[2].."%<color> sát thương độc duy trì"
				end
				return szMsg;
			end
		},
		--闪避技能
		--参数1是闪避概率,参数2表示是否获得时清除,参数3表示关联buff类型
		{ "ignoreskill",
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				local nRateMin = tbMagic1[1];
				local nRateMax;
				if (tbMagic2 and tbMagic2[1]) then
					nRateMax = tbMagic2[1];
				end
				local tbIgnoreString = {
						[1] = string.format("Hủy <color=gold>%d<color> trạng thái vòng sáng\nKhông thể nhận trạng thái vòng sáng: <color=gold>%s%%<color>",tbMagic1[2],tbMagic1[1]),
						[2] = string.format("Tỷ lệ né toàn bộ sát thương nội công: <color=gold>%s%%<color>", Add1(nRateMin, nRateMax, bEx2)),
						[3] = string.format("Tỷ lệ né toàn bộ sát thương nội ngoại công: <color=gold>%s%%<color>", Add1(nRateMin, nRateMax, bEx2)),
						[4] = string.format("Tỷ lệ né toàn bộ sát thương ngoại công: <color=gold>%s%%<color>", Add1(nRateMin, nRateMax, bEx2)),
						[5] = string.format("Xác suất <color=gold>%s%%<color> nhận trạng thái tránh cạm bẫy 100%%", KFightSkill.GetMissileRate(tbSkillInfo.nId, tbSkillInfo.nLevel)),
						[6] = string.format("Xác xuất né tránh hoàn toàn tấn công tầm xa: <color=gold>%s%%<color>", Add1(nRateMin, nRateMax, bEx2)),
						[7] = string.format("Xác suất không thể nhận trạng thái hỗ trợ chủ động: <color=gold>%s%%<color>", Add1(nRateMin, nRateMax, bEx2)),
						[8] = string.format("Tỷ lệ né toàn bộ kỹ năng trạng thái: <color=gold>%s%%<color>", Add1(nRateMin, nRateMax, bEx2)),--闲置
						[9] = string.format("Tỷ lệ bỏ qua tất cả tấn công: <color=gold>%s%%<color>", Add1(nRateMin, nRateMax, bEx2)),
					};
				if tbIgnoreString[tbMagic1[3]] then
					if (tbMagic1[3] ==1) or (tbMagic1[1] ~= 0) then
						return tbIgnoreString[tbMagic1[3]];
					else
						return "";
					end
				else
					print("[ERROR]unknown ignoreskill style:", tbMagic1[3]);
					return "";
				end
			end
		},
		{ "magic_duck_skill",  { "Né tránh <color=gold>%s<color>", { "getskillname", 1} } },--一个角色身上最多只能有7个这种属性；
		{ "ignore_skillstyle_bydist",
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				return string.format(
					"Có <color=gold>(Cự ly hai bên/%s)%%<color> tỷ lệ né tránh hoàn toàn sát thương nội ngoại công",
					tbMagic1[1]/100)
			end
		},
		{ "ignoreattackontime",  { "Cách mỗi <color=gold>%s giây<color> bỏ qua nửa giây tấn công", { "frame2sec", 1 } } },
		{ "returnskill_p",  { "Xác suất phản đòn bùa chú: <color=gold>%s%%<color>", { "add1", 1 } } },
		--官印抵御
		{ "ignoreattack",
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				return GetIgnoreAttackDesc(tbSkillInfo);
			end
		},
		--挡子弹
		{ "destory_missile",  { "Tỷ lệ xuyên thấu kỹ năng ngăn người chơi bay: <color=gold>%s%%<color>", 1 }  },
		
		--锁状态,以buff形式存在的限制属性
		{ "locked_state",
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				local szMsg = "";
				if tbMagic1[1] == 1 then
					szMsg = szMsg.."Không thể di chuyển";
					szMsg = szMsg..(tbMagic1[2]+tbMagic1[3] > 0 and "\n" or "");
				end
				if  tbMagic1[2] == 1 then 
					szMsg = szMsg.."Không thể sử dụng kỹ năng";
					szMsg = szMsg..(tbMagic1[3] > 0 and "\n" or "");
				end
				if  tbMagic1[3] == 1 then 
					szMsg = szMsg.."Không thể sử dụng đạo cụ";
				end
				return string.format("<color=red>%s<color>", szMsg);
			end
		},
		
		--忽略对手五行几率抗性
		{ "state_hurt_resisttargetrate",  { "Xuyên kháng tỷ lệ thọ thương: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_weak_resisttargetrate",  { "Xuyên kháng tỷ lệ suy yếu: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_slowall_resisttargetrate", { "Xuyên kháng tỷ lệ làm chậm: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_burn_resisttargetrate",  { "Xuyên kháng tỷ lệ bỏng: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_stun_resisttargetrate",  { "Xuyên kháng tỷ lệ choáng: <color=gold>%s<color>", { "add1", 1 } } },
		--造成五行状态的几率
		{ "state_hurt_attackrate",  { "Tỷ lệ gây thọ thương: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_weak_attackrate",  { "Tỷ lệ gây suy yếu: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_slowall_attackrate", { "Tỷ lệ gây làm chậm: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_burn_attackrate",  { "Tỷ lệ gây bỏng: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_stun_attackrate",  { "Tỷ lệ gây choáng: <color=gold>%s<color>", { "add1", 1 } } },
		{ "allseriesstateattackrate",  { "Tỷ lệ trạng thái ngũ hành: <color=gold>%s<color>", { "add1", 1 } } },
		{ "seriesstate_added", 
			 function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				local tbMsg = {
						"Tỷ lệ gây thọ thương: +<color=gold>",
						"Tỷ lệ suy nhược: +<color=gold>",
						"Tỷ lệ làm chậm: +<color=gold>",
						"Tỷ lệ bỏng: +<color=gold>",
						"Tỷ lệ choáng: +<color=gold>",
						"Gây hiệu quả ngũ hành tương ứng: Tăng <color=gold>",
					};
				local nSeries = me.nSeries;
				if (nSeries >  6 or nSeries <=0) then
					nSeries = 6;
				end;
			 	local szMsg = tbMsg[nSeries]..tbMagic1[1].."<color>";
			 	return szMsg;
			end
		},
		--造成负面状态的几率
		{ "state_fixed_attackrate",  { "Tỷ lệ gây bất động: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_palsy_attackrate",  { "Tỷ lệ gây tê liệt: <color=gold>%s%<color>", { "add1", 1 } } },
		{ "state_slowrun_attackrate", { "Tỷ lệ gây giảm tốc độ chạy: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_freeze_attackrate",  { "Tỷ lệ gây đóng băng: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_confuse_attackrate", { "Tỷ lệ gây hỗn loạn: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_knock_attackrate",  { "Tỷ lệ gây tấn công đẩy lùi: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_drag_attackrate",  { "Tỷ lệ gây kéo lại: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_silence_attackrate",  { "Tỷ lệ gây bất lực: <color=gold>%s<color>", { "add1", 1 } } },
		{ "allspecialstateattackrate",  { "Tỷ lệ trạng thái bất lợi: <color=gold>%s<color>", { "add1", 1 } } },
		--忽略对手五行时间抗性
		{ "state_hurt_resisttargettime",  { "Xuyên kháng thời gian thọ thương: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_weak_resisttargettime",  { "Xuyên kháng thời gian suy yếu: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_slowall_resisttargettime", { "Xuyên kháng thời gian làm chậm: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_burn_resisttargettime",  { "Xuyên kháng thời gian bỏng: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_stun_resisttargettime",  { "Xuyên kháng thời gian choáng: <color=gold>%s<color>", { "add1", 1 } } },
		--造成五行状态的时间
		{ "state_hurt_attacktime",  { "Thời gian gây thọ thương: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_weak_attacktime",  { "Thời gian gây suy yếu: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_slowall_attacktime", { "Thời gian gây làm chậm: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_burn_attacktime",  { "Thời gian gây bỏng: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_stun_attacktime",  { "Thời gian gây choáng: <color=gold>%s<color>", { "add1", 1 } } },
		{ "seriesstate_time_added",  { "Thời gian tạo ra trạng thái ngũ hành: <color=gold>%s<color>", { "add1", 1 } } },
		{ "allseriesstateattacktime",  { "Thời gian hiệu quả ngũ hành: <color=gold>%s<color>", { "add1", 1 } } },
		--造成负面状态的时间
		{ "state_fixed_attacktime",  { "Thời gian gây bất động: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_palsy_attacktime",  { "Thời gian gây tê liệt: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_slowrun_attacktime", { "Thời gian gây giảm tốc độ chạy: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_freeze_attacktime",  { "Thời gian gây đóng băng: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_confuse_attacktime", { "Thời gian gây hỗn loạn: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_knock_attacktime",  { "Thời gian gây tấn công đẩy lùi: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_drag_attacktime",  { "Thời gian gây kéo lại: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_silence_attacktime",  { "Thời gian gây bất lực: <color=gold>%s<color>", { "add1", 1 } } },
		{ "allspecialstateattacktime",  { "Thời gian trạng thái bất lợi: <color=gold>%s<color>", { "add1", 1 } } },
		
		--五行状态几率抗性
		{ "state_hurt_resistrate",  { "Kháng tỷ lệ thọ thương: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_weak_resistrate",  { "Kháng tỷ lệ suy yếu: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_slowall_resistrate", { "Kháng tỷ lệ làm chậm: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_burn_resistrate",  { "Kháng tỷ lệ bỏng: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_stun_resistrate",  { "Kháng tỷ lệ choáng: <color=gold>%s<color>", { "add1", 1 } } },
		{ "allseriesstateresistrate",  { "Kháng tỷ lệ ngũ hành: <color=gold>%s<color>", { "add1", 1 } } },
		--负面状态几率抗性
		{ "state_fixed_resistrate",  { "Kháng tỷ lệ bất động: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_palsy_resistrate",  { "Kháng tỷ lệ tê liệt: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_slowrun_resistrate", { "Kháng tỷ lệ giảm tốc: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_freeze_resistrate",  { "Kháng tỷ lệ đóng băng: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_confuse_resistrate", { "Kháng tỷ lệ hỗn loạn: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_knock_resistrate",  { "Kháng tỷ lệ đánh lui: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_drag_resistrate",  { "Kháng tỷ lệ kéo lại: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_silence_resistrate",  { "Kháng tỷ lệ bất lực: <color=gold>%s<color>", { "add1", 1 } } },
		{ "allspecialstateresistrate",  { "Kháng tỷ lệ trạng thái xấu: <color=gold>%s<color>", { "add1", 1 } } },
		--五行状态时间抗性
		{ "state_hurt_resisttime",  { "Kháng thời gian thọ thương: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_weak_resisttime",  { "Kháng thời gian suy yếu: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_slowall_resisttime", { "Kháng thời gian làm chậm: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_burn_resisttime",  { "Kháng thời gian bỏng: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_stun_resisttime",  { "Kháng thời gian choáng: <color=gold>%s<color>", { "add1", 1 } } },
		{ "allseriesstateresisttime",  { "Kháng thời gian ngũ hành: <color=gold>%s<color>", { "add1", 1 } } },
		--负面状态时间抗性
		{ "state_fixed_resisttime",  { "Kháng thời gian bất động: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_palsy_resisttime",  { "Kháng thời gian tê liệt: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_slowrun_resisttime", { "Kháng thời gian giảm tốc: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_freeze_resisttime",  { "Kháng thời gian đóng băng: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_confuse_resisttime", { "Kháng thời gian hỗn loạn: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_knock_resisttime",  { "Kháng thời gian đánh lui: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_drag_resisttime",  { "Kháng thời gian kéo lại: <color=gold>%s<color>", { "add1", 1 } } },
		{ "state_silence_resisttime",  { "Kháng thời gian bất lực: <color=gold>%s<color>", { "add1", 1 } } },
		{ "allspecialstateresisttime",  { "Kháng thời gian trạng thái bất lợi: <color=gold>%s<color>", { "add1", 1 } } },
		--免疫五行状态
		{ "state_hurt_ignore",  { "Hóa giải và miễn nhiễm sát thương" } },
		{ "state_weak_ignore",  { "Hóa giải và miễn nhiễm suy yếu" } },
		{ "state_slowall_ignore",  { "Hóa giải và miễn nhiễm làm chậm" } },
		{ "state_burn_ignore",  { "Hóa giải và miễn nhiễm bỏng" } },
		{ "state_stun_ignore",  { "Hóa giải và miễn nhiễm choáng" } },
		--免疫负面状态
		{ "state_fixed_ignore",  { "Hóa giải và miễn nhiễm bất động" } },
		{ "state_palsy_ignore",  { "Hóa giải và miễn nhiễm tê liệt" } },
		{ "state_slowrun_ignore",  { "Hóa giải và miễn nhiễm giảm tốc độ chạy" } },
		{ "state_freeze_ignore",  { "Hóa giải và miễn nhiễm đóng băng" } },
		{ "state_confuse_ignore",  { "Hóa giải và miễn nhiễm hỗn loạn" } },
		{ "state_knock_ignore",  { "Hóa giải và miễn nhiễm tấn công đầy lùi" } },
		{ "state_drag_ignore",  { "Hóa giải và miễn nhiễm kéo lại" } },
		{ "state_silence_ignore",  { "Hóa giải và miễn nhiễm bất lực" } },
		--免疫一系列状态
		{ "ignoredebuff",
			--多个生效的话是数个数字相加
			--Lib:LoadBits(tbMagic1[1],i,i) ==1 
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				local tbValue2 = {};
				local tbState = {
						[0]	= "Thọ thương",
						[1] = "Suy yếu",
						[2] = "Làm chậm",
						[3] = "Bỏng",
						[4] = "Choáng",
						[5] = "Bất động",
						[6] = "Tê liệt",
						[7] = "Giảm tốc",
						[8] = "Đóng băng",
						[9] = "Hỗn loạn",
						[10] = "Đánh lui",
						[11] = "Lôi kéo",
						[12] = "Bất lực",
						[13] = "Chí tàn",
						[14] = "Phù không",
					};
				local nValue = tbMagic1[1]
				do
					local i = 0
					repeat
						if nValue == 2*math.floor(nValue/2) then
							tbValue2[i] = 0
							nValue = math.floor(nValue/2)
							i = i+1
						else
							tbValue2[i] = 1
							nValue = math.floor(nValue/2)
							i = i+1
						end
					until nValue == 0
				end
				local szMsg = "";
				local nNum = #tbValue2;
				do
					local bS1,bS2 = 1,1;
					--五行全有就显示免疫五行,不单独显示
					for i=0,4 do
						bS1 = tbValue2[i] and bS1*tbValue2[i] or 0;
					end
					if bS1 == 1 then
						szMsg = szMsg..((szMsg~="" )and "\n" or "").."<color=gold>Hóa giải và miễn nhiễm trạng thái ngũ hành<color>";
						for i=0,4 do
							tbValue2[i] = 0;
						end
					end
					
					--负面全有就显示免疫负面,不单独显示
					for i=5,14 do
						bS2 = tbValue2[i] and bS2*tbValue2[i] or 0;
					end
					if bS2 == 1 then
						szMsg = szMsg..((szMsg~="") and "\n" or "").."<color=gold>Hóa giải và miễn nhiễm trạng thái bất lợi<color>";
						for i=5,14 do
							tbValue2[i] = 0;
						end
					end
				end
				
				for i =0, nNum do
					if tbValue2[i] == 1 then
						szMsg = szMsg..((szMsg~="") and "\n" or "").."<color=gold>Thanh trừ và miễn dịch"..(tbState[i] or "Chưa rõ").."<color>";
					end
				end
				return string.format("%s", szMsg);
			end
		},
		
		--跑速
		{ "fastwalkrun_v",  { "Tốc độ di chuyển: <color=gold>%s<color>", { "add1", 1 } } },
		{ "fastwalkrun_p",
			function(tbMagic, tbSkillInfo, tbMagic2, bEx2)
				if (tbMagic[1] == 0) then
					return "";
				end
				return string.format("Tốc độ di chuyển: <color=gold>%s%%<color>", Add1(tbMagic[1], tbMagic2 and tbMagic2[1], bEx2));
			end
		},
		--技能+n
		{ "allskill_v",
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				--多个生效的话是数个数字相加
				if (FightSkill.MAGIC_INVALID == tbMagic1[3]) then
					local tbAddSkillType = {
							[0] = "Toàn bộ",	--0
							[1] = "Phái",	--1
							[2] = "Bí kíp",	--2
							[3] = "Đồng hành",	--4
						};
					local szMsg = "";
					for i=0,31 do
						if tbMagic1[2] == 0 then
							szMsg = szMsg..tbAddSkillType[0];
							break;
						end
						if Lib:LoadBits(tbMagic1[2],i,i) ==1 then
							if szMsg == "" then
								szMsg = tbAddSkillType[i+1];
							else
								szMsg = szMsg.." và "..tbAddSkillType[i+1];
							end
						end
					end;
					szMsg = string.format("Kỹ năng %s: <color=gold>Cấp %s<color>",szMsg, Add1(tbMagic1[1], tbMagic2 and tbMagic2[1], bEx2));
					return szMsg;
				end
				local szSkillName	= GetSkillName(tbMagic1[3]);
				return string.format(
					"<color=blue>%s<color> cấp: <color=gold>%s<color>",
					szSkillName,
					Add1(tbMagic1[1], tbMagic2 and tbMagic2[1], bEx2)
				);
			end
		},
		{ "hide",
			 function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
			 	local nLastTime = tbMagic1[2] + KFightSkill.GetAddSkillHideTime(tbSkillInfo.nId);
			 	if (tbMagic1[3] == 1) then
					return string.format(
						"Ẩn thân <color=gold>%s giây<color>, đồng đội có thể thấy, chủ động tấn công sẽ hiện thân",
						Frame2Sec(nLastTime)
					);
				elseif (tbMagic1[3] == 2) then
					return string.format(
						"Ẩn thân <color=gold>%s giây<color>, cùng phe có thể thấy, chủ động tấn công sẽ hiện thân",
						Frame2Sec(nLastTime)
					);
				end
				return "";
			end
		},
		{ "prop_showhide",  { "Có thể phát hiện đối thủ ẩn thân" } },
		--改变战斗关系
		{ "defense_state",  { "Không bị tấn công (Được tấn công kẻ địch)" } },
		--变身
		--参数1,变身npcid,参数2变身npc等级,参数3变身类型:1变外观,2变属性,4改变技能
		--{ "domainchangeself",  { "变身为npc<color=gold>%s%%<color>", { "add1", 1 } } },
		--特殊的状态属性,非战斗属性
		{ "expenhance_p",  { "Kinh nghiệm đánh quái: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "expxiuwei_v",
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				return string.format("Luyện nhận được   Còn <color=gold>%s<color> điểm", me.GetTask(1023, 4));
			end
		},
		{ "subexplose",  { "Kinh nghiệm trọng thương tổn thất: <color=gold>%s%%<color>", { "add2", 1 } } },
		{ "addexpshare",  { "Hưởng kinh nghiệm khi đồng đội đánh quái: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "magic_item_abrade_p",  { "Tốc độ giảm độ bền trang bị: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "lucky_v",  { "May mắn: <color=gold>%s điểm<color>", { "add1", 1 } } },
		--激活
		{"active_all_ornament", "Kích hoạt thuộc tính ẩn của trang sức"},
		{"active_all_hide_attrib", "Kích hoạt thuộc tính ẩn toàn bộ trang bị"},
		{"active_suit",
			function(tbMagic, tbSkillInfo, tbMagic2, bEx2)
				local tbSuiteAttrib = KItem.GetPlayerGreenSuiteAttrib(me, tbMagic[1]);
				if tbSuiteAttrib then
					return string.format("<color=gold>激活<color=green>%s<color>上的<color=green>%d<color>条套装属性<color>", tbSuiteAttrib.szName, tbMagic[2]);
				end
				return "";
			end,
		},
		--改变外观
		{ "disguise_part_base", 
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				if Item.szResPart[tbMagic1[2]] then
					return string.format("Có thể thay đổi bề ngoài của %s", Item.szResPart[tbMagic1[2]]);
				end				
				return "";
			end
		},
		{ "disguise_part_effect", ""},
	},
	[5] = --状态属性2,技能加成类放后面好看点儿
	{
		--技能加成
		{"addenchant",
			function(tbMagic, tbSkillInfo, tbMagic2, bEx2)
				return EnchantDesc(tbMagic, tbSkillInfo, tbMagic2, bEx2);
			end;
		},
		{"addmissilethroughrate", {"<color=orange>%s<color> có <color=gold>%s%%<color> xuyên suốt mục tiêu", {"getskillname", 1},  2}},
		{"addpowerwhencol", {"<color=orange>%s<color> lực tấn công sau mỗi lần xuyên suốt mục tiêu <color=gold>%s%%<color>, cộng dồn tối đa <color=gold>%s%%<color>", {"getskillname", 1},  {"add1", 2}, 3}},
		{"addrangewhencol", {"<color=orange>%s<color> phạm vi hiệu quả sau mỗi lần xuyên suốt mục tiêu <color=gold>%s ô<color>, cộng dồn tối đa <color=gold>%s ô<color>", {"getskillname", 1},  {"add1", 2}, 3}},
		{"decautoskillcdtime", {"Thời gian giãn cách xuất hiện của <color=orange>%s<color>: <color=gold>Giảm %s giây<color>", {"getskillname", 1}, {"frame2sec", 3}}},
		{ "changecdtype", 
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				local szMsg = string.format("<color=orange>%s<color> dùng hình thức thay đổi: ",GetSkillName(tbMagic1[1]));
				if (tbMagic1[3]~=0) then
					szMsg = szMsg.."\n    Số lần có thể dùng trong thời gian chờ: <color=gold>"..(tbMagic1[3]/100).." lần<color>"
				else
					szMsg = szMsg.."\n    Dealy không thể hồi phục số lần sử dụng"
				end;
				szMsg = szMsg.."\n    Số lần dùng tối đa: <color=gold>"..(math.floor(tbMagic1[2]/100)).." lần<color>";
				return szMsg;
			end
		},
		{ "changecdtype2", 
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				local szMsg = string.format("<color=orange>%s<color> dùng hình thức thay đổi: ",GetSkillName(tbMagic1[1]));
				if (tbMagic1[3]~=0) then
					szMsg = szMsg.."\n    Số lần có thể dùng trong thời gian chờ: <color=gold>"..(tbMagic1[3]/100).." lần<color>"
				end;
				szMsg = szMsg.."\n    Số lần dùng tối đa: <color=gold>"..(math.floor(tbMagic1[2]/100)).." lần<color>";
				return szMsg;
			end
		},
		{ "changecdtype3", 
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				local szMsg = string.format("<color=orange>%s<color> dùng hình thức thay đổi: ",GetSkillName(tbMagic1[1]));
				if (tbMagic1[3]~=0) then
					szMsg = szMsg.."\n    Số lần có thể dùng trong thời gian chờ: <color=gold>"..(tbMagic1[3]/100).." lần<color>"
				end;
				szMsg = szMsg.."\n    Số lần dùng tối đa: <color=gold>"..(math.floor(tbMagic1[2]/100)).." lần<color>";
				return szMsg;
			end
		},
		{ "changecdtype4", 
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				local szMsg = string.format("<color=orange>%s<color> dùng hình thức thay đổi: ",GetSkillName(tbMagic1[1]));
				if (tbMagic1[3]~=0) then
					szMsg = szMsg.."\n    Số lần có thể dùng trong thời gian chờ: <color=gold>"..(tbMagic1[3]/100).." lần<color>"
				end;
				szMsg = szMsg.."\n    Số lần dùng tối đa: <color=gold>"..(math.floor(tbMagic1[2]/100)).." lần<color>";
				return szMsg;
			end
		},
		--调用其他技能
		{ "addedwith_enemycount",
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				return AddedwithEnemyCount(tbMagic1, tbSkillInfo, tbMagic2, bEx2);
			end;
		},
		{ "rdclifewithdis",
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				return string.format("Sát thương căn cứ cự ly di chuyển trong mỗi nửa giây\nPhát huy sức tấn công cơ bản: <color=gold>Cự ly di chuyển * %s%%<color>, không vượt quá <color=gold>%s%%<color>",
					tbMagic1[1] / 100, math.floor(tbMagic1[1] / 100 * tbMagic1[2]));
			end
		},
		{ "autoskill",
			function(tbMagic, tbSkillInfo, tbMagic2, bEx2)
				local tbAutoInfo	= KFightSkill.GetAutoInfo(tbMagic[1], tbMagic[2]);
				local szClassName	= (tbSkillInfo and tbSkillInfo.szClassName) or "default";
				return FightSkill.tbClass[szClassName]:GetAutoDesc(tbAutoInfo, tbSkillInfo);
			end,
		},
		{ "autoskill2",
			function(tbMagic, tbSkillInfo, tbMagic2, bEx2)
				local tbAutoInfo	= KFightSkill.GetAutoInfo(tbMagic[1], tbMagic[2]);
				local szClassName	= (tbSkillInfo and tbSkillInfo.szClassName) or "default";
				return FightSkill.tbClass[szClassName]:GetAutoDesc2(tbAutoInfo, tbSkillInfo);
			end,
		},
		{ "addstartskill",
			function(tbMagic, tbSkillInfo, tbMagic2, bEx2)
				local tbMsg = {};
				local tbChildInfo	= KFightSkill.GetSkillInfo(tbMagic[2], tbMagic[3]);
				FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0);
				local szSkillInfo = table.concat(tbMsg, "\n").."\n";
				if (tbMagic[1] == 182 and tbMagic[2] == 1660) then
					return string.format("");
				else
					return string.format(
						"<color=orange>%s<color> đồng thời thi triển:\n<color=green>[%s] cấp %s<color>\n%s",
						GetSkillName(tbMagic[1]), GetSkillName(tbMagic[2]), tbMagic[3],
						szSkillInfo
					);
				end
			end
		},
		{ "addflyskill",
			function(tbMagic, tbSkillInfo, tbMagic2, bEx2)
				local tbMsg = {};
				local tbChildInfo	= KFightSkill.GetSkillInfo(tbMagic[2], tbMagic[3]);
				FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0);
				local szSkillInfo = table.concat(tbMsg, "\n").."\n";
				return string.format(
					"Trong lúc <color=orange>%s<color> thi triển:\n<color=green>[%s] cấp %s<color>\n%s",
					GetSkillName(tbMagic[1]), GetSkillName(tbMagic[2]), tbMagic[3],
					szSkillInfo
				);
			end
		},
		{ "addvanishskill",
			function(tbMagic, tbSkillInfo, tbMagic2, bEx2)
				local tbMsg = {};
				local tbChildInfo	= KFightSkill.GetSkillInfo(tbMagic[2], tbMagic[3]);
				FightSkill:GetClass("default"):GetDescAboutLevel(tbMsg, tbChildInfo, 0);
				local szSkillInfo = table.concat(tbMsg, "\n").."\n";
				return string.format(
					"Khi kết thúc <color=orange>%s<color> thi triển:\n<color=green>[%s] cấp %s<color>\n%s",
					GetSkillName(tbMagic[1]), GetSkillName(tbMagic[2]), tbMagic[3],
					szSkillInfo
				);
			end
		},
	},
	[6] = --比较适合放在后面的技能设置
	{	
		{ "missile_dmginterval",  { "Giãn cách tác dụng chiêu: <color=gold>%s giây<color>", { "frame2sec", 1 } } },
		{ "missile_lifetime_v",  { "Thời gian duy trì chiêu: <color=gold>%s giây<color>", { "frame2sec", 1 } } },
		{ "missile_collzheight",  { "Có tác dụng với mục tiêu trên không"} },--至少要参数填的比较大,填个9999差不多够了,目标高度小于等于p时才会与子弹碰撞
		{ "missile_random",
			 function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
			 	if (tbMagic1[2] == 0) then
					return string.format(
						"Tỷ lệ xuất hiện mỗi chiêu thức: <color=gold>%s%%<color>",
						tbMagic1[1]
					);
				elseif (tbMagic1[2] == 1) then
					return string.format(
						"Tất cả chiêu thức ngẫu nhiên xuất hiện <color=gold>%s%%<color>",
						tbMagic1[1]
					);
				else
					return string.format("Chưa biết loại hình xuất hiện đạn ngẫu nhiên");
				end
				return "";
			end
		},
		{ "superposemagic", 
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				local szMsg = "";
				if tbMagic1[1] <= 1 then
					return "";
				elseif tbMagic1[2] > 0 then
					szMsg = string.format("Cộng dồn hiện tại: <color=gold>%s/%s tầng<color>", tbMagic1[2], tbMagic1[1]);
				else--if tbMagic1[2] <= 0 then
					szMsg = string.format("Cộng dồn tối đa: <color=gold>%s tầng<color>", tbMagic1[1]);
					if tbMagic1[3] > 1 then
						szMsg = string.format("Mỗi lần cộng dồn <color=gold>%s tầng<color>,", tbMagic1[3])..szMsg;
					end
				end
				return szMsg;
			end
		},
	},
	[7] = --确定无效或很可能无效的属性
	{
		---------------------应该有效,但不知道怎么用----------------
		{ "fatallystrike_p",  { "Xác suất chí mạng: <color=gold>%s%%, bỏ qua kháng %s", 1, 3 } },
		{ "infectpoison",  { "Lây độc công <color=gold>%s%%<color>", 1 } },
		{"addignoreskill",
			function(tbMagic1, tbSkillInfo, tbMagic2, bEx2)
				if (tbMagic1[3] == 1) then
					return string.format(
						"Giúp <color=orange>%s<color> có xác suất <color=gold>%s%%<color> giải <color=gold>%s<color> bùa, xác suất <color=gold>%s%%<color> miễn nhiễm bùa",
						KFightSkill.GetMissileRate(tbSkillInfo.nId, tbSkillInfo.nLevel),
						Add4(tbMagic1[2], tbMagic2 and tbMagic2[2], bEx2),
						Add4(tbMagic1[1], tbMagic2 and tbMagic2[1], bEx2)
					);
				elseif (tbMagic1[3] == 2) then
					return string.format(
						"Giúp <color=orange>%s<color> tránh công nội <color=gold>%s%%<color>",
						GetSkillName(tbMagic1[1]),
						Add4(tbMagic1[2], tbMagic2 and tbMagic2[2], bEx2)
					);
				elseif (tbMagic1[3] == 3) then
					return string.format(
						"Giúp <color=orange>%s<color> tránh công nội ngoại <color=gold>%s%%<color>",
						GetSkillName(tbMagic1[1]),
						Add4(tbMagic1[2], tbMagic2 and tbMagic2[2], bEx2)
					);
				end
				print("[ERROR]unknown ignoreskill style:", tbMagic1[3]);
				return "";
			end
		},
		----------------------------虽然有效,不过有了技能加成机制,这些也不需要了-------------------------------
		{"addmissilenum", {"Số lượng của <color=orange>%s<color>: <color=gold>%s<color>", {"getskillname", 1}, {"add1", 2}}},
		{"addrestorelife", {"Hiệu quả hồi máu của <color=orange>%s<color>: <color=gold>%s%%<color>", {"getskillname", 1}, {"add1", 2}}},
		{"addmaxlife", {"Sinh lực tối đa của <color=orange>%s<color>: <color=gold>%s%%<color>", {"getskillname", 1}, {"add1", 3}}},
		{"addmaxmana", {"Nội lực tối đa của <color=orange>%s<color>: <color=gold>%s%%<color>", {"getskillname", 1}, {"add1", 3}}},
		{"addmissilerange", {"Phạm vi hiệu quả của <color=orange>%s<color>: <color=gold>%s ô<color>", {"getskillname", 1}, {"add1", 2}}},
		{"addmissilerange2", {"Phạm vi hiệu quả của <color=orange>%s<color>: <color=gold>%s ô<color>", {"getskillname", 1}, {"add1", 2}}},
		{"addmissilerange3", {"Phạm vi hiệu quả của <color=orange>%s<color>: <color=gold>%s ô<color>", {"getskillname", 1}, {"add1", 2}}},
		{"addmissilerange4", {"Phạm vi hiệu quả của <color=orange>%s<color>: <color=gold>%s ô<color>", {"getskillname", 1}, {"add1", 2}}},
		{"addmissilerange5", {"Phạm vi hiệu quả của <color=orange>%s<color>: <color=gold>%s ô<color>", {"getskillname", 1}, {"add1", 2}}},
		{"addmissilerange6", {"Phạm vi hiệu quả của <color=orange>%s<color>: <color=gold>%s ô<color>", {"getskillname", 1}, {"add1", 2}}},
		{"addskillslowstaterate", {"Xác suất làm chậm của <color=orange>%s<color>: <color=gold>%s%%<color>", {"getskillname", 1}, {"add1", 3}}},
		{"addskillcastrange", {"Cự ly thi triển của <color=orange>%s<color>: <color=gold>%s<color>", {"getskillname", 1}, {"add1", 3}}},
		{"addrunattackspeed", {"Tốc độ xung kích của <color=orange>%s<color>: <color=gold>%s<color>", {"getskillname", 1}, {"add1", 3}}},
		{"addmoveposdistance", {"Cự ly di chuyển nhanh của <color=orange>%s<color>: <color=gold>%s%%<color>", {"getskillname", 1}, {"add1", 2}}},
		{"addmissilespeed", {"Tốc độ bay của <color=orange>%s<color>: <color=gold>%s<color>", {"getskillname", 1}, {"add1", 3}}},
		{"addignoreskillrate", {"Xác suất né tránh hoàn toàn của <color=orange>%s<color>: <color=gold>%s%%<color>", {"getskillname", 1}, {"add1", 3}}},
		{"addmissilelifetime", {"Thời gian duy trì của <color=orange>%s<color>: <color=gold>Tăng %s giây<color>", {"getskillname", 1}, {"frame2sec", 3}}},
		{"adddragspeed", {"Tốc độ kéo người của <color=orange>%s<color>: <color=gold>%s<color>", {"getskillname", 1}, {"add1", 3}}},
		{"addmissilecolrange", {"Phạm vi va chạm của <color=orange>%s<color>: <color=gold>%s ô<color>", {"getskillname", 1}, {"add1", 2}}},
		{"addmissiledamagerange", {"Phạm vi sát thương của <color=orange>%s<color>: <color=gold>%s ô<color>", {"getskillname", 1}, {"add1", 2}}},
		{"addskillhidetime",    { "Thời gian ẩn thân của <color=orange>%s<color>: <color=gold>Tăng %s giây<color>", {"getskillname", 1}, { "frame2sec", 2}}},
		{"decreaseskillcasttime", {"Thời gian giãn cách thi triển của <color=orange>%s<color>: <color=gold>Giảm %s giây<color>", {"getskillname", 1}, {"frame2sec", 2}}},
		-- {"addstartskill", {"<color=orange>%s<color>时发出：<color=gold>%s级<color><color=green>%s<color>", {"getskillname", 1},  3, {"getskillname", 2}}},
		{"addfastmanareplenish_v", {"<color=orange>%s<color> khiến đối thủ mỗi nửa giây hồi phục nội lực: <color=gold>%s điểm<color>", {"getskillname", 1}, {"add1", 2}}},
		
		---------------------确定无效的--------------------
		-- 增加受到伤害百分比
		{ "damage_physics_receive_p", { "Sát thương vật công phải chịu: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "damage_poison_receive_p",  { "Sát thương độc công phải chịu: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "damage_cold_receive_p",  { "Sát thương băng công phải chịu: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "damage_fire_receive_p",  { "Sát thương hỏa công phải chịu: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "damage_light_receive_p",  { "Sát thương lôi công phải chịu: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "physicsresmax_p",  { "Kháng vật công tối đa: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "coldresmax_p",  { "Kháng băng công tối đa: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "fireresmax_p",  { "Kháng hỏa công tối đa: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "lightingresmax_p",  { "Kháng lôi công tối đa: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "poisonresmax_p",  { "Kháng độc công tối đa: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "allresmax_p",  { "Kháng tất cả tối đa: <color=gold>%s%%<color>", { "add1", 1 } } },
		
		---------------------可能无效的--------------------
		{ "knockback_p",  { "Xác suất tấn công đẩy lùi: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "drag_p",  { "Xác suất tấn công kéo lại: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "stun_p",  { "Xác suất tấn công gây hôn mê: <color=gold>%s%%<color>", { "add1", 1 } } },
		
		{ "poisonres_p",  { "Độc phòng: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "fireres_p",  { "Hỏa phòng:  <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "lightingres_p",  { "Lôi phòng: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "physicsres_p",  { "Vật phòng: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "coldres_p",  { "Băng phòng: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "freezetimereduce_p",  { "Thời gian làm chậm: <color=gold>%s%%<color>", { "add2", 1 } } },
		{ "poisontimereduce_p",  { "Thời gian trúng độc: <color=gold>%s%%<color>", { "add2", 1 } } },
		{ "poisontimeenhance_p",  { "Số lần độc công gây ra: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "poisondamagereduce_v",  { "Độc sát: <color=gold>%s<color>", { "add2", 1 } } },
		{ "stuntimereduce_p",  { "Thời gian choáng: <color=gold>%s%%<color>", { "add2", 1 } } },
		
		{ "fasthitrecover_v",  { "Thời gian thọ thương: <color=gold>%s<color>", { "add2", 1 } } },
		{ "allres_p",  { "Kháng tất cả: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "slowmissile_b",  { "Giảm tốc khí công" } },
		{ "changecamp_b",  { "Mê hoặc đối thủ" } },
		{ "physicsarmor_v",  { "Vật lý hộ giáp: <color=gold>%s điểm<color>", { "add1", 1 } } },
		{ "coldarmor_v",  { "Băng hộ giáp: <color=gold>%s điểm<color>", { "add1", 1 } } },
		{ "firearmor_v",  { "Hỏa hộ giáp: <color=gold>%s điểm<color>", { "add1", 1 } } },
		{ "poisonarmor_v",  { "Độc hộ giáp: <color=gold>%s điểm<color>", { "add1", 1 } } },
		{ "lightingarmor_v",  { "Điện hộ giáp: <color=gold>%s điểm<color>", { "add1", 1 } } },
		{ "lucky_v_partner",  { "May mắn: <color=gold>%s điểm<color>", { "add1", 1 } } },
		{ "skilllevel_added", 
			function(tbMagic, tbSkillInfo, tbMagic2, bEx2)
				if (tbMagic[1] == 0) then
					return "";
				end
				if me.nRouteId == 0 then
					return string.format("Kỹ năng Môn Phái <color=gold>%s<color>: +1 cấp", tbParamToLevel[tbMagic[1]]);
				else
					return string.format("%s: <color=gold>cấp %s<color>", GetSkillNameByParam(tbMagic[1]) , Add1(tbMagic[2], tbMagic2 and tbMagic2[2], bEx2));
				end
			end
		},
		{ "metalskill_v",  { "Cấp võ công hệ Kim: <color=gold>Cấp %s<color>", { "add1", 1 } } },
		{ "woodskill_v",  { "Cấp võ công hệ Mộc: <color=gold>Cấp %s<color>", { "add1", 1 } } },
		{ "waterskill_v",  { "Cấp võ công hệ Thủy: <color=gold>Cấp %s<color>", { "add1", 1 } } },
		{ "fireskill_v",  { "Cấp võ công hệ Hỏa: <color=gold>Cấp %s<color>", { "add1", 1 } } },
		{ "earthskill_v",  { "Cấp võ công hệ Thổ: <color=gold>Cấp %s<color>", { "add1", 1 } } },
		{ "knockback_p",  { "Xác suất tấn công đẩy lùi: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "drag_p",  { "Xác suất tấn công kéo lại: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "badstatustimereduce_v",  { "Thời gian duy trì trạng thái xấu: <color=gold>%s giây<color>", { "add2", 1 } } },
		{ "coldenhance_p",  { "Thời gian làm chậm: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "fireenhance_p",  { "Hỏa sát tối đa: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "lightingenhance_p",  { "Lôi sát tối đa: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "poisonenhance_p",  { "Giãn cách độc phát: <color=gold>%s%%<color>", { "add2", 1 } } },
		{ "knockbackenhance_p",  { "Xác suất đánh trúng đẩy lùi: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "dragenhance_p",  { "Xác suất đánh trúng kéo lại: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "stunenhance_p",  { "Xác suất đánh trúng gây choáng: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "fatallystrikeenhance_p",  { "Xác suất tấn công chí mạng:  <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "magicenhance_p",  { "Sát thương ngũ hành: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "fatallystrikeres_p",  { "Lực kháng chí mạng: <color=gold>%s%%<color>", { "add1", 1 } } },
		{ "addstealfeatureskill",  { "Kỹ năng ngụy trang còn: <color=gold>%s lần<color>", 1 } },
		{ "clearnegativestate",  { "Xác suất <color=gold>%s%%<color> giải trừ trạng thái khác thường cho người chơi phe ta trong phạm vi nhất định", 1 } },
		{ "prop_ignoretrap",  { "Xác suất %s%% không thi triển cạm bẫy", 1 } },
		{ "prop_evadeattack",  { "Xác suất %s%% né tránh tấn công và hiệu ứng kèm theo", 1 } },
		{ "infectcurse",
			function(tbMagic, tbSkillInfo, tbMagic2, bEx2)
				return string.format(
					"Xác suất <color=gold>%d%%<color> lây <color=gold>%s<color> bùa chú của mình sang đối thủ kế cận\nMỗi lần lây tối đa ảnh hưởng <color=gold>%d<color> mục tiêu",
					KFightSkill.GetMissileRate(tbSkillInfo.nId, tbSkillInfo.nLevel),
					Add4(tbMagic[1], tbMagic2 and tbMagic2[1], bEx2),
					tbSkillInfo.tbWholeMagic["missile_hitcount"][1]
				);
			end
		},
	},
}

FightSkill.tbStr2Fun =
{
	["add1"]		= Add1,
	["add2"]		= Add2,
	["add3"]		= Add3,
	["add4"]		= Add4,
	["add5"]		= Add5,
	["add6"]		= Add6,
	["frame2sec"]	= Frame2Sec,
	["frame2sec2"]	= Frame2Sec2,
	["castskill"]	= CastSkill,
	["getskillname"]	= GetSkillName,
	["frame2times"]	= Frame2Times,
	["enchanttype"]	= EnchantType,
	["enchanttypev"]	= EnchantTypeV,
	["enchanttypep"]	= EnchantTypeP,
	["v2p"]	= v2p,
};

function FightSkill:ParingDesc(tbParams, tbMagicData)
	local strDescSrc = tbParams[1];
	local strResult = "";
	local strNow = strDescSrc;
	local strTrans = {strDescSrc};
	local nCount = 1;
	local nFindCur = 0;
	while (true) do

		nFindCur = string.find(strDescSrc,"%%s", nFindCur + 1);
		if (not nFindCur) then
			break;
		end

		nCount = nCount + 1;
		strTrans[nCount] = "";
		if (type(tbParams[nCount]) == "table") then

			local funPas = {};
			for i = 1, #tbParams[nCount] - 1 do
				funPas[i] = tbMagicData[tbParams[nCount][i+1]];
			end
			if (#funPas < 1) then
				return "";
			end;

			if (type(tbParams[nCount][1]) == "string") then
				if (type(self.tbStr2Fun[tbParams[nCount][1]]) == "function") then
					strTrans[nCount] = self.tbStr2Fun[tbParams[nCount][1]](unpack(funPas));
					--print(nCount, strTrans[nCount]);
				else
					print("FightSkill:ParingDesc can not find func", tbParams[nCount][1]);
				end
			elseif (type(tbParams[nCount][1]) == "table") then
				strTrans[nCount] = tbParams[nCount][1][funPas[1]] or tostring(funPas[1]);
			end

		else
			if type(tbMagicData[tbParams[nCount]]) == "table" then
				strTrans[nCount] = tbMagicData[tbParams[nCount]].nPoint;
			else
				strTrans[nCount] = tbMagicData[tbParams[nCount]];
			end
			

		end

	end

	if (not strTrans)then
		print("FightSkill:ParingDesc strTrans is nill");
		return "null";
	end
	return string.format(unpack(strTrans));

end

function FightSkill:GetMagicDesc(szMagicName, tbMagicData, tbSkillInfo, bNoColor, bEnchantMagic, nMode)
	local szMsg = "";
	local nGroupId = 0;
	local szDesc = "";
	local varMagicDesc, nNum;
	if (bEnchantMagic and bEnchantMagic == true) then
		varMagicDesc, nGroupId, nNum = self:GetEnchantMaigcDesc(szMagicName, nMode);
	else
		varMagicDesc, nGroupId, nNum = self:GetOriginalMagicDesc(szMagicName, nMode);
	end
	if (not varMagicDesc) and (szMagicName ~= "") then
		print(string.format("magic[%s] not found!", tostring(szMagicName)));
		return	"";
	end

	if (type(varMagicDesc) == "table") then
		local tbParams	= { varMagicDesc[1] };
		for i = 2, #varMagicDesc do
			tbParams[i]	= varMagicDesc[i];
		end
		szDesc = self:ParingDesc(tbParams, tbMagicData, tbSkillInfo);
	elseif (type(varMagicDesc) == "function") then
		szDesc = varMagicDesc(tbMagicData, tbSkillInfo);
	elseif (type(varMagicDesc) == "string") then
		szDesc = ""..varMagicDesc;
	end
	if (szDesc and szDesc ~= "") then
		szMsg = szMsg..szDesc;
		--szMsg = szMsg.."["..nGroupId.."."..nNum.."]"..szDesc;
	end;

	if (1 ~= bNoColor) then
		return	szMsg, nGroupId, nNum;
	end
	return	string.gsub(szMsg, "<color([^>]*)>", ""), nGroupId, nNum;

end

-- nMode为1时表示取详细模式，nMode为0时取简略模式，默认是详细模式
function FightSkill:GetOriginalMagicDesc(szDescMagicName, nMode)
	nMode = nMode or 1;
	local nGroupId,nNum = 0,0;
	for nGroupId,tbMagicGroup in ipairs(FightSkill.MAGIC_DESCS) do
		if (type(tbMagicGroup) == "table") then
			for nNum, tbMagicDesc in pairs(tbMagicGroup) do
				local szMagicName = tbMagicDesc[1];
				local MagicDesc = tbMagicDesc[2];
				if nMode == 0 and tbMagicDesc[3] then
					MagicDesc = tbMagicDesc[3];
				end
				
				if (szMagicName == szDescMagicName) then
					return MagicDesc, nGroupId, nNum;
				end
			end
		end
	end
end

function FightSkill:GetEnchantMaigcDesc(szDescMagicName)
	local tbDesc = "";
	local nGroupId,nNum = 0,0;
	for nGroupId, tbMagicGroup in ipairs(FightSkill.ENCHANT_DESCS) do
		if (type(tbMagicGroup) == "table") then
			for nNum, tbMagicDesc in pairs(tbMagicGroup) do
				local szMagicName = tbMagicDesc[1];
				local MagicDesc = tbMagicDesc[2];
				if (szMagicName == szDescMagicName) then
					tbDesc  = MagicDesc;
					return MagicDesc, nGroupId, nNum;
				end
			end
		end
	end
	return tbDesc, nGroupId, nNum;
end;

function FightSkill:GetExtentMagicDesc(szMagicName, tbMagicDataLow, tbMagicDataHigh, bEx2)

	local varMagicDesc = self:GetOriginalMagicDesc(szMagicName);
	local szDesc = "";

	if (not varMagicDesc) and (szMagicName ~= "") then
		print(string.format("magic[%s] not found!", tostring(szMagicName)));
		return	"";
	end

	if (type(varMagicDesc) == "table") then
		local tbParams	= { varMagicDesc[1] };
		for i = 2, #varMagicDesc do
			tbParams[i]	= varMagicDesc[i];
		end
		szDesc = self:ParingExtentDesc(tbParams, tbMagicDataLow, tbMagicDataHigh, bEx2);
	elseif (type(varMagicDesc) == "function") then
		-- TODO: liuchang 还没完
		szDesc = varMagicDesc(tbMagicDataLow, tbSkillInfo, tbMagicDataHigh, bEx2);
	elseif (type(varMagicDesc) == "string") then
		szDesc = ""..varMagicDesc;
	end

	if bEx2 == 1 then
		szDesc = string.gsub(szDesc, "<color([^>]*)>", "");
		szDesc = string.gsub(szDesc, "→", "<color=gold>→<color>");
	end

	return szDesc;

end

function FightSkill:ParingExtentDesc(tbParams, tbMagicDataLow, tbMagicDataHigh, bEx2)

	local strDescSrc = tbParams[1];
	local strResult = "";
	local strNow = strDescSrc;
	local strTrans = {strDescSrc};
	local nCount = 1;
	local nFindCur = 0;

	while (true) do

		nFindCur = string.find(strDescSrc, "%%s", nFindCur + 1);
		if (not nFindCur) then
			break;
		end

		nCount = nCount + 1;
		strTrans[nCount] = "";

		if (type(tbParams[nCount]) == "table") then

			local funPasLow = {};
			local funPasUp = {};

			for i = 1, #tbParams[nCount] - 1 do
				funPasLow[i] = tbMagicDataLow[tbParams[nCount][i+1]];
				funPasUp[i] = tbMagicDataHigh[tbParams[nCount][i+1]];
			end

			if (type(tbParams[nCount][1]) == "string") then
				if (type(self.tbStr2Fun[tbParams[nCount][1]]) == "function") then
					strTrans[nCount] = self.tbStr2Fun[tbParams[nCount][1]](unpack(funPasLow), unpack(funPasUp), bEx2);
				else
					print("FightSkill:ParingDesc can not find func", tbParams[nCount][1]);
				end
			end
		end
	end

	if (not strTrans)then
		print("FightSkill:ParingDesc strTrans is nill");
		return "null";
	end

	return string.format(unpack(strTrans));

end

