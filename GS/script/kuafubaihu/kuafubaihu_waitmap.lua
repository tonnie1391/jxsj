-------------------------------------------------------
-- 文件名　：kuafubaihu_map.lua
-- 创建者　：zhangjunjie
-- 创建时间：2010-12-19
-- 文件描述：准备场地图的进入和离开事件
-------------------------------------------------------


Require("\\script\\kuafubaihu\\kuafubaihu_def.lua")

if not MODULE_GAMESERVER then
	return;
end


local tbMap = KuaFuBaiHu.WaitMap or {};
KuaFuBaiHu.WaitMap = tbMap;


function tbMap:OnEnter(szParam)
	if (me.GetCamp() == 6) then	-- GM阵营
		return;
	end
	if KuaFuBaiHu.nActionState == KuaFuBaiHu.APPLYSTATE then
		local tbTemp = {};
		tbTemp.nId = me.nId;
		local nUnionId = me.GetTask(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_UNION_ID);--联盟id
		local nTongId  = me.GetTask(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_TONG_ID); --获取帮会id
		local nRiches  = me.GetTask(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_RICHES); --获取财富
		local nScores = GetPlayerSportTask(me.nId,KuaFuBaiHu.GB_TASK_GID,KuaFuBaiHu.GB_TASK_SCORES) or 0;--获取积分
		local nSubScores = me.GetTask(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_MYSERVER_SCORES) or 0;
		--本服积分比跨服大，修正跨服变量为本服，防止出现负值
		if nSubScores > nScores then
			SetPlayerSportTask(me.nId,KuaFuBaiHu.GB_TASK_GID,KuaFuBaiHu.GB_TASK_SCORES, nSubScores);--获取积分
			nScores = nSubScores;
		end
		tbTemp.nCampId = ( nUnionId ~= 0 and nUnionId) or nTongId;  --如果联盟id不等于0，则阵营id为联盟id
		tbTemp.nRiches = nRiches or 0;	--获取财富
		tbTemp.nLevel  = me.nLevel;	--获取等级
		GCExcute{"KuaFuBaiHu:ReceivePlayerInfo",tbTemp};--将玩家信息同步给gc
		me.SetTask(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_OUT_FOR_DEATH,0); --是否是可进入状态死亡设置为0
		me.SetTask(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_CURRENT_GET_SCORES,0);--准备时间进入准备场地图,将当前获得积分设置为0
		me.SetTask(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_GB_TOTAL_SCORES,nScores - nSubScores);--用该变量进行累计积分统计
		---数据埋点---------------------------------------------------------------------
		local szGate = me.GetTaskStr(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_SERVER_NAME);	--服务器名
		local szTongName = me.GetTaskStr(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_TONG_NAME); --帮会名
		local nCampId = ( nUnionId ~= 0 and nUnionId) or nTongId;
		local nMapId  = me.nMapId;
		local szLogMsg = string.format("%s,%s,%d,%d,%d",szGate,szTongName,nCampId,nMapId,nRiches);
		StatLog:WriteStatLog("stat_info", "kuafubaihu","prepare", me.nId, szLogMsg);
		-------------------------------------------------------------------------------	
	end
	Dbg:WriteLogEx(2, "KuafuBaiHu","Enter Wait Map:",KuaFuBaiHu.nActionState,me.nId,me.szName);
end

function tbMap:OnEnter2(szParam)
	if (me.GetCamp() == 6) then	-- GM阵营
		return;
	end
	--每个人加上称号，统一颜色
	me.SetFightState(0);
	KuaFuBaiHu:AddPlayerTitle(me,5);
	if KuaFuBaiHu.nActionState == KuaFuBaiHu.APPLYSTATE then
		KuaFuBaiHu:ShowTimeInfo(me,KuaFuBaiHu.APPLYSTATE);
	elseif KuaFuBaiHu.nActionState == KuaFuBaiHu.FIGHTSTATE or KuaFuBaiHu.nActionState == KuaFuBaiHu.FORBIDENTER then
		KuaFuBaiHu:ShowTimeInfo(me,KuaFuBaiHu.RESTSTATE);
	elseif KuaFuBaiHu.nActionState == KuaFuBaiHu.RESTSTATE then
		KuaFuBaiHu:ShowTimeInfo(me,KuaFuBaiHu.RESTSTATE);
	end
end

function tbMap:OnLeave(szParam)
	if (me.GetCamp() == 6) then	-- GM阵营
		return;
	end
	if KuaFuBaiHu.nActionState == KuaFuBaiHu.APPLYSTATE then
		GCExcute{"KuaFuBaiHu:RemovePlayerInfo",me.nId};
	end
	--离开时去掉称号
	Dialog:ShowBattleMsg(me, 0, 0);
	KuaFuBaiHu:RemovePlayerTitle(me);
	Dbg:WriteLogEx(2, "KuafuBaiHu","Leave Wait Map:",KuaFuBaiHu.nActionState,me.nId,me.szName);
end

function KuaFuBaiHu:LinkWaitMap(nMapId)
	local tbMap = Map:GetClass(nMapId);
	for szFunMap, _ in pairs(self.WaitMap) do
		tbMap[szFunMap] = self.WaitMap[szFunMap];
	end
end

for nId,tbMap in pairs(KuaFuBaiHu.tbWaitMapIdList) do
	if tbMap then
		for _,nMapId in pairs(tbMap) do
			if nMapId then
				KuaFuBaiHu:LinkWaitMap(nMapId);
			end
		end
	end
end

