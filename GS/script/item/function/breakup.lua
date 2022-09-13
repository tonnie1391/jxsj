
-- 装备，拆解功能脚本

------------------------------------------------------------------------------------------
-- initialize

local STUFF1_DETAIL_INDEX  		= 1;
local STUFF1_PARTICULAR_INDEX	= 2;
local STUFF2_DETAIL_INDEX  		= 3;
local STUFF2_PARTICULAR_INDEX	= 4;
local LIFESKILL_ID				= 11;		-- 装备拆解所对应的生活技能ID

------------------------------------------------------------------------------------------
-- private

local function CheckEquip(pEquip)		-- 服务端检查装备的合法性
	if (not pEquip) or (pEquip.nGenre ~= Item.EQUIP_GENERAL) then
		return 0;						-- 非一般装备不能拆解
	end
	if (pEquip.nDetail < Item.MIN_COMMON_EQUIP) or (pEquip.nDetail > Item.MAX_COMMON_EQUIP) then
		return 0;						-- 只有参与五行激获的装备才能拆解
	end
	if (pEquip.nEnhTimes > 0) or (pEquip.IsBind() == 1) then
		return 0;						-- 已被强化过或已绑定装备不能拆解
	end
	return 1;
end

local function CalcLifeSkillExp(tbStuff)	-- 根据材料计算增加的加工系生活技能经验
	local tbExp = {};
	for _, tb in ipairs(tbStuff) do
		local nRecipeId = 0;
		for nId, tbRecipe in ipairs(LifeSkill.tbRecipeDatas) do
			for _, v in ipairs(tbRecipe.tbProductSet) do
				local tbItem = v.tbItem;
				if (tb.nGenre == tbItem[1]) and (tb.nDetail == tbItem[2]) and (tb.nParticular == tbItem[3]) and
				(tb.nLevel == tbItem[4]) and (tb.nSeries == tbItem[6]) then
					nRecipeId = nId;		-- 找到对应的材料配方
					break;
				end
			end
			if (nRecipeId > 0) then
				break;
			end
		end
		if (nRecipeId > 0) then
			local nSkillId 	  = LifeSkill:GetBelongSkillId(nRecipeId);	-- 材料对应加工系生活技能ID
			local nExp	   	  = tb.nValue * tb.nCount;					-- 计算增加经验（与价值量比例1:1）
			local tbSkill 	  = LifeSkill.tbLifeSkillDatas[nSkillId];
			local szSkillName = tbSkill and tbSkill.Name or "";			-- 加工系生活技能名称
			local bMerge      = 0;
			for _, v in ipairs(tbExp) do
				if (v.nSkillId == nSkillId) then
					v.nExp = v.nExp + nExp;
					bMerge  = 1;
					break;
				end
			end
			if (bMerge ~= 1) then
				table.insert(tbExp, { nSkillId = nSkillId, nExp = nExp, szSkillName = szSkillName });
			end
		end
	end
	return tbExp;
end

------------------------------------------------------------------------------------------
-- public

