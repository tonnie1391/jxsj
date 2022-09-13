-------------------------------------------------------------------
--File: 	base.lua
--Author: sunduoliang
--Date: 	2008-4-15
--Describe:	活动管理系统
--InterFace1:Init(...) 初始化数据
--InterFace2:CreateKind() 建立小活动类基类.
--InterFace3:
-------------------------------------------------------------------
local EventKind = {};
EventManager.EventKindBase = EventKind;

function EventKind:Init(tbEvent, tbEventPart, bGmCmd)
	--初始化数据
	self.tbEvent = tbEvent;
	
	self.tbEventPart = tbEventPart;
--	self.tbEventPart.nId 			= tbEventPart.nId;
--	self.tbEventPart.szName 		= tbEventPart.szName;
--	self.tbEventPart.szKind 		= tbEventPart.szKind;
--	self.tbEventPart.szSubKind 		= tbEventPart.szSubKind;
--	self.tbEventPart.szExClass		= tbEventPart.szExClass;	
--	self.tbEventPart.nStartDate 	= tbEventPart.nStartDate;
--	self.tbEventPart.nEndDate 		= tbEventPart.nEndDate;
--	self.tbEventPart.tbParam		= tbEventPart.tbParam;
--	self.tbEventPart.tbParamIndex	= tbEventPart.tbParamIndex;
	--table.insert(self.tbEventPart.tbParam, string.format("CheckGDate:%s,%s",self.tbEvent.nStartDate, self.tbEvent.nEndDate));
	
	if bGmCmd ~= 1 or self.tbEventPart.tbParamIndex[101] == nil then 
		table.insert(self.tbEventPart.tbParam, string.format("CheckGDate:%s,%s",self.tbEventPart.nStartDate, self.tbEventPart.nEndDate));
		self.tbEventPart.tbParamIndex[101] = #self.tbEventPart.tbParam;
		table.insert(self.tbEventPart.tbParam, string.format("__nPartId:%s",self.tbEventPart.nId));
		self.tbEventPart.tbParamIndex[201] = #self.tbEventPart.tbParam;
		table.insert(self.tbEventPart.tbParam, string.format("__nEventId:%s",self.tbEvent.nId));
		self.tbEventPart.tbParamIndex[202] = #self.tbEventPart.tbParam;
		table.insert(self.tbEventPart.tbParam, string.format("SetTaskBatch:%s",self.tbEvent.nTaskPacth));
		self.tbEventPart.tbParamIndex[301] = #self.tbEventPart.tbParam;
		
		--如果不是物品类则需要判断最大活动时间
		if #EventManager.tbFun:GetParam(self.tbEventPart.tbParam, "Item", 1) <= 0 then
			table.insert(self.tbEventPart.tbParam, string.format("CheckGDate:%s,%s",self.tbEvent.nStartDate, self.tbEvent.nEndDate));
			self.tbEventPart.tbParamIndex[102] = #self.tbEventPart.tbParam;
		end
	end
	
	self.tbDialog = {};
	self.tbTimer = {};
	self.tbNpcDrop ={};
	self.tbTimer.tbStartTime = {};
	self.tbTimer.tbEndTime = {};	
	self:CreateKind();
end

function EventKind:CreateKind()
	--
	--self.SubCreateKind = self.SubKind.CreateKind;
	--if self.SubCreateKind then
	if (MODULE_GAMESERVER) or (MODULE_GC_SERVER) then
		EventManager.tbFunction_Base:SetTimerStart(self);
		EventManager.tbFunction_Base:SetTimerEnd(self);
		EventManager.tbFunction_Base:SetMapPath(self);
		EventManager.tbFunction_Base:SetDropNpc(self);
		EventManager.tbFunction_Base:SetDropNpcType(self);
		EventManager.tbFunction_Base:SetNpc(self);		
	end	

	if (MODULE_GAMESERVER) or (MODULE_GAMECLIENT)then
		EventManager.tbFunction_Base:SetItem(self);
	end
	
		--self.SubCreateKind(self)
	--end
end

