-- 文件名　：chenchongzhen_room.lua
-- 创建者　：zhangjunjie
-- 创建时间：2012-02-20 14:37:29
-- 描述：room

ChenChongZhen.tbRoom = {};

ChenChongZhen.tbRoom[1]  = {};
ChenChongZhen.tbRoom[2]  = {};
ChenChongZhen.tbRoom[3]  = {};
ChenChongZhen.tbRoom[4]  = {};
ChenChongZhen.tbRoom[5]  = {};
ChenChongZhen.tbRoom[6]  = {};
ChenChongZhen.tbRoom[7]  = {};

local tb1stRoom = ChenChongZhen.tbRoom[1];
local tb2ndRoom = ChenChongZhen.tbRoom[2];
local tb3rdRoom = ChenChongZhen.tbRoom[3];
local tb4thRoom = ChenChongZhen.tbRoom[4];
local tb5thRoom = ChenChongZhen.tbRoom[5];
local tb6thRoom = ChenChongZhen.tbRoom[6];
local tb7thRoom = ChenChongZhen.tbRoom[7];

------------room logic
--room 1
--define
tb1stRoom.tbMachineSwitchNpc = --光圈npc
{
--	["trap_machine1"] =	{
--			{{48896/32,104992/32},{48640/32,104864/32},{48800/32,105056/32}},
--			{{48352/32,105216/32},{48544/32,105344/32}},
--	},
	["trap_machine2"] = {
			{{49472/32,104128/32},{49696/32,104256/32},{49824/32,104384/32}},
			{{49152/32,104416/32},{49472/32,104608/32},{49312/32,104480/32}},
	},
	["trap_machine3"] = {
			{{50624/32,103168/32},{50752/32,103232/32},{50848/32,103392/32}},
			{{50464/32,103808/32},{50464/32,103552/32},{50592/32,103680/32},{50720/32,103840/32}},
	},
	["trap_machine4"] = {
			{{51680/32,102304/32},{51872/32,102368/32}},
			{{51552/32,102720/32},{51392/32,102752/32},{51328/32,102496/32},{51712/32,102912/32}},
	},
};

tb1stRoom.tbMachineSwitchBackPos =
{
	["trap_machine2"] = {49440/32,104448/32},
	["trap_machine3"] = {50656/32,103616/32},
	["trap_machine4"] = {51520/32,102528/32},
};

tb1stRoom.tbMachineSwitchInfo = 
{
	["trap_machine2"] = {9988},
	["trap_machine3"] = {9988,9989,9990},
	["trap_machine4"] = {9988,9989,9990},
};

tb1stRoom.tbWhiteSwitch = {9987,2};--白色光圈

tb1stRoom.nOpenSwitchTemplateId = 9988;

tb1stRoom.tbMachineManager = --管理机关的开关
{
	[9988] = {10,"OpenSwitch"},
	[9989] = {5 ,"SufferRedDebuff",2661},
	[9990] = {5 ,"SufferBlueDebuff",2470},
};

tb1stRoom.tbTrapNpc = --trap上的站位npc
{
	--["trap_machine1"] = {9991,{{48512/32,105088/32},{48576/32,105152/32},{48640/32,105216/32},{48704/32,105280/32}}},
	["trap_machine2"] = {9991,{{49344/32,104256/32},{49408/32,104320/32},{49504/32,104416/32},{49600/32,104512/32}}},
	["trap_machine3"] = {9991,{{50592/32,103456/32},{50656/32,103520/32},{50720/32,103584/32},{50784/32,103648/32}}},
	["trap_machine4"] = {9991,{{51392/32,102336/32},{51488/32,102432/32},{51584/32,102528/32},{51680/32,102624/32}}},	
};

tb1stRoom.tbMachineEnemeyNpc =	--每个机关前对应的敌人 
{
	["trap_machine1"] = {9992,{{48672/32,104928/32},{49088/32,104608/32},{49024/32,104832/32},{48864/32,104800/32},{49376/32,104512/32}}},
	["trap_machine2"] = {9993,{{49632/32,104320/32},{49920/32,104320/32},{50112/32,104224/32},{50304/32,103904/32},{50592/32,103776/32}}},
	["trap_machine3"] = {9994,{{50848/32,103136/32},{51136/32,103104/32},{51136/32,102848/32},{50912/32,103584/32},{51360/32,102560/32}}},
	["trap_machine4"] = {9995,{{51552/32,102272/32},{51904/32,102112/32},{51904/32,101824/32},{51744/32,102144/32},{51744/32,102464/32}}},	
};

tb1stRoom.nMaxEnemyNpcCount = 30;	--最多刷出40只怪物

tb1stRoom.nScanPlayerDelay = 5;	--9帧检测一次周围玩家

tb1stRoom.nScanPlayerRange = 2;	--2个格子范围内玩家进入就算踩上

tb1stRoom.tbTalkEndNpc = {9996,{52032/32,101920/32}};	--结束后的对话npc


--logic
--处理机关
function tb1stRoom:ProcessMachine(szTrapName)
	if self:IsRoomStart() ~= 1 or self:IsRoomFinished() == 1 or self:IsRoomFailed() == 1 then
		return 0;
	end
	if self.tbTrapSwitchInfo[szTrapName] and self.tbTrapSwitchInfo[szTrapName] ~= 1 then
		local tbPos = self.tbMachineSwitchBackPos[szTrapName];
		if tbPos then
			me.NewWorld(me.nMapId,tbPos[1],tbPos[2]);
		end
		self:AddTrapEnemy(szTrapName);
	else
		return 0;
	end
end

function tb1stRoom:ClearNpc()
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,9991);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,self.tbWhiteSwitch[1]);
	for _,tbInfo in pairs(self.tbMachineEnemeyNpc) do
		ClearMapNpcWithTemplateId(self.tbBase.nMapId,tbInfo[1]);
	end
	for nTempId,_ in pairs(self.tbMachineManager) do
		ClearMapNpcWithTemplateId(self.tbBase.nMapId,nTempId);
	end
end

function tb1stRoom:StartRoom()
	self.nIsStart = 1;
	self.nIsFailed = 0;
	self:ClearRoom();
	self:InitTrapInfo();
	self:InitTrapEnemy();
	self:StartSwitch();
	self.tbBase:UpdateUiState("Xích Hầu Trong Đêm\n\n<color=red>Tiêu diệt toàn bộ trinh sát<color>");
end

function tb1stRoom:InitTrapEnemy()
	self.nTrapEnemyCount = 0;
	self.tbTrapEnemy = {};	--每个trap前的怪物数量
	for szName , _ in pairs(self.tbMachineEnemeyNpc) do
		self:AddTrapEnemy(szName);
	end
end

