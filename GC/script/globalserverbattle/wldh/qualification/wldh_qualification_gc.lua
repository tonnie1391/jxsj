-------------------------------------------------------
-- 文件名　：wldh_qualification_gc.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-09-08 10:38:00
-- 文件描述：
-------------------------------------------------------

Require("\\script\\globalserverbattle\\wldh\\qualification\\wldh_qualification_def.lua");

if (not MODULE_GC_SERVER) then
	return 0;
end

local tbQualification = Wldh.Qualification;

-- 计划任务
function Wldh:MakeProssession()
	Wldh.Qualification:MakeProssession_GC();
end

function Wldh:FinalProssession()
	Wldh.Qualification:FinalProssession_GC();
end

function Wldh:UpdateYingxiong()
	Wldh.Qualification:UpdateYingxiong_GC();
end

function Wldh:ConfirmCaptain()
	Wldh.Qualification:ConfirmCaptain_GC();
end
-- end

function tbQualification:SaveBuffer()
	
	-- 存入Global Buffer
	SetGblIntBuf(GBLINTBUF_WLDH_MEMBER, 0, 0, self.tbGblBuf_Member);
	
	-- 同步给gs
	for szPlayerName, tbMemberInfo in pairs(self.tbGblBuf_Member) do
		GlobalExcute({"Wldh.Qualification:LoadMember", szPlayerName, tbMemberInfo});
	end
end

function tbQualification:ClearBuffer()
	self.tbGblBuf_Member = {};
	SetGblIntBuf(GBLINTBUF_WLDH_MEMBER, 0, 0, {});
	GlobalExcute({"Wldh.Qualification:ClearBuffer_GS"});
end

-- 合服时候用
function tbQualification:MergeCoZoneAndMainZoneBuffer(tbSubBuf)
	print("[tbQualification MergeCoZoneAndMainZoneBuffer] start!!");

	self:StartEvent();
	if (not self.tbGblBuf_Member) then
		self.tbGblBuf_Member = {};
	end
	if (tbSubBuf) then
		for szName, tbInfo in pairs(tbSubBuf) do
			self.tbGblBuf_Member[szName] = tbInfo;
		end
	end
		
	self:SaveBuffer();
end

function tbQualification:Broadcast(nState, szCaptainName1, szCaptainName2)
	GlobalExcute({"Wldh.Qualification:Broadcast_GS", nState, szCaptainName1, szCaptainName2});
end

function tbQualification:ConfirmCaptain_GC()
	
	if self:CheckServer() ~= 1 then
		return 0;
	end
	
	-- 判断时间
	local nNowDate = tonumber(GetLocalDate("%Y%m%d%H%M"));
	if nNowDate < self.CAPTAIN_STATE[2] then
		return;
	end
	
	-- 已经产生过了, 1-武林荣誉100, 2-最终名单, 3-盟主
	local nProssession = KGblTask.SCGetDbTaskInt(DBTASK_WLDH_PROSSESSION);
	if nProssession >= 3 then
		return;
	end
	
	-- 排序
	local tbSort = {};
	for szPlayerName, tbMemberInfo in pairs(self.tbGblBuf_Member) do
		tbMemberInfo.nCaptain = 0;
		table.insert(tbSort, {szPlayerName, tbMemberInfo});
	end
	table.sort(tbSort, self._Sort);
	
	self.tbGblBuf_Member[tbSort[1][1]].nCaptain = 1;
	self.tbGblBuf_Member[tbSort[2][1]].nCaptain = 1;
	
	self:SaveBuffer();
	self:Broadcast(3, tbSort[1][1], tbSort[2][1]);
	self:SendMail(3);
	
	-- 设全局变量
	KGblTask.SCSetDbTaskInt(DBTASK_WLDH_PROSSESSION, 3);
end

function tbQualification:UpdateYingxiong_GC()
	
	if self:CheckServer() ~= 1 then
		return 0;
	end
	
	-- 判断时间
	local nNowDate = tonumber(GetLocalDate("%Y%m%d%H%M"));
	if nNowDate < self.MEMBER_STATE[1] or nNowDate > self.MEMBER_STATE[2] then
		return;
	end
	
	PlayerHonor:OnSchemeUpdatePrettygirlHonorLadder();
end

-- 生成member列表，存入global buffer
function tbQualification:SetMemeber(tbPlayerRank)
	
	-- 转换下(名字做索引)
	for nRank, tbPlayer in pairs(tbPlayerRank or {}) do
		local szPlayerName = tbPlayer.szPlayerName;
		if not self.tbGblBuf_Member[szPlayerName] then
			self.tbGblBuf_Member[szPlayerName] = {};
			self.tbGblBuf_Member[szPlayerName].nVote = 0;
			self.tbGblBuf_Member[szPlayerName].nCaptain = 0; 
		end
	end
	
	self:SaveBuffer();
end
	
-- 9月21号3点更新武林荣誉后，取排名前100者，获得参赛资格
function tbQualification:MakeProssession_GC()
	
	if self:CheckServer() ~= 1 then
		return 0;
	end
	
	-- 判断时间
	local nNowDate = tonumber(GetLocalDate("%Y%m%d%H%M"));
	if nNowDate < self.MEMBER_STATE[1] or nNowDate > self.MEMBER_STATE[2] then
		return;
	end
	
	-- 已经产生过了, 1-武林荣誉100, 2-最终名单, 3-盟主
	local nProssession = KGblTask.SCGetDbTaskInt(DBTASK_WLDH_PROSSESSION);
	if nProssession >= 1 then
		return;
	end
	
	-- 取武林荣誉排行榜，返回table
	local tbPlayerRank = GetTotalLadderPart(
		Ladder:GetType(0, Ladder.LADDER_CLASS_WULIN, Ladder.LADDER_TYPE_WULIN_HONOR_WULIN, 0), 
		1, 100);	

	-- 生成名单列表
	self:SetMemeber(tbPlayerRank);
	self:Broadcast(1);
	self:SendMail(1);
	
	-- 设全局变量
	KGblTask.SCSetDbTaskInt(DBTASK_WLDH_PROSSESSION, 1);
