-- 文件名　：missionlevel20_base.lua
-- 创建者　：jiazhenwei
-- 创建时间：2012-07-24 17:06:32
-- 功能    ：

local tbBase = Mission:New();

Task.NewPrimerLv20 = Task.NewPrimerLv20 or {};
local NewPrimerLv20 = Task.NewPrimerLv20;
NewPrimerLv20.tbBase = tbBase;

--初始化mission
function tbBase:InitGame(nMapId)
	self.nMapId = nMapId;
	self.nCurSec = 0;		--副本计时器
	self.nYanhua = 0;		--烟花点燃数量
	self.nIsEnded = 0;
	self.tbYanhuaList = {};
	self.tbMisCfg = 
	{
		nForbidSwitchFaction = 1,
		nFightState = 1,
		tbEnterPos 	= {},
		tbLeavePos	= {},	-- 离开坐标
		tbDeathRevPos = {{nMapId, 1922, 3537}},	-- 死亡重生点
		nOnDeath 	= 1, 		-- 死亡脚本可用
		nDeathPunish 	= 1,
		nPkState = Player.emKPK_STATE_PRACTISE,
	};
	ResetMapNpc(nMapId);
	ChangeWorldWeather(nMapId, 0);	--这里防止之前没有关闭掉
	self:Open();
	self:GameStart();
end

function tbBase:JoinGame(pPlayer)
	self:JoinPlayer(pPlayer,1);	-- 只有一个阵营
	self.nPlayerId = pPlayer.nId;
	local nLevel = math.ceil(pPlayer.nLevel / 10);
	pPlayer.AddSkillState(1972, nLevel, 1,  90 * 60 * 18, 1, 1);
	--刷一次任务目标，使指引变为具体任务目标
	pPlayer.CallClientScript({"GM:DoCommand", "Ui(Ui.UI_TASKTRACK):OnTimeRefresh()"});
	Setting:SetGlobalObj(pPlayer);
	self:OpenEvent();
	Setting:RestoreGlobalObj();
end

--结束mission
function tbBase:EndGame()
	if self.nGameTimerId and self.nGameTimerId > 0 then
		Timer:Close(self.nGameTimerId);
		self.nGameTimerId = 0;
	end
	if self.nWaringTimerId and self.nWaringTimerId > 0 then
		Timer:Close(self.nWaringTimerId);
		self.nWaringTimerId = 0;
	end
	self:Close();
	self.nIsGameStart = 0;
	GCExcute{"Task.NewPrimerLv20:SysCloseInfo", GetServerId(), self.nPlayerId, self.nMapId};
end

--申请完之后就开启了
function tbBase:GameStart()
	--如果已经开启，不进行游戏开启操作
	if self.nIsGameStart == 1 then
		return 0;
	end
	self.nGameTimerId = Timer:Register(NewPrimerLv20.MAX_TIME * Env.GAME_FPS, self.GameTimeUp, self);
	self.nWaringTimerId = Timer:Register(Env.GAME_FPS, self.WaringMsg, self);
	self.nIsGameStart = 1;
end

function tbBase:OpenEvent()
	NewPrimerLv20:OpenEvent(self.nMapId);
	for i =38, 52 do
		Npc.SceneAction:DoParam(i);
	end
	Npc.SceneAction:DoParam(117);
	Npc.SceneAction:DoParam(118);
end

function tbBase:WaringMsg()
	if (not self.nCurSec) then
		self.nCurSec = 1;
	else
		self.nCurSec = self.nCurSec + 1;
	end
	
	if (self.nCurSec % 300 == 0) then
		self:AllBlackBoard("Còn "..math.floor((NewPrimerLv20.MAX_TIME - self.nCurSec)/60).." phút nữa sẽ kết thúc phó bản Tân Thủ.");
	end
	
	if #self.tbYanhuaList > 0 and self.nCurSec % 5 == 0 then
		for _, nNpcId in ipairs(self.tbYanhuaList) do
			local pNpc = KNpc.GetByIndex(nNpcId);
			if pNpc then
				pNpc.CastSkill(2934, 1,-1, pNpc.nIndex);
			end
		end
	end
end

function tbBase:GameTimeUp()
	self.nGameTimerId = 0;
	self:AllBlackBoard("Đã hết thời gian, hãy trở lại phó bản nếu chưa hoàn thành nhiệm vụ!");
	self:EndGame();
	return 0;
end

function tbBase:FireYanhua()
	if #self.tbYanhuaList <= 0 then
		self.tbYanhuaList = KNpc.GetMapNpcWithName(self.nMapId, "Pháo hoa");
	end
end

--关闭前清理
function tbBase:OnClose()
	ClearMapNpc(self.nMapId);
	ClearMapObj(self.nMapId);
	self.nIsEnded = 1;	--是否已经关闭过了，防止onleave时重复关闭
end

--离开时
function tbBase:OnLeave()
	me.SetFightState(0);	-- 非战斗状态
	me.DisabledStall(0);		-- 允许摆摊
	me.DisableOffer(0);		-- 允许贩卖
	--self:ClearTask();
	if self.nIsEnded ~= 1 then
		self:EndGame();			-- 离开的时候把副本关闭
	end
	local tbLevelPos = {55, 1679, 3722};
	tbLevelPos = NewPrimerLv20:GetLevelPos(me);
	me.NewWorld(unpack(tbLevelPos));
	--刷一次任务目标，如果任务没完成会变成指引提示
	me.CallClientScript({"GM:DoCommand", "Ui(Ui.UI_TASKTRACK):OnTimeRefresh()"});
end

function tbBase:OnJoin(nGroupId)
	me.SetLogoutRV(1);			-- 服务器宕机保护
	me.DisabledStall(1);		-- 禁止摆摊
	me.DisableOffer(1);			-- 禁止贩卖
end

function tbBase:OnDeath()
	me.ReviveImmediately(0);
	if me.nFightState == 0 then
		me.SetFightState(1);
	end
end

--黑条通知
function tbBase:BlackBoard(pPlayer,szMsg)
	if pPlayer and szMsg and #szMsg ~= 0 then
		Dialog:SendBlackBoardMsg(pPlayer, szMsg);
	end
end

--集体黑条
function tbBase:AllBlackBoard(szMsg)
	local tbPlayer,nCount = self:GetPlayerList();
	if nCount > 0 then
		for _,pPlayer in pairs(tbPlayer) do
			if pPlayer then
				self:BlackBoard(pPlayer,szMsg);
			end
		end
	end
end