function EventKind:OnUse()
	--
	--local nFlag, szMsg = EventManager.tbFun:CheckParam(self.tbEventPart.tbParam);
	--if nFlag == 1 then
	--	if szMsg then
	--		me.Msg(szMsg);
	--	end
	--	return 0;
	--end
	
	local nDelay = 0;	--秒
	local nUseDel = 0;
	local tbItemLiveTime = EventManager.tbFun:GetParam(self.tbEventPart.tbParam, "Item", 1);
	local tbItemLiveTimeId = EventManager.tbFun:GetParam(self.tbEventPart.tbParam, "ItemGId", 1);
	if #tbItemLiveTimeId <= 0 then
		for nParam, szParam in ipairs(tbItemLiveTime) do
			local tbItemName = EventManager.tbFun:SplitStr(szParam);
			local szClassName = tbItemName[1];
			if szClassName == it.szClass then
				nDelay = tonumber(tbItemName[3]) or 0;	--默认没有进度条
				nUseDel = tonumber(tbItemName[4]) or 0;	--默认不删
				break;
			end
		end
	else
		for nParam, szParam in ipairs(tbItemLiveTimeId) do
			local tbItemName = EventManager.tbFun:SplitStr(szParam);
			local szGenIdName = tbItemName[1];
			if szGenIdName == string.format("%s,%s,%s,%s", it.nGenre, it.nDetail, it.nParticular, it.nLevel) then
				nDelay = tonumber(tbItemName[3]) or 0;	--默认没有进度条
				nUseDel = tonumber(tbItemName[4]) or 0;	--默认不删
				break;
			end
		end		
	end

	EventManager:GetTempTable().nType = 2;
	EventManager:GetTempTable().tbParam = {nItemId=it.dwId};
	if nDelay > 0 then
		local tbEvent = 
		{
			Player.ProcessBreakEvent.emEVENT_MOVE,
			Player.ProcessBreakEvent.emEVENT_ATTACK,
			Player.ProcessBreakEvent.emEVENT_ATTACKED,
			Player.ProcessBreakEvent.emEVENT_SITE,
			Player.ProcessBreakEvent.emEVENT_USEITEM,
			Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
			Player.ProcessBreakEvent.emEVENT_DROPITEM,
			Player.ProcessBreakEvent.emEVENT_SENDMAIL,
			Player.ProcessBreakEvent.emEVENT_TRADE,
			Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
			Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
			Player.ProcessBreakEvent.emEVENT_LOGOUT,
			Player.ProcessBreakEvent.emEVENT_DEATH,
		}
		
		GeneralProcess:StartProcess("使用中...", nDelay * Env.GAME_FPS, 
				{self.OnUse_Delay, self, me.nId, it.dwId, nUseDel, 1}, nil, tbEvent);
			return 0;
	end
	return self:OnUse_Delay(me.nId, it.dwId, nUseDel, 0);
end
function EventKind:OnUse_Delay(nPlayerId, nItemId, nUseDel, nType)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	
	local nSureFlag = 0;
	local nReturnFlag = 0;
	Setting:SetGlobalObj(pPlayer, nil, pItem);
	local nFlag, szMsg = EventManager.tbFun:CheckParam(self.tbEventPart.tbParam);
	if nFlag and nFlag ~= 0 then
		if szMsg then
			me.Msg(szMsg);
		end
		if nFlag == 2 then
			if nType == 1 and nUseDel == 1 then
				if it.nCount > 1 then
					it.SetCount(it.nCount - 1, Item.emITEM_DATARECORD_REMOVE);
				else
					me.DelItem(it, Player.emKLOSEITEM_USE);
				end
				nReturnFlag = 0;
			else
				nReturnFlag = nUseDel;
			end
		else
			nReturnFlag = 0;
		end
		Setting:RestoreGlobalObj()
		return nReturnFlag;
	end
	
	local nExUse = 0;	--扩展OnUse返回是否删除物品。
	if self.tbEventPart.szExClass ~= nil and self.tbEventPart.szExClass ~= "" then
		if EventManager.EventKind.ExClass[self.tbEventPart.szExClass] ~= nil then
			if EventManager.EventKind.ExClass[self.tbEventPart.szExClass].OnUse ~= nil then
				nExUse = EventManager.EventKind.ExClass[self.tbEventPart.szExClass]:OnUse() or 0;
				nSureFlag = 1;
			end
		end
	end

	self.SubOnUse = self.SubKind.OnUse;
	local nSubFlag = 0;
	if nSureFlag == 0 and self.SubOnUse then
		nSubFlag = self.SubOnUse(self);
	end
	if nSubFlag == 0 then
		nReturnFlag = nExUse;
	else
		if nType == 1 and nUseDel == 1 then
			if it.nCount > 1 then
				it.SetCount(it.nCount - 1, Item.emITEM_DATARECORD_REMOVE);
			else
				me.DelItem(it, Player.emKLOSEITEM_USE);
			end
			nReturnFlag = 0;
		else
			nReturnFlag = nUseDel;	
		end
	end
	Setting:RestoreGlobalObj();
	return nReturnFlag;
