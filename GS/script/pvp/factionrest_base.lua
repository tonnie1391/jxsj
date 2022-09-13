-------------------------------------------------------------------
--File: 	factionrest_base.lua
--Author: 	sunduoliang
--Date: 	2008-2-23 9:00
--Describe:	门派战休息时间活动
--InterFace1: JoinEvent(pPlayer)--玩家加入活动
--InterFace2: LeaveEvent(pPlayer)--玩家离开活动
--InterFace3: StartRest() --开始活动，
--InterFace3: EndRest()					--该届活动结束，关闭该届活动，一届有3场活动，3场活动后再使用，
--InterFace4: HmCloseRest()					--手动强制关闭活动；
--InterFace4: InitRest(nMapId) 初始化：nMapId:活动地图;
-------------------------------------------------------------------
Require("\\script\\pvp\\factionbattle_def.lua");
local tbBaseFactionRest	= {};	-- 	门派战休息时间活动
FactionBattle.tbBaseFactionRest = tbBaseFactionRest;
tbBaseFactionRest.tbPlayerIdList = {}; --玩家列表
tbBaseFactionRest.POS_SUM = 1;			--刷npc个数
tbBaseFactionRest.NPC_TEMPID = 2701;	--刷npc的模版ID
tbBaseFactionRest.NPC_LEVEL = 1;		--刷npc的等级
tbBaseFactionRest.NPC_SERIES = Env.SERIES_NONE; --刷npc的五行属性
tbBaseFactionRest.TRAP_CONFIG = "\\setting\\pvp\\map\\jingjiqizhi.txt"; 	--npc刷新trap点绑定文件
tbBaseFactionRest.TASK_GROUP_ID = FactionBattle.TASK_GROUP_ID;	--任务变量，任务分组ID
tbBaseFactionRest.TASK_ID1 = FactionBattle.DEGREE_TASK_ID;			--任务变量，记录积分的届
tbBaseFactionRest.TASK_ID2 = FactionBattle.SCORE_TASK_ID;			--任务变量，记录积分
tbBaseFactionRest.TASK_ID3 = FactionBattle.ELIMINATION_TASK_ID;
tbBaseFactionRest.MY_GET_POINT = {nPoint = 100, nExNum = 5, nExPoint = 300}--点旗人获得积分,额外积分
tbBaseFactionRest.MEMBER_GET_POINT = {nPoint = 20, nExNum = 5, nExPoint = 60}	--点旗人队员获得积分,额外积分
--旗帜阶段性出现 时间单位秒
tbBaseFactionRest.RESTSTATE =	
{
	[1] = {nEndTime = 90,}, --第90秒
	[2] = {nEndTime = 90,}, --第180秒
	[3] = {nEndTime = 90,}, --第270秒
	[4] = {nEndTime = 90,}, --第360秒
	[5] = {nEndTime = 60,}, --第420秒
}
local nTimeLastSum = 0;
for nRestState, tbTime in pairs(tbBaseFactionRest.RESTSTATE) do
		nTimeLastSum = nTimeLastSum + tbTime.nEndTime;
end
tbBaseFactionRest.STATE_TIEM_SUM = nTimeLastSum;	--记录总时间

--数据维护函数start-------------

function tbBaseFactionRest:InitRest(nMapId)	--数据初始化
	self.nMapId  = nMapId; 	--nMapId:活动地图

	self.nState = 0;			 	--开启状态, 0未开启，1,2,3,4,5为各阶段
	self.tbNpcIdList = {} 	--刷所有npc的ID列表
	self.nTimerId = 0;			--刷npc所产生的定时器Id
	self.nTimeLastSum = self.STATE_TIEM_SUM;
end

function tbBaseFactionRest:ClearRest()	--清除所有数据
	self.nState = 0;			--开启状态
	self.tbNpcIdList = {} --刷所有npc的ID列表
	self.nTimerId = 0;		--刷npc所产生的定时器Id	
	self.nTimeLastSum = self.STATE_TIEM_SUM;	
	self:ClearPlayerInfo();
end

function tbBaseFactionRest:ClearPlayerInfo()	--清除玩家数据
	for nPlayerId, tbPlayerInfo in pairs(self.tbPlayerIdList) do
		self:ClearSinglePlayerInfo(nPlayerId);		--清除单个玩家数据
	end	
end

function tbBaseFactionRest:ClearSinglePlayerInfo(nPlayerId)	--清除玩家数据
	self.tbPlayerIdList[nPlayerId] = {};
	self.tbPlayerIdList[nPlayerId].nHitQiZhi = 0;
	self.tbPlayerIdList[nPlayerId].tbHitQiZhiSign = {};	
end

function tbBaseFactionRest:RestSetPlayerList()--初始玩家列表数据
	self.tbPlayerIdList = {};
end
--数据维护函数end-------------

