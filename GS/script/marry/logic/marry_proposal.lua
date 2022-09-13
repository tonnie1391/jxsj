-------------------------------------------------------
-- 文件名　：marry_proposal.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-01-05 00:38:37
-- 文件描述：
-------------------------------------------------------

Require("\\script\\marry\\logic\\marry_def.lua");

if (not MODULE_GAMESERVER) then
	return 0;
end

-- 清除全局数据表
function Marry:ClearProposal_GS()
	self.tbProposalBuffer = {};
end

-- 同步数据
function Marry:SyncProposal_GS(szPreName, szMatchName)
	self.tbProposalBuffer[szPreName] = szMatchName;
end

-- 增加解除求婚
function Marry:AddProposal_GS(szPreName, szMatchName)
	GCExcute({"Marry:AddProposal_GC", szPreName, szMatchName});
end

-- 删除解除求婚
function Marry:RemoveProposal_GS(szPreName)
	GCExcute({"Marry:RemoveProposal_GC", szPreName});
end

-- 清除婚姻全局数据表
function Marry:ClearDivorce_GS()
	self.tbDivorceBuffer = {};
end

-- 同步婚姻数据
function Marry:SyncDivorce_GS(szPreName, szMatchName)
	self.tbDivorceBuffer[szPreName] = szMatchName;
end

-- 增加解除婚姻
function Marry:AddDivorce_GS(szPreName, szMatchName)
	GCExcute({"Marry:AddDivorce_GC", szPreName, szMatchName});
end

-- 删除解除婚姻
function Marry:RemoveDivorce_GS(szPreName)
	GCExcute({"Marry:RemoveDivorce_GC", szPreName});
end

-- 判断求婚关系
function Marry:CheckQiuhun(pMale, pFemale)
	local szMaleQiuhun = pMale.GetTaskStr(self.TASK_GROUP_ID, self.TASK_QIUHUN_NAME);
	local szFemaleQiuhun = pFemale.GetTaskStr(self.TASK_GROUP_ID, self.TASK_QIUHUN_NAME);
	if szMaleQiuhun == "" or szFemaleQiuhun == "" then
		return 0;
	end
	if szMaleQiuhun == pFemale.szName and szFemaleQiuhun == pMale.szName then
		return 1;
	end
	return 0
end

-- 增加求婚关系
function Marry:AddQiuhun(pMale, pFemale)
	-- 系统开关
	if Marry:CheckState() ~= 1 then
		return 0;
	end
	if self:CheckQiuhun(pMale, pFemale) == 1 then
		return 0;
	end
	pMale.SetTaskStr(self.TASK_GROUP_ID, self.TASK_QIUHUN_NAME, pFemale.szName);
	pFemale.SetTaskStr(self.TASK_GROUP_ID, self.TASK_QIUHUN_NAME, pMale.szName);
	
	pMale.SetTask(Marry.TASK_GROUP_ID, Marry.TASK_TIME_RESELECTDATE, 0);
	pFemale.SetTask(Marry.TASK_GROUP_ID, Marry.TASK_TIME_RESELECTDATE, 0);
	
	pMale.AddSpeTitle(string.format("%s的心上人", pFemale.szName), GetTime() + 7 * 60 * 60 * 24, "gold");
	pFemale.AddSpeTitle(string.format("%s的心上人", pMale.szName), GetTime() + 7 * 60 * 60 * 24, "gold");
end

-- 删除求婚关系
function Marry:RemoveQiuhun(pMale, pFemale)
	-- 系统开关
	if Marry:CheckState() ~= 1 then
		return 0;
	end
	if self:CheckQiuhun(pMale, pFemale) ~= 1 then
		return 0;
	end
	pMale.SetTaskStr(self.TASK_GROUP_ID, self.TASK_QIUHUN_NAME, "");
	pFemale.SetTaskStr(self.TASK_GROUP_ID, self.TASK_QIUHUN_NAME, "");
