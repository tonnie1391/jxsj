-- 文件名　：leaguemacth.lua
-- 创建者　：jiazhenwei
-- 创建时间：2009-10-14
-- 描  述  ：地图进入离开事件相关

if (MODULE_GAMECLIENT) then
	return;
end
--准备场
DaTaoSha.MACTH_TO_MAP = 
{
	{1653,1654},1833,
}

local tbMap = {};

-- 定义玩家进入事件
function tbMap:OnEnter()
	--记录快捷键
	--me.SetTask(DaTaoSha.TASKID_GROUP, DaTaoSha.TASKID_SHORTCUT1, me.GetTask(Item.TSKGID_SHORTCUTBAR, Item.TSKID_SHORTCUTBAR_FLAG));
	--me.SetTask(DaTaoSha.TASKID_GROUP, DaTaoSha.TASKID_SHORTCUT2, me.GetTask(FightSkill.TSKGID_LEFT_RIGHT_SKILL, FightSkill.TSKID_LEFT_RIGHT_SKILL));
	local nFlag_ShotCut = GetPlayerSportTask(me.nId,DaTaoSha.GBTSKG_DATAOSHA, DaTaoSha.GBTASKID_SHOTCUT) or 0;
	SetPlayerSportTask(me.nId,DaTaoSha.GBTSKG_DATAOSHA, DaTaoSha.GBTASKID_SHOTCUT, nFlag_ShotCut + 1);
	DaTaoSha:ClearPlayer(me, DaTaoSha.DEF_MAXLEVEL[DaTaoSha.WaitMapMemList[me.nMapId].nLevel]);
	DaTaoSha.WaitMapMemList[me.nMapId].tbRange = DaTaoSha.WaitMapMemList[me.nMapId].tbRange or {};
	DaTaoSha.WaitMapMemList[me.nMapId].tbRange[me.nId] =  (DaTaoSha.WaitMapMemList[me.nMapId].nCount or 0) + 1;
	local nGroupId = me.GetTask(DaTaoSha.TASKID_GROUP, DaTaoSha.TASKID_GROUPID);
	local szMsg = "Di tích Hàn Vũ đang chuẩn bị...";
	DaTaoSha:OpenSingleUi(me, szMsg);
	Dialog:SendBattleMsg(me, "");
	--设置状态
	me.ClearSpecialState()		--清除特殊状态
	me.RemoveSkillStateWithoutKind(Player.emKNPCFIGHTSKILLKIND_CLEARDWHENENTERBATTLE) --清除状态
	me.DisableChangeCurCamp(1);	--设置与帮会有关的变量，不允许在竞技场战改变某个帮会阵营的操作
	me.SetFightState(0);	  	--设置战斗状态
	me.ForbidEnmity(1);		--禁止仇杀
	me.DisabledStall(1);		--摆摊
	me.ForbitTrade(1);		--交易
	me.nPkModel = Player.emKPK_STATE_PRACTISE;	
	me.nForbidChangePK	= 1;
	me.LeaveTeam();
	me.TeamDisable(1);			--禁止组队	
	local szMsg1 = string.format("Khi nào có đủ <color=yellow>%s<color> người, trận chiến sẽ bắt đầu",DaTaoSha.PLAYER_NUMBER);
	Dialog:SendBlackBoardMsg(me, szMsg1);
	GlobalExcute{"DaTaoSha:CreaseNum", me.nMapId, nGroupId, me.nId, DaTaoSha.WaitMapMemList[me.nMapId].tbRange[me.nId]};
	GCExcute{"DaTaoSha:CreaseNum", me.nMapId, nGroupId,  me.nId};--同步gc	
end

-- 定义玩家离开事件
function tbMap:OnLeave()	
	local nNumber = DaTaoSha.WaitMapMemList[me.nMapId].tbRange[me.nId];
	if not nNumber then
		DaTaoSha:CloseSingleUi(me);
		return;
	end
	--DaTaoSha.WaitMapMemList[me.nMapId].tbRange[me.nId] = nil;
	local nGroupId = me.GetTask(DaTaoSha.TASKID_GROUP, DaTaoSha.TASKID_GROUPID);
	--状态设置
	me.TeamDisable(0);			--组队		
	me.ForbitTrade(0);			--交易	
	DaTaoSha.tbTransferPlayerList = DaTaoSha.tbTransferPlayerList or {};	
	local nFlag = 0;
	for i = 1, #DaTaoSha.tbTransferPlayerList do 
		if me.nId == DaTaoSha.tbTransferPlayerList[i] then
			nFlag = 1;
		end
	end
	if nFlag == 1 then		
		return;
	end	
	Dialog:SendBattleMsg(me, "");
	if not DaTaoSha.MissionList or not DaTaoSha.MissionList[me.nMapId] or DaTaoSha.MissionList[me.nMapId]:GetPlayerGroupId(me) < 0 then
		DaTaoSha:CloseSingleUi(me);
	end
	for _, nPlayerId in ipairs (DaTaoSha.WaitMapMemList[me.nMapId].tbGroupList[nGroupId]) do
		if nPlayerId == me.nId then		 
			GlobalExcute{"DaTaoSha:DecreaseNum", me.nMapId, nGroupId, me.nId, nNumber};
			GCExcute{"DaTaoSha:DecreaseNum", me.nMapId, nGroupId, me.nId};--gc地图人数减少
			break;
		end
	end
end

for _, varMap in pairs(DaTaoSha.MACTH_TO_MAP) do
	if type(varMap) == "table" then
		for nMapId = varMap[1], varMap[2] do
			local tbBattleMap = Map:GetClass(nMapId);
			for szFnc in pairs(tbMap) do
				tbBattleMap[szFnc] = tbMap[szFnc];
			end
		end
	else
		local tbBattleMap = Map:GetClass(varMap);
		for szFnc in pairs(tbMap) do
			tbBattleMap[szFnc] = tbMap[szFnc];
		end
	end	
end

----------------------------------------------------------------------------------------------------------
local tbMacthMapEx = {};
function tbMacthMapEx:OnLeave()
	-- 删除身上物品	
	local tbBag = {		
		Item.ROOM_MAINBAG,	-- 主背包			
		Item.ROOM_EXTBAG1,	-- 扩展背包1
		Item.ROOM_EXTBAG2,	-- 扩展背包2
		Item.ROOM_EXTBAG3,	-- 扩展背包3
		Item.ROOM_EXTBAGBAR,	-- 扩展背包放置栏
		};
	local tbEquit = {};
	local pItem = nil;
	for i = 1, #tbBag do 
		tbEquit = me.FindAllItem(tbBag[i]);	
		for _,nIndex in pairs(tbEquit) do 
			pItem = KItem.GetItemObj(nIndex);
			if pItem then
				pItem.Delete(me);
			end	
		end	
	end	
end

for nLevel , tbInfo in pairs(DaTaoSha.MACTH_TYPE) do
	for _ , nMapId in pairs(tbInfo.tbMacthMap) do
		local tbBattleMap = Map:GetClass(nMapId); 
		for szFnc in pairs(tbMacthMapEx) do
			tbBattleMap[szFnc] = tbMacthMapEx[szFnc];
		end
	end
end

