--
-- FileName: invite_gc.lua
-- Author: hanruofei
-- Time: 2011/5/4 9:35
-- Comment:VIP邀请新玩家加盟GC代码
--
if not MODULE_GC_SERVER then
	return;
end
SpecialEvent.tbVipInvite = SpecialEvent.tbVipInvite or {};
local tbVipInvite = SpecialEvent.tbVipInvite;

-- 初始化
function tbVipInvite:OnGCStart()
	local tbData = GetGblIntBuf(GBLINTBUF_VIP_INVITE, 0); 
	if type(tbData) == "table" then
		self.tbData = tbData;
	end
	
	local nOpenTime = GetTime() - KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME);
	if nOpenTime >= self.nDaysFromServerStart * 60 * 60 * 24  then
		self:Open();
		if not self.tbData[1] then
			self.tbData[1] = true;
			self:SendMail();
			self:SaveData();
		end
		return;
	end
	
--	local nTaskId = KScheduleTask.AddTask("VipInvite", "SpecialEvent", "CheckVipInviteOpened");
--	KScheduleTask.RegisterTimeTask(nTaskId, 2002, 0);
end

-- 打开这个功能
function tbVipInvite:Open(nConnectId)
	nConnectId = nConnectId or -1; -- 默认为-1
	self.bOpened = true;
	GSExcute(nConnectId, {"SpecialEvent.tbVipInvite:Open"});
end

-- 关闭这个功能
function tbVipInvite:Close()
	self.bOpened = false;
	GlobalExcute{"SpecialEvent.tbVipInvite:Close"};
end

-- 该功能开启的时候自动发送邮件
tbVipInvite.szMailTitle = "VIP邀请资格";
tbVipInvite.szMailContent = "恭喜您获得了VIP邀请好友的资格。请与您的好友二人组队前往活动推广员古枫霞处，邀请您的好友加盟。";
function tbVipInvite:SendMail()
	local nType = Ladder:GetType(0, Ladder.LADDER_CLASS_MONEY, Ladder.LADDER_TYPE_MONEY_HONOR_MONEY, 0);
	local tbPlayers = GetHonorLadderPart(nType, 1, self.nWealthOrder); -- 获得财富荣誉前self.nWealthOrder的玩家列表
	for _, v in pairs(tbPlayers) do
		SendMailGC(v.nPlayerId, self.szMailTitle, self.szMailContent);
	end
end

-- 检查并开启该功能
function tbVipInvite:CheckVipInviteOpened()
	if self.bOpened == 1 then
		return;  -- 已经开启了，不能重复开启
	end

	local nOpenTime = GetTime() - KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME);
	if nOpenTime < self.nDaysFromServerStart * 60 * 60 * 24  then
		return;
	end
	
	self:Open();-- 开启该功能
	if not self.tbData[1] then
		self.tbData[1] = true;
		self:SendMail();-- 发邮件
		self:SaveData();
	end
end

-- 保存数据
function tbVipInvite:SaveData()
	SetGblIntBuf(GBLINTBUF_VIP_INVITE, 0, 1, self.tbData);
end


-- 记录玩家szName需要返还nBindCoin的绑金
function tbVipInvite:RecordFanhuan(szName, nBindCoin)
	if not self.tbData[szName] then
		self.tbData[szName] =  nBindCoin;
	else
		self.tbData[szName] =  self.tbData[szName] + nBindCoin;
	end
	self:SaveData();
	GlobalExcute{"SpecialEvent.tbVipInvite:SynDataItem", szName, self.tbData[szName]};
end

-- nServerId上的szName尝试获取返还
function tbVipInvite:TryGetFanhuan(szName)
	local nBindCoin = self.tbData[szName]
	if not nBindCoin then
		--数据异常 解锁玩家
		GlobalExcute{"SpecialEvent.tbVipInvite:DoGetFanhuan", szName};
		return;
	end
	self:ClearRecord(szName)
	GlobalExcute{"SpecialEvent.tbVipInvite:DoGetFanhuan", szName, nBindCoin};
end

-- 清除指定玩家的返还记录
function tbVipInvite:ClearRecord(szName)
	self.tbData[szName] = nil;
	self:SaveData();
	GlobalExcute{"SpecialEvent.tbVipInvite:SynDataItem", szName, nil};
end

function tbVipInvite:OnGCShutDown()
	self:SaveData();
end

tbVipInvite.nTimerId = nil;
tbVipInvite.nResetFPSCount = 10 * 60 * Env.GAME_FPS;
tbVipInvite.bIsBuying = tbVipInvite.bIsBuying or false;
-- 修改升级道具价格并锁定状态，保证只有锁定的人可以购买
function tbVipInvite:Lock(szName, nCoin, nDestLevel, nFactionId, nServerId)
	if self.bIsBuying then
		GlobalExcute{"SpecialEvent.tbVipInvite:LockFailed", szName, nServerId};
		return;
	end
	self.bIsBuying = true;
	--  启动一个Timer重置self.bIsBuying
	self.nTimerId = Timer:Register(self.nResetFPSCount, self.Unlock_Timer, self);
	-- 改价格
	local tbTemp = {["WareId"] = self.nIndexOfLevelUpItem, ["nOrgPrice"]=nCoin};
	ModifyIBWare(tbTemp);
	GlobalExcute{"SpecialEvent.tbVipInvite:LockSuccess", szName, nCoin, nDestLevel, nFactionId, nServerId};
end

function tbVipInvite:Unlock_Timer()
	self.bIsBuying = false;
	return 0;
end

function tbVipInvite:Unlock()
	self.bIsBuying = false;
	if self.nTimerId then
		Timer:Close(self.nTimerId);
		self.nTimer = nil;
	end
end

function SpecialEvent:CheckVipInviteOpened()
	tbVipInvite:CheckVipInviteOpened();
end

GCEvent:RegisterGCServerStartFunc(tbVipInvite.OnGCStart, tbVipInvite)
GCEvent:RegisterGCServerShutDownFunc(tbVipInvite.OnGCShutDown, tbVipInvite);