--每关开始时候刷出障碍npc
function tb1stRoom:InitTrapInfo()
	self.tbTrapNpcInfo = {};
	self.tbTrapSwitchInfo = {};	--刚开始，标记每个机关都没打开
	self.tbFootOnSwitch = {};	--标记当前是否有人踩上
	for szTrapName,tbInfo in pairs(self.tbTrapNpc) do
		if not self.tbTrapNpcInfo[szTrapName] then
			self.tbTrapNpcInfo[szTrapName] = {};
		end
		self.tbTrapSwitchInfo[szTrapName] = 0;
		self.tbFootOnSwitch[szTrapName] = {0,0};		
		local nTemplateId = tbInfo[1];
		local tbPosInfo = tbInfo[2];
		for _,tbPos in pairs(tbPosInfo) do
			local pNpc = KNpc.Add2(nTemplateId,125,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
			if pNpc then
				table.insert(self.tbTrapNpcInfo[szTrapName],pNpc.dwId);
			end
		end
	end
end

function tb1stRoom:IsFootOnOtherTrap(szTrapName,nIndex)
	if not self.tbFootOnSwitch[szTrapName] or not self.tbFootOnSwitch[szTrapName][nIndex] then
		return 0;
	end
	return self.tbFootOnSwitch[szTrapName][2 - nIndex + 1];
end

--加trap上的npc
function tb1stRoom:AddTrapNpc(szTrapName,nIndex)
	if self.tbTrapSwitchInfo[szTrapName] == 0 then	--如果未开启，说明npc也没删除
		return 0;
	end
	if self:IsFootOnOtherTrap(szTrapName,nIndex) == 1 and self.tbTrapSwitchInfo[szTrapName] == 1 then
		return 0;
	end
	if not self.tbTrapNpcInfo[szTrapName] then
		self.tbTrapNpcInfo[szTrapName] = {};
	end
	for _,nNpcId in pairs(self.tbTrapNpcInfo[szTrapName]) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			pNpc.Delete();
		end
	end
	self.tbTrapNpcInfo[szTrapName] = {};	--先清空原来的npc
	self.tbTrapSwitchInfo[szTrapName] = 0;	--标记未打开
	self.tbFootOnSwitch[szTrapName][nIndex] = 0;	--当前没人踩
	local tbInfo = self.tbTrapNpc[szTrapName];
	local nTemplateId = tbInfo[1];
	local tbPosInfo = tbInfo[2];
	for _,tbPos in pairs(tbPosInfo) do
		local pNpc = KNpc.Add2(nTemplateId,125,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
		if pNpc then
			table.insert(self.tbTrapNpcInfo[szTrapName],pNpc.dwId);
		end
	end
end

--删除trap上的npc
function tb1stRoom:DelTrapNpc(szTrapName)
	if self.tbTrapSwitchInfo[szTrapName] == 1 then	
		return 0;
	end
	if not self.tbTrapNpcInfo[szTrapName] then
		self.tbTrapNpcInfo[szTrapName] = {};
	end
	for _,nNpcId in pairs(self.tbTrapNpcInfo[szTrapName]) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			pNpc.Delete();
		end
	end
	self.tbTrapNpcInfo[szTrapName] = {};	--先清空原来的npc
	self.tbTrapSwitchInfo[szTrapName] = 1;	--标记打开
end

--增加对应trap的怪物
function tb1stRoom:AddTrapEnemy(szTrapName)
	if not self.tbTrapEnemy[szTrapName] then
		self.tbTrapEnemy[szTrapName] = 0;
	end
	local tbInfo = self.tbMachineEnemeyNpc[szTrapName];
	local nTemplateId = tbInfo[1];
	local tbPosInfo = tbInfo[2];
	for _,tbPos in pairs(tbPosInfo) do
		if self.tbTrapEnemy[szTrapName] >= self.nMaxEnemyNpcCount then	--如果达到上限就不刷了
			break;
		end
		local pNpc = KNpc.Add2(nTemplateId,125,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
		if pNpc then
			self.tbTrapEnemy[szTrapName] = (self.tbTrapEnemy[szTrapName] or 0) + 1;
			Npc:RegPNpcOnDeath(pNpc,self.OnTrapEnemyDeath,self,szTrapName); 
			self.nTrapEnemyCount = self.nTrapEnemyCount + 1;	--加上计数
		end
	end
end

function tb1stRoom:OnTrapEnemyDeath(szTrapName)
	self.tbTrapEnemy[szTrapName] = (self.tbTrapEnemy[szTrapName] or 0) - 1;
	if self.tbTrapEnemy[szTrapName] <= 0 then
		self.tbTrapEnemy[szTrapName] = 0;
	end
	self.nTrapEnemyCount = self.nTrapEnemyCount - 1;
	if self.nTrapEnemyCount <= 0 then
		self.nTrapEnemyCount = 0;
		self:EndRoom();
	end
end

--光圈开始活动
function tb1stRoom:StartSwitch()
	for szName,tbInfo in pairs(self.tbMachineSwitchNpc) do
		for nIndex,_ in ipairs(tbInfo) do
			self:AddSwitch(szName,nIndex);
		end
	end
end

--加光圈
function tb1stRoom:AddSwitch(szTrapName,nIndex)
	local tbInfo = self.tbMachineSwitchNpc[szTrapName];
	local tbPos = tbInfo[nIndex][MathRandom(#tbInfo[nIndex])];
	local tbWaitNpcInfo = self.tbWhiteSwitch;
	local nTempId = tbWaitNpcInfo[1];
	local nTime = tbWaitNpcInfo[2] * Env.GAME_FPS;
	local pNpc = KNpc.Add2(nTempId,125,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
	if pNpc then
		pNpc.GetTempTable("ChenChongZhen").nDeathTimer = Timer:Register(nTime,self.OnWhiteNpcDeath,self,pNpc.dwId,szTrapName,nIndex,tbPos[1],tbPos[2]);
	end
end

function tb1stRoom:OnWhiteNpcDeath(nNpcId,szTrapName,nIndex,nX,nY)
	if not self.tbBase or self.tbBase:IsOpen() ~= 1 then
		return 0;
	end
	local pNpc = KNpc.GetById(nNpcId);
	if pNpc then
		pNpc.Delete();
	else
		return 0;
	end	
	local tbMachine = self.tbMachineSwitchInfo[szTrapName];
	if not tbMachine then
		return 0;
	end
	local nIdx = MathRandom(#tbMachine);	--随机出现什么颜色的
	local nTempId = tbMachine[nIdx];
	local tbInfo = self.tbMachineManager[nTempId];
	if not tbInfo then
		return 0;
	end
	local nTime  =  tbInfo[1] * Env.GAME_FPS;
	local pNewNpc = KNpc.Add2(nTempId,125,-1,self.tbBase.nMapId,nX,nY);
	if pNewNpc then
		pNewNpc.GetTempTable("ChenChongZhen").nCount = 0;	--检测了多少次
		pNewNpc.GetTempTable("ChenChongZhen").nTime = nTime;	--总次数
		pNewNpc.GetTempTable("ChenChongZhen").nScanPlayerTimer = Timer:Register(self.nScanPlayerDelay,self.OnSwitchScanPlayer,self,pNewNpc.dwId,szTrapName,nIndex);
		self:OnSwitchScanPlayer(pNewNpc.dwId,szTrapName,nIndex);
	end
	return 0;
end

function tb1stRoom:OnSwitchScanPlayer(nNpcId,szTrapName,nIndex)
	if not self.tbBase or self.tbBase:IsOpen() ~= 1 then
		return 0;
	end
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end	
	pNpc.GetTempTable("ChenChongZhen").nCount = pNpc.GetTempTable("ChenChongZhen").nCount + self.nScanPlayerDelay;
	if pNpc.GetTempTable("ChenChongZhen").nCount >= pNpc.GetTempTable("ChenChongZhen").nTime then
		self:AddSwitch(szTrapName,nIndex);
		if pNpc.nTemplateId == self.nOpenSwitchTemplateId then
			self.tbFootOnSwitch[szTrapName][nIndex] = 0;	--没人踩
			self:AddTrapNpc(szTrapName,nIndex);
		end
		pNpc.Delete();
		return 0;
	else
		local tbNearPlayer = KNpc.GetAroundPlayerList(nNpcId,self.nScanPlayerRange);	
		local szFun = self.tbMachineManager[pNpc.nTemplateId][2];
		local nParam = self.tbMachineManager[pNpc.nTemplateId][3];
		if szFun and self[szFun] then
			self[szFun](self,nNpcId,szTrapName,tbNearPlayer,nIndex,nParam);				
		end
	end
end

function tb1stRoom:OpenSwitch(nNpcId,szTrapName,tbPlayer,nIndex)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	if not tbPlayer then
		return 0;
	end
	local nCount = 0;
	for _,pPlayer in pairs(tbPlayer) do
		if pPlayer and pPlayer.IsDead() ~= 1 then
			nCount = nCount + 1;
		end
	end
	if nCount <= 0 then
		self.tbFootOnSwitch[szTrapName][nIndex] = 0;	--没人踩
		self:AddTrapNpc(szTrapName,nIndex);
		return 0;
	end
	self.tbFootOnSwitch[szTrapName][nIndex] = 1;	--标记当前是踩上的
	if self.tbTrapSwitchInfo[szTrapName] == 1 then
		return 0;
	else
		self:DelTrapNpc(szTrapName);
	end
end

function tb1stRoom:SufferRedDebuff(nNpcId,szTrapName,tbPlayer,nIndex,nSkillId)
	if not tbPlayer or #tbPlayer <= 0 then
		return 0;
	end
	for _,pPlayer in pairs(tbPlayer) do
		if pPlayer and pPlayer.IsDead() ~= 1 then
			pPlayer.AddSkillState(nSkillId,19,1,4 * Env.GAME_FPS,0,0,1);
		end
	end
end

function tb1stRoom:SufferBlueDebuff(nNpcId,szTrapName,tbPlayer,nIndex,nSkillId)
	if not tbPlayer or #tbPlayer <= 0 then
		return 0;
	end
	for _,pPlayer in pairs(tbPlayer) do
		if pPlayer and pPlayer.IsDead() ~= 1 then
			pPlayer.AddSkillState(nSkillId,19,1,4 * Env.GAME_FPS,0,0,1);
		end
	end
end


function tb1stRoom:FailedRoom()
	self.nIsFailed = 1;
	self.nIsStart = 0;
	self:ClearRoom();
	self.tbBase:StartCurrentRoom();
	self.tbBase:AllBlackBoard("Thất bại rồi! Hãy làm lại từ đầu đi.");
end

function tb1stRoom:IsRoomFailed()
	return self.nIsFailed or 0;
end

function tb1stRoom:EndRoom()
	self.nIsFinished = 1;
	self.tbBase:DropBox();	--加宝箱
	self.tbBase:AllBlackBoard("Trận pháp đã biến mất. Mau đi bắt Trinh sát!");
	self:ClearRoom();
	self:RoomFinish();
end

function tb1stRoom:ClearRoom()
	self:ClearNpc();
	self.tbBase:UpdateUiState("");
end

function tb1stRoom:IsRoomStart()
	return self.nIsStart or 0;
end

function tb1stRoom:IsRoomFinished()
	return self.nIsFinished or 0;
end

function tb1stRoom:RoomFinish()
	self.tbBase:RoomFinish();
	self:AddTalkEndNpc();
end

function tb1stRoom:AddTalkEndNpc()
	local nTempId = self.tbTalkEndNpc[1];
	local tbPos = self.tbTalkEndNpc[2];
	local pNewNpc = KNpc.Add2(nTempId,125,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);	
	if not pNewNpc then
		Dbg:WriteLog("ChenChongZhen","Room 1 Add End Npc Failed!",self.tbBase.nMapId,self.tbBase.nServerId,self.tbBase.nPlayerId);	
	end
end
---room 1 end-----------


---room 2
--define
tb2ndRoom.tbDialogGirl = {9997,{52896/32,100288/32}};	--对话框的

tb2ndRoom.tbTalkGirl = {9998,{52896/32,100288/32}};	--说话的

tb2ndRoom.tbBossInfo = {9999,{52928/32,99488/32}};

tb2ndRoom.tbBossAiPos = {53440,100032};

tb2ndRoom.tbEnemyInfo = {
	{10000,{52928/32,99680/32}},
	{10022,{52960/32,99488/32}},
	{10023,{53088/32,99424/32}},
};

tb2ndRoom.tbEnemyAiPos = {
	{53376,99936},
	{53536,99936},
	{53536,100128},
};	--小怪的ai路线，对应刷出pos的index

tb2ndRoom.tbBossEndInfo = {10001,{53440/32,100032/32}};

tb2ndRoom.tbBossEndAiPos = {
	{53280,99744},
	{53216,99456},
	{53856,98720},
	{54144,98944},
	{54400,99200},
	{54816,98592},
};

tb2ndRoom.tbBossPercent = {70,50,30,10};	--boss血量触发点

tb2ndRoom.nPersonTempId = 10002;	--平民

tb2ndRoom.nAddPersonCount = 2;	--每次加几个平民

tb2ndRoom.nBossCastSkillId = 2493;	--杀死平民释放的技能

tb2ndRoom.nBossFindRange = 100;	--放技能时候找玩家范围

tb2ndRoom.tbPersonAiStartPos = {
	{52896,99584},
	{52864,99712},
	{52864,99840},
	{52896,100032},
	{53056,99392},
	{52992,100192},
	{53152,100384},
	{53408,100544},
	{53632,100640},
	{53536,100608},
	{53792,100640},
	{53920,100576},
	{54048,100480},
	{54208,100384},
};	

tb2ndRoom.tbPersonAiEndPos = {
	{53408,99520},
	{53440,99648},
	{53504,99744},
	{53568,99808},
	{53632,99840},
	{53696,99904},
	{53664,99968},
	{53440,99840},
	{53568,99904},
	{53760,99968},
	{53856,100064},
}

tb2ndRoom.nTalkDelay = 2 * Env.GAME_FPS;	--说话的时间间隔

tb2ndRoom.tbGirlTalkText = 
{
	"风岫居士？",
	"他就住在镇外寒光洲......",
	"时常来镇里添置些吃食......",	
};

tb2ndRoom.tbBossTalkText = 
{	
	"原、原来是误会。各位要找风岫居士？包在我身上！",
};

--logic
function tb2ndRoom:ClearNpc()
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,self.tbDialogGirl[1]);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,self.tbTalkGirl[1]);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,self.tbBossInfo[1]);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,self.tbEnemyInfo[1][1]);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,self.tbEnemyInfo[2][1]);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,self.tbEnemyInfo[3][1]);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,self.nPersonTempId);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,self.tbBossEndInfo[1]);
end

function tb2ndRoom:StartRoom()
	self.nIsStart = 1;
	self.nIsFailed = 0;
	self.nIsMovieStart = 0;	--剧情是否开启
	self:ClearRoom();
	self:AddTalkGirl();	--先加个开启的npc
	self.tbBase:UpdateUiState("Gặp thiếu niên ngôn cuồng trên phố\n\n<color=red>Hạ gục Mộc Đạc Lạc<color>");
end

function tb2ndRoom:AddTalkGirl()
	local nTempId = self.tbDialogGirl[1];
	local tbPos = self.tbDialogGirl[2];
	local pNpc = KNpc.Add2(nTempId,125,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);	
	if not pNpc then
		Dbg:WriteLog("ChenChongZhen","Room 2 Add Start Npc Failed!",self.tbBase.nMapId,self.tbBase.nServerId,self.tbBase.nPlayerId);	
	end
end

function tb2ndRoom:StartMovie()
	if self.nIsMovieStart == 1 then
		return 0;
	end
	self.nIsMovieStart = 1;	--剧情是否开启
	local nTempId = self.tbTalkGirl[1];
	local tbPos = self.tbTalkGirl[2];
	local pNpc = KNpc.Add2(nTempId,125,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);	
	if not pNpc then
		Dbg:WriteLog("ChenChongZhen","Room 2 Add Talk Npc Failed!",self.tbBase.nMapId,self.tbBase.nServerId,self.tbBase.nPlayerId);	
	else
		pNpc.GetTempTable("ChenChongZhen").nTalkTimer = Timer:Register(self.nTalkDelay,self.OnNpcTalk,self,pNpc.dwId);
		pNpc.GetTempTable("ChenChongZhen").nTalkCount = 0;	--说话的次数
	end
end

function tb2ndRoom:OnNpcTalk(nNpcId)
	if not self.tbBase or self.tbBase:IsOpen() ~= 1 then
		return 0;
	end
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	pNpc.GetTempTable("ChenChongZhen").nTalkCount = pNpc.GetTempTable("ChenChongZhen").nTalkCount + 1;
	local szContent = self.tbGirlTalkText[pNpc.GetTempTable("ChenChongZhen").nTalkCount];
	if szContent then
		self.tbBase:NpcTalk(nNpcId,szContent);
	else
		self:StartAddBoss();	--说完了，boss剧情触发
		self:StartAddEnemy();
		return 0;
	end
end

function tb2ndRoom:StartAddBoss()
	local nTempId = self.tbBossEndInfo[1];	--非战斗
	local tbPos = self.tbBossInfo[2];	--战斗的刷出点
	local pBoss = KNpc.Add2(nTempId,125,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);	
	if not pBoss then
		Dbg:WriteLog("ChenChongZhen","Room 2 Add Boss Failed!",self.tbBase.nMapId,self.tbBase.nServerId,self.tbBase.nPlayerId);	
	else
		pBoss.SetCurCamp(6);
		local tbAiPos = self.tbBossAiPos;
		pBoss.AI_ClearPath();
		pBoss.AI_AddMovePos(tbAiPos[1],tbAiPos[2]);
		pBoss.SetNpcAI(9,0,0,0,0,0,0,0);
		pBoss.SetActiveForever(1);
		pBoss.GetTempTable("Npc").tbOnArrive = {self.OnBossArrive,self,pBoss.dwId};
	end
end

function tb2ndRoom:StartAddEnemy()
	self.tbEnemy = {};
	for nIndex,tbInfo in ipairs(self.tbEnemyInfo) do
		local nTempId = tbInfo[1];
		local tbPos = tbInfo[2];
		local pNpc = KNpc.Add2(nTempId,125,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);	
		if not pNpc then
			Dbg:WriteLog("ChenChongZhen","Room 2 Add Boss Failed!",self.tbBase.nMapId,self.tbBase.nServerId,self.tbBase.nPlayerId);	
		else
			pNpc.SetCurCamp(6);	--先变成非战斗
			local tbAiPos = self.tbEnemyAiPos[nIndex];
			pNpc.AI_ClearPath();
			pNpc.AI_AddMovePos(tbAiPos[1],tbAiPos[2]);
			pNpc.SetNpcAI(9,0,0,0,0,0,0,0);
			pNpc.SetActiveForever(1);
			pNpc.GetTempTable("Npc").tbOnArrive = {self.OnEnemyArrive,self,pNpc.dwId};
		end
	end
end