--对外接口start-------------
function tbBaseFactionRest:JoinEvent(pPlayer)--玩家加入活动
	if pPlayer.nMapId ~= self.nMapId then
		return;
	end
	if self.tbPlayerIdList[pPlayer.nId] == nil then
		self.tbPlayerIdList[pPlayer.nId] = {};
		self.tbPlayerIdList[pPlayer.nId].nHitQiZhi = 0;
		self.tbPlayerIdList[pPlayer.nId].tbHitQiZhiSign = {};
		self.tbPlayerIdList[pPlayer.nId].nState = 0;	--参加活动的情况
	end
	if self.nState > 0 then
		self.tbPlayerIdList[pPlayer.nId].nState = 1;	--参加活动的情况
		self:OpenSingleShowMsg(pPlayer);	--参加活动的情况		
	end
end

function tbBaseFactionRest:LeaveEvent(pPlayer)--玩家离开活动
	if self.tbPlayerIdList[pPlayer.nId] ~= nil then
		self:CloseSingleShowMsg(pPlayer);
	end
end

function tbBaseFactionRest:EndRest()
	self:RestSetPlayerList();
end

function tbBaseFactionRest:StartRest()	--开启活动
	if self.nState > 0 then
		print("活动进行开启，请完毕后再开启。不能重启开启。");
		return 0;
	end
	self.nTimerId = Timer:Register( self.RESTSTATE[1].nEndTime * Env.GAME_FPS ,  self.StartState,  self);	
	self:StartState();
end
--对外接口end-------------

