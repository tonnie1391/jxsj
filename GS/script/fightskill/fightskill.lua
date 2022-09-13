Require("\\script\\fightskill\\define.lua");

if (not FightSkill.tbClassBase) then
	FightSkill.tbClassBase	= {};
	FightSkill.tbClass	= {
		[""] 	= FightSkill.tbClassBase,
		default	= FightSkill.tbClassBase,
	};
end	

FightSkill.tbParam =
{
	nS1  = 0.7,		--90级技能1级数值同10级技能的比值
	nS20 = 1.1,		--90级技能20级数值同10级技能的比值
	nSadd = 1.05,	--攻速系技能+1的威力提升
	nSadd1 = 1.09,	--格斗系技能+1的威力提升
	nTAdd = 1.1, 	--同伴技能+1数值提升
	nS100Min  = 1,		--100级技能1级数值提升DPS比例
	nS100Max  = 10,		--100级技能10级数值提升DPS比例
	tbMidBookSkillExp = {{		--中级秘籍升级经验
		{ 1,  14175},
		{ 7,  70875},
		{ 8, 343224},
		{ 9, 756000},
	}},
	
	tbHighBookSkillExp = {{		--高级秘籍升级经验_约2.7本秘籍升到10级技能
		{ 1,  3*2*4725},
		{ 2,  5*2*4725},
		{ 3,  7*2*4725},
		{ 4,  9*2*4725},
		{ 5, 11*2*4725},
		{ 6, 13*2*4725},
		{ 7, 15*2*4725},
		{ 8, 17*4*4725},
		{ 9, 19*8*4725},
	}},
	--古墓坐骑技能修为
	tbHorseSkillExp1 = {{
		{ 1,   55},
		{10,  493},
		{20, 3439},
		{30, 8501},
		{40,10071},
		{49,32386},
	}},
	tbHorseSkillExp2 = {{
		{ 1,  5753},
		{10, 12237},
		{20, 17067},
		{30, 27871},
		{40, 58973},
		{49,103618},
	}},
	tbHorseSkillExp3 = {{
		{ 1,  8069},
		{10, 14308},
		{20, 30706},
		{30, 61307},
		{40,152862},
		{49,159961},
	}},
	
	nTitleLevel = 2, --领土头衔划分等级
	nTitleGrowValue = 30, --领土头衔抵御攻击几率成长值
	nTitleLevelPower = 1, --头衔等级乘方参数
	nTitleLevelAdjust = 8,	--头衔等级修正系数
	
	nTongBan = 70,--同伴技能3级时的能力相对于6级时的比例

}


--隐藏技能名"&"字符后的文字
function FightSkill:GetSkillName(value)
	if type(value) == "table" then
		value = value.nPoint;
	end
	value = tonumber(value)
	local szName = KFightSkill.GetSkillName(value);
	local tbTrueName = Lib:SplitStr(szName, "&");
	return tbTrueName[1];
end

--迭代函数，用于计算技能熟练度
--具体方法：
--根据1级熟练度，升级加速度，级数，重复伤害次数，范围，计算出相应等级熟练度
-- SkillExp(i) = Exp1 * a ^ (i - 1) * time * range
function FightSkill:SkillExpFunc(nExp0, nA, nLevel, nTimes, nRange)
	return math.floor(nExp0 * (nA ^ (nLevel - 1)) * nTimes * nRange / 2);
end

-- 取得特定类名的Skill类
function FightSkill:GetClass(szClassName, bNotCreate)
	local tbSkill	= self.tbClass[szClassName];
	if (not tbSkill and bNotCreate ~= 1) then
		tbSkill	= Lib:NewClass(self.tbClassBase);
		self.tbClass[szClassName] = tbSkill;
	end
	return tbSkill;
end