function tb2ndRoom:OnBossArrive(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if pNpc then
		pNpc.Delete();
	end
	local nTempId = self.tbBossInfo[1];	--战斗的
	local tbPos = self.tbBossEndInfo[2]; --非战斗的刷出点
	local pBoss = KNpc.Add2(nTempId,125,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);	
	if not pBoss then
		Dbg:WriteLog("ChenChongZhen","Room 2 Add Boss Failed!",self.tbBase.nMapId,self.tbBase.nServerId,self.tbBase.nPlayerId);	
	else
		Npc:RegPNpcOnDeath(pBoss,self.OnBossDeath,self); 
		Npc:RegDeathLoseItem(pBoss,self.tbBase.OnBossDrop,self.tbBase);	--掉落回调
		for _,nPercent in pairs(self.tbBossPercent) do
			Npc:RegPNpcLifePercentReduce(pBoss,nPercent,self.OnBossPercent,self,pBoss.dwId);
		end
	end
end

function tb2ndRoom:OnBossPercent(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	self:AddPerson(nNpcId);
	self.tbBase:AllBlackBoard("Các huynh đệ chú ý đừng làm hại người xung quanh!");
end

function tb2ndRoom:AddPerson(nNpcId)
	local nTempId = self.nPersonTempId;
	for i = 1 ,self.nAddPersonCount do
		local tbStartPos = self.tbPersonAiStartPos[MathRandom(#self.tbPersonAiStartPos)];
		local tbMiddlePos = self.tbPersonAiEndPos[MathRandom(#self.tbPersonAiEndPos)];
		local tbEndPos =  self.tbPersonAiStartPos[MathRandom(#self.tbPersonAiStartPos)];
		local pNpc = KNpc.Add2(nTempId,125,-1,self.tbBase.nMapId,tbStartPos[1]/32,tbStartPos[2]/32);
		if pNpc then
			pNpc.AI_ClearPath();
			pNpc.AI_AddMovePos(tbMiddlePos[1],tbMiddlePos[2]);
			pNpc.AI_AddMovePos(tbEndPos[1],tbEndPos[2]);
			pNpc.SetNpcAI(9,0,0,0,0,0,0,0);
			pNpc.SetActiveForever(1);
			pNpc.GetTempTable("Npc").tbOnArrive = {self.OnPersonArrive,self,pNpc.dwId};
			Npc:RegPNpcOnDeath(pNpc,self.OnPersonDeath,self,nNpcId);
		end 
	end
end

function tb2ndRoom:OnPersonArrive(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if pNpc then
		pNpc.Delete();
	end	
	return 0;
end

function tb2ndRoom:OnPersonDeath(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end	
	local tbNearPlayer = KNpc.GetAroundPlayerList(nNpcId,self.nBossFindRange);
	if #tbNearPlayer > 0 then
		local pPlayer = nil;
		for i = 1,#tbNearPlayer do
			local pRand = tbNearPlayer[MathRandom(#tbNearPlayer)];
			if pRand and pRand.IsDead() ~= 1 then
				pPlayer = pRand;
				break;
			end
		end
		if pPlayer then
			local _,nX,nY = pPlayer.GetWorldPos();
			pNpc.CastSkill(self.nBossCastSkillId,11,nX*32,nY*32,1);
		end
	end
end

function tb2ndRoom:OnEnemyArrive(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if pNpc then
		local _,x,y = pNpc.GetWorldPos();
		local nTempId = pNpc.nTemplateId;
		pNpc.Delete();	--变为战斗状态
		local pNpc = KNpc.Add2(nTempId,125,-1,self.tbBase.nMapId,x,y);
		if pNpc then
			table.insert(self.tbEnemy,pNpc.dwId);
		end
	end
	return 0;
end

function tb2ndRoom:OnBossDeath()
	for _,nId in pairs(self.tbEnemy) do	--清除小怪
		local pNpc = KNpc.GetById(nId);
		if pNpc then
			pNpc.Delete();
		end
	end
	self.tbBase:NpcDropItem(him);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,self.nPersonTempId); --清除平民
	self.tbBase:RevivePlayerAfterFinish();
	self:StartEndMovie();	--结束剧情	
end


function tb2ndRoom:StartEndMovie()
	local nTempId = self.tbBossEndInfo[1];
	local tbPos = self.tbBossEndInfo[2];
	local pBoss = KNpc.Add2(nTempId,125,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);	
	if not pBoss then
		Dbg:WriteLog("ChenChongZhen","Room 2 Add Boss Failed!",self.tbBase.nMapId,self.tbBase.nServerId,self.tbBase.nPlayerId);	
	else
		pBoss.SetCurCamp(6);
		pBoss.GetTempTable("ChenChongZhen").nTalkTimer = Timer:Register(self.nTalkDelay,self.OnBossTalk,self,pBoss.dwId);
		pBoss.GetTempTable("ChenChongZhen").nTalkCount = 0;	--说话的次数
	end	
end

function tb2ndRoom:OnBossTalk(nNpcId)
	if not self.tbBase or self.tbBase:IsOpen() ~= 1 then
		return 0;
	end
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	pNpc.GetTempTable("ChenChongZhen").nTalkCount = pNpc.GetTempTable("ChenChongZhen").nTalkCount + 1;
	local szContent = self.tbBossTalkText[pNpc.GetTempTable("ChenChongZhen").nTalkCount];
	if szContent then
		self.tbBase:NpcTalk(nNpcId,szContent);
	else
		local tbAiPos = self.tbBossEndAiPos;
		pNpc.AI_ClearPath();
		for i = 1,#tbAiPos do
			pNpc.AI_AddMovePos(tbAiPos[i][1],tbAiPos[i][2]);
		end
		pNpc.SetNpcAI(9,0,0,0,0,0,0,0);
		pNpc.SetActiveForever(1);
		pNpc.GetTempTable("Npc").tbOnArrive = {self.OnBossArriveTrap,self,pNpc.dwId};
		self.tbBase:UpdateUiState("<color=red>Theo Mộc Đạc Lạc đi về phía trước<color>");
		return 0;
	end
end

function tb2ndRoom:OnBossArriveTrap(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if pNpc then
		pNpc.Delete();
	end
	self:EndRoom();
end

function tb2ndRoom:FailedRoom()
	self.nIsFailed = 1;
	self.nIsStart = 0;
	self.nIsMovieStart = 0;	--剧情是否开启
	self:ClearRoom();
	self.tbBase:StartCurrentRoom();
	self.tbBase:AllBlackBoard("Mộc Đạc Lạc: “Thực lực các ngươi còn quá kém!”");
end

function tb2ndRoom:IsRoomFailed()
	return self.nIsFailed or 0;
end

function tb2ndRoom:EndRoom()
	self.nIsFinished = 1;
	self.tbBase:AllBlackBoard("Hãy men theo con đường này để tiến về phía trước!");
	self:ClearRoom();
	self:RoomFinish();
	-- 发经验
	local tbPlayer = self.tbBase:GetPlayerList();
	for _, pPlayer in pairs(tbPlayer) do
		if pPlayer then
			pPlayer.AddExp(2400000);
		end
	end
end

function tb2ndRoom:ClearRoom()
	self:ClearNpc();
	self.tbBase:UpdateUiState("");
end

function tb2ndRoom:IsRoomStart()
	return self.nIsStart or 0;
end

function tb2ndRoom:IsRoomFinished()
	return self.nIsFinished or 0;
end

function tb2ndRoom:RoomFinish()
	self.tbBase:RoomFinish();
	self.tbBase:StartNextRoom();
end
--room 2 end-------------


--room 3-----------------
---define
tb3rdRoom.nCastStarPercent = 70;	--70%血量触发星星

tb3rdRoom.tbCasrStarPercent = {80,65,50,35,20};	--放星星的血量

tb3rdRoom.tbBossInfo = {10003,{57088/32,94496/32}};		--boss刷出点

tb3rdRoom.nNotifyNpcTemplateId = 10004;	--提示npc的模板id

tb3rdRoom.tbNotifyNpcInfo = {
	{56928/32,94816/32},
	{57152/32,94272/32},	
};	--提示npc的点

tb3rdRoom.nNotifyNpcTalkDelay = 2 * Env.GAME_FPS;	--npc刷出后多久冒泡

tb3rdRoom.tbNotifyNpcTalkContent = { --提示说的话语
	"嘻嘻，蓝为生，黄为死。",
	"这边这边~这边是黄色。",
	"这边这边~这边是蓝色。",
	"=3=~这边才不是蓝色。",
	"=3=~这边才不是黄色。",
	"我会告诉你这边是蓝色星星吗？",
	"我会告诉你这边是黄色星星吗？",
	"你猜哪边是蓝色星星？~",
	"你猜哪边是黄色星星？~",
	"哈哈！傻子才信我说是黄色的~",
	"哈哈！傻子才信我说是蓝色的~",
};	

tb3rdRoom.nCastStarAfterNotify = 8 * Env.GAME_FPS;	--提示完后施放技能的间隔

tb3rdRoom.nCastStarDelay = 30 * Env.GAME_FPS;	--每20秒释放一次

tb3rdRoom.tbStarSkillId = {	--释放星星的技能
	{2561,11},
	{2560,5},
};	

tb3rdRoom.tbStarNotifyId = {
	{2709,1},
	{1830,1},
};

tb3rdRoom.tbStarSkillPos = {	--释放星星的pos
  {57216,94112},
  {56800,94912},
};

tb3rdRoom.tbStarRealSkillPos = {
	{
		{56672,94240},{56768,94368},{57024,94080},{57184,94112},{57312,94176},
		{57216,93952},{56960,93856},{56832,94240},{56864,94464},{56992,94432},
		{57120,94464},{57248,94496},{56960,94272},{57088,94272},{57216,94304},
		{57440,94016},{57344,93984},{57376,94560},{57504,94624},{57344,94368},
		{57600,94528},{57600,94720},{57728,94752},{57696,94624},{57728,94432},
		{57632,94336},{57472,94400},{57440,94208},{57760,94240},{57600,94208},
		{56928,93792},{56960,94016},{57056,94016},{57344,104032},
		{56608,94304},{57792,94656},{57760,94560},{56576,94176},{56672,94176},
		{56768,94176},{56576,94272},{56672,94368},{56896,94144},{57152,93856},
		{57536,94112},{57728,94144},{57792,94368},{57856,94208},
	},  
	{   
		{55744,95744},{55744,95840},{56096,95520},{56192,95456},{56288,95328},
		{56000,95520},{55936,95744},{56064,95776},{56000,95808},{55840,95680},
		{55808,95712},{55872,95776},{55808,95872},{55936,95904},{56032,95904},
		{56128,95840},{56416,95168},{56480,95104},{56512,95200},{56544,95008},
		{56576,95072},{56576,94912},{56800,94816},{56416,95296},{56896,95040},
		{56992,94848},{57056,95040},{57184,94848},{57184,95072},{56512,94336},
		{56448,94432},{56448,94528},{56448,94368},{56480,94272},{56416,94304},
	},
};

tb3rdRoom.tbTalkColor = {"blue","yellow"};	--头上冒的泡泡颜色，和释放的技能索引对应


---logic
function tb3rdRoom:ClearNpc()
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,self.tbBossInfo[1]);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,self.nNotifyNpcTemplateId);
end

function tb3rdRoom:StartRoom()
	self.nIsStart = 1;
	self.nIsFailed = 0;
	self:ClearRoom();
	self:StartAddBoss();
	self.tbBase:UpdateUiState("Tinh hà trận lạc dị thú bàng\n\n<color=red>Đánh bại Tinh Hà Dị Thú<color>");
end

--增加boss
function tb3rdRoom:StartAddBoss()
	local nTempId = self.tbBossInfo[1];	
	local tbPos = self.tbBossInfo[2]; 
	local pBoss = KNpc.Add2(nTempId,125,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);	
	if not pBoss then
		Dbg:WriteLog("ChenChongZhen","Room 3 Add Boss Failed!",self.tbBase.nMapId,self.tbBase.nServerId,self.tbBase.nPlayerId);	
	else
		Npc:RegDeathLoseItem(pBoss,self.tbBase.OnBossDrop,self.tbBase);	--掉落回调
		Npc:RegPNpcOnDeath(pBoss,self.OnBossDeath,self); 
		for _,nPercent in pairs(self.tbCasrStarPercent) do
			Npc:RegPNpcLifePercentReduce(pBoss,nPercent,self.OnBossPercent,self,pBoss.dwId);
		end
	end
end

function tb3rdRoom:OnBossDeath()
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,self.nNotifyNpcTemplateId);	--如果有提示npc，先清除
	self.tbBase:NpcDropItem(him);
	self:EndRoom();
end

function tb3rdRoom:OnBossPercent(nBossId)
	local pBoss = KNpc.GetById(nBossId);
	if not pBoss then
		return 0;
	end
	self:AddNotifyNpc(nBossId);
end

function tb3rdRoom:AddNotifyNpc(nBossId)
	local nTempId = self.nNotifyNpcTemplateId;
	local nIdx = MathRandom(#self.tbNotifyNpcInfo);
	local tbPos = self.tbNotifyNpcInfo[nIdx];
	local pNpc = KNpc.Add2(nTempId,125,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);	
	if not pNpc then
		Dbg:WriteLog("ChenChongZhen","Room 3 Add Notify Npc Failed!",self.tbBase.nMapId,self.tbBase.nServerId,self.tbBase.nPlayerId);	
	else
		pNpc.GetTempTable("ChenChongZhen").nTalkTimer = Timer:Register(self.nNotifyNpcTalkDelay,self.OnNotify,self,pNpc.dwId,nBossId,nIdx);
	end
end

function tb3rdRoom:OnNotify(nNpcId,nBossId,nPosIdx)
	if not self.tbBase or self.tbBase:IsOpen() ~= 1 then
		return 0;
	end
	local pNpc = KNpc.GetById(nNpcId);
	local pBoss = KNpc.GetById(nBossId);
	if not pNpc or not pBoss then
		return 0;
	end
	local nIdx = MathRandom(#self.tbStarSkillId);
	local szColor = self.tbTalkColor[nIdx];
	local szContent = self.tbNotifyNpcTalkContent[MathRandom(#self.tbNotifyNpcTalkContent)];
	local szText = string.format("<color=%s>%s<color>",szColor,szContent);
	self.tbBase:NpcTalk(nNpcId,szText);
	pNpc.GetTempTable("ChenChongZhen").nDeleteTimer = Timer:Register(self.nCastStarAfterNotify,self.OnBossCastStar,self,pNpc.dwId,nBossId,nIdx,nPosIdx);
	return 0;
end

function tb3rdRoom:OnBossCastStar(nNpcId,nBossId,nSkillIdx,nPosIdx)
	if not self.tbBase or self.tbBase:IsOpen() ~= 1 then
		return 0;
	end
	local pNpc = KNpc.GetById(nNpcId);
	if pNpc then
		pNpc.Delete();
	end
	local pBoss = KNpc.GetById(nBossId);
	if not pBoss or pBoss.IsDead() == 1 then
		return 0;
	end
	local nSkillId1 = self.tbStarNotifyId[nSkillIdx][1];
	local nLevel1 =  self.tbStarNotifyId[nSkillIdx][2];
	local tbPos1 = self.tbStarSkillPos[nPosIdx];
	local nSkillId2 = self.tbStarNotifyId[#self.tbStarSkillId - nSkillIdx + 1][1];	--另一边释放另一个技能
	local nLevel2 =  self.tbStarNotifyId[#self.tbStarSkillId - nSkillIdx + 1][2];
	local tbPos2 = self.tbStarSkillPos[#self.tbStarSkillPos - nPosIdx + 1];
	pBoss.CastSkill(nSkillId1,nLevel1,tbPos1[1],tbPos1[2],1);
	pBoss.CastSkill(nSkillId2,nLevel2,tbPos2[1],tbPos2[2],1);
	local nSkillIdReal1 = self.tbStarSkillId[nSkillIdx][1];
	local nLevelReal1 =  self.tbStarSkillId[nSkillIdx][2];
	local tbPosReal1 = self.tbStarRealSkillPos[nPosIdx];
	for _,tbPos in pairs(tbPosReal1) do
		pBoss.CastSkill(nSkillIdReal1,nLevelReal1,tbPos[1],tbPos[2]);	
	end
	local nSkillIdReal2 = self.tbStarSkillId[#self.tbStarSkillId - nSkillIdx + 1][1];	--另一边释放另一个技能
	local nLevelReal2 =  self.tbStarSkillId[#self.tbStarSkillId - nSkillIdx + 1][2];
	local tbPosReal2 = self.tbStarRealSkillPos[#self.tbStarSkillPos - nPosIdx + 1];
	for _,tbPos in pairs(tbPosReal2) do
		pBoss.CastSkill(nSkillIdReal2,nLevelReal2,tbPos[1],tbPos[2]);	
	end
	return 0;
end

function tb3rdRoom:OnBossBeginCastStar(nBossId)
	if not self.tbBase or self.tbBase:IsOpen() ~= 1 then
		return 0;
	end
	local pBoss = KNpc.GetById(nBossId);
	if not pBoss then
		return 0;
	end
	self:AddNotifyNpc(nBossId);
	return 0;
end

function tb3rdRoom:FailedRoom()
	self.nIsFailed = 1;
	self.nIsStart = 0;
	self:ClearRoom();
	self.tbBase:StartCurrentRoom();
	self.tbBase:AllBlackBoard("Trời đất tối sầm, Tinh Hà Dị Thú ngày càng đi xa mất.");
end

function tb3rdRoom:IsRoomFailed()
	return self.nIsFailed or 0;
end

function tb3rdRoom:EndRoom()
	self.nIsFinished = 1;
	self.tbBase:AllBlackBoard("Tinh Hà Dị Thú bỏ chạy rồi, nhanh chân đuổi theo!");
	self:ClearRoom();
	self:RoomFinish();
end

function tb3rdRoom:ClearRoom()
	self:ClearNpc();
	self.tbBase:UpdateUiState("");
end

function tb3rdRoom:IsRoomStart()
	return self.nIsStart or 0;
end

function tb3rdRoom:IsRoomFinished()
	return self.nIsFinished or 0;
end

function tb3rdRoom:RoomFinish()
	self.tbBase:RoomFinish();
	self.tbBase:StartNextRoom();
end
---room 3 end--------------


---room 4------------------
---define
tb4thRoom.tbStarManagerInfo = {10005,{46816/32,94688/32}};	--开启星盘守护者的npc

tb4thRoom.tbStarManagerMovieInfo = {10011,{47264/32,95168/32}};	--剧情的星盘守护者

tb4thRoom.nLightUnFireTemplateId = 10006;	--未点燃的灯

tb4thRoom.nLightFiredTemplateId = 10007;	--已经点然的灯

tb4thRoom.nLightEnemyTemplateId = 10008;	--刷出来可以攻击的灯

tb4thRoom.nEnemyByLightTemplateId = 10009;	--灯召唤的小怪

tb4thRoom.nEnemyMovieTemplateId = 10010;	--剧情的小怪

tb4thRoom.tbNeedFireLightCount = {5,5};	--需要点燃15个灯

tb4thRoom.nAddLightEnemyBeginDelay = 6 * Env.GAME_FPS;	--6秒刷第一次可攻击的灯

tb4thRoom.nAddLightEnemyDelay = 19 * Env.GAME_FPS;	--之后19秒刷可攻击的灯

tb4thRoom.nAddLightEnemyCount = 5;	--一次加1-5个可以攻击的灯

tb4thRoom.nLightCastSkillDelay = 10 * Env.GAME_FPS;	--灯5秒放一次技能

tb4thRoom.nNotifyLightOrderDelay = 10 * Env.GAME_FPS;	--提示的时间长度

tb4thRoom.nEndMovieDelay = 20 * Env.GAME_FPS;	--结束时的剧情长度

tb4thRoom.nCastSkillDelay = 3 * Env.GAME_FPS;

tb4thRoom.nTransferDelay = 	10 * Env.GAME_FPS;--传到小木屋里的时间

tb4thRoom.nStarManagerCastSkillId = 2161;	--剧情npc释放的技能

tb4thRoom.tbTrans2HousePos = {45440/32,101856/32};	--传送到木屋的pos

tb4thRoom.nCanFireErrorCount = 3;	--最多能点错的次数

tb4thRoom.nViewLightOrderCount = 3;	--可以查询顺序的次数，用完了后就重新开

tb4thRoom.nEnemyByLightCount = 4;	--每次加4个灯召唤怪

tb4thRoom.nEnemyByLightMaxCount = 20;	--最多召唤出20只

tb4thRoom.tbLightRegionPos = {	--灯座原始位置
	{46912/32,95136/32},{47008/32,95040/32},{46784/32,95264/32},{46880/32,95360/32},{46976/32,95456/32},
	{47072/32,95552/32},{47008/32,95232/32},{47104/32,95136/32},{47104/32,94944/32},{47200/32,95040/32},
	{47296/32,95136/32},{47232/32,94816/32},{47328/32,94912/32},{47424/32,95008/32},{47520/32,95104/32},
	{47168/32,95648/32},{47104/32,95328/32},{47200/32,95424/32},{47296/32,95520/32},{47200/32,95232/32},
	{47296/32,95328/32},{47392/32,95424/32},{47392/32,95232/32},{47488/32,95328/32},{47616/32,95200/32},
};	

tb4thRoom.tbStarManagerInHouse = {10011,{45408/32,101632/32}};	--木屋里的星盘守护者

tb4thRoom.tbStarManagerAiPos = 
{
	{45376,101760},
	{45376,101920},
	{45440,102016},
	{45536,102112},
	{46016,102272},
};	--木屋里的星盘守护者走的路线

tb4thRoom.tbStarBossInfo = {9932,{47200/32,95232/32}};		--boss刷出点

tb4thRoom.tbStarBossPercent = {80,60,40,20};

tb4thRoom.tbLightHelperInfo = {10025,
	{
		{46592/32,95264/32},{47232/32,94624/32},
		{47200/32,95840/32},{47808/32,95200/32},
	}
};	--解debuff的灯

tb4thRoom.tbBossCallNpcInfo = {9933,
	{
		{46400/32,95264/32},{46816/32,94784/32},
		{46784/32,95680/32},{47232/32,94368/32},
		{47168/32,96096/32},{48032/32,95200/32},
		{47648/32,94784/32},{47616/32,95648/32},
	}	
};	--boss召唤的小怪

tb4thRoom.nBossSkillId = 2735;

tb4thRoom.nDebuffId = 2733;

tb4thRoom.nBossCallNpcDelay = 2 * Env.GAME_FPS;

tb4thRoom.tbBossCallNpcAiPos = {47200,95232};	--小怪的ai路线终点

tb4thRoom.nTalkDelay = 4 * Env.GAME_FPS;	--说话的时间间隔

tb4thRoom.tbNpcTalkText = 
{
	"唐突各位，风岫惭愧。诸位所寻商队，我早已送之离开。",
	"我乃星象遗族最后一人，仇家为独窥天运",
	"不仅灭我一族，还逼我逃亡至此",	
	"不得已才在镇口与此处布下阵法",
	"我现在就送各位离开，请跟我来",
};

---logic
function tb4thRoom:ClearNpc()
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,self.tbBossCallNpcInfo[1]);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,self.tbLightHelperInfo[1]);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,self.tbStarBossInfo[1]);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,self.tbStarManagerInfo[1]);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,self.tbStarManagerInHouse[1]);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,self.nLightUnFireTemplateId);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,self.nLightFiredTemplateId);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,self.nLightEnemyTemplateId);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,self.nEnemyByLightTemplateId);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,self.nEnemyMovieTemplateId);
end


function tb4thRoom:StartRoom()
	self.nIsStart = 1;
	self.nIsFailed = 0;
	self.nIsLightBegin = 0;	--标记是否开始点灯了
	self.nCurrentStep = 1;	--开始是第一步
	self:ClearRoom();
	self:AddStarManager();
	self.tbBase:UpdateUiState("Nguyệt mộng tinh kỳ\n\n<color=red>Phá giải Đăng Kỳ Trận<color>");
end

function tb4thRoom:AddStarManager()
	local nTempId = self.tbStarManagerInfo[1];
	local tbPos = self.tbStarManagerInfo[2];
	local pNpc = KNpc.Add2(nTempId,125,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);	
	if not pNpc then
		Dbg:WriteLog("ChenChongZhen","Room 4 Add Star Manager Npc Failed!",self.tbBase.nMapId,self.tbBase.nServerId,self.tbBase.nPlayerId);	
	end
end

function tb4thRoom:StartFireLight()
	self:ClearLight();
	self:ClearTimer();
	self:ResetLightIdx();
	self:GenLightOrder();	--生成要点的灯的顺序
	self:NotifyLight(0);	--提示需要点的灯
	self.nIsLightBegin = 1;	--已经开始点灯了
	self.tbBase:UpdateUiState(string.format("Nguyệt mộng tinh kỳ\n\n<color=green>Thắp sáng đèn: %s/%s<color>\n\n<color=red>Thắp sai đèn: %s/%s<color>",
		self.nFireCorrectLightCount,
		self.tbNeedFireLightCount[self.nCurrentStep],
		self.nFireErrorLightCount,
		self.nCanFireErrorCount));
end


function tb4thRoom:GetIsLightBegin()
	return self.nIsLightBegin;
end

--重置索引和位置
function tb4thRoom:ResetLightIdx()
	self:ClearLight();
	self.tbLightNeedFireIdx = {};
	self.tbLightUnNeedFireIdx = {};
	self.nNotifyLightOrderCount = 0;	--查询次数
	self.nFireErrorLightCount = 0;		--点错的次数
	self.nFireCorrectLightCount = 0;	--点对的灯的数量
	self.nEnemyCallByLightCount = 0;	--灯召唤出来的怪物数量
end

function tb4thRoom:GenLightOrder()
	self:ResetLightIdx();
	local tbIdx = {};
	for i = 1 , #self.tbLightRegionPos do
		tbIdx[i] = i;
	end
	for i = 1 , self.tbNeedFireLightCount[self.nCurrentStep] do
		local nRand = MathRandom(#tbIdx);
		local nIdx = tbIdx[nRand];
		local tbPos = self.tbLightRegionPos[nIdx];
		table.remove(tbIdx,nRand);
		table.insert(self.tbLightNeedFireIdx,{nIdx,tbPos});
	end
	for _,nIdx in pairs(tbIdx) do
		local tbPos = self.tbLightRegionPos[nIdx];
		table.insert(self.tbLightUnNeedFireIdx,{nIdx,tbPos});
	end
end

function tb4thRoom:NotifyLight(bAddCount)
	if not self.tbNotifyLightNpc then
		self.tbNotifyLightNpc = {};
	end
	if self:CheckCanNotifyLight() ~= 1 then
		return 0;
	end
	self.tbNotifyLightNpc = {};	--提示的npc
	if bAddCount == 1 then
		self.nNotifyLightOrderCount = self.nNotifyLightOrderCount + 1;	--增加查询次数
	end
	if self.nNotifyLightOrderCount > self.nViewLightOrderCount then	--如果超过次数，重新开始
		self:StartFireLight();
		return 0;		
	end
	for _,tbInfo in pairs(self.tbLightNeedFireIdx) do
		local nTempId = self.nLightFiredTemplateId;
		local tbPos = tbInfo[2];
		local pNpc = KNpc.Add2(nTempId,125,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
		table.insert(self.tbNotifyLightNpc,pNpc.dwId);			
	end
	if self.nNotifyLightTimer and self.nNotifyLightTimer > 0 then
		Timer:Close(self.nNotifyLightTimer);
		self.nNotifyLightTimer = 0;
	end
	self.nFireErrorLightCount = 0;		--点错的次数清零
	self.nFireCorrectLightCount = 0;	--点对的灯的数量清零
	self.tbBase:UpdateUiState(string.format("Nguyệt mộng tinh kỳ\n\n<color=green>Thắp sáng đèn: %s/%s<color>\n\n<color=red>Thắp sai đèn: %s/%s<color>",
							self.nFireCorrectLightCount,
							self.tbNeedFireLightCount[self.nCurrentStep],
							self.nFireErrorLightCount,
							self.nCanFireErrorCount));		
	self.nNotifyLightTimer = Timer:Register(self.nNotifyLightOrderDelay,self.OnFireLightBegin,self);
end


--清除所有灯座
function tb4thRoom:ClearLight()
	if not self.tbNotifyLightNpc then
		self.tbNotifyLightNpc = {};
	end
	if not self.tbLightNeedFireNpc then
		self.tbLightNeedFireNpc = {};
	end
	if not self.tbLightUnNeedFireNpc then
		self.tbLightUnNeedFireNpc = {};
	end
	for _,nId in pairs(self.tbNotifyLightNpc) do
		local pNpc = KNpc.GetById(nId);
		if pNpc then
			pNpc.Delete();
		end		
	end
	self.tbNotifyLightNpc = {};
	for _,nId in pairs(self.tbLightNeedFireNpc) do
		local pNpc = KNpc.GetById(nId);
		if pNpc then
			pNpc.Delete();
		end		
	end
	self.tbLightNeedFireNpc = {};
	for _,nId in pairs(self.tbLightUnNeedFireNpc) do
		local pNpc = KNpc.GetById(nId);
		if pNpc then
			pNpc.Delete();
		end		
	end
	self.tbLightUnNeedFireNpc = {};
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,self.nLightFiredTemplateId);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,self.nEnemyByLightTemplateId);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,self.nLightEnemyTemplateId);
end

function tb4thRoom:OnFireLightBegin()
	if not self.tbBase or self.tbBase:IsOpen() ~= 1 then
		return 0;
	end
	for _,nId in pairs(self.tbNotifyLightNpc) do
		local pNpc = KNpc.GetById(nId);
		if pNpc then
			pNpc.Delete();
		end		
	end
	self.tbNotifyLightNpc = {};
	self.nFireErrorLightCount = 0;		--点错的次数
	self.nFireCorrectLightCount = 0;	--点对的灯的数量
	self.nEnemyCallByLightCount = 0;	--灯召唤出来的怪物数量
	if not self.tbLightNeedFireNpc then
		self.tbLightNeedFireNpc = {};
	end
	if not self.tbLightUnNeedFireNpc then
		self.tbLightUnNeedFireNpc = {};
	end
	for nIdx,tbInfo in ipairs(self.tbLightNeedFireIdx) do
		local nTempId = self.nLightUnFireTemplateId;
		local tbPos = tbInfo[2];
		local pNpc = KNpc.Add2(nTempId,125,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
		if pNpc then
			pNpc.GetTempTable("ChenChongZhen").nIsNeedFire = 1;	--标记是否是需要点燃的
			table.insert(self.tbLightNeedFireNpc,pNpc.dwId);
		end			
	end
	for nIdx,tbInfo in ipairs(self.tbLightUnNeedFireIdx) do
		local nTempId = self.nLightUnFireTemplateId;
		local tbPos = tbInfo[2];
		local pNpc = KNpc.Add2(nTempId,125,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
		if pNpc then
			pNpc.GetTempTable("ChenChongZhen").nIsNeedFire = 0;
			table.insert(self.tbLightUnNeedFireNpc,pNpc.dwId);
		end			
	end
	if self.nAddLightEnemyBeginTimer and self.nAddLightEnemyBeginTimer > 0 then
		Timer:Close(self.nAddLightEnemyBeginTimer);
		self.nAddLightEnemyBeginTimer = 0;
	end
	self.nAddLightEnemyBeginTimer = Timer:Register(self.nAddLightEnemyBeginDelay,self.OnAddLightBgeinEnemy,self);
	self.nNotifyLightTimer = 0;
	return 0;
end

function tb4thRoom:AddLightEnemy()
	local nAddCount = MathRandom(self.nAddLightEnemyCount);
	for i = 1,nAddCount do
		local nIdx = MathRandom(#self.tbLightUnNeedFireNpc);
		local nId = self.tbLightUnNeedFireNpc[nIdx];
		if nId then
			local pNpc = KNpc.GetById(nId);
			table.remove(self.tbLightUnNeedFireNpc,nIdx);
			if pNpc then
				local nMapId,nX,nY = pNpc.GetWorldPos();
				local nTempId = self.nLightEnemyTemplateId;
				local pNewNpc = KNpc.Add2(nTempId,125,-1,nMapId,nX,nY);
				if pNewNpc then
					pNewNpc.GetTempTable("ChenChongZhen").nCastSkillTimer = Timer:Register(self.nLightCastSkillDelay,self.OnLightEnemyCastSkill,self,pNewNpc.dwId);
					Npc:RegPNpcOnDeath(pNewNpc,self.OnLightEnemyDeath,self,nMapId,nX,nY);
				end
				pNpc.Delete();
			end
		end
	end
end

--定时刷出可以攻击的灯座
function tb4thRoom:OnAddLightBgeinEnemy()
	if not self.tbBase or self.tbBase:IsOpen() ~= 1 then
		return 0;
	end
	self:AddLightEnemy();
	self.nAddLightEnemyBeginTimer = 0;
	if self.nAddLightEnemyTimer and self.nAddLightEnemyTimer > 0 then
		Timer:Close(self.nAddLightEnemyTimer);
		self.nAddLightEnemyTimer = 0;
	end
	self.nAddLightEnemyTimer = Timer:Register(self.nAddLightEnemyDelay,self.OnAddLightEnemy,self);
	return 0;
end

function tb4thRoom:OnAddLightEnemy()
	if not self.tbBase or self.tbBase:IsOpen() ~= 1 then
		return 0;
	end
	self:AddLightEnemy();
end

function tb4thRoom:OnLightEnemyCastSkill(nNpcId)
	if not self.tbBase or self.tbBase:IsOpen() ~= 1 then
		return 0;
	end
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local nMapId,nX,nY = pNpc.GetWorldPos();
	local tbInPos = {};
	for x = - 1 , 1 do
		for y = -1, 1 do
			if x == 0 or y == 0 then
				table.insert(tbInPos,{nX + x ,nY + y});
			end
		end
	end
	for _,tbPos in pairs(tbInPos) do
		local nTempId = self.nEnemyByLightTemplateId;
		if  self.nEnemyCallByLightCount < self.nEnemyByLightMaxCount then	--没超过数量就加
			local pEnemy = KNpc.Add2(nTempId,125,-1,nMapId,tbPos[1],tbPos[2]);
			if pEnemy then
				Npc:RegPNpcOnDeath(pEnemy,self.OnEnemyCalledDeath,self);
				self.nEnemyCallByLightCount = (self.nEnemyCallByLightCount or 0) + 1;
			end
		end
	end
end

function tb4thRoom:OnEnemyCalledDeath()
	self.nEnemyCallByLightCount = (self.nEnemyCallByLightCount or 0) - 1;
	if self.nEnemyCallByLightCount <= 0 then
		self.nEnemyCallByLightCount = 0;
	end
end

function tb4thRoom:OnLightEnemyDeath(nMapId,nX,nY)
	local nTempId = self.nLightUnFireTemplateId;
	local pNpc = KNpc.Add2(nTempId,125,-1,nMapId,nX,nY);
	if pNpc then
		pNpc.GetTempTable("ChenChongZhen").nIsNeedFire = 0;
		table.insert(self.tbLightUnNeedFireNpc,pNpc.dwId);
	end		
end

function tb4thRoom:FindLight(tbLight,nNpcId)
	if not tbLight or #tbLight <= 0 then
		return;
	end
	for nIdx,nId in ipairs(tbLight) do
		if nId == nNpcId then
			return nIdx;
		end
	end
	return;
end	
	

--处理点灯
function tb4thRoom:ProcessFireLight(nIsCorrect,nNpcId,nX,nY)
	if nIsCorrect == 1 then
		local nIdx = self:FindLight(self.tbLightNeedFireNpc,nNpcId);
		if nIdx then
			local pNpc = KNpc.GetById(nNpcId);
			if pNpc then
				pNpc.Delete();
				local nTempId = self.nLightFiredTemplateId;
				local pNewNpc = KNpc.Add2(nTempId,125,-1,self.tbBase.nMapId,nX,nY);
			end
			self.nFireCorrectLightCount = self.nFireCorrectLightCount + 1;	
			self.tbBase:UpdateUiState(string.format("Nguyệt mộng tinh kỳ\n\n<color=green>Thắp sáng đèn: %s/%s<color>\n\n<color=red>Thắp sai đèn: %s/%s<color>",
										self.nFireCorrectLightCount,
										self.tbNeedFireLightCount[self.nCurrentStep],
										self.nFireErrorLightCount,
										self.nCanFireErrorCount));
			if self.nFireCorrectLightCount >= self.tbNeedFireLightCount[self.nCurrentStep] then	--点成功了
				self:ProcessStep();
			end
		end
	else
		local nIdx = self:FindLight(self.tbLightUnNeedFireNpc,nNpcId);
		if nIdx then
			local pNpc = KNpc.GetById(nNpcId);
			if pNpc then
				pNpc.Delete();
				local nTempId = self.nLightEnemyTemplateId;
				local pNewNpc = KNpc.Add2(nTempId,125,-1,self.tbBase.nMapId,nX,nY);
				if pNewNpc then
					pNewNpc.GetTempTable("ChenChongZhen").nCastSkillTimer = Timer:Register(self.nLightCastSkillDelay,self.OnLightEnemyCastSkill,self,pNewNpc.dwId);
					Npc:RegPNpcOnDeath(pNewNpc,self.OnLightEnemyDeath,self,self.tbBase.nMapId,nX,nY);
					table.remove(self.tbLightUnNeedFireNpc,nIdx);
				end
			end
			self.tbBase:AllBlackBoard("Chuôi đèn phát ra một tiếng kêu lớn...");
			self.nFireErrorLightCount = self.nFireErrorLightCount + 1;
			self.tbBase:UpdateUiState(string.format("Nguyệt mộng tinh kỳ\n\n<color=green>Thắp sáng đèn: %s/%s<color>\n\n<color=red>Thắp sai đèn: %s/%s<color>",
										self.nFireCorrectLightCount,
										self.tbNeedFireLightCount[self.nCurrentStep],
										self.nFireErrorLightCount,
										self.nCanFireErrorCount));		
			if self.nFireErrorLightCount > self.nCanFireErrorCount then	--点错超过数量
				self.tbBase:AllBlackBoard("Thắp sai quá lượt qui định, Đăng Kỳ Trận tái khởi động.");
				self.tbBase:RevivePlayerAfterFinish();	-- 复活玩家
				self:StartFireLight();
			end
		end
	end
end

function tb4thRoom:ProcessStep()
	self.nCurrentStep = self.nCurrentStep + 1;
	self.tbBase:RevivePlayerAfterFinish();	-- 复活玩家
	if self.nCurrentStep > #self.tbNeedFireLightCount then
		self.nCurrentStep = #self.tbNeedFireLightCount;
		self:StartEndMovie();
	else
		self.tbBase:UpdateUiState("Nguyệt mộng tinh kỳ\n\n<color=red>Hạ Huyễn Ảnh Cửu Thế Tinh Bàn<color>");
		self:ClearTimer();
		self:ClearLight();
		self:ClearNpc();
		self:AddStarBoss();
		--self:AddLightHelper();
	end
end

function tb4thRoom:AddLightHelper()
	local nTempId = self.tbLightHelperInfo[1];	
	local tbPos = self.tbLightHelperInfo[2]; 
	for _,tb in pairs(tbPos) do
		KNpc.Add2(nTempId,125,-1,self.tbBase.nMapId,tb[1],tb[2]);	
	end
end


function tb4thRoom:AddStarBoss()
	local nTempId = self.tbStarBossInfo[1];	
	local tbPos = self.tbStarBossInfo[2]; 
	local pBoss = KNpc.Add2(nTempId,125,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);	
	if not pBoss then
		Dbg:WriteLog("ChenChongZhen","Room 3 Add Boss Failed!",self.tbBase.nMapId,self.tbBase.nServerId,self.tbBase.nPlayerId);	
	else
		Npc:RegPNpcOnDeath(pBoss,self.OnBossDeath,self); 
		for _,nPercent in pairs(self.tbStarBossPercent) do
			Npc:RegPNpcLifePercentReduce(pBoss,nPercent,self.OnCastSkill,self,pBoss.dwId);
		end
	end
end

function tb4thRoom:OnCastSkill(nBossId)
	local pBoss = KNpc.GetById(nBossId);
	if not pBoss then
		return 0;
	end
	local _,x,y = pBoss.GetWorldPos();
	pBoss.CastSkill(self.nBossSkillId,6,x*32,y*32,1);
	pBoss.GetTempTable("ChenChongZhen").nCallNpcTimer = Timer:Register(self.nBossCallNpcDelay,self.AddBossCallNpc,self,nBossId);
	return 0;
end


function tb4thRoom:AddBossCallNpc(nBossId)
	if not self.tbBase or self.tbBase:IsOpen() ~= 1 then
		return 0;
	end
	local pBoss = KNpc.GetById(nBossId);
	if not pBoss then
		return 0;
	end
	if pBoss.IsDead() == 1 then
		pBoss.GetTempTable("ChenChongZhen").nCallNpcTimer = 0;
		return 0;
	end
	local nTempId = self.tbBossCallNpcInfo[1];	
	local tbPos = self.tbBossCallNpcInfo[2]; 
	for nIndex,tb in ipairs(tbPos) do
		local pNpc = KNpc.Add2(nTempId,125,-1,self.tbBase.nMapId,tb[1],tb[2]);
		if pNpc then
			local tbAi = self.tbBossCallNpcAiPos;
			pNpc.AI_ClearPath();
			pNpc.AI_AddMovePos(tbAi[1],tbAi[2]);
			pNpc.SetNpcAI(9,0,0,0,0,0,0,0);
			pNpc.SetActiveForever(1);
			pNpc.GetTempTable("Npc").tbOnArrive = {self.OnCallEnemyArrive,self,pNpc.dwId};
		end
	end
	pBoss.GetTempTable("ChenChongZhen").nCallNpcTimer = 0;
	return 0;
end

function tb4thRoom:OnCallEnemyArrive(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	pNpc.Delete();
end

function tb4thRoom:OnBossDeath()
	if him.GetTempTable("ChenChongZhen").nCallNpcTimer and him.GetTempTable("ChenChongZhen").nCallNpcTimer > 0 then
		Timer:Close(him.GetTempTable("ChenChongZhen").nCallNpcTimer);
		him.GetTempTable("ChenChongZhen").nCallNpcTimer = 0;
	end
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,self.tbBossCallNpcInfo[1]);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,self.tbLightHelperInfo[1]);
	self.tbBase:RevivePlayerAfterFinish();	-- 复活玩家
	self:ClearDebuff();
	self:AddStarManager();
	self:StartFireLight();	
end

function tb4thRoom:ClearDebuff()
	local tbPlayer = self.tbBase:GetPlayerList();
	for _,pPlayer in pairs(tbPlayer) do
		if pPlayer then
			pPlayer.RemoveSkillState(self.nDebuffId);
		end
	end
end

--开启结束剧情
function tb4thRoom:StartEndMovie()
	self.tbBase:UpdateUiState("");
	self:ClearTimer();
	self:ClearNpc();
	self:AddMovieEnemy();
	self.tbBase:DropBox();	--加宝箱
	if self.nEndMovieTimer and self.nEndMovieTimer > 0 then
		Timer:Close(self.nEndMovieTimer);
		self.nEndMovieTimer = 0;
	end
	self.nEndMovieTimer = Timer:Register(self.nEndMovieDelay,self.OnEndMovieTime,self);
end


function tb4thRoom:AddMovieEnemy()
	local nTempId = self.nEnemyMovieTemplateId;
	for _,tbPos in pairs(self.tbLightRegionPos) do
		KNpc.Add2(nTempId,125,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);		
	end
end

function tb4thRoom:OnEndMovieTime()
	if not self.tbBase or self.tbBase:IsOpen() ~= 1 then
		return 0;
	end
	local nTempId = self.tbStarManagerMovieInfo[1];
	local tbPos = self.tbStarManagerMovieInfo[2];
	local pNpc = KNpc.Add2(nTempId,125,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);	
	if pNpc then
		pNpc.GetTempTable("ChenChongZhen").nCastSkillTimer = Timer:Register(self.nCastSkillDelay,self.OnCastMovieSkill,self,pNpc.dwId);		
	end	
	self.nEndMovieTimer = 0;
	return 0;
end

function tb4thRoom:OnCastMovieSkill(nNpcId)
	if not self.tbBase or self.tbBase:IsOpen() ~= 1 then
		return 0;
	end
	local pNpc = KNpc.GetById(nNpcId);
	if pNpc then
		local _,nX,nY = pNpc.GetWorldPos();
		pNpc.CastSkill(self.nStarManagerCastSkillId,20,nX*32,nY*32,1);
		pNpc.GetTempTable("ChenChongZhen").nEndTimer = Timer:Register(self.nTransferDelay,self.OnTranser2House,self,nNpcId);
	end
	self.tbBase:AllBlackBoard("Đã phá giải Đăng Kỳ Trận, các vị không cần sợ nữa.");
	return 0;
end

function tb4thRoom:OnTranser2House(nNpcId)
	if not self.tbBase or self.tbBase:IsOpen() ~= 1 then
		return 0;
	end
	local pNpc = KNpc.GetById(nNpcId);
	if pNpc then
		pNpc.Delete();
	else
		return 0;
	end
	local tbPlayer = self.tbBase:GetPlayerList();
	local tbPos = self.tbTrans2HousePos;
	for _,pPlayer in pairs(tbPlayer) do
		if pPlayer then
			pPlayer.NewWorld(self.tbBase.nMapId,tbPos[1],tbPos[2]);
			if pPlayer.nFightState == 0 then
				pPlayer.SetFightState(1);
			end
		end
	end
	local nTempId = self.tbStarManagerInHouse[1];
	local tbPos = self.tbStarManagerInHouse[2];
	local pNpc = KNpc.Add2(nTempId,125,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);	
	if pNpc then
		pNpc.GetTempTable("ChenChongZhen").nTalkTimer = Timer:Register(self.nTalkDelay,self.OnNpcTalk,self,pNpc.dwId);	
		pNpc.GetTempTable("ChenChongZhen").nTalkCount = 0;	--说话的次数
	end
	return 0;
end

function tb4thRoom:OnNpcTalk(nNpcId)
	if not self.tbBase or self.tbBase:IsOpen() ~= 1 then
		return 0;
	end
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	pNpc.GetTempTable("ChenChongZhen").nTalkCount = pNpc.GetTempTable("ChenChongZhen").nTalkCount + 1;
	local szContent = self.tbNpcTalkText[pNpc.GetTempTable("ChenChongZhen").nTalkCount];
	if szContent then
		self.tbBase:NpcTalk(nNpcId,szContent);
	else
		local tbAiPos = self.tbStarManagerAiPos;
		pNpc.AI_ClearPath();
		for _,tbPos in ipairs(tbAiPos) do
			pNpc.AI_AddMovePos(tbPos[1],tbPos[2]);
		end
		pNpc.SetNpcAI(9,0,0,0,0,0,0,0);
		pNpc.SetActiveForever(1);
		pNpc.GetTempTable("Npc").tbOnArrive = {self.OnNpcArrive,self,pNpc.dwId};
		return 0;
	end
end

function tb4thRoom:OnNpcArrive(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if pNpc then
		pNpc.Delete();		
	else
		return 0;
	end
	self:EndRoom();
end

function tb4thRoom:ApplyNotifyLight()
	if self:CheckCanNotifyLight() ~= 1 then
		return 0;
	end
	self:ClearTimer();
	self:ClearLight();
	self:NotifyLight(1);	--要加上查询次数
end

function tb4thRoom:GetCorrectCount()
	return self.nFireCorrectLightCount;
end

function tb4thRoom:GetErrorCount()
	return self.nFireErrorLightCount;
end

--如果处于提示状态，则不能再进行提示
function tb4thRoom:CheckCanNotifyLight()
	if #self.tbNotifyLightNpc > 0 then
		return 0;
	else
		return 1;
	end
end

function tb4thRoom:FailedRoom()
	self.nIsFailed = 1;
	self.nIsStart = 0;
	self:ClearRoom();
	self.tbBase:StartCurrentRoom();
	self.tbBase:AllBlackBoard("Chẳng lẽ thế gian không ai phá nổi Kỳ Đăng Trận sao?");
end

function tb4thRoom:IsRoomFailed()
	return self.nIsFailed or 0;
end

function tb4thRoom:EndRoom()
	self.nIsFinished = 1;
	self.tbBase:AllBlackBoard("Dù chưa nói rõ, nhưng hãy theo ông ta rời khỏi đây!");
	self:ClearRoom();
	self:RoomFinish();
end

function tb4thRoom:ClearTimer()
	if self.nNotifyLightTimer and self.nNotifyLightTimer > 0 then
		Timer:Close(self.nNotifyLightTimer);
		self.nNotifyLightTimer = 0;
	end
	self.nNotifyLightTimer = 0;
	if self.nAddLightEnemyTimer and self.nAddLightEnemyTimer > 0 then
		Timer:Close(self.nAddLightEnemyTimer);
		self.nAddLightEnemyTimer = 0;
	end
	self.nAddLightEnemyTimer = 0;
	if self.nAddLightEnemyBeginTimer and self.nAddLightEnemyBeginTimer > 0 then
		Timer:Close(self.nAddLightEnemyBeginTimer);
		self.nAddLightEnemyBeginTimer = 0;
	end
	self.nAddLightEnemyBeginTimer = 0;
	if self.nEndMovieTimer and self.nEndMovieTimer > 0 then
		Timer:Close(self.nEndMovieTimer);
		self.nEndMovieTimer = 0;
	end
	self.nEndMovieTimer = 0;
end

function tb4thRoom:ClearRoom()
	self:ClearNpc();
	self:ClearTimer();
	self:ResetLightIdx();
	self.tbBase:UpdateUiState("");
end

function tb4thRoom:IsRoomStart()
	return self.nIsStart or 0;
end

function tb4thRoom:IsRoomFinished()
	return self.nIsFinished or 0;
end

function tb4thRoom:RoomFinish()
	self.tbBase:RoomFinish();
	self.tbBase:StartNextRoom();
end
---room 4 end


---room 5
--define
tb5thRoom.tbStarManagerInfo = {10011,{61600/32,97376/32}};	--星盘，路人

tb5thRoom.tbBossInfo = {10012,{61536/32,97600/32}};	--追兵头

tb5thRoom.tbBossPercent = {70,50,30};	--血量触发

tb5thRoom.tbHorseNpcInfo = {10013,
	{
		{61920/32,97184/32},
		{61856/32,97184/32},
		{61856/32,97088/32},
		{61920/32,97280/32},
		{61984/32,97184/32},
		{62048/32,97184/32},
		{61952/32,97376/32},
		{61984/32,97440/32},
		{61984/32,97536/32},
		{62080/32,97536/32},
		{62080/32,97632/32},
		{62080/32,97440/32},
		{62016/32,97376/32},
		{61984/32,97280/32},
		{62048/32,97280/32},
	}
};	--装饰的骑兵

tb5thRoom.tbEnemyInfo = {10014,{61888/32,97376/32}};	--随从的模板id

tb5thRoom.nBossReduceLifePercent = 0.1;	--每次杀死随从boss掉的血量

tb5thRoom.nStarManagerTalkDelay = 3 * Env.GAME_FPS;

tb5thRoom.nClearBuffDelay = 1 * Env.GAME_FPS;

tb5thRoom.tbNpcTalkText = 
{
	"我在镇口安置下三根定魂石",
	"使得追兵无法出去求援",
	"现下我们损毁定魂石便可破阵离开",
};

tb5thRoom.tbEnemyCallInfo = {10015,
	{
		{61408/32,97504/32},
		{61408/32,97728/32},
		{61664/32,97536/32},
		{61600/32,97792/32},
	}
};	--杀死随从召唤出来的小怪

tb5thRoom.tbEnemyPasserbyInfo = {10015,
	{
		{60256/32,98880/32},
		{60736/32,98528/32},
		{60640/32,99328/32},
		{61024/32,98112/32},
	}
};

tb5thRoom.nNotifySkillId = 2702; --提示aoe

tb5thRoom.nPassDebuffId = 2566;	--传递debuff

tb5thRoom.nPassChildDebuffId = 2587;

tb5thRoom.nNotifySkillPercent = 50;	--放技能的percent

tb5thRoom.nScanPassDebufDelay = 10 * Env.GAME_FPS;

tb5thRoom.tbStarManagerAiPos = {
	{61408,97984},
	{60960,98272},
	{60704,98528},
	{60608,98592},
	{60288,98912},
	{60512,99360},
	{60736,99744},
	{59968,100896},
	{59136,101792},
	{58496,102848},
	{57984,102496},
	{57376,103264},
};	--星盘的ai路线

--logic
function tb5thRoom:ClearNpc()
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,self.tbEnemyPasserbyInfo[1]);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,self.tbStarManagerInfo[1]);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,self.tbBossInfo[1]);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,self.tbHorseNpcInfo[1]);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,self.tbEnemyInfo[1]);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,self.tbEnemyCallInfo[1]);
end

function tb5thRoom:StartRoom()
	self.nIsStart = 1;
	self.nIsFailed = 0;
	self:ClearRoom();
	self:StartClearBuff();	--复活的帧可能无法清楚掉buff，延迟清楚
	self:AddHorseNpc();
	self:AddStarManager();
	self:AddBoss();
	self.tbBase:UpdateUiState("Đại chiến truy binh\n\n<color=red>Đánh bại Thủ Lĩnh Truy Binh<color>");
end

function tb5thRoom:StartClearBuff()
	self.nClearBuffTimer = Timer:Register(self.nClearBuffDelay,self.OnClearBuff,self);
end

function tb5thRoom:OnClearBuff()
	if not self.tbBase or self.tbBase:IsOpen() ~= 1 then
		self.nClearBuffTimer = 0;
		return 0;
	end
	self:ClearPassDebuff();
	self.nClearBuffTimer = 0;
	return 0;	
end

function tb5thRoom:AddPasserByEnemey()
	local nTempId = self.tbEnemyPasserbyInfo[1];
	local tbPos = self.tbEnemyPasserbyInfo[2];
	for _,tb in pairs(tbPos) do
		KNpc.Add2(nTempId,125,-1,self.tbBase.nMapId,tb[1],tb[2]);
	end
end

function tb5thRoom:AddHorseNpc()
	local nTempId = self.tbHorseNpcInfo[1];
	local tbPos = self.tbHorseNpcInfo[2];
	for _,tb in pairs(tbPos) do
		KNpc.Add2(nTempId,125,-1,self.tbBase.nMapId,tb[1],tb[2]);
	end
end

function tb5thRoom:AddStarManager()
	local nTempId = self.tbStarManagerInfo[1];
	local tbPos = self.tbStarManagerInfo[2];
	KNpc.Add2(nTempId,125,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
end


function tb5thRoom:AddBoss()
	local nTempId = self.tbBossInfo[1];
	local tbPos = self.tbBossInfo[2];
	local pBoss = KNpc.Add2(nTempId,125,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
	if pBoss then
		for _,nPercent in pairs(self.tbBossPercent) do
			Npc:RegPNpcLifePercentReduce(pBoss,nPercent,self.OnBossPercent,self,pBoss.dwId);
		end
		Npc:RegPNpcOnDeath(pBoss,self.OnBossDeath,self);
		Npc:RegDeathLoseItem(pBoss,self.tbBase.OnBossDrop,self.tbBase);	--掉落回调
	else
		Dbg:WriteLog("ChenChongZhen","Room 5 Add Boss Failed!",self.tbBase.nMapId,self.tbBase.nServerId,self.tbBase.nPlayerId);	
	end
end

function tb5thRoom:OnBossDeath()
	if him.GetTempTable("ChenChongZhen").nCastSkillTimer and him.GetTempTable("ChenChongZhen").nCastSkillTimer > 0 then
		Timer:Close(him.GetTempTable("ChenChongZhen").nCastSkillTimer);
		him.GetTempTable("ChenChongZhen").nCastSkillTimer = 0;
	end
	self.tbBase:NpcDropItem(him);
	self.tbBase:RevivePlayerAfterFinish();
	self:ClearPassDebuff();
	self:ClearNpc();
	self:AddWalkNpc();
	self:AddPasserByEnemey();
end

function tb5thRoom:AddWalkNpc()
	local nTempId = self.tbStarManagerInfo[1];
	local tbPos = self.tbStarManagerInfo[2];
	local pNpc = KNpc.Add2(nTempId,125,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
	if pNpc then
		local tbAi = self.tbStarManagerAiPos;
		pNpc.AI_ClearPath();
		pNpc.SetCurCamp(6);
		for _,tbPos in ipairs(tbAi) do
			pNpc.AI_AddMovePos(tbPos[1],tbPos[2]);
		end
		pNpc.SetNpcAI(9,0,0,0,0,0,0,0);
		pNpc.SetActiveForever(1);
		pNpc.GetTempTable("Npc").tbOnArrive = {self.OnNpcArrive,self,pNpc.dwId};
		pNpc.GetTempTable("ChenChongZhen").nTalkTimer = Timer:Register(self.nStarManagerTalkDelay,self.OnNpcTalk,self,pNpc.dwId);
		pNpc.GetTempTable("ChenChongZhen").nTalkCount = 0;
		self.tbBase:AllBlackBoard("Phong Tụ Cư Sĩ: “Đừng vội giao chiến, hãy theo ta!”");
	end
end

function tb5thRoom:OnNpcTalk(nNpcId)
	if not self.tbBase or self.tbBase:IsOpen() ~= 1 then
		return 0;
	end
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	pNpc.GetTempTable("ChenChongZhen").nTalkCount = (pNpc.GetTempTable("ChenChongZhen").nTalkCount or 0) + 1;
	local szText = self.tbNpcTalkText[pNpc.GetTempTable("ChenChongZhen").nTalkCount];
	if szText then
		self.tbBase:NpcTalk(nNpcId,szText);
	else
		return 0;
	end
end                                      
                                      
                              
function tb5thRoom:OnNpcArrive(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if pNpc then
		pNpc.Delete();
	end
	self:EndRoom();
end

function tb5thRoom:OnBossPercent(nBossId,nPercent)
	local pBoss = KNpc.GetById(nBossId);
	if not pBoss then
		return 0;
	end
	self.tbBase:AllBlackBoard("Hãy giải quyết tên đáng ngờ nhất trong bọn!");
	self:AddEnemy(nBossId);
	if nPercent == self.nNotifySkillPercent then
		self:CastPassDebuff(nBossId);
	end
end

function tb5thRoom:CastPassDebuff(nBossId)
	local pBoss = KNpc.GetById(nBossId);
	if not pBoss then
		return 0;
	end
	self.tbBase:AllBlackBoard("Phong Tụ Cư Sĩ: “Tiêu Vân Tán! Hai người chuyền đi mới không mất mạng!”");
	self:OnCastPassDebuff(nBossId);
	pBoss.GetTempTable("ChenChongZhen").nCastSkillTimer = Timer:Register(self.nScanPassDebufDelay,self.OnCastPassDebuff,self,nBossId);
end

function tb5thRoom:OnCastPassDebuff(nBossId)
	if not self.tbBase or self.tbBase:IsOpen() ~= 1 then
		return 0;
	end
	local pBoss = KNpc.GetById(nBossId);
	if not pBoss then
		return 0;
	end
	if pBoss.IsDead() == 1 then
		pBoss.GetTempTable("ChenChongZhen").nCastSkillTimer = 0;
		return 0;
	end
	if self:CheckIsNoDebuff() ~= 1 then
		local _,x,y = pBoss.GetWorldPos();
		pBoss.CastSkill(self.nNotifySkillId,1,x*32,y*32,1);
		self:AddPassDebuff(nBossId);
	end
end

function tb5thRoom:AddPassDebuff(nBossId)
	local pBoss = KNpc.GetById(nBossId);
	if not pBoss or pBoss.IsDead() == 1 then
		return 0;
	end
	local tbPlayer = KNpc.GetAroundPlayerList(nBossId,40);
	if #tbPlayer <= 0 then
		return 0;
	end
	local pPlayer = nil;
	for i = 1,#tbPlayer do
		local pRand = tbPlayer[MathRandom(#tbPlayer)];
		if pRand and pRand.IsDead() ~= 1 then
			pPlayer = pRand;
			break;
		end
	end
	if pPlayer then
		pPlayer.AddSkillState(self.nPassDebuffId,1,0,5 * 60 * Env.GAME_FPS,0,0);
	end
end

function tb5thRoom:CheckIsNoDebuff()
	local tbPlayer = self.tbBase:GetPlayerList();
	local nExist = 0;
	for _,pPlayer in pairs(tbPlayer) do
		if pPlayer and pPlayer.GetSkillState(self.nPassDebuffId) > 0 then
			nExist = 1;
			break;
		end
	end
	return nExist;
end

function tb5thRoom:ClearPassDebuff()
	local tbPlayer = self.tbBase:GetPlayerList();
	for _,pPlayer in pairs(tbPlayer) do
		if pPlayer then
			pPlayer.RemoveSkillState(self.nPassDebuffId);
			pPlayer.RemoveSkillState(self.nPassChildDebuffId);
		end
	end
end

function tb5thRoom:AddEnemy(nBossId)
	local pBoss = KNpc.GetById(nBossId);
	if not pBoss then
		return 0;
	end
	local nTempId = self.tbEnemyInfo[1];
	local tbPos = self.tbEnemyInfo[2];
	local pNpc = KNpc.Add2(nTempId,125,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
	if pNpc then
		Npc:RegPNpcOnDeath(pNpc,self.OnEnemyDeath,self,nBossId);
	end
end

function tb5thRoom:OnEnemyDeath(nBossId,pKiller)
	local pBoss = KNpc.GetById(nBossId);
	if not pBoss then
		return 0;
	end
	local pPlayer = pKiller.GetPlayer();
	local nMaxLife = pBoss.nMaxLife;
	local nReduce = math.floor(nMaxLife * self.nBossReduceLifePercent);
	pBoss.ReduceLife(nReduce);
	self:AddEnemyCalled();	--加召唤怪
	if pBoss.nCurLife <= 0 and pPlayer then
		pPlayer.KillNpc(nBossId);
	end
end

function tb5thRoom:AddEnemyCalled()
	local nTempId = self.tbEnemyCallInfo[1];
	local tbPos = self.tbEnemyCallInfo[2];
	for _,tb in pairs(tbPos) do
		KNpc.Add2(nTempId,125,-1,self.tbBase.nMapId,tb[1],tb[2]);
	end
end

function tb5thRoom:FailedRoom()
	self.nIsFailed = 1;
	self.nIsStart = 0;
	self:ClearRoom();
	self.tbBase:StartCurrentRoom();
	self.tbBase:AllBlackBoard("Thủ lĩnh Truy Binh: “Haha...Cửu Thế Tinh Bàn là của ta!”");
end

function tb5thRoom:IsRoomFailed()
	return self.nIsFailed or 0;
end

function tb5thRoom:EndRoom()
	self.nIsFinished = 1;
	self:ClearRoom();
	self:RoomFinish();
	-- 发经验
	local tbPlayer = self.tbBase:GetPlayerList();
	for _, pPlayer in pairs(tbPlayer) do
		if pPlayer then
			pPlayer.AddExp(3200000);
		end
	end
end

function tb5thRoom:ClearRoom()
	self:ClearNpc();
	self:ClearPassDebuff();
	self.tbBase:UpdateUiState("");
end

function tb5thRoom:IsRoomStart()
	return self.nIsStart or 0;
end

function tb5thRoom:IsRoomFinished()
	return self.nIsFinished or 0;
end

function tb5thRoom:RoomFinish()
	self.tbBase:RoomFinish();
	self.tbBase:StartNextRoom();
end
--room 5 end


--room 6 
--define
tb6thRoom.tbBossInfo = {10016,{1792,3251}};	--boss

tb6thRoom.nBossDeathPercent = 50;	--boss打 50%血量就结束

tb6thRoom.tbStarManagerInfo = {10018,{57440/32,103392/32}};	--路人，星盘

tb6thRoom.nEndDelay = 2 * Env.GAME_FPS;	--2秒后删除npc

tb6thRoom.nStarManagerTalkDelay = 3 * Env.GAME_FPS;

tb6thRoom.tbBossCastSkillPercent = {75,70,65,60,55,50};

tb6thRoom.nSkillPosCount = 3;

tb6thRoom.nBossSkillId = 2680;

tb6thRoom.nBossExp = 3600000;	

tb6thRoom.nPassDebuffId = 2566;	--传递debuff

tb6thRoom.nPassChildDebuffId = 2587;

tb6thRoom.nBossFindRange = 60;

tb6thRoom.tbBossSkillPos = 
{
	{56768,104032},{56672,103712},{57280,103328},{57120,103072},
	{57248,103808},{57152,104160},{57024,103456},{57024,103936},
	{56928,104288},{56832,103456},{57408,103392},{57568,103072},
	{57408,103584},{57408,103968},{57632,103904},{57632,103680},
	{57792,103552},{57792,104288},{57632,104192},{57504,104480},
	{57728,105024},{57408,104768},{57952,103712},{57920,104000},
	{58208,104032},{58240,104416},{57856,104672},{58272,104960},
	{58464,103776},
};

tb6thRoom.tbStarManagerTalkText = 
{
	"血樱千放为虚，躲于波纹之内无恙。",
	"缚神樱杀需以身拦剑气，耗血气增攻修。",
	"夜樱曼天罗所缠之人休乱动，过后速来吾处。",
};

--logic
function tb6thRoom:ClearNpc()
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,self.tbBossInfo[1]);		--清boss
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,self.tbStarManagerInfo[1]);	
end

function tb6thRoom:ClearPassDebuff()
	local tbPlayer = self.tbBase:GetPlayerList();
	for _,pPlayer in pairs(tbPlayer) do
		if pPlayer then
			pPlayer.RemoveSkillState(self.nPassDebuffId);
			pPlayer.RemoveSkillState(self.nPassChildDebuffId);
		end
	end
end

function tb6thRoom:StartRoom()
	self.nIsStart = 1;
	self.nIsFailed = 0;
	self.nStarManager = 0;
	self.nIsMovieStart = 0;	--剧情没开始
	self:ClearRoom();
	self:AddBoss();
	self:AddStarManager();
	self.tbBase:UpdateUiState("Cố nhân tương phùng\n\n<color=red>Đánh thắng Thác Bạt Phù Anh<color>");
end

function tb6thRoom:AddBoss()
	local nTempId = self.tbBossInfo[1];
	local tbPos = self.tbBossInfo[2];
	local pBoss = KNpc.Add2(nTempId,125,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
	if pBoss then
		--for _,nPercent in pairs(self.tbBossCastSkillPercent) do
		Npc:RegPNpcLifePercentReduce(pBoss,self.nBossDeathPercent,self.OnBossPercent,self,pBoss.dwId);
		--end
		Npc:RegDeathLoseItem(pBoss,self.tbBase.OnBossDrop,self.tbBase);	--掉落回调
	else
		Dbg:WriteLog("ChenChongZhen","Room 5 Add Boss Failed!",self.tbBase.nMapId,self.tbBase.nServerId,self.tbBase.nPlayerId);	
	end
end

function tb6thRoom:OnBossPercent(nNpcId,nPercent)
	local pNpc = KNpc.GetById(nNpcId);
	if pNpc then
--		if nPercent == self.nBossDeathPercent then
		self.tbBase:NpcDropItem(pNpc);
		pNpc.SetCurCamp(6);
		pNpc.GetTempTable("ChenChongZhen").nEndTimer = Timer:Register(self.nEndDelay,self.OnEnd,self,nNpcId);
--		else
--			self:BossCastSkill(nNpcId);	
--		end	
	end
end


function tb6thRoom:BossCastSkill(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local tbNearPlayer = KNpc.GetAroundPlayerList(nNpcId,self.nBossFindRange);
	if #tbNearPlayer > 0 then
		local pPlayer = nil;
		for i = 1,#tbNearPlayer do
			local pRand = tbNearPlayer[MathRandom(#tbNearPlayer)];
			if pRand and pRand.IsDead() ~= 1 then
				pPlayer = pRand;
				break;
			end
		end
		if pPlayer then
			local _,nX,nY = pPlayer.GetWorldPos();
			pNpc.CastSkill(self.nBossSkillId,20,nX*32,nY*32,1);
		end
	end
--	local tbIdx = {};
--	for i = 1,#self.tbBossSkillPos do
--		tbIdx[i] = i;
--	end
--	for i = 1 , self.nSkillPosCount do
--		local nRand = MathRandom(#tbIdx)
--		local nIdx = tbIdx[nRand];
--		local tbPos = self.tbBossSkillPos[nIdx];
--		pNpc.CastSkill(self.nBossSkillId,20,tbPos[1],tbPos[2],1);
--		table.remove(tbIdx,nRand);
--	end
end


function tb6thRoom:OnEnd(nNpcId)
	if not self.tbBase or self.tbBase:IsOpen() ~= 1 then
		return 0;
	end
	local pNpc = KNpc.GetById(nNpcId);
	if pNpc then
		pNpc.Delete();
	end
	self.nIsMovieStart = 1;	--剧情开始了
	self:EndRoom();
	return 0;	
end

function tb6thRoom:AddPlayerExp()
	local tbPlayer = self.tbBase:GetPlayerList();
	for _,pPlayer in pairs(tbPlayer) do
		if pPlayer then
			pPlayer.AddExp(self.nBossExp);
		end
	end
end

function tb6thRoom:AddStarManager()
	local nTempId = self.tbStarManagerInfo[1];
	local tbPos = self.tbStarManagerInfo[2];
	local pNpc = KNpc.Add2(nTempId,125,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
	if pNpc then
		pNpc.GetTempTable("ChenChongZhen").nTalkTimer = Timer:Register(self.nStarManagerTalkDelay,self.OnStarManagerTalk,self,pNpc.dwId);
		pNpc.GetTempTable("ChenChongZhen").nTalkCount = 0;
	end
end

function tb6thRoom:OnStarManagerTalk(nNpcId)
	if not self.tbBase or self.tbBase:IsOpen() ~= 1 then
		return 0;
	end
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	if self.nIsMovieStart == 1 then	--剧情开始，星盘就不喊话了
		return 0;
	end
	pNpc.GetTempTable("ChenChongZhen").nTalkCount = (pNpc.GetTempTable("ChenChongZhen").nTalkCount or 0) + 1;
	if pNpc.GetTempTable("ChenChongZhen").nTalkCount > #self.tbStarManagerTalkText then
		pNpc.GetTempTable("ChenChongZhen").nTalkCount = 1;
	end
	local szText = self.tbStarManagerTalkText[pNpc.GetTempTable("ChenChongZhen").nTalkCount];
	if szText then
		self.tbBase:NpcTalk(nNpcId,szText);
	else
		return 0;
	end
end  

function tb6thRoom:FailedRoom()
	self.nIsFailed = 1;
	self.nIsStart = 0;
	self:ClearRoom();
	self.tbBase:StartCurrentRoom();
	self.tbBase:AllBlackBoard("Thác Bạt Phù Anh: “Các ngươi không được dẫn hắn đi!”");
end

function tb6thRoom:IsRoomFailed()
	return self.nIsFailed or 0;
end

function tb6thRoom:EndRoom()
	self.nIsFinished = 1;
	self:ClearRoom();
	self:RoomFinish();
	self:AddPlayerExp();	--由于是手动杀死的，所以手动加经验
	self.tbBase:ChangeWeather(1);	--打完就下雨
	self.tbBase:AllBlackBoard("Phong Tụ Cư Sĩ: “Người này giao cho ta! Hãy cưỡi dị thú rời khỏi đây!”");
end

function tb6thRoom:ClearRoom()
	self:ClearNpc();
	self:ClearPassDebuff();
	self.tbBase:UpdateUiState("");
end

function tb6thRoom:IsRoomStart()
	return self.nIsStart or 0;
end

function tb6thRoom:IsRoomFinished()
	return self.nIsFinished or 0;
end

function tb6thRoom:RoomFinish()
	self.tbBase:RoomFinish();
	self.tbBase:StartNextRoom();
end

--room 6 end

--room 7
--define
tb7thRoom.tbMachineInfo = {10021,
	{
		{53088/32,107904/32},
		{52864/32,108384/32},
		{52736/32,109088/32},
		{53664/32,107584/32},
		{53568/32,108352/32},
		{54144/32,107552/32},
		{54080/32,108192/32},
		{54560/32,106912/32},
		{54560/32,107552/32},
		{55232/32,106208/32},
		{55136/32,106944/32},
		{54912/32,107424/32},
		{54976/32,106624/32},
		{55488/32,105728/32},
		{55648/32,106560/32},
	}
};	--要开启的机关

tb7thRoom.nMachineCount = 3;	--刷3个机关

tb7thRoom.nTalkDelay = 3 * Env.GAME_FPS;

tb7thRoom.tbBossUnFightInfo = {10017,{57632/32,103744/32}};	--非战斗boss

tb7thRoom.tbStarManagerInfo = {10018,{57440/32,103392/32}};	--路人，星盘

tb7thRoom.tbTalkContent = {
	"你可否忘了世仇跟我走？",
	"我不敢忘，我一忘…世上便再没有浮樱。",
	"哈哈……世上本就没有什么浮樱，只有我。",
	"…你确实不是她，你是拓跋氏的英雄。",
	"你明知道……我不可能背弃我的部族。",
	"哈哈，我就是太知道…你允我一事，我便跟你走",
	"……何事？",
	"陪我在这呆一会吧。让浮樱好好看看我的样子。",
	"……你…",
	"我要她记得，这世上曾有一人，名之风岫。"
};

--logic
function tb7thRoom:ClearNpc()
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,self.tbMachineInfo[1]);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,self.tbBossUnFightInfo[1]);
	ClearMapNpcWithTemplateId(self.tbBase.nMapId,self.tbStarManagerInfo[1]);
end

function tb7thRoom:StartRoom()
	self.nIsStart = 1;
	self.nIsFailed = 0;
	self.nUnFightBoss = 0;
	self.nStarManager = 0;
	self:ClearRoom();
	self:InitMachineInfo();
	self:AddMachine();
	self:AddStarManager();
	self:AddUnFightBoss();
	self.tbBase:UpdateUiState("Biển lửa nghìn trùng\n\n<color=red>Vượt biển lửa, đóng cơ quan<color>");
end

function tb7thRoom:InitMachineInfo()
	self.tbOpenSwitchInfo = {};	--标记谁点过
	self.tbMachineNpc = {};
end

function tb7thRoom:AddStarManager()
	local nTempId = self.tbStarManagerInfo[1];
	local tbPos = self.tbStarManagerInfo[2];
	local pNpc = KNpc.Add2(nTempId,125,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
	if pNpc then
		self.nStarManager = pNpc.dwId;
	end
end

function tb7thRoom:AddUnFightBoss()
	local nTempId = self.tbBossUnFightInfo[1];
	local tbPos = self.tbBossUnFightInfo[2];
	local pNpc = KNpc.Add2(nTempId,125,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
	if pNpc then
		self.nUnFightBoss = pNpc.dwId;
		pNpc.GetTempTable("ChenChongZhen").nTalkTimer = Timer:Register(self.nTalkDelay,self.OnNpcTalk,self);
		pNpc.GetTempTable("ChenChongZhen").nTalkCount = 0;
	end
end

function tb7thRoom:AddHorse()
	self.tbBase:AddRoom7Horse();
end

function tb7thRoom:OnNpcTalk()
	if not self.tbBase or self.tbBase:IsOpen() ~= 1 then
		return 0;
	end
	local pBoss = KNpc.GetById(self.nUnFightBoss);
	local pNpc = KNpc.GetById(self.nStarManager);
	if not pNpc or not pBoss then
		self:AddHorse();
		return 0;
	end
	pBoss.GetTempTable("ChenChongZhen").nTalkCount = (pBoss.GetTempTable("ChenChongZhen").nTalkCount or 0) + 1;
	local nIndex = pBoss.GetTempTable("ChenChongZhen").nTalkCount;
	local szText = self.tbTalkContent[nIndex];
	if szText then
		if nIndex % 2 == 0 then
			self.tbBase:NpcTalk(self.nStarManager,szText);
		else
			self.tbBase:NpcTalk(self.nUnFightBoss,szText);
		end
	else
		self:AddHorse();
		return 0;
	end
end

function tb7thRoom:AddMachine()
	local nTempId = self.tbMachineInfo[1];
	local tbPos = self.tbMachineInfo[2];
	local tbIdx = {};
	for i = 1,#self.tbMachineInfo[2] do
		tbIdx[i] = i;
	end
	for i = 1,self.nMachineCount do
		local nIdx = tbIdx[MathRandom(#tbIdx)];
		local tbPos = self.tbMachineInfo[2][nIdx];
		local pNpc = KNpc.Add2(nTempId,125,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);	
		if pNpc then
			table.insert(self.tbMachineNpc,pNpc.dwId);
		end
		table.remove(tbIdx,nIdx);
	end
end

function tb7thRoom:ProcessSwitch(nPlayerId)
	if not self.tbOpenSwitchInfo then
		self.tbOpenSwitchInfo = {};
	end
	self.tbOpenSwitchInfo[nPlayerId] = 1;
	self:ProcessIsOver();
end

function tb7thRoom:ProcessIsOver()
	local nCount = 0;
	for _,nFlag in pairs(self.tbOpenSwitchInfo) do
		if nFlag == 1 then
			nCount = nCount + 1;
		end		
	end
	if nCount >= #self.tbMachineNpc then
		self:EndRoom();
	end
end

function tb7thRoom:IsPlayerOpened(nPlayerId)
	if not self.tbOpenSwitchInfo or self.tbOpenSwitchInfo[nPlayerId] ~= 1 then
		return 0;
	end
	return 1;
end

function tb7thRoom:FailedRoom()
	self.nIsFailed = 1;
	self.nIsStart = 0;
	self:ClearRoom();
	self.tbBase:StartCurrentRoom();
	self.tbBase:AllBlackBoard("Hỏa thần bủa vây, không thể nào tìm được lối thoát.");
end

function tb7thRoom:IsRoomFailed()
	return self.nIsFailed or 0;
end

function tb7thRoom:EndRoom()
	self.nIsFinished = 1;
	self:FinishPlayerTask();	--完成任务
	self.tbBase:AllBlackBoard("Phong Tụ và Phù Anh ở lại trong biển lửa cùng Thần Trùng Trấn.")
	self.tbBase:DropBox();	--加宝箱
	self:ClearRoom();
	self:RoomFinish();
end

function tb7thRoom:FinishPlayerTask()
	local tbPlayer = self.tbBase:GetPlayerList();
	for _,pPlayer in pairs(tbPlayer) do
		if pPlayer then
			Faction:AchieveTask(pPlayer, Faction.TYPE_CHENCHONGZHEN);
			pPlayer.SetTask(ChenChongZhen.nTaskHavePlayerTaskGroupId,ChenChongZhen.nTaskHavePlayerTaskId,1);
		end
	end
end

function tb7thRoom:ClearRoom()
	self:ClearNpc();
	self.tbBase:UpdateUiState("");
end

function tb7thRoom:IsRoomStart()
	return self.nIsStart or 0;
end

function tb7thRoom:IsRoomFinished()
	return self.nIsFinished or 0;
end

function tb7thRoom:RoomFinish()
	self.tbBase:RoomFinish();
end
--room 7 end