
local tbDefault	= FightSkill:GetClass("default");

local tbWeaponName	= {
	[11]	= "空手、缠手",
	[12]	= "剑",
	[13]	= "刀",
	[14]	= "棍棒",
	[15]	= "枪",
	[16]	= "锤",
	[21]	= "飞镖",
	[22]	= "飞刀",
	[23]	= "袖箭",
	[24]	= "机关",
}

local SKILLTXT = "\\setting\\fightskill\\skill.txt";
tbDefault.tbSkilltxt = Lib:LoadTabFileById(SKILLTXT, 3) or {};
local function GetSkillInfoByTxt(nId, szColumn)
	if tbDefault.tbSkilltxt[nId] then
		if (tbDefault.tbSkilltxt[nId][szColumn] ~= "") then
			return tbDefault.tbSkilltxt[nId][szColumn];
		else
			return "无风格";
		end
	else
		return "skill表找不到id";
	end
end

--隐藏技能名"&"字符后的文字
local function GetSkillName(value)
	if type(value) == "table" then
		value = value.nPoint;
	end
	local szName = KFightSkill.GetSkillName(value);
	local tbTrueName = Lib:SplitStr(szName, "&");
	return tbTrueName[1];
end

local tbHoresName	= {
	"骑马中不能施展",
	"必须骑马施展",
}

local tbSeriesColor	= {
	[Env.SERIES_NONE]	= "white",
	[Env.SERIES_METAL]	= "gold",
	[Env.SERIES_WOOD]	= "wood",
	[Env.SERIES_WATER]	= "water",
	[Env.SERIES_FIRE]	= "fire",
	[Env.SERIES_EARTH]	= "earth",
};

local function Frame2Sec(value)
	return math.floor(value / Env.GAME_FPS * 10) / 10;
end

function tbDefault:OnLevelUp()
end;