function tbBaseFactionRest:CallRandomNpc()
	self:GetNpcPos();--得到刷npc的随机点
	for nPos=1, self.POS_SUM do
		local pNPC = KNpc.Add2(self.NPC_TEMPID, self.NPC_LEVEL, self.NPC_SERIES, self.nMapId * 1, self.tbNpcPos[nPos].nX * 1, self.tbNpcPos[nPos].nY * 1, 0, 0, 0)
		if pNPC == nil then
			print("门派竞技休息间活动，召唤npc失败。");
			Dbg:WriteLog("门派竞技休息间活动",  "手动关闭定时器失败");
		else
			local tbNpcInfo = pNPC.GetTempTable("FactionBattle");
			tbNpcInfo.tbBaseClass = self;
			self.tbNpcIdList[#self.tbNpcIdList+ 1] = pNPC.dwId;
		end
	end
end

function tbBaseFactionRest:StartState()
	self.nState = self.nState + 1;
	if self.nState > #self.RESTSTATE then
		self:AutoCloseRest();
		return 0;
	else
		if self.nState > 1 then
			self.nTimeLastSum = self.nTimeLastSum - self.RESTSTATE[self.nState - 1].nEndTime;
		end
		self:ClearNpc();	--清除上次npc
		self:CallRandomNpc(); --召唤npc
		self:BroadcastMsg();	--公告
		self:OpenShowMsg(); --打开所有玩家界面
		return self.RESTSTATE[self.nState].nEndTime * Env.GAME_FPS;
	end
	return 0;
end

function tbBaseFactionRest:GetNpcPos()		--从配置文件获得npc的trap
	local tbsortpos = Lib:LoadTabFile(self.TRAP_CONFIG);
	local nLineCount = #tbsortpos;
	local tbClassPos = {};
	for nLine=1, nLineCount do
		local nZone = tonumber(tbsortpos[nLine].ZONE) or 0;
		local nTrapX = tonumber(tbsortpos[nLine].TRAPX);
		local nTrapY = tonumber(tbsortpos[nLine].TRAPY);
		if nZone == 0 then
			nZone = #tbClassPos + 1
		end
		if tbClassPos[nZone] == nil then
			tbClassPos[nZone] = {};
		end
		local nPosNo = (#tbClassPos[nZone]+ 1);
		tbClassPos[nZone][nPosNo] = {};
		tbClassPos[nZone][nPosNo].nX = nTrapX;
		tbClassPos[nZone][nPosNo].nY = nTrapY;
	end
	tbClassPos = self:GetRandomList(tbClassPos, #tbClassPos);
	self.tbNpcPos = {};
	for nPos=1, self.POS_SUM do
		tbClassPos[nPos] = self:GetRandomList(tbClassPos[nPos], #tbClassPos[nPos]);
		self.tbNpcPos[nPos] = {};
		self.tbNpcPos[nPos].nX = tbClassPos[nPos][1].nX;
		self.tbNpcPos[nPos].nY = tbClassPos[nPos][1].nY;
	end
end

function tbBaseFactionRest:GetRandomList(tbitem, nmax)	--把table进行随机，返回随机表
	for ni = 1, nmax do
		local p = MathRandom(1, nmax);
		tbitem[ni], tbitem[p] = tbitem[p], tbitem[ni];
	end
	return tbitem;
end

--
function tbBaseFactionRest:BroadcastMsg()	--发布公共公告
	for nPlayerId, tbPlayerInfo in pairs(self.tbPlayerIdList) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer ~= nil then
			if (pPlayer.nMapId == self.nMapId) then
				local szAnnouce = "";
				self.tbPlayerIdList[pPlayer.nId].nState = 1;
				if self.nState == 1 then
				 	szAnnouce = "Cờ Thi Đấu Môn Phái đã xuất hiện, Tổ đội tìm cờ sẽ tích lũy được nhiều điểm hơn.";
				else
					szAnnouce = string.format("Cờ %s đã xuất hiện, Tổ đội tìm cờ sẽ tích lũy được nhiều điểm hơn.",self.nState); 
				end
				Dialog:SendBlackBoardMsg(pPlayer, szAnnouce)
			end
		end
	end
end
--

--界面相关函数start--------------
function tbBaseFactionRest:OpenShowMsg()			--打开所有玩家列表界面显示
	for nPlayerId, tbPlayerInfo in pairs(self.tbPlayerIdList) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer ~= nil and self.nMapId == pPlayer.nMapId then	-- 对存在没有成功开启门派竞技的玩家也有非正常显示问题
			self:OpenSingleShowMsg(pPlayer);
		end
	end
end

function tbBaseFactionRest:OpenSingleShowMsg(pPlayer)	--打开单个玩家界面
	if (not pPlayer or self.tbPlayerIdList[pPlayer.nId].nState == 0) then	--参加活动的情况
		return;
	end
	Dialog:ShowBattleMsg(pPlayer,  0,  0); -- 关闭界面
	if self.nState > 0 then
		local szMsgFormat = "<color=green>Hoạt động tìm cờ: <color><color=white>%s<color>\n\n";
		local nLastFrameTime = tonumber(self.RESTSTATE[self.nState].nEndTime * Env.GAME_FPS);
		szMsgFormat = szMsgFormat .. string.format("<color=green>Cờ sẽ biến mất sau: %s giây<color>", self.nState) .. "<color=white>%s<color>";
		Dialog:SetBattleTimer(pPlayer,  szMsgFormat, self.nTimeLastSum * Env.GAME_FPS, nLastFrameTime);
		self:UpdateShowMsg(pPlayer);
		
	elseif self.nState == 0 then
		local nLastFrameTime = 0;
		local szMsgFormat = "<color=green>Hoạt động chưa bắt đầu: <color><color=white>%s<color>";
		Dialog:SetBattleTimer(pPlayer,  nLastFrameTime,  szMsgFormat);
		local szMsg = "\nCờ chưa xuất hiện.";
		Dialog:SendBattleMsg(pPlayer,  szMsg);
	end
	self.tbPlayerIdList[pPlayer.nId].nState = 1 	--处于活动中
	Dialog:ShowBattleMsg(pPlayer,  1,  0); --开启界面
	
end

function tbBaseFactionRest:UpdateShowMsg(pPlayer)	--更新显示玩家界面内容
	local szFindQiZhiMsg = "";
	if self.tbPlayerIdList[pPlayer.nId].nHitQiZhi == self.nState and self.nState > 0 then
		szFindQiZhiMsg = "\n<color=yellow>Đã tìm thấy cờ<color>";
	end
	szFindQiZhiMsg = string.format("%s\nTìm kiếm cờ trong lần này: <color=yellow>%s/%s<color>", szFindQiZhiMsg, self.tbPlayerIdList[pPlayer.nId].nHitQiZhi, #self.RESTSTATE);
	local nGradePoint = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_ID2);
		local szGradePointMsg = string.format("\nTích lũy hiện tại: <color=yellow>%s<color> điểm", nGradePoint);
	local szMsg = string.format("%s%s", szFindQiZhiMsg, szGradePointMsg);
	Dialog:SendBattleMsg(pPlayer,  szMsg);
end

function tbBaseFactionRest:CloseShowMsg()			--关闭所有玩家列表的界面
	for nPlayerId, tbPlayerInfo in pairs(self.tbPlayerIdList) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer ~= nil then
			self:CloseSingleShowMsg(pPlayer);
		end
	end
end

function tbBaseFactionRest:CloseSingleShowMsg(pPlayer)	--关闭单个玩家界面
	Dialog:ShowBattleMsg(pPlayer,  0,  0); -- 关闭界面
	self.tbPlayerIdList[pPlayer.nId].nState = 0;
end
--界面相关函数end--------------

--定时器相关start------------
function tbBaseFactionRest:AutoCloseRest()	--定时器自动关闭
	self:BaseCloseRest();
	return 0;
end

function tbBaseFactionRest:HmCloseRest()	--手动关闭
	if self.nState == 0 then
		print("门派竞技休息间活动，该定时器已经关闭，无定时器可关闭。");
		Dbg:WriteLog("门派竞技休息间活动",  "手动关闭定时器失败");
		return 0;
	end
	self:BaseCloseRest();
	Timer:Close(self.nTimerId);
end

function tbBaseFactionRest:BaseCloseRest()	--关闭基类
	self:ClearNpc();
	self:ClearRest();
	--self:CloseShowMsg();
end

function tbBaseFactionRest:ClearNpc()	--清除npc
	if self.tbNpcIdList ~= nil or #self.tbNpcIdList ~= 0 then 
		for nNpcNo=1, #self.tbNpcIdList do
			local pNpc = KNpc.GetById(self.tbNpcIdList[nNpcNo]);
			if pNpc ~= nil then
				pNpc.Delete();
			end
		end
	end
	self.tbNpcIdList = {};	
end
--定时器相关start------------