end

function EventKind:PickUp()
	
	if self.tbEventPart.szExClass ~= nil and self.tbEventPart.szExClass ~= "" then
		if EventManager.EventKind.ExClass[self.tbEventPart.szExClass] ~= nil then
			if EventManager.EventKind.ExClass[self.tbEventPart.szExClass].PickUp ~= nil then
				return EventManager.EventKind.ExClass[self.tbEventPart.szExClass]:PickUp();
			end
			
		end
	end
		
	self.SubPickUp = self.SubKind.PickUp;
	if self.SubPickUp then
		if self.SubPickUp(self) == 0 then
			return 0;
		end
	end
	return 1;
end

function EventKind:IsPickable()

	if self.tbEventPart.szExClass ~= nil and self.tbEventPart.szExClass ~= "" then
		if EventManager.EventKind.ExClass[self.tbEventPart.szExClass] ~= nil then
			if EventManager.EventKind.ExClass[self.tbEventPart.szExClass].IsPickable ~= nil then
				return EventManager.EventKind.ExClass[self.tbEventPart.szExClass]:IsPickable();
			end
			
		end
	end
		
	self.SubIsPickable = self.SubKind.IsPickable;
	if self.SubIsPickable then
		if self.SubIsPickable(self) == 0 then
			return 0;
		end
	end
	return 1;	
end

function EventKind:InitGenInfo()
	local tbItemLiveTime = EventManager.tbFun:GetParam(self.tbEventPart.tbParam, "Item", 1)
	local tbItemLiveTimeId = EventManager.tbFun:GetParam(self.tbEventPart.tbParam, "ItemGId", 1);
	if #tbItemLiveTimeId <= 0 then
		for nParam, szParam in ipairs(tbItemLiveTime) do
			local tbItemName = EventManager.tbFun:SplitStr(szParam);
			local szClassName = tbItemName[1];
			if szClassName == it.szClass and tbItemName[2] and tbItemName[2] ~= "" then
				if tonumber(tbItemName[2]) ~= nil then
					if tonumber(tbItemName[2]) > 0 then
						it.SetTimeOut(0, (GetTime() + tonumber(tbItemName[2]) * 60));
					end
				else
					local nStartTime = EventManager.tbFun:DateFormat(tbItemName[2], 0);
					if nStartTime > 0 then
						it.SetTimeOut(0, Lib:GetDate2Time(nStartTime));
					end
				end
				it.Sync();
				break;
			end
		end
	else
		for nParam, szParam in ipairs(tbItemLiveTimeId) do
			local tbItemName = EventManager.tbFun:SplitStr(szParam);
			local szGenIdName = tbItemName[1];
			if szGenIdName == string.format("%s,%s,%s,%s", it.nGenre, it.nDetail, it.nParticular, it.nLevel) and 
				tbItemName[2] and tbItemName[2] ~= "" then
				if tonumber(tbItemName[2]) ~= nil then
					if tonumber(tbItemName[2]) > 0 then
						it.SetTimeOut(0, (GetTime() + tonumber(tbItemName[2]) * 60));
					end
				else
					local nStartTime = EventManager.tbFun:DateFormat(tbItemName[2], 0);
					if nStartTime > 0 then
						it.SetTimeOut(0, Lib:GetDate2Time(nStartTime));
					end
				end
				it.Sync();
				break;
			end
		end		
	end
	
	if self.tbEventPart.szExClass ~= nil and self.tbEventPart.szExClass ~= "" then
		if EventManager.EventKind.ExClass[self.tbEventPart.szExClass] ~= nil then
			if EventManager.EventKind.ExClass[self.tbEventPart.szExClass].InitGenInfo ~= nil then
				return EventManager.EventKind.ExClass[self.tbEventPart.szExClass]:InitGenInfo();
			end
			
		end
	end
	
	self.SubInitGenInfo = self.SubKind.InitGenInfo;
	if self.SubInitGenInfo then
		return self.SubInitGenInfo(self);
	end
	return {};	
