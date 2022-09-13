-- 文件名　：kuafubaihu_item.lua
-- 创建者　：zhangjunjie
-- 创建时间：2010-12-22 21:40:49
-- 描述：跨服白虎的道具

Require("\\script\\kuafubaihu\\kuafubaihu_def.lua")

--------------------名录残页---------------------
local tbCanYe = Item:GetClass("kuafubaihu_canye");

function tbCanYe:PickUp()
	local pItem = it;
	pItem.Bind(1);
	local nRegionScores = me.GetTask(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_GB_TOTAL_SCORES);
	local nNewScores = nRegionScores + KuaFuBaiHu.nScoreAddByCanYe;
	local nScoresGet	= me.GetTask(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_CURRENT_GET_SCORES) or 0;
	me.SetTask(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_CURRENT_GET_SCORES,nScoresGet + KuaFuBaiHu.nScoreAddByCanYe); 
	me.SetTask(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_GB_TOTAL_SCORES,nNewScores);
	KuaFuBaiHu:ChangeScoresShow(me);--积分更新
	---通知玩家----------------
	me.Msg("您获得了"..it.szName .. ",获得了" .. tostring(KuaFuBaiHu.nScoreAddByCanYe) .. "积分","系统提示");
	return 1;
end

function tbCanYe:IsPickable(szClassName, nObjId)
	if (me.GetCamp() == 6) then	-- GM阵营
		return 0;
	else
		return 1;
	end
end

-------------名录残卷-----------------------

local tbCanJuan = Item:GetClass("kuafubaihu_canjuan");

function tbCanJuan :PickUp()
	local pItem = it;
	pItem.Bind(1);
	local nRegionScores = me.GetTask(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_GB_TOTAL_SCORES);
	local nNewScores = nRegionScores + KuaFuBaiHu.nScoreAddByCanJuan;
	local nScoresGet	= me.GetTask(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_CURRENT_GET_SCORES) or 0;
	me.SetTask(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_CURRENT_GET_SCORES,nScoresGet + KuaFuBaiHu.nScoreAddByCanJuan);
	me.SetTask(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_GB_TOTAL_SCORES,nNewScores);
	KuaFuBaiHu:ChangeScoresShow(me);--积分更新
	---通知玩家----------------
	me.Msg("您获得了"..it.szName .. ",获得了" .. tostring(KuaFuBaiHu.nScoreAddByCanJuan) .. "积分","系统提示");
	return 1;
end


function tbCanJuan:IsPickable(szClassName, nObjId)
	if (me.GetCamp() == 6) then	-- GM阵营
		return 0;
	else
		return 1;
	end
end