function tbDefault:GetDesc(tbThisInfo, bNext, bShowTitle, bNoNeedLevel) -- bNoNeedLevel 不需要自身能级也能取到对应技能TIP
	local tbInfo	= tbThisInfo;
	local bMaxLevel = 0;
	local tbMsg	= {};
	
	-- 1.技能名字, 标题大字了~独立传
	local szTitle	= string.format("<color=yellow>%s<color>\n", tbInfo.szName);
	if (not bNext or bShowTitle) then
		-- 1.技能类型
		if(tbInfo.szProperty ~= "") then
			tbMsg[#tbMsg+1]	= string.format("<color=metal>%s<color>",tbInfo.szProperty.."\n");
		end;

		if (tbInfo.nIsAura == 1 and not bNoNeedLevel) then
			tbMsg[#tbMsg+1] = "<color=gray>(可拖到快捷栏，点击数字键使其自动施放)<color>";
		end
		-- 2.格斗系技能描述
		if(tbInfo.nSkillType == 1) then
			tbMsg[#tbMsg+1]	= string.format("<color=gray>(格斗系技能，出招速度不受攻速影响)<color>");
		end;

		-- 3.技能描述
		if(tbInfo.szDesc ~= "") then
			tbMsg[#tbMsg+1]	= string.format("%s",tbInfo.szDesc);
		end;
		
		if (MODULE_GAMECLIENT and FightSkill:CheckCanAddSkillPoint(me, tbInfo.nId) ~= 1) then
			if(tbInfo.nReqLevel == 110) then
				tbMsg[#tbMsg+1] = "<color=green>(在门派接引弟子处接取110级技能任务并完成后，可为该技能投点升级)<color>";
			end;
		end;
	end
	--if (tbInfo.nReqLevel >= 120) then
	--	tbMsg[#tbMsg+1]	= "<color=red>此技能稍后开放，暂时不能投点<color>";
	--	return szTitle, table.concat(tbMsg, "\n");
	--end

	if (me.nLevel < tbInfo.nReqLevel and not bNoNeedLevel) then
		tbMsg[#tbMsg+1]	= string.format("<color=red>角色等级达到%d级可以悟得该技能<color>", tbInfo.nReqLevel);
		--return szTitle, table.concat(tbMsg, "\n");
	end
	
	if (not bNext or bShowTitle) then
		if (tbInfo.nRouteLimited and tbInfo.nRouteLimited > 0) then
			if (me.nRouteId ~= tbInfo.nRouteLimited or me.nFaction ~= tbInfo.nFactionLimited) then
				tbMsg[#tbMsg+1]	= "\n路线需求：<color=red>"..Player:GetFactionRouteName(tbInfo.nFactionLimited, tbInfo.nRouteLimited).."<color>";
			else
				tbMsg[#tbMsg+1]	= "\n路线需求："..Player:GetFactionRouteName(tbInfo.nFactionLimited, tbInfo.nRouteLimited);
			end
		elseif (tbInfo.nFactionLimited and tbInfo.nFactionLimited > 0) then
			if (me.nFaction ~= tbInfo.nFactionLimited) then
				tbMsg[#tbMsg+1]	= "\n门派需求：<color=red>"..Player:GetFactionRouteName(tbInfo.nFactionLimited, nil).."<color>";
			else
				tbMsg[#tbMsg+1]	= "\n门派需求："..Player:GetFactionRouteName(tbInfo.nFactionLimited, nil);
			end
		end
		
		-- 4.技能五行属性
		if(tbInfo.nSeries ~= 0) then
			-- or 后面的部分用于出错保护
			tbMsg[#tbMsg+1]	= string.format("\n五行：<color=%s>%s系<color>",
				tbSeriesColor[tbInfo.nSeries] or "",
				Env.SERIES_NAME[tbInfo.nSeries] or tostring(tbInfo.nSeries));
		end;
		
		-- 5.技能武器限制
		if (tbInfo.nWeaponLimited ~= 0) then
			-- or 后面的部分用于出错保护
			if(tbInfo.nSeries == 0) then
				tbMsg[#tbMsg+1] = "";
			end
			tbMsg[#tbMsg+1]	= string.format("武器限制：<color=gold>%s<color>",
				tbWeaponName[tbInfo.nWeaponLimited] or tostring(tbInfo.nWeaponLimited));
		end;

		-- 6.技能是否能骑马施展
		if (tbInfo.nHorseLimited ~= 0) then
			-- or 后面的部分用于出错保护
			if(tbInfo.nSeries == 0) then
				tbMsg[#tbMsg+1] = "";
			end
			tbMsg[#tbMsg+1]	= string.format("%s\n",tbHoresName[tbInfo.nHorseLimited] or
				("骑马限制？："..tostring(tbInfo.nHorseLimited)));
		else
			tbMsg[#tbMsg+1]	= "";	
		end;
	end
	
	-- 等级相关信息
	if (tbThisInfo) then
		-- 7.当前等级
		local nMaxLevel = KFightSkill.GetSkillMaxLevel(tbInfo.nId);
		local szLevel	= "";
		if (nMaxLevel > 0) then
			szLevel = string.format("<color=gold>%d/%d级<color>", tbInfo.nLevel, nMaxLevel);
		else
			szLevel = string.format("<color=gold>%d级<color>", tbInfo.nLevel);
		end
		if (bNext ~= 1) then
			if (tbInfo.nBaseLevel and tbInfo.nBaseLevel ~= tbInfo.nLevel) then	-- 有受到加成
				szLevel	= szLevel..string.format(" (%d", tbInfo.nBaseLevel);
				if (tbInfo.nAddPoint and tbInfo.nAddPoint > 0) then
					szLevel	= szLevel.."+"..tbInfo.nAddPoint;
				end
			
				if (tbInfo.nLevelAddition and tbInfo.nLevelAddition > 0) then
					szLevel	= szLevel..string.format("<color=cyan>+%d<color>", tbInfo.nLevelAddition);
				end;
				
				szLevel	= szLevel..")";
			end
		end;
		if (bNext) then
			tbMsg[#tbMsg+1]	= string.format("<color=cyan>下一级<color>：%s", szLevel);
		else
			tbMsg[#tbMsg+1]	= string.format("<color=cyan>当前等级<color>：%s", szLevel);
		end
		local nMaxSkillLevel = KFightSkill.GetSkillMaxLevel(tbInfo.nId);
		if (tbInfo.nBaseLevel and (nMaxSkillLevel <= (tbInfo.nBaseLevel + (tbInfo.nAddPoint or 0))) and nMaxSkillLevel ~= 0) then
			bMaxLevel = 1;
		end
		if (bMaxLevel == 1) then
			if(tbInfo.nExpPercent) then
			else	
				tbMsg[#tbMsg+1]	= string.format("<color=red>已达到投点最高等级<color>");
			end
		end
		
		self:GetDescAboutLevel(tbMsg, tbThisInfo);
	else
		tbMsg[#tbMsg+1]	= string.format("<color=cyan>当前等级<color>：<color=gold>0/%d级<color>", KFightSkill.GetSkillMaxLevel(tbInfo.nId));
	end
	
	return szTitle, table.concat(tbMsg, "\n").."\n";
end;

-- 只获取与等级相关的部分
function tbDefault:GetDescAboutLevel(tbMsg, tbInfo, bShow)
	local bShow = bShow or 1;
	if (not tbInfo) then
		return;
	end
	--技能Id
	--tbMsg[#tbMsg+1]	= string.format("<color=green>SkillId：%s<color>",Lib:StrFillR(tbInfo.nId, 4));
	--显示SkillStyle
	--tbMsg[#tbMsg+1]	= string.format("<color=green>SkillStyle: %s<color>", GetSkillInfoByTxt(tbInfo.nId, "SkillStyle"));
	
	if bShow == 1 then
		-- 8.修炼度
		if (tbInfo.nExpPercent) then
			local nMaxLevel = KFightSkill.GetSkillMaxLevel(tbInfo.nId);
			if (tbInfo.nBaseLevel < nMaxLevel) then
				tbMsg[#tbMsg+1]	= string.format("修炼度：<color=gold>%d%%<color>", tbInfo.nExpPercent);
			else
				tbMsg[#tbMsg+1]	= string.format("<color=red>已修炼至最高等级<color>");
			end
			if (tbInfo.nBaseLevel == 8) or (tbInfo.nBaseLevel == 9) then
				if (nMaxLevel ~= 50) then--古墓的坐骑技能不显示这个提示...todo,todo你妹,怎么做都很恶心,就这样吧
					tbMsg[#tbMsg+1]	= string.format("<color=red>你可能需要购买新的秘籍以继续修炼此技能<color>");
				end
			end
		end;
		-- 10.施展距离...迷影纵不显示施展距离...
		if (tbInfo.nAttackRadius ~= 0) and (tbInfo.nId ~= 64) then
			tbMsg[#tbMsg+1]	= string.format("<color=blue>施展距离：<color><color=gold>%d<color>", tbInfo.nAttackRadius);
		end;
	
		-- 11.最大移动距离(瞬移)
		self:GetParamDesc(tbMsg, tbInfo.nParam1, tbInfo.nParam2, tbInfo);
	
		-- 12.消耗类属性
		if (tbInfo.nCost ~= 0) then
			tbMsg[#tbMsg+1]	= string.format("<color=blue>%s消耗：<color><color=gold>%d点<color>",
				FightSkill.COSTTYPE_NAME[tbInfo.nCostType] or tostring(tbInfo.nCostType).."?", tbInfo.nCost);
		end;
	
		-- 13.冷却时间
		if (tbInfo.nMinTimePerCast > 0) then
			if (tbInfo.nMinTimePerCast == tbInfo.nMinTimePerCastOnHorse or tbInfo.nMinTimePerCastOnHorse <= 0 or tbInfo.nHorseLimited == 1) then
				local nMinTimePerCast = math.max(0, tbInfo.nMinTimePerCast - KFightSkill.GetDecreaseSkillCastTime(tbInfo.nId));
				tbMsg[#tbMsg+1]	= string.format("<color=blue>施展间隔：<color><color=gold>%s秒<color>",
					Frame2Sec(nMinTimePerCast));
			else
				local nMinTimePerCast = math.max(0, tbInfo.nMinTimePerCastOnHorse - KFightSkill.GetDecreaseSkillCastTime(tbInfo.nId));
				tbMsg[#tbMsg+1]	= string.format("<color=blue>施展间隔：<color><color=gold>%s秒<color>\n<color=blue>骑马施展间隔时间：<color><color=gold>%s秒<color>",
					Frame2Sec(tbInfo.nMinTimePerCast), Frame2Sec(nMinTimePerCast));
			end;
		end;
	end
	
	-- 15.最多同时施放数
	if (tbInfo.nMaxMissile > 0) then
		if (tbInfo.nChildSkillNum and tbInfo.nChildSkillNum > 1) then
			tbMsg[#tbMsg+1]	= string.format("<color=blue>最多同时布置数：<color><color=gold>%d个<color>", math.floor(tbInfo.nMaxMissile/tbInfo.nChildSkillNum));
		else
			tbMsg[#tbMsg+1]	= string.format("<color=blue>最多同时布置数：<color><color=gold>%d个<color>", tbInfo.nMaxMissile);
		end
	end
	--tbMsg[#tbMsg+1]	= string.format("会心一击率：%d", tbInfo.nDeadlyStrikeRate);

	self:GetAllMagicsDesc(tbMsg, tbInfo);
	

	-- 17.技能攻击力系数
	if (tbInfo.nSkillDamageP and tbInfo.nSkillDamageP ~= 100) then
		tbMsg[#tbMsg+1]	= string.format("发挥技能攻击力：<color=gold>%d%%<color>", tbInfo.nSkillDamageP);
	end

	-- 18.基础攻击力系数
	if (not tbInfo.tbWholeMagic.appenddamage_p) and (tbInfo.IsOpenFloatDamage == 0) then
		if (tbInfo.nAppenDamageP and tbInfo.nAppenDamageP >= 0) then
			local szMsg = "";
			--local tbSkillInfo = KFightSkill.GetSkillInfo(tbSkillInfo.nId, tbSkillInfo.nLevel);
			local nAppend = tbInfo.nAppenDamageP;
			if (nAppend == 0) then
				szMsg = "<color=gray>不受基础攻击影响<color>";
			else
				szMsg = string.format("发挥基础攻击力：<color=gold>%s%%<color>", nAppend);
				if tbInfo.bIsPhysical == 1 then
					szMsg = szMsg.."外功系攻击";
				elseif tbInfo.bIsPhysical == 0 then
					szMsg = szMsg.."内功系攻击";
				end
			end
			tbMsg[#tbMsg+1] = szMsg
			--tbMsg[#tbMsg+1]	= string.format("发挥基础攻击力：<color=gold>%d%%<color>", tbInfo.nAppenDamageP);
		end
	end
	
	-- 招式数目
	if (tbInfo.nChildSkillNum and tbInfo.nChildSkillNum > 0) then
		tbMsg[#tbMsg+1]	= string.format("招式数目：<color=gold>%d个<color>", tbInfo.nChildSkillNum);
	end
	
	-- 16.最多同时影响目标
	if (tbInfo.nMissileHitcount > 0) then
		if (tbInfo.nIsChainLightting == 1) then
			tbMsg[#tbMsg+1]	= string.format("连环次数：<color=gold>%d次<color>", tbInfo.nMissileHitcount);
		else	
			tbMsg[#tbMsg+1]	= string.format("作用人数：<color=gold>每个招式%d个<color>", tbInfo.nMissileHitcount);
		end		
	end
	
	-- 14.持续时间
	if (tbInfo.nStateTime > 0 and tbInfo.nIsAura ~= 1) then
		if tbInfo.nId ~= 1259 then --隐藏反两仪刀法技能持续时间显示
			tbMsg[#tbMsg+1]	= string.format("<color=white>Thời gian duy trì: <color><color=gold>%s秒<color>", Frame2Sec(tbInfo.nStateTime));
		end
	end;
	
	-- 19.受其它技能加成
	if (tbInfo.nAddPercent) then
		tbMsg[#tbMsg+1]	= string.format("\n<color=green>攻击受其他技能加成<color>：<color=gold>%d%%<color>", tbInfo.nAddPercent);
	end;
	
	-- 9.对其他技能加成
	--for _, tbAdd in pairs(tbInfo.tbAddition or {}) do
	--	tbMsg[#tbMsg+1]	= string.format("<color=green>对[%s]的攻击加成：<color><color=Gold>%d%%<color>", GetSkillName(tbAdd.nSkillId), tbAdd.nPercent);
	--end;
	local tbAddMagic = {
		"addskilldamagep",
		"addskilldamagep2",
		"addskilldamagep3",
		"addskilldamagep4",
		"addskilldamagep5",
		"addskilldamagep6",
	};
	for i = 0, #tbAddMagic do
		local tbAdd = tbInfo.tbWholeMagic[tbAddMagic[i]]
		if (tbAdd and tbAdd[3] ==1) then
			tbMsg[#tbMsg+1]	= string.format("<color=green>对[%s]的攻击加成：<color><color=Gold>%d%%<color>", KFightSkill.GetSkillName(tbAdd[1]), tbAdd[2]);
		end
	end;

	-- 填充子技能
	local tbChild	= {};
	tbInfo.tbChild	= tbChild;
	local tbEvent	= tbInfo.tbEvent;
	if (tbEvent) then
		if (tbEvent.nAddStartSkillId) then
			tbChild[#tbChild+1] = {"\n招式同时释放：\n%s", tbEvent.nAddStartSkillId, tbEvent.nAddStartSkillLevel};
		elseif (tbEvent.nStartSkillId and tbEvent.nStartSkillId > 0) then
			tbChild[#tbChild+1]	= {"\n招式同时释放：\n%s", tbEvent.nStartSkillId, tbEvent.nLevel};
		end;

		if (tbEvent.nFlySkillId and tbEvent.nFlySkillId > 0) then
			tbChild[#tbChild+1]	= {"\n招式持续中释放：\n%s",tbEvent.nFlySkillId, tbEvent.nLevel};
		end;
		if (tbEvent.nCollideSkillId and tbEvent.nCollideSkillId > 0) then
			tbChild[#tbChild+1]	= {"\n招式击中时释放：\n%s", tbEvent.nCollideSkillId, tbEvent.nLevel};
		end;
		if (tbEvent.nVanishedSkillId and tbEvent.nVanishedSkillId > 0) then
			tbChild[#tbChild+1]	= {"\n招式结束时释放：\n%s", tbEvent.nVanishedSkillId, tbEvent.nLevel};
		end;
		if (tbEvent.HitSkillId and tbEvent.HitSkillId > 0) then
			tbChild[#tbChild+1]	= {"\n击中目标时释放：\n%s", tbEvent.HitSkillId, tbEvent.nLevel};
		end;
	end;
	
	-- 子技能
	for _, tb in pairs(tbChild) do
		local szName	= GetSkillName(tb[2]);
		local nLevel	= tb[3];
		if (nLevel) then -- 有等级,小于0也显示吧,容易发现bug
			szName	= string.format("<color=green>[%s] %d级<color>", szName, nLevel);
		else
			nLevel	= tbInfo.nLevel;
		end;
		tbMsg[#tbMsg+1]	= string.format(tb[1], szName);
		local tbChildInfo	= KFightSkill.GetSkillInfo(tb[2], nLevel);
		self:GetDescAboutLevel(tbMsg, tbChildInfo, 0);--子技能不显示消耗和距离的属性
	end;
end;

-- 技能参数说明
function tbDefault:GetParamDesc(tbMsg, nParam1, nParam2)
end;

-- 全部魔法属性说明
-- 参数3为1表示显示的是buff的描述,不显示立即生效的属性描述
function tbDefault:GetAllMagicsDesc(tbMsg, tbInfo, bBuff)
	bBuff = bBuff or 0;
	local tbMsgTmp = {};
	for _,tbMagicGroup in ipairs(FightSkill.MAGIC_DESCS) do
		if (type(tbMagicGroup) == "table") then
			for _, tbMagicDesc in pairs(tbMagicGroup) do
				local szMagicName = tbMagicDesc[1];
				local MagicDesc = tbMagicDesc[2];
				local tbMagicPropList = self:GetMagicProp(tbInfo, szMagicName);
				if (tbMagicPropList) then
					for _, tbMagicProp in ipairs(tbMagicPropList) do
						local szMsg, nGroupId, nNum = FightSkill:GetMagicDesc(szMagicName, tbMagicProp, tbInfo);
						if (szMsg ~= "") then
							tbMsgTmp[#tbMsgTmp+1] = {nGroupId, nNum, szMsg};
						end;
					end
				end
			end
		else
			print("未分组的魔法属性");
		end
	end	
	local function _sort(a, b)
		if (a[1] ~= b[1]) then
			return a[1]<b[1];
		end
		return a[2] < b[2];
	end
	table.sort(tbMsgTmp, _sort);
	for i=1, #tbMsgTmp do
		if not((bBuff == 1) and (tbMsgTmp[i][1] == 2)) then
			tbMsg[#tbMsg+1] = tbMsgTmp[i][3]
		end
	end
end;

-- 获得一个技能中一种魔法属性的描述
function tbDefault:GetMagicProp(tbInfo, szSrcMagicName)
	local tbRet = {};
	
	local tbTotleMagic = 
	{
		tbInfo.tbWholeMagic,
	}
	for _, tbMagicList in pairs(tbTotleMagic) do
		for szMagicName, tbMagicProp in pairs(tbMagicList) do
			if (szMagicName == szSrcMagicName) then
				if (not string.find(szMagicName, "^addskilldamagep%d$") or tbMagicProp[3] == 1) then
					tbRet[#tbRet+1] = tbMagicProp;
				end
			end
		end
	end
	
	if (#tbRet > 0) then
		return  tbRet;
	end
end


-- 自动释放技能描述
function tbDefault:GetAutoDesc(tbAutoInfo, tbSkill)
	tbSkill.tbChild[#tbSkill.tbChild+1]	= {
		string.format("%s释放：<color=gold>%%s<color>", (FightSkill.AUTOTYPE_NAME[tbAutoInfo.nType] or tostring(tbAutoInfo.nType))),
		tbAutoInfo.nSkillId,
		tbAutoInfo.nSkillLevel,
	};
	return "";
end;