end

function EventKind:GetTip()
	local tbItemLiveTime = EventManager.tbFun:GetParam(self.tbEventPart.tbParam, "Item", 1);
	local tbItemLiveTimeId = EventManager.tbFun:GetParam(self.tbEventPart.tbParam, "ItemGId", 1);
	if #tbItemLiveTimeId <= 0 then	
		for nParam, szParam in ipairs(tbItemLiveTime) do
			local tbItemName = EventManager.tbFun:SplitStr(szParam);
			local szGenIdName = tbItemName[1];
			if szGenIdName == string.format("%s,%s,%s,%s", it.nGenre, it.nDetail, it.nParticular, it.nLevel) and 
			tbItemName[5] and tbItemName[5] ~= "" then
				local szScript = string.gsub(tbItemName[5], "<enter>", "\n");
				return loadstring(szScript)() or "";
			end
		end
	else
		for nParam, szParam in ipairs(tbItemLiveTimeId) do
			local tbItemName = EventManager.tbFun:SplitStr(szParam);
			local szClassName = tbItemName[1];
			if szClassName == it.szClass and tbItemName[5] and tbItemName[5] ~= "" then
				local szScript = string.gsub(tbItemName[5], "<enter>", "\n");
				return loadstring(szScript)() or "";
			end
		end		
	end
	return "";	
end

function EventKind:OnDialog(nCheck, nDelayCheck)
	nDelayCheck = nDelayCheck or 0;
	local tbGRoleArgs = Dialog:GetMyDialog().tbGRoleArgs;
	if not tbGRoleArgs then
		return 0;
	end
	local pNpc = KNpc.GetById((tbGRoleArgs.npcId)or 0);
	if not pNpc then
		return 0;
	end
	if nDelayCheck == 0 then
		local tbNpcParam = EventManager.tbFun:GetParam(self.tbEventPart.tbParam, "Npc", 1);
		local nDelay = 0;
		for nNpc, szParam in pairs(tbNpcParam) do
			local tbParam = EventManager.tbFun:SplitStr(szParam);	
			nDelay = tbParam[2] or 0;
			nDelay = tonumber(nDelay) or 0;	-- 默认没有进度条
			break;
		end
		if nDelay > 0 then
			local tbEvent = 
			{
				Player.ProcessBreakEvent.emEVENT_MOVE,
				Player.ProcessBreakEvent.emEVENT_ATTACK,
				Player.ProcessBreakEvent.emEVENT_ATTACKED,
				Player.ProcessBreakEvent.emEVENT_SITE,
				Player.ProcessBreakEvent.emEVENT_USEITEM,
				Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
				Player.ProcessBreakEvent.emEVENT_DROPITEM,
				Player.ProcessBreakEvent.emEVENT_SENDMAIL,
				Player.ProcessBreakEvent.emEVENT_TRADE,
				Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
				Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
				Player.ProcessBreakEvent.emEVENT_LOGOUT,
				Player.ProcessBreakEvent.emEVENT_DEATH,
			}
		
			GeneralProcess:StartProcess("请等待...", nDelay * Env.GAME_FPS, 
					{self.OnDialog, self, nCheck, 1}, nil, tbEvent);
			return 0;
		end
	end
	Setting:SetGlobalObj(nil, pNpc);
	EventManager:GetTempTable().nType = 1;
	EventManager:GetTempTable().tbParam = {};
	--扩展参数
	if self.tbEventPart.szExClass ~= nil and self.tbEventPart.szExClass ~= "" then
		if EventManager.EventKind.ExClass[self.tbEventPart.szExClass] ~= nil then
			if EventManager.EventKind.ExClass[self.tbEventPart.szExClass].OnDialog ~= nil then
				local nFlag, szMsg = EventManager.tbFun:CheckParam(self.tbEventPart.tbParam);
				if nFlag and nFlag ~= 0 then
					if szMsg then
						me.Msg(szMsg);
					end
					Setting:RestoreGlobalObj();
					return 0;
				end				
				EventManager.EventKind.ExClass[self.tbEventPart.szExClass]:OnDialog()
				Setting:RestoreGlobalObj();
				return 0;
			end
		end
	end
	self.SubOnDialog = self.SubKind.OnDialog;
	if self.SubOnDialog then
		self.SubOnDialog(self, nCheck)
	end
	Setting:RestoreGlobalObj();