end

-- 9月28号0点取英雄帖排行榜
function tbQualification:FinalProssession_GC()
	
	if self:CheckServer() ~= 1 then
		return 0;
	end
	
	-- 判断时间
	local nNowDate = tonumber(GetLocalDate("%Y%m%d%H%M"));
	if nNowDate < self.CAPTAIN_STATE[1] or nNowDate > self.CAPTAIN_STATE[2] then
		return;
	end
	
	-- 已经产生过了, 1-武林荣誉100, 2-最终名单, 3-盟主
	local nProssession = KGblTask.SCGetDbTaskInt(DBTASK_WLDH_PROSSESSION);
	if nProssession >= 2 then
		return;
	end
	
	-- 取英雄帖排行榜(1-50)，返回table
	local tbPlayerRank = GetTotalLadderPart(
		Ladder:GetType(0, Ladder.LADDER_CLASS_LADDER, Ladder.LADDER_TYPE_LADDER_ACTION, Ladder.LADDER_TYPE_LADDER_ACTION_PRETTYGIRL), 
		1, 50);	

	-- 生成名单列表
	self:SetMemeber(tbPlayerRank);
	self:Broadcast(2);
	self:SendMail(2);
	
	-- 设全局变量
	KGblTask.SCSetDbTaskInt(DBTASK_WLDH_PROSSESSION, 2);
end

-- 启动的时候载入global buffer
function tbQualification:StartEvent()
	
	-- 存拥有资格的玩家列表(包括每人的投票)
	local tbBuf = GetGblIntBuf(GBLINTBUF_WLDH_MEMBER, 0);
	if tbBuf and type(tbBuf) == "table" then
		self.tbGblBuf_Member = tbBuf;
	end
end

-- 同步给gs
function tbQualification:OnRecConnectEvent(nConnectId)	
	for szPlayerName, tbMemberInfo in pairs(self.tbGblBuf_Member) do
		GSExcute(nConnectId, {"Wldh.Qualification:LoadMember", szPlayerName, tbMemberInfo});
	end
end

function tbQualification:DoVote_GC(szPlayerName)
	
	if not self.tbGblBuf_Member[szPlayerName] then
		return;
	end
	
	self.tbGblBuf_Member[szPlayerName].nVote = self.tbGblBuf_Member[szPlayerName].nVote + 1;
	
	-- 存入Global Buffer
	self:SaveBuffer();
end

function tbQualification:SendMail(nState)
	
	local tbName = {};
	for szPlayerName, tbMemberInfo in pairs(self.tbGblBuf_Member) do
		table.insert(tbName, szPlayerName);
	end
	
	local tbMailInfo = 
	{
		szTitle = "武林大会参赛通知", 
		szContent = string.format([[
您好：
    恭喜您获得这届武林大会的参赛资格！
    <color=yellow>首次比赛将在10月9日开始<color>，<color=yellow>临安府的武林大会接引人<color>将会负责传送参赛选手进入比赛场地，请提前做好准备！
    <color=green>注：修炼珠上可以查询参赛资格名单。<color>	
]])};
	Mail.tbParticularMail:SendMail(tbName, tbMailInfo);
end

-- 清除美女榜荣誉，同时更新排行榜的名字，每次起服务器调一次
function tbQualification:ClearGirlLadder()
	
	-- 不在时间段返回
	local nNowDate = tonumber(GetLocalDate("%Y%m%d%H%M"));
	if nNowDate >= self.MEMBER_STATE[1] then
		return;
	end
	
	-- 清排行数据
	local nLadderType = Ladder:GetType(0, Ladder.LADDER_CLASS_LADDER, Ladder.LADDER_TYPE_LADDER_ACTION, Ladder.LADDER_TYPE_LADDER_ACTION_PRETTYGIRL);
	local nDataClass = PlayerHonor.HONOR_CLASS_PRETTYGIRL;
	
	ClearTotalLadderData(nLadderType, nDataClass, 0, 1);
	PlayerHonor:OnSchemeUpdatePrettygirlHonorLadder();
end

-- 调试使用
function tbQualification:AddMember(szPlayerName)

	if not self.tbGblBuf_Member[szPlayerName] then
		self.tbGblBuf_Member[szPlayerName] = {};
		self.tbGblBuf_Member[szPlayerName].nVote = 0;
		self.tbGblBuf_Member[szPlayerName].nCaptain = 0; 
	end
	
	self:SaveBuffer();
end

function tbQualification:RemoveMember(szPlayerName)
	
	if not self.tbGblBuf_Member[szPlayerName] then
		return;
	end
	
	self.tbGblBuf_Member[szPlayerName] = nil;
	self:SaveBuffer();
end

GCEvent:RegisterGCServerStartFunc(Wldh.Qualification.ClearGirlLadder, Wldh.Qualification);
GCEvent:RegisterGCServerStartFunc(Wldh.Qualification.StartEvent, Wldh.Qualification);