function Item:CalcBreakUpStuff(pEquip)		-- 计算拆解成品及活力消耗，客户端与服务端共用

	if CheckEquip(pEquip) ~= 1 then
		return 0;
	end

	local nLevel 		= pEquip.nLevel;
	local nStuffCount 	= 0;
	local tbStuff		= {};
	local tbStuffInfo	= {};
	local tbParam 		=
	{
		{ pEquip.GetExtParam(STUFF1_DETAIL_INDEX), pEquip.GetExtParam(STUFF1_PARTICULAR_INDEX) },
		{ pEquip.GetExtParam(STUFF2_DETAIL_INDEX), pEquip.GetExtParam(STUFF2_PARTICULAR_INDEX) },
	};

	for i, v in ipairs(tbParam) do
		if (v[1] > 0) and (v[2] > 0) then
			local tb = {};
			tb.nGenre		= Item.STUFFITEM;
			tb.nDetail		= v[1];
			tb.nParticular	= v[2];
			tb.nCount		= 0;
			tb.bBind		= 0;
			table.insert(tbStuffInfo, tb);
		end
	end

	if #tbStuffInfo <= 0 then
		return 0;				-- 该类装备没有可拆解的材料
	end

	local nEquipValue = math.floor(pEquip.nValue * 0.8);

	while (#tbStuff < 2) and (nLevel > 0) do

		local tbSort = {};
		local nCurLevel = nLevel;
		for i, v in ipairs(tbStuffInfo) do
			local tbBaseProp = KItem.GetItemBaseProp(v.nGenre, v.nDetail, v.nParticular, nCurLevel);
			if tbBaseProp and tbBaseProp.nValue > 0 then
				v.nLevel = nCurLevel;
				v.nValue = tbBaseProp.nValue;
				table.insert(tbSort, v);
			end
			nCurLevel = nCurLevel - 1;
		end

		table.sort(tbSort, function(tbL, tbR) return tbL.nValue > tbR.nValue end);	-- 按材料价值量降排序

		for i, v in ipairs(tbSort) do
			local nCount = math.floor(nEquipValue / v.nValue);
			if (nCount > 0) then
				nEquipValue = nEquipValue - nCount * v.nValue;
				-- 找到合适的材料，记录
				local tb = {};
				tb.nGenre		= v.nGenre;
				tb.nDetail		= v.nDetail;
				tb.nParticular	= v.nParticular;
				tb.nLevel		= v.nLevel;
				tb.nSeries		= Env.SERIES_NONE;
				tb.nValue		= v.nValue;
				tb.nCount		= nCount;
				tb.bBind		= 0;
				table.insert(tbStuff, tb);
				if (#tbStuff >= 2) then
					break;
				end
			end
		end

		nLevel = nLevel - 1;	-- 递减材料级别，寻找合适的生成物

	end

	local nGTPCost = math.floor(math.floor(pEquip.nValue * 0.4) * 0.1);
	if nGTPCost < 1 then
		nGTPCost = 1;		-- 至少损耗1点活力
	end

	return nGTPCost, tbStuff, CalcLifeSkillExp(tbStuff);

end

function Item:BreakUp(pEquip)			-- 程序接口：服务端执行装备拆解

	if me.HasLearnLifeSkill(LIFESKILL_ID) ~= 1 then
		return 0;
	end
	
	if me.IsAccountLock() ~= 0 then
		me.Msg("你的账号正在锁定状态，不能执行该操作！");
		Account:OpenLockWindow(me);
		return;
	end
	if Account:Account2CheckIsUse(me, 7) == 0 then
		me.Msg("你正在使用副密码登陆游戏，设置了权限控制，无法进行该操作！");
		return 0;
	end
	if (me.nFightState > 0) then
		me.Msg("战斗状态下不能使用生活技能。");
		return 0;
	end

	if (me.GetNpc().nDoing ~= Npc.DO_STAND) then
		me.Msg("只有在伫立状态才能使用生活技能。");
		return 0;
	end

	local nGTP, tbStuff, tbExp = Item:CalcBreakUpStuff(pEquip);
	if (nGTP <= 0) or (#tbStuff <= 0) then
		return 0;		-- 不能拆解
	end

	if (me.dwCurGTP < nGTP) or (me.CanAddItemIntoBag(unpack(tbStuff)) ~= 1) then
		return 0;			-- 活力之不足或者背包格子不够
	end

	if (me.DelItem(pEquip, Player.emKLOSEITEM_BREAKUP) ~= 1) then
		return 0;			-- 删除装备失败
	end

	me.ChangeCurGatherPoint(-nGTP);		-- 扣除活力

	-- 生成材料
	for _, tb in ipairs(tbStuff) do
		for i = 1, tb.nCount do
			me.AddStuffItem(tb.nDetail, tb.nParticular, tb.nLevel, tb.nSeries, 0, Player.emKLOSEITEM_BREAKUP);	-- TODO: xyf 该方法效率低
		end
	end

	-- 增加生活技能经验
	for _, tb in ipairs(tbExp) do
		me.AddLifeSkillExp(tb.nSkillId, tb.nExp);
	end

	return 1;

end