end

function EventKind:ExeStartFun(tbParam, bGCFlag)
	
	--加入有效对话	
	
	EventManager.Event:ExeDialog(self.tbEvent.nId);
	--GC调过来的不做CheckGDate（GS延迟这里会出问题）
	local tbEventPartParam = {};
	if bGCFlag then
		for nParam, szParam in ipairs(self.tbEventPart.tbParam) do
			local szKey = EventManager.tbFun:GetParamKey(szParam);
			if szKey ~= "CheckGDate" then	
				table.insert(tbEventPartParam, szParam);
			end
		end
	else
		tbEventPartParam = self.tbEventPart.tbParam;
	end
	local nFlag, szMsg = EventManager.tbFun:CheckParamWithOutPlayer(tbEventPartParam);
	if nFlag and nFlag ~= 0 then
		return 0;
	end
	
	if self.tbEventPart.szExClass ~= nil and self.tbEventPart.szExClass ~= "" then
		if EventManager.EventKind.ExClass[self.tbEventPart.szExClass] ~= nil then
			if EventManager.EventKind.ExClass[self.tbEventPart.szExClass].ExeStartFun ~= nil then
				EventManager.EventKind.ExClass[self.tbEventPart.szExClass]:ExeStartFun(tbParam)
				return 0;
			end
		end
	end
		
	self.SubExeStartFun = self.SubKind.ExeStartFun;
	if self.SubExeStartFun then
		self.SubExeStartFun(self, tbParam);
	end
	return 0;
end

function EventKind:ExeEndFun(tbParam)
	
	--检查对话是否已失效
	local tbEvent = EventManager.EventManager.tbEvent[self.tbEvent.nId];
	if tbEvent.tbDialog then
		for varNpc, tbNpcDialogParam in pairs(tbEvent.tbDialog) do
			EventManager.Event:CheckEffectDialog(self.tbEvent.nId, varNpc);
		end
	end
	
	if self.tbEventPart.szExClass ~= nil and self.tbEventPart.szExClass ~= "" then
		if EventManager.EventKind.ExClass[self.tbEventPart.szExClass] ~= nil then
			if EventManager.EventKind.ExClass[self.tbEventPart.szExClass].ExeEndFun ~= nil then
				EventManager.EventKind.ExClass[self.tbEventPart.szExClass]:ExeEndFun(tbParam)
				return 0;
			end
		end
	end
		
	self.SubExeEndFun = self.SubKind.ExeEndFun;
	if self.SubExeEndFun then
		self.SubExeEndFun(self, tbParam);
	end
	return 0;
end


function EventKind:ExeNpcStartFun(tbParam)
	local nFlag, szMsg = EventManager.tbFun:CheckParamWithOutPlayer(self.tbEventPart.tbParam);
	if nFlag and nFlag ~= 0 then
		return 0;
	end
	
	if self.tbEventPart.szExClass ~= nil and self.tbEventPart.szExClass ~= "" then
		if EventManager.EventKind.ExClass[self.tbEventPart.szExClass] ~= nil then
			if EventManager.EventKind.ExClass[self.tbEventPart.szExClass].ExeNpcStartFun ~= nil then
				EventManager.EventKind.ExClass[self.tbEventPart.szExClass]:ExeNpcStartFun(tbParam)
				return 0;
			end
		end
	end
		
	self.SubExeNpcStartFun = self.SubKind.ExeNpcStartFun;
	if self.SubExeNpcStartFun then
		self.SubExeNpcStartFun(self, tbParam);
	end
	return 0;
end

function EventKind:ExeNpcEndFun(tbParam)

	if self.tbEventPart.szExClass ~= nil and self.tbEventPart.szExClass ~= "" then
		if EventManager.EventKind.ExClass[self.tbEventPart.szExClass] ~= nil then
			if EventManager.EventKind.ExClass[self.tbEventPart.szExClass].ExeNpcEndFun ~= nil then
				EventManager.EventKind.ExClass[self.tbEventPart.szExClass]:ExeNpcEndFun(tbParam)
				return 0;
			end
		end
	end
		
	self.SubExeNpcEndFun = self.SubKind.ExeNpcEndFun;
	if self.SubExeNpcEndFun then
		self.SubExeNpcEndFun(self, tbParam);
	end
	return 0;
end
