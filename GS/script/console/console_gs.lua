-- 文件名　：console_gs.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-04-23 10:04:41
-- 描  述  ：--控制台

if (MODULE_GC_SERVER) then
	return 0;
end

--报名进场
function Console:ApplySignUp(nDegree, tbPlayerIdList)
	GCExcute{"Console:ApplySignUp", nDegree, tbPlayerIdList};
end

function Console:StartSignUp(nDegree)
	self:GetBase(nDegree):StartSignUp();
end

function Console:OnStartMission(nDegree)
	self:GetBase(nDegree):OnStartMission();
	return 0;
end

function Console:SignUpFail(tbPlayerList)
	for _, nPlayerId in pairs(tbPlayerList) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			pPlayer.Msg("报名参加活动的名额已满。");
			Dialog:SendBlackBoardMsg(pPlayer, "报名参加活动的名额已满")
			return 0;
		end
	end
end

function Console:SignUpSucess(nDegree, nReadyMapId, tbPlayerList)
	local tbBase = self:GetBase(nDegree);
	for _, nPlayerId in pairs(tbPlayerList) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			if tbBase:IsOpen() == 0 then
				pPlayer.Msg("前方路途不顺，无法前往活动地图，请下场再参与。");
			else
				pPlayer.NewWorld(nReadyMapId, unpack(tbBase.tbCfg.tbMap[nReadyMapId].tbInPos));
				tbBase:OnSingUpSucess(nPlayerId);
			end
		end
	end
end

function Console:OnDyJoin(nDegree, me, nDyId, tbPos, GroupId)
	local tbBase = self:GetBase(nDegree);
	tbBase:OnDyJoin(me, nDyId, tbPos, GroupId);
end

--副本申请
function Console:ApplyDyMap(nDegree, nMapId)
	local tbBase   = self:GetBase(nDegree);
	local nDyCount = tbBase.tbCfg.nMaxDynamic;
	local nDynamicMap = tbBase.tbCfg.nDynamicMap;
	local nCurCount = #tbBase.tbDynMapLists[nMapId];
	if nCurCount < nDyCount then
		for i=1, (nDyCount - nCurCount) do
			if (Map:LoadDynMap(1, nDynamicMap, {self.OnLoadMapFinish, self, nDegree, nMapId}) ~= 1) then
				print("活动副本地图加载失败。。", nDegree, nMapId);
			end
		end
	end
	return 0;
end

--比赛地图动态加载成功
function Console:OnLoadMapFinish(nDegree, nMapId, nDyMapId)
	local tbBase   = self:GetBase(nDegree);
	tbBase.tbDynMapLists[nMapId] = tbBase.tbDynMapLists[nMapId] or {};
	table.insert(tbBase.tbDynMapLists[nMapId], nDyMapId);
end