end

-- 情花奖励回调
function Marry:GiveQinghua(pPlayer)
	-- 系统开关
	if Marry:CheckState() ~= 1 then
		return 0;
	end
	local nCount = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_QINGHUA_DAILY);
	if nCount >= self.MAX_QINGHUA_DAILY then
		return 0;
	end
	local pItem = pPlayer.AddItem(unpack(self.ITEM_HUABAN_ID));
	if pItem then
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_QINGHUA_DAILY, nCount + 1);
	end
end

-- 清除角色所有情花(背包.箱子)
function Marry:ClearQinghua(pPlayer)

	-- 扣除背包里的
	local nCount = pPlayer.GetItemCountInBags(unpack(self.ITEM_QINGHUA_ID));
	local nRet = pPlayer.ConsumeItemInBags2(nCount, unpack(self.ITEM_QINGHUA_ID));
	if nRet == 1 then
		-- error
	end
	
	-- 扣除储物箱的
	local tbFind = me.FindItemInRepository(unpack(self.ITEM_QINGHUA_ID));
	for _, tbItem in pairs(tbFind or {}) do
		local nRet = pPlayer.DelItem(tbItem.pItem, Player.emKLOSEITEM_USE);
		if nRet ~= 1 then
			-- error
		end
	end
end

-- 每日事件
function Marry:DailyEvent()
	if Marry:CheckState() ~= 1 then
		return 0;
	end
	me.SetTask(Marry.TASK_GROUP_ID, Marry.TASK_QINGHUA_DAILY, 0);
end

function Marry:MonthEvent()
	if Marry:CheckState() ~= 1 then
		return 0;
	end
	me.SetTask(Marry.TASK_GROUP_ID, Marry.TASK_DIVORCE_INTERVAL, 0);	
end

-- 登陆事件
function Marry:OnPlayerLogin()
	
	-- 系统开关
	if Marry:CheckState() ~= 1 then
		return 0;
	end
	self:OnLoginProposal();
	self:OnLoginDivorce();
end

function Marry:OnLoginProposal()
	local szMatchName = me.GetTaskStr(self.TASK_GROUP_ID, self.TASK_QIUHUN_NAME);
	if szMatchName == "" then
		return 0;
	end
	local szKeyName = self.tbProposalBuffer[me.szName];
	if not szKeyName then
		return 0;
	end
	if szKeyName == szMatchName then
		me.SetTaskStr(self.TASK_GROUP_ID, self.TASK_QIUHUN_NAME, "");
	end
	
	if me.nSex == 0 then
		me.RemoveSpeTitle(string.format("%s的心上人", szMatchName));
	else
		me.RemoveSpeTitle(string.format("%s的心上人", szMatchName));
	end
	
	me.Msg(string.format("你和<color=yellow>%s<color>的纳吉关系已经解除了。", szMatchName));		
	self:RemoveProposal_GS(me.szName);
end

function Marry:OnLoginDivorce()
	local szTmpName = self.tbDivorceBuffer[me.szName];
	if not szTmpName then
		return 0;
	end
	self.tbDivorceBuffer[me.szName] = nil;
	self:DoDivorce(me, szTmpName);
	self:RemoveDivorce_GS(me.szName);
end

-- 注册玩家每日事件
PlayerSchemeEvent:RegisterGlobalDailyEvent({Marry.DailyEvent, Marry});
PlayerSchemeEvent:RegisterGlobalMonthEvent({Marry.MonthEvent, Marry});

-- 注册玩家登陆事件
PlayerEvent:RegisterGlobal("OnLogin", Marry.OnPlayerLogin, Marry);

-- 结婚log
function Marry:_Log(pPlayer, szLog)
	
	-- 本地日志
	Dbg:WriteLog("Marry", "结婚系统", pPlayer.szAccount, pPlayer.szName, szLog);
	
	-- 行为日志
	pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "【结婚系统】"..szLog);	
end
