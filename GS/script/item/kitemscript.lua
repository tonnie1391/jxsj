
if MODULE_GC_SERVER then
	return
end
-------------------------------------------------------------------------------
-- for both server & client

-------------------------------------------------------------------------------
-- for server

-- 给指定角色增加一个普通装备
function KItem.AddPlayerGeneralEquip(pPlayer, nDetail, nParticular, nLevel, nSeries, nEnhTimes, nLucky, nVersion, uRandSeed, nWay)

	return	KItem.AddPlayerItem(
		pPlayer,
		Item.EQUIP_GENERAL,
		nDetail,
		nParticular,
		nLevel,
		nSeries or Env.SERIES_NONE,
		nEnhTimes or 0,
		nLucky or 0,
		nil,nil,
		nVersion or 0,
		uRandSeed or 0,
		0,0,1,
		nWay or 100
	);

end

-- 给指定角色增加一个黄金装备
function KItem.AddPlayerGoldEquip(pPlayer, nDetail, nParticular, nLevel, nSeries, nEnhTimes, nVersion, nWay)

	return	KItem.AddPlayerItem(
		pPlayer,
		Item.EQUIP_GOLD,
		nDetail,
		nParticular,
		nLevel,
		nSeries or Env.SERIES_NONE,
		nEnhTimes or 0,
		0,
		nil,nil,
		nVersion or 0,
		0,0,0,1,
		nWay or 100
	);

end

-- 给指定角色增加一个绿色装备
function KItem.AddPlayerGreenEquip(pPlayer, nDetail, nParticular, nLevel, nSeries, nEnhTimes, nVersion, nWay)

	return	KItem.AddPlayerItem(
		pPlayer,
		Item.EQUIP_GREEN,
		nDetail,
		nParticular,
		nLevel,
		nSeries or Env.SERIES_NONE,
		nEnhTimes or 0,
		0,
		nil,nil,
		nVersion or 0,
		0,0,0,1,
		nWay or 100
	);

end

-- 给指定角色增加一个药品
function KItem.AddPlayerMedicine(pPlayer, nDetail, nParticular, nLevel, nSeries, nVersion, nWay)

	return	KItem.AddPlayerItem(
		pPlayer,
		Item.MEDICINE,
		nDetail,
		nParticular,
		nLevel,
		nSeries or Env.SERIES_NONE,
		0,
		0,
		nil,nil,
		nVersion or 0,
		0,0,0,1,
		nWay or 100
	);

end

-- 给指定角色增加一个脚本道具
function KItem.AddPlayerScriptItem(pPlayer, nDetail, nParticular, nLevel, nSeries, tbGenInfo, nVersion, nWay)

	return	KItem.AddPlayerItem(
		pPlayer,
		Item.SCRIPTITEM,
		nDetail,
		nParticular,
		nLevel,
		nSeries or Env.SERIES_NONE,
		0,
		0,
		tbGenInfo,nil,
		nVersion or 0,
		0,0,0,1,
		nWay or 100
	);

end

-- 给指定角色增加一个技能道具
function KItem.AddPlayerSkillItem(pPlayer, nDetail, nParticular, nLevel, nSeries, nVersion, nWay)

	return	KItem.AddPlayerItem(
		pPlayer,
		Item.SKILLITEM,
		nDetail,
		nParticular,
		nLevel,
		nSeries or Env.SERIES_NONE,
		0,
		0,
		nil,nil,
		nVersion or 0,
		0,0,0,1,
		nWay or 100
	);

end

-- 给指定角色增加一个任务道具
function KItem.AddPlayerQuest(pPlayer, nDetail, nParticular, nLevel, nSeries, tbGenInfo, nVersion, nWay)

	return	KItem.AddPlayerItem(
		pPlayer,
		Item.TASKQUEST,
		nDetail,
		nParticular,
		nLevel,
		nSeries or Env.SERIES_NONE,
		0,
		0,
		tbGenInfo,nil,
		nVersion or 0,
		0,0,0,1,
		nWay or 100
	);

end

-- 给指定角色增加一个扩展背包
function KItem.AddPlayerExtBag(pPlayer, nDetail, nParticular, nVersion, nWay)

	return	KItem.AddPlayerItem(
		pPlayer,
		Item.EXTBAG,
		nDetail,
		nParticular,
		1,
		0,
		Env.SERIES_NONE,
		0,
		nil,nil,
		nVersion or 0,
		0,0,0,1,
		nWay or 100
	);

end

-- 给指定角色增加一个生活技能材料
function KItem.AddPlayerStuffItem(pPlayer, nDetail, nParticular, nLevel, nSeries, nVersion, nWay)

	return	KItem.AddPlayerItem(
		pPlayer,
		Item.STUFFITEM,
		nDetail,
		nParticular,
		nLevel,
		0,
		nSeries or Env.SERIES_NONE,
		0,
		nil,nil,
		nVersion or 0,
		0,0,0,1,
		nWay or 100
	);

end

-- 给指定角色增加一个生活技能配方
function KItem.AddPlayerPlanItem(pPlayer, nDetail, nParticular, nLevel, nSeries, nVersion, nWay)

	return	KItem.AddPlayerItem(
		pPlayer,
		Item.PLANITEM,
		nDetail,
		nParticular,
		nLevel,
		0,
		nSeries or Env.SERIES_NONE,
		0,
		nil,nil,
		nVersion or 0,
		0,0,0,1,
		nWay or 100
	);

end

-- tbItemInfo =
--{
--		nSeries or Env.SERIES_NONE,		五行，默认无
--		nEnhTimes or 0,					强化次数，默认0
--		nLucky or 0,					幸运
--		tbGenInfo,						
--		tbRandomInfo, 					装备随机品质
--		nVersion or 0,					
--		uRandSeed or 0,					随机种子
--		bForceBind,						强制绑定默认0
--		bTimeOut,						是否会超时（有时限）
-- 		bMsg,							是否消息通知
--}	
-- 获得该道具需要多少格背包空间
function KItem.GetNeedFreeBag(nGenre, nDetail, nParticular, nLevel, tbItemInfo, nCount)
	if tbItemInfo and (tonumber(tbItemInfo.bTimeOut) or 0) > 0 then
		return nCount or 0;
	end
	nCount 		= tonumber(nCount) or 0;
	nGenre 		= tonumber(nGenre) or 0;
	nDetail 	= tonumber(nDetail) or 0;
	nParticular = tonumber(nParticular) or 0;
	nLevel 		= tonumber(nLevel) or 0;
	if nGenre <= 0 or nDetail <= 0 or nParticular <= 0 or nLevel <= 0 then
		return 0;
	end

	local tbProp = KItem.GetEquipBaseProp(nGenre, nDetail, nParticular, nLevel);
	if (tbProp) then -- 判断是否是装备
		return 1;
	end

	tbProp = KItem.GetOtherBaseProp(nGenre, nDetail, nParticular, nLevel);
	if not tbProp then
		return 0;
	end
	local nStackMax = tonumber(tbProp.nStackMax) or 1;
	local nNeedFree = math.ceil(nCount/nStackMax);
	return nNeedFree;
end
-------------------------------------------------------------------------------
-- for client
