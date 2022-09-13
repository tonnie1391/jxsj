------------------------------------------------------
-- 文件名　：tianyanmiyuwan.lua
-- 创建者　：dengyong
-- 创建时间：2009-12-07 11:35:10
-- 描  述  ：甜言蜜语丸，用来说服NPC成为自己的同伴
------------------------------------------------------

local tbItem = Item:GetClass("tianyanmiyuwan");

tbItem.nProcessTime 			  = 15;		-- 使用道具过程中，需要读条15秒
tbItem.nPersuadeSkillId          = 1526;	-- 说服状态，玩家
tbItem.nBePersuadeSkillId 		  = 1527;	-- 被说服状态，

-- 记录玩家吃了多少本经验书的任务变量索引
tbItem.nTask	 = 2112;
tbItem.nSubTask  = 3;
tbItem.nDateTask  = 4;

--Level对应的说服等级
tbItem.tbIndex = {
	[1] = 1,
	[2] = 2,
	[3] = 1,
	[4] = 2,
	[5] = 1,
	[6] = 2}

-- 参数应该为选中NPC的ID
function tbItem:OnUse(nParam)	
	local dwId = nParam;
	
	local pNpc = KNpc.GetById(dwId);
	print(dwId, pNpc)
	if dwId == 0 or not pNpc then
		me.Msg("Hãy chọn 1 NPC rồi sử dụng đạo cụ này!");
		return 0;
	end
		
	local szNpcName = pNpc.szName;
	local nRet = Partner:CreatePartner(me.nId, dwId, it.dwId);
	if nRet == 1 then
		me.SetTask(self.nTask, self.nSubTask, me.GetTask(self.nTask, self.nSubTask) + 1);
		-- 如果抓取成功，且有队伍给队伍通知队伍
		if me.GetTeamId() then
			KTeam.Msg2Team(me.nTeamId, string.format("Đồng đội <color=yellow>%s<color> bắt được đồng hành <color=yellow>%s<color>.", me.szName, szNpcName));
		end
	end	
	return 0;
end 

function tbItem:CheckUsable(nParam)
	if (Partner.bOpenPartner ~= 1) then
		Dialog:Say("Hiện hoạt động đồng hành đã đóng, không thể sử dụng thẻ!");
		return 0;
	end
	
	if MODULE_GAMECLIENT then
		local pSelectNpc = me.GetSelectNpc();
		if not pSelectNpc then
			me.Msg("Hãy chọn 1 NPC rồi sử dụng đạo cụ này!");
			return 0;
		end
		local nLevel = self.tbIndex[it.nLevel];
		local nRes, varMsg = Partner:TryToPersuade(me, pSelectNpc, nLevel);
		if nRes == 0 then
			me.Msg(varMsg);		-- 不能说服，返回错误信息
			UiManager:OpenWindow("UI_INFOBOARD", varMsg);
			return 0;
		end		
	elseif MODULE_GAMESERVER then
		if not nParam or nParam == 0 then
			me.Msg("Hãy chọn 1 NPC rồi sử dụng đạo cụ này!");
			return 0;
		end
		
		local pNpc = KNpc.GetById(nParam);
		if not pNpc then
			return 0;
		end
		
		-- 是否满足说服的条件
		local nLevel = self.tbIndex[it.nLevel];
		local nRes, varMsg = Partner:TryToPersuade(me, pNpc, nLevel);
		if nRes == 0 then
			me.Msg(varMsg);		-- 不能说服，返回错误信息
			Partner:SendClientMsg(varMsg);
			return 0;
		end
		
		--每天使用的限制
		local nCurDate = tonumber(os.date("%Y%m%d", GetTime()))
		local nDate = me.GetTask(self.nTask, self.nDateTask);	   -- 日期
		if nCurDate ~= nDate then
			me.SetTask(self.nTask, self.nSubTask, 0)
			me.SetTask(self.nTask, self.nDateTask, nCurDate);
		end
		
		local nTimes = me.GetTask(self.nTask, self.nSubTask);	   -- 已经使用
		local nCanUseCount = KGblTask.SCGetDbTaskInt(DBTASK_DAY_PARTNERARRESTBOOK_COUNT);
		if nTimes >= nCanUseCount and nCanUseCount > 0 then
			me.Msg(string.format("Mỗi ngày chỉ có thể dùng %s Thiệp lụa.", nCanUseCount));
			return 0;
		end
	end
	
	return 1;
end

-- 从客户端得到选择中的NPC对象，并把ID返回给服务器
-- 如果没有选择NPC对象，返回0
function tbItem:OnClientUse()
	local pSelectNpc = me.GetSelectNpc();
	if not pSelectNpc then
		return 0;
	end

	return pSelectNpc.dwId;
end

-- 被打断后，去除特殊状态
function tbItem:OnBreak(nPlayerId, nNpcId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	local pNpc = KNpc.GetById(nNpcId);
	
	if pPlayer and pPlayer.GetTempTable("Partner").nPersuadeRefCount <= 1 then
		pPlayer.RemoveSkillState(self.nPersuadeSkillId);
		pPlayer.GetTempTable("Partner").nPersuadeRefCount = 0;
	else
		pPlayer.GetTempTable("Partner").nPersuadeRefCount = pPlayer.GetTempTable("Partner").nPersuadeRefCount - 1;
	end	
	
	if not pNpc or not pNpc.GetTempTable("Partner").nPersuadeRefCount then
		return;
	end
		
	pNpc.GetTempTable("Partner").nPersuadeRefCount = pNpc.GetTempTable("Partner").nPersuadeRefCount - 1;
	if pNpc.GetTempTable("Partner").nPersuadeRefCount <= 0 then
		pNpc.RemoveTaskState(self.nBePersuadeSkillId);
	end

end