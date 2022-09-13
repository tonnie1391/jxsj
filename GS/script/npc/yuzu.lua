-- 狱卒

local tbNpc = Npc:GetClass("yuzu");

tbNpc.tbTaskIdReduceOnePkSec	= {2000, 2};		-- 洗一点Pk的剩余时间的任务变量的Id
tbNpc.tbPrisonMapId				= {222,223};		-- 大牢的MapId
tbNpc.tbLingpai 				= {					-- 刑部令牌
	["nGenre"] 					= 18,
	["nDetailType"]				= 1,
	["nParticularType"] 		= 17,
	["nLevel"]					= 1,
};

local tbMap = {};

-- 定义玩家进入事件
function tbMap:OnEnter(szParam)
	if (me.nPKValue <= 0) then	-- 如果PK值等于0则不做处理
		return;
	end
	
	--local tbNpc 	= Npc:GetClass("yuzu");
	local nRestSec	= me.GetTask(tbNpc.tbTaskIdReduceOnePkSec[1], tbNpc.tbTaskIdReduceOnePkSec[2]);
	if (nRestSec <= 0) then		-- 从大牢传进来	
		local nReduceOnePkHour, nSumTimer	= tbNpc:OnePkTime(me.nPKValue);
		nRestSec = 3600 * nReduceOnePkHour;
	end
	assert(nRestSec > 0);
	
	-- 开启计时器
	local tbTmp	= me.GetTempTable("Npc");
	tbTmp.nNpcYuzuTimerId = Timer:Register(nRestSec * Env.GAME_FPS, tbNpc.OnTimer, tbNpc, me.nId);
end

-- 定义玩家离开事件
function tbMap:OnLeave(szParam)
	local tbTmp = me.GetTempTable("Npc");
	if (tbTmp.nNpcYuzuTimerId) then
		local nRestSec	= Timer:GetRestTime(tbTmp.nNpcYuzuTimerId) / Env.GAME_FPS;
		if (nRestSec <= 0) then	-- 特殊处理正好等于0的情况
			nRestSec = 1;
		end
		me.SetTask(tbNpc.tbTaskIdReduceOnePkSec[1], tbNpc.tbTaskIdReduceOnePkSec[2], nRestSec);
		Timer:Close(tbTmp.nNpcYuzuTimerId);

		tbTmp.nNpcYuzuTimerId = nil;
	end
end

-- 复制函数
for i, nMapId in pairs(tbNpc.tbPrisonMapId) do
	local tbPrisonMap = Map:GetClass(nMapId);
	for szMsg in pairs(tbMap) do
		tbPrisonMap[szMsg] = tbMap[szMsg];
	end
	tbPrisonMap.i = i;
end

function tbNpc:OnDialog()
	if (me.nPKValue > 0) then
		Dialog:Say("狱卒：罪孽未清之犯人，不得随意走动！",
				{
					{"询问当前时辰", self.ZishouAskTime, self},
					{"出示刑部令牌,离开大牢", self.ShowLingpai, self, me},
					{"马上回去坐好"}
				});
	else
		Dialog:Say("狱卒：你！收拾收拾行李，已经可以出狱了！\n\n玩家：多谢狱卒大哥，那么我就走了！",
				{
					{"Xác nhận", self.LeavePrison, self, me},
					{"Kết thúc đối thoại"}
				});
				
		me.Msg("在深刻反省之后，你终于被释放出狱。");
	end
end


-- 自首的玩家向狱卒询问时间
function tbNpc:ZishouAskTime()
	local tbTmp					= me.GetTempTable("Npc");
	local nRestReduceOnePkSec	= Timer:GetRestTime(tbTmp.nNpcYuzuTimerId) / Env.GAME_FPS;
	local nHour, nMin, nSec		= Lib:TransferSecond2NormalTime(nRestReduceOnePkSec);
	
	Dialog:Say("玩家：这位大哥，我想问一下现在是什么时辰了?\n\n狱卒：你想要减低1点恶名值，都还差"..nHour.."小时"..nMin.."分"..nSec.."秒，赶紧回去坐好！");
	me.Msg("要降低1点恶名值还需"..nHour.."小时"..nMin.."分"..nSec.."秒！");
end

-- 坐牢的玩家出示令牌
function tbNpc:ShowLingpai(pPlayer)
	-- 没有令牌
	if (pPlayer.GetItemCountInBags(self.tbLingpai.nGenre, self.tbLingpai.nDetailType, self.tbLingpai.nParticularType, self.tbLingpai.nLevel) <= 0) then
		Dialog:Say("狱卒：你根本就没有刑部令牌，居然敢来戏耍本大爷，还不滚开！");
		return;
	end

	Dialog:Say("狱卒：果然是刑部令牌，之前多有得罪，还望大侠多多包涵！您现在要离开大牢吗？",
			{
				{"离开大牢", self.LeavePrisonByLingpai, self, pPlayer},
				{"容Để ta suy nghĩ lại"}
			});
end

function tbNpc:LeavePrisonByLingpai(pPlayer)
	if (pPlayer.ConsumeItemInBags(1, self.tbLingpai.nGenre, self.tbLingpai.nDetailType, self.tbLingpai.nParticularType, self.tbLingpai.nLevel) ~= 0) then								-- 删除一块令牌失败，记录错误，处理并停止逻辑
		pPlayer.Msg("删除刑部令牌失败！");
		return;
	end	
	pPlayer.Msg(pPlayer.szName.."使用了刑部令牌，离开大牢！");
	self:LeavePrison(pPlayer);
end

function tbNpc:LeavePrison(pPlayer)
	local tbNpcYayi = Npc:GetClass("yayi");
	tbNpcYayi:TransferPos(pPlayer.GetMapId(), pPlayer);
end

-- Pk值到达某一点时,每降低一点所需要的时间
function tbNpc:OnePkTime(nPkValue)
	if (nPkValue == 0) then
		return 0, 0;
	end
	local tbReducePkTime =		-- 分成几段来消Pk值, 得到Pk值中每降低1点所需要的时间(小时)
	{
		{ 7, 2 },				-- Pk值大于7的时候,每降低1点需要2小时
		{ 4, 1 },				-- Pk值大于4, 并且小于等于7的时候,每降低1点需要1小时
		{ 0, 0.5 },				-- Pk值大于0, 并且小于等于4的时候,每降低1点需要0.5小时
	};
	local nReduceOnePkHour	= 0;
	local nSumHourTime		= 0;
	
	for i = 1, #tbReducePkTime do
		if (nPkValue > tbReducePkTime[i][1]) then
			nSumHourTime = nSumHourTime + (nPkValue - tbReducePkTime[i][1]) * tbReducePkTime[i][2];	
			nPkValue = tbReducePkTime[i][1];
			if (nReduceOnePkHour == 0) then
				nReduceOnePkHour = tbReducePkTime[i][2];
			end
		end
	end

	return nReduceOnePkHour, nSumHourTime;
end

function tbNpc:OnTimer(nPlayerId)				-- 时间到会调用此函数
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end
	pPlayer.AddPkValue(-1);
	if (pPlayer.nPKValue <= 0) then			-- 返回0，表示要关闭此Timer
		local tbTmp = me.GetTempTable("Npc");
		tbTmp.nNpcYuzuTimerId = nil;
		return 0;
	end	
	return  math.floor(3600 * self:OnePkTime(pPlayer.nPKValue) * Env.GAME_FPS);
end