--供程序调用，获取指定等级技能的全部魔法属性数据
function FightSkill:GetLevelData(szSkillName, nLevel)
	assert(szSkillName and nLevel);
	local tbSkill = assert(self.tbClass[szSkillName], "[ERROR]Skill{"..tostring(szSkillName).."} not found!");
	local tbRet	= {};
	if (#tbSkill.tbMagics ~= 0) then
		for _, tbMagic in ipairs(tbSkill.tbMagics) do
			local tbData = { szName = tbMagic.szMagicName };
			if (type(tbMagic.tbValue) == "function") then
				tbData.szData = tbMagic.tbValue(nLevel);
			else
				local tbProp = {};
				for i = 1, self.MAGIC_VALUE_NUM do
					tbProp[i] = Lib.Calc:Link(nLevel, tbMagic.tbValue[i]);
				end
				tbData.szData = table.concat(tbProp, ",");
			end;
			tbRet[#tbRet + 1] = tbData;
		end
	else
		for szMagicName, tbMagicProp in pairs(tbSkill.tbMagics) do
			local tbData = { szName = szMagicName };
			if (type(tbMagicProp) == "function") then
				tbData.szData = tbMagicProp(nLevel);
			else
				local tbProp = {};
				for i = 1, self.MAGIC_VALUE_NUM do
					tbProp[i] = Lib.Calc:Link(nLevel, tbMagicProp[i]);
				end
				tbData.szData = table.concat(tbProp, ",");
			end;
			tbRet[#tbRet + 1] = tbData;
		end
	end
	
	return tbRet;
end

-- 供程序调用，技能升级
function FightSkill:OnLevelUp(szSkillName)
	local tbSkill = assert(self.tbClass[szSkillName]);
	--新手加点选路线
	if me.GetTask(1025,47) ~=1 then
		me.SetTask(1025,47,1);
	end
	return tbSkill:OnLevelUp();
end

-- 供程序调用，分析数值公式
function FightSkill:GetFormatValue(szFormat, nLevel)
	local fnData	= loadstring("return "..szFormat);
	if (not fnData) then
		error("loadstring failed!");
	end
	local tbPoint	= {fnData()};
	if (#tbPoint <= 1) then	-- 只填一个数字的情况
		local varValue	= tbPoint[1];
		if (type(varValue) == "string") then	-- 策划文档不小心出了引号
			return self:GetFormatValue(varValue, nLevel);
		elseif (type(varValue) == "number") then
			return varValue;
		else
			error("format error!");
		end
	end
	return Lib.Calc:Link(nLevel, tbPoint);
end

function FightSkill:GetPointValue(tbPoint, nLevel)
	if (#tbPoint <= 1) then	-- 只填一个数字的情况
		local varValue	= tbPoint[1];
		if (type(varValue) == "string") then	-- 策划文档不小心出了引号
			return self:GetFormatValue(varValue, nLevel);
		elseif (type(varValue) == "number") then
			return varValue;
		else
			error("format error!");
		end
	end
	return Lib.Calc:Link(nLevel, tbPoint);
end

-- 供程序调用，形成技能描述
function FightSkill:GetDesc(nSkillId, nSkillLevel, nAddPoint, nNeedNextLevel, pNpc, bNoNeedLevel)
	local tbThisInfo, tbNextInfo;
	if (nSkillLevel > 0) then
		tbThisInfo	= KFightSkill.GetSkillInfo(unpack({nSkillId, nSkillLevel, pNpc}));	-- unpack({...}) 当pNpc为空时减少一个参数
		tbThisInfo.nAddPoint= nAddPoint;
	else
		nSkillLevel	= 0;	-- 传进来的-1表示不能学习
	end
	
	if (nNeedNextLevel == 1) then
		tbNextInfo	= KFightSkill.GetSkillInfo(unpack({nSkillId, nSkillLevel + 1, pNpc}));
	end;
	
	local tbInfo = tbThisInfo or tbNextInfo;
	if (not tbInfo) then
		return "";
	end

	local szClassName = tbInfo.szClassName;
	local tbSkill = assert(self.tbClass[szClassName], "Skill{"..szClassName.."} not found!");
	local szTitleThis;
	local szMsgThis = "";
	if (tbThisInfo) then
		if bNoNeedLevel then
			szTitleThis, szMsgThis = tbSkill:GetDesc(tbThisInfo, nNeedNextLevel, 1 ,bNoNeedLevel);	
		else
			szTitleThis, szMsgThis = tbSkill:GetDesc(tbThisInfo);	
		end
	end
	
	

	if (tbThisInfo) then
			local nMaxSkillLevel = KFightSkill.GetSkillMaxLevel(tbThisInfo.nId);
			if ((nMaxSkillLevel <= tbThisInfo.nLevel) and nMaxSkillLevel ~= 0) then
				tbNextInfo = nil;
			end
	end
		
	local szTitleNext;
	local szMsgNext = "";
	if (tbNextInfo) then
		local bShowTitle = (not tbThisInfo);
		szTitleNext, szMsgNext = tbSkill:GetDesc(tbNextInfo, 1, bShowTitle);
	end
	
	local szExtraDescThis = "";
	local szExtraDescNext = "";

	if (tbSkill.GetExtraDesc) then
		szExtraDescThis = tbSkill:GetExtraDesc(tbThisInfo);
		szExtraDescNext = tbSkill:GetExtraDesc(tbNextInfo);
	end
	
	if (szExtraDescThis ~= "") then
		szMsgThis = szMsgThis..szExtraDescThis.."\n";	
	end
	if (szExtraDescNext ~= "") then
		szMsgNext = szMsgNext..szExtraDescNext.."\n";
	end
	
	local szTitle = szTitleThis or szTitleNext;
	if (szMsgThis ~= "") then
		szMsgThis = "\n"..szMsgThis;
	end
	if (szMsgNext ~= "") then
		szMsgNext = "\n"..szMsgNext;
	end
	
	return szTitle, szMsgThis..szMsgNext;
end

-- 供程序调用，形成状态描述 请勿在脚本中调用于物品的描述！！！
function FightSkill:GetStateTip(nStateId, nSkillId, nSkillLevel, szMsg, bBuff, nStateType, nLeftTime, nTotalTime)
	return self.tbState:GetTip(nStateId, nSkillId, nSkillLevel, szMsg, bBuff, nStateType, nLeftTime, nTotalTime);
end

function FightSkill:AddMagicData(tbMagicDatas)
	
	for szSkillName, tbMagics in pairs(tbMagicDatas) do
		self:GetClass(szSkillName).tbMagics	= tbMagics;
	end
end

function FightSkill:OnLogIn_Anger(bExchangeServer)
	if (bExchangeServer == 1) then
		return;
	end
	local nTskGroup = 2014;
	local nTskId	= 1;
	me.SetTask(nTskGroup, nTskId, 0);
end

function FightSkill:Frame2Sec(value)
	return math.floor(value / Env.GAME_FPS * 10) / 10;
end

--毒伤时间转化为次数
function FightSkill:Frame2Times(value)
	return math.floor(value *2 / Env.GAME_FPS ) + 1;
end

function FightSkill:GetConflictingSkillList(nSkillId)
	return FightSkill.tbStateReplaceRegular:GetConflictingSkillList(nSkillId);
end

function FightSkill:GetStateGroupReplaceType(nSkillId)
	return FightSkill.tbStateReplaceRegular:GetStateGroupReplaceType(nSkillId);
end

function FightSkill:ReloadFile()
	SendChannelMsg("GM", "?pl KFightSkill.ReloadFile(me)");
	KFightSkill.ReloadFile(me);
end

function FightSkill:ClearCDTime()
	SendChannelMsg("GM", "?pl KFightSkill.ClearCDTime(me)");
	KFightSkill.ClearCDTime(me);
end

function FightSkill:CheckCanAddSkillPoint(pNpc, nSkillId)
	if (not pNpc) then
		return 0;
	end;
	
	local pPlayer 	= nil;
	
	if MODULE_GAMESERVER then
		pPlayer 	= pNpc.GetPlayer();
	else
		pPlayer 	= me; 
	end;
	
	if (not pPlayer) then
		return 0;
	end;
	
	-- 无门派的人可以加
	if (pPlayer.nFaction < 1) then
		return 1;
	end;
	
	-- 检测110技能
	if (pPlayer.nFaction ~= 13) then
		-- if (pPlayer.nFaction == 1) or (pPlayer.nFaction == 2) or (pPlayer.nFaction == 3) then
			-- if (nSkillId == Player.tbFactions[pPlayer.nFaction].tbRoutes[1].tbSkills[11].nId or 
				-- nSkillId == Player.tbFactions[pPlayer.nFaction].tbRoutes[2].tbSkills[11].nId or 
				-- nSkillId == Player.tbFactions[pPlayer.nFaction].tbRoutes[3].tbSkills[11].nId) then
				
				-- local nTaskGroup 	= 1022;
				-- local nTaskId		= 215;
				-- local nValue 		= pPlayer.GetTask(nTaskGroup, nTaskId);
			
				-- if (KLib.GetBit(nValue, pPlayer.nFaction) ~= 1) then
					-- return 0;
				-- end;	
			-- end;
		-- else
			if (nSkillId == Player.tbFactions[pPlayer.nFaction].tbRoutes[1].tbSkills[11].nId or 
				nSkillId == Player.tbFactions[pPlayer.nFaction].tbRoutes[2].tbSkills[11].nId) then
				
				local nTaskGroup 	= 1022;
				local nTaskId		= 215;
				local nValue 		= pPlayer.GetTask(nTaskGroup, nTaskId);

				if (KLib.GetBit(nValue, pPlayer.nFaction) ~= 1) then
					return 0;
				end;	
			end;
		-- end
	end
	return 1;
end;
	
--物品TIP用	
function FightSkill:GetSkillItemTip(nSkillId, nLevel)
	local szTip = "";
	local tbInfo = KFightSkill.GetSkillInfo(nSkillId, nLevel);
	local tbMsg = {};
	local tbDefault = FightSkill:GetClass("default");
	tbDefault:GetDescAboutLevel(tbMsg, tbInfo);
	szTip = szTip .. table.concat(tbMsg, "\n").."\n";
	szTip = string.gsub(szTip, "<color=white>Thời gian duy trì: <color><color=gold>%d*.*%d*秒<color>\n", "");
	
    return Lib:StrTrim(szTip, "\n");
end;
----------------------------------------------------------
-- 定时同步伤害，用于测试
function FightSkill:DamageAccount(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end;
	pPlayer.CallClientScript({"Ui:ServerCall", "UI_DAMAGETEST", "OpenWindow"});	
end;


function FightSkill:StartDamageAccount(nPlayerId)
	if MODULE_GAMECLIENT then
		return;
	end;
	
	self.tbDamageAccountPlayer = self.tbDamageAccountPlayer or {};
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end;
	print("start")
	pPlayer.StartDamageCounter();
	self.tbDamageAccountPlayer[nPlayerId] = 1;
	
	if (not self.nDATimer) then 
		self.nDATimer	= Timer:Register(Env.GAME_FPS * 5, self.DABreathe, self);
	end;
end;

function FightSkill:DABreathe()
	if MODULE_GAMECLIENT then
		return;
	end;
	
	local nLength = 0; 
	for nId, _ in pairs(self.tbDamageAccountPlayer) do
		nLength = nLength + 1;
	end;
	
	if (nLength == 0) then
		Timer:Close(self.nDATimer);
		self.nDATimer = nil;
		return;
	end;

	for nId, _ in pairs(self.tbDamageAccountPlayer) do
		local pPlayer = KPlayer.GetPlayerObjById(nId);
		if (not pPlayer) then
			self.tbDamageAccountPlayer[nId] = nil;
			return;
		end;
	
		local nDamage = pPlayer.GetDamageCounter();
		print("RefreshMsg", nDamage);
		pPlayer.CallClientScript({"Ui:ServerCall", "UI_DAMAGETEST", "RefreshMsg", nDamage, 0});
	end;
end;

function FightSkill:EndDamageAccount(nPlayerId)
	if MODULE_GAMECLIENT then
		return;
	end;
	
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		self.tbDamageAccountPlayer[nPlayerId] = nil;
		return;
	end;
	self.tbDamageAccountPlayer[nPlayerId] = nil;
	pPlayer.StopDamageCounter();
	
	local nLength = 0; 
	for nId, _ in pairs(self.tbDamageAccountPlayer) do
		nLength = nLength + 1;
	end;
	
	if nLength == 0 then
		if (self.nDATimer) then
			print("Close");
			Timer:Close(self.nDATimer);
			self.nDATimer = nil;
		end;
	end;
end;

function FightSkill:OnLogIn_Check(bExchangeServer)
	Player:RegisterTimer(1 * Env.GAME_FPS, self.Check_RealTime, self);
end

------------------------------------------
function FightSkill:Check_RealTime()
	-----------CHECK MÁU-----------
	local nMaxCount = me.GetBagCellCount();
	
	local tbFind = me.FindClassItemInBags("localmedicine");
	Lib:MergeTable(tbFind, me.FindClassItemInBags("fulimedicine"));
	
	local nCurCount = 0;
	for _, tbItem in pairs (tbFind) do
		nCurCount = nCurCount + tbItem.pItem.nCount;
	end
	
	if nCurCount > nMaxCount then
		tbFind[1].pItem.Delete(me);
	end
	-- local szMsg = "<color=red>"..me.szName.." <color> bug trang bị pet. Bị cho lên đảo vĩnh viễn";
    -- local pItem1 = me.GetItem(Item.ROOM_PARTNEREQUIP, Item.PARTNEREQUIP_WEAPON, 0);
	-- if pItem1 then
		-- if pItem1.szName == "Bích Huyết Chi Nhẫn" or pItem1.szName == "Kim Lân Chi Nhẫn" or pItem1.szName == "Đơn Tâm Chi Nhẫn" or pItem1.szName == "Hào Hiệp Chi Nhẫn" then
			-- local tbItemList = me.FindItemInBags(pItem1.nGenre, pItem1.nDetail, pItem1.nParticular, pItem1.nLevel);
			-- for _, tbItemInfo in pairs (tbItemList) do
				-- local pItem = tbItemInfo.pItem;
				-- pItem.Delete(me);
			-- end
		-- else
			-- if GetMapType(me.nMapId) ~= "taoyuanrukou" then
				-- KDialog.NewsMsg(0, Env.NEWSMSG_COUNT, szMsg);
				-- Player:Arrest(me.szName);
			-- end
		-- end
	-- end
	
	-- local pItem2 = me.GetItem(Item.ROOM_PARTNEREQUIP, Item.PARTNEREQUIP_BODY, 0);
	-- if pItem2 then
		-- if pItem2.szName == "Bích Huyết Chiến Y" or pItem2.szName == "Kim Lân Chiến Y" or pItem2.szName == "Đơn Tâm Chiến Y" or pItem2.szName == "Hào Hiệp Chiến Y" then
			-- local tbItemList = me.FindItemInBags(pItem2.nGenre, pItem2.nDetail, pItem2.nParticular, pItem2.nLevel);
			-- for _, tbItemInfo in pairs (tbItemList) do
				-- local pItem = tbItemInfo.pItem;
				-- pItem.Delete(me);
			-- end
		-- else
			-- if GetMapType(me.nMapId) ~= "taoyuanrukou" then
				-- KDialog.NewsMsg(0, Env.NEWSMSG_COUNT, szMsg);
				-- Player:Arrest(me.szName);
			-- end
		-- end
	-- end
	
	-- local pItem3 = me.GetItem(Item.ROOM_PARTNEREQUIP, Item.PARTNEREQUIP_RING, 0);
	-- if pItem3 then
		-- if pItem3.szName == "Bích Huyết Giới Chỉ" or pItem3.szName == "Kim Lân Chi Giới" or pItem3.szName == "Đơn Tâm Chi Giới" or pItem3.szName == "Hào Hiệp Chi Giới" then
			-- local tbItemList = me.FindItemInBags(pItem3.nGenre, pItem3.nDetail, pItem3.nParticular, pItem3.nLevel);
			-- for _, tbItemInfo in pairs (tbItemList) do
				-- local pItem = tbItemInfo.pItem;
				-- pItem.Delete(me);
			-- end
		-- else
			-- if GetMapType(me.nMapId) ~= "taoyuanrukou" then
				-- KDialog.NewsMsg(0, Env.NEWSMSG_COUNT, szMsg);
				-- Player:Arrest(me.szName);
			-- end
		-- end
	-- end
	
	-- local pItem4 = me.GetItem(Item.ROOM_PARTNEREQUIP, Item.PARTNEREQUIP_CUFF, 0);
	-- if pItem4 then
		-- if pItem4.szName == "Bích Huyết Hộ Uyển" or pItem4.szName == "Kim Lân Hộ Uyển" or pItem4.szName == "Đơn Tâm Hộ Uyển" or pItem4.szName == "Hào Hiệp Hộ Uyển" then
			-- local tbItemList = me.FindItemInBags(pItem4.nGenre, pItem4.nDetail, pItem4.nParticular, pItem4.nLevel);
			-- for _, tbItemInfo in pairs (tbItemList) do
				-- local pItem = tbItemInfo.pItem;
				-- pItem.Delete(me);
			-- end
		-- else
			-- if GetMapType(me.nMapId) ~= "taoyuanrukou" then
				-- KDialog.NewsMsg(0, Env.NEWSMSG_COUNT, szMsg);
				-- Player:Arrest(me.szName);
			-- end
		-- end
	-- end
	
	-- local pItem5 = me.GetItem(Item.ROOM_PARTNEREQUIP, Item.PARTNEREQUIP_AMULET, 0);
	-- if pItem5 then
		-- if pItem5.szName == "Bích Huyết Hộ Thân Phù" or pItem5.szName == "Kim Lân Hộ Thân Phù" or pItem5.szName == "Đơn Tâm Hộ Thân Phù" or pItem5.szName == "Hào Hiệp Hộ Thân Phù" then
			-- local tbItemList = me.FindItemInBags(pItem5.nGenre, pItem5.nDetail, pItem5.nParticular, pItem5.nLevel);
			-- for _, tbItemInfo in pairs (tbItemList) do
				-- local pItem = tbItemInfo.pItem;
				-- pItem.Delete(me);
			-- end
		-- else
			-- if GetMapType(me.nMapId) ~= "taoyuanrukou" then
				-- KDialog.NewsMsg(0, Env.NEWSMSG_COUNT, szMsg);
				-- Player:Arrest(me.szName);
			-- end
		-- end
	-- end
	
	-- local pItem11 = me.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_BODY, 0);--áo lên áo
	-- if pItem11 then
		-- if pItem11.szName == "Bích Huyết Chiến Y" or pItem11.szName == "Kim Lân Chiến Y" or pItem11.szName == "Đơn Tâm Chiến Y" or pItem11.szName == "Hào Hiệp Chiến Y" then
			-- if GetMapType(me.nMapId) ~= "taoyuanrukou" then
				-- KDialog.NewsMsg(0, Env.NEWSMSG_COUNT, szMsg);
				-- Player:Arrest(me.szName);
			-- end
		-- end
	-- end
    -- local pItem21 = me.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_BELT, 0);---nhẫn lên lưng
	-- if pItem21 then
		-- if pItem21.szName == "Bích Huyết Giới Chỉ" or pItem21.szName == "Kim Lân Chi Giới" or pItem21.szName == "Đơn Tâm Chi Giới" or pItem21.szName == "Hào Hiệp Chi Giới" then
			-- if GetMapType(me.nMapId) ~= "taoyuanrukou" then
				-- KDialog.NewsMsg(0, Env.NEWSMSG_COUNT, szMsg);
				-- Player:Arrest(me.szName);
			-- end	
		-- end
	-- end
	-- local pItem31 = me.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_HEAD, 0);--vũ khí lên mũ
	-- if pItem31 then
		-- if pItem31.szName == "Bích Huyết Chi Nhẫn" or pItem31.szName == "Kim Lân Chi Nhẫn" or pItem31.szName == "Đơn Tâm Chi Nhẫn" or pItem31.szName == "Hào Hiệp Chi Nhẫn" then
			-- if GetMapType(me.nMapId) ~= "taoyuanrukou" then
				-- KDialog.NewsMsg(0, Env.NEWSMSG_COUNT, szMsg);
				-- Player:Arrest(me.szName);
			-- end
		-- end
	-- end
	-- local pItem41 = me.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_WEAPON, 0);--hộ uyển lên vũ khí
	-- if pItem41 then
		-- if pItem41.szName == "Bích Huyết Hộ Uyển" or pItem41.szName == "Kim Lân Hộ Uyển" or pItem41.szName == "Đơn Tâm Hộ Uyển" or pItem41.szName == "Hào Hiệp Hộ Uyển" then
			-- if GetMapType(me.nMapId) ~= "taoyuanrukou" then
				-- KDialog.NewsMsg(0, Env.NEWSMSG_COUNT, szMsg);
				-- Player:Arrest(me.szName);
			-- end
		-- end
	-- end
	-- local pItem51 = me.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_FOOT, 0);---hộ thân phù lên giày
	-- if pItem51 then
		-- if pItem51.szName == "Bích Huyết Hộ Thân Phù" or pItem51.szName == "Kim Lân Hộ Thân Phù" or pItem51.szName == "Đơn Tâm Hộ Thân Phù" or pItem51.szName == "Hào Hiệp Hộ Thân Phù" then
			-- if GetMapType(me.nMapId) ~= "taoyuanrukou" then
				-- KDialog.NewsMsg(0, Env.NEWSMSG_COUNT, szMsg);
				-- Player:Arrest(me.szName);
			-- end
		-- end
	-- end

end

----------------------------------------------------------

PlayerEvent:RegisterGlobal("OnLogin", FightSkill.OnLogIn_Anger, FightSkill);
PlayerEvent:RegisterGlobal("OnLogin", FightSkill.OnLogIn_Check, FightSkill);
