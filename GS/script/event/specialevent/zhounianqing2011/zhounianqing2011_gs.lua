-- 文件名  : zhounianqing2011_gs.lua
-- 创建者  : zhongjunqi
-- 创建时间: 2011-06-14 09:52:57
-- 描述    : 三周年庆 佳肴活动

if  not MODULE_GAMESERVER then
	return;
end

Require("\\script\\event\\specialevent\\zhounianqing2011\\zhounianqing2011_def.lua");

SpecialEvent.ZhouNianQing2011 = SpecialEvent.ZhouNianQing2011 or {};
local ZhouNianQing2011 = SpecialEvent.ZhouNianQing2011;

-- 周年活动，除了换团锦簇和掉落活动，都用这个
function ZhouNianQing2011:CheckTime()
	local nNowTime = tonumber(GetLocalDate("%Y%m%d"));
	if nNowTime < self.nStartTime or nNowTime > self.nEndTime then
		return 0;
	else
		return 1;
	end
end

---------------------------- 佳肴活动处理开始 -----------------------------
local tbDestopNpcPos = {
	-- 1号地图云中镇的桌子位置
	[1] = {[1] = {43584, 99040}, [2] = {43744, 98528}, [3] = {43904, 99392}, [4] = {44416, 99168},[5] = {44160, 98336}, [6] = {44544, 98720},},
	-- 2号地图龙门镇的桌子位置
	[2] = {[1] = {56224, 114208}, [2] = {56704, 113696}, [3] = {56416, 113856}, [4] = {56608, 114688},[5] = {57184, 114144}, [6] = {56960, 114528},},
	-- 3号地图永乐镇的桌子位置
	[3] = {[1] = {50944, 102304}, [2] = {51296, 101920}, [3] = {51680, 101536}, [4] = {51520, 102432},[5] = {52064, 102016}, [6] = {52480, 102432},},
	-- 4号地图稻香村的桌子位置
	[4] = {[1] = {51200, 103488}, [2] = {51232, 104224}, [3] = {51776, 104000}, [4] = {51744, 104672},[5] = {52224, 102208}, [6] = {52640, 102592},},
	-- 5号地图江津村的桌子位置
	[5] = {[1] = {50944, 98944}, [2] = {50912, 99680}, [3] = {51232, 98656}, [4] = {51264, 100096},[5] = {51712, 99808}, [6] = {52000, 99456},},
	-- 6号地图石鼓镇的桌子位置
	[6] = {[1] = {50144,99296}, [2] = {50080,99872}, [3] = {50560,100352}, [4] = {50784,98912},[5] = {51008,100352}, [6] = {51392,99648},},
	-- 7号地图龙泉村的桌子位置
	[7] = {[1] = {48576, 104032}, [2] = {48608, 104736}, [3] = {49120, 103552}, [4] = {49024, 105088},[5] = {49632, 104704}, [6] = {49664, 103808},},
	-- 8号地图巴陵县的桌子位置
	[8] = {[1] = {54176, 107264}, [2] = {54208, 108096}, [3] = {54592, 106720}, [4] = {55104, 107072},[5] = {54912, 108384}, [6] = {55296, 108000},},
};

local DESKTOP_COUNT = 6;			-- 每个村佳肴的数量

-- GC通知刷新出桌子NPC
function ZhouNianQing2011:RefreshJiaYao(nMapId)
	self:ClearDesktop();
	if (not tbDestopNpcPos[nMapId]) then
		return;				-- 内部错误，不应该出现这个情况
	end
	self.nMapId = nMapId;
	if (SubWorldID2Idx(nMapId) >= 0) then			-- 刷出桌子和菜肴
		for i = 1, DESKTOP_COUNT do
			-- 桌子
			local nDesktopX = math.floor(tbDestopNpcPos[nMapId][i][1]/32);
			local nDesktopY = math.floor(tbDestopNpcPos[nMapId][i][2]/32);
			local pDesktopNpc = KNpc.Add2(self.nDesktopTemplateId, 1, -1, nMapId, nDesktopX, nDesktopY);
			if (pDesktopNpc) then
				table.insert(self.tbJiaYaoNpcs, pDesktopNpc.dwId);
			end
			-- 菜，todo 位置需要调整
			local pJiaYaoNpc = KNpc.Add2(self.nJiaYaoTemplateId, 1, -1, nMapId, nDesktopX, nDesktopY+1);
			if (pJiaYaoNpc) then
				table.insert(self.tbJiaYaoNpcs, pJiaYaoNpc.dwId);
			end
		end
	end
end

-- 当一个菜被吃完了，通知一下GS
function ZhouNianQing2011:OnJiaYaoDeath(dwNpcId)
	-- 如果所有的菜都被吃光了，通知GC，准备下一轮菜
	for i, id in pairs(self.tbJiaYaoNpcs) do
		if (id == dwNpcId) then
			self.tbJiaYaoNpcs[i] = nil;
			break;
		end
	end
	if (Lib:CountTB(self.tbJiaYaoNpcs) <= DESKTOP_COUNT) then
		GCExcute({"SpecialEvent.ZhouNianQing2011:AllJiaYaoDeath"});
	end
end

-- 清空所有佳肴和桌子
function ZhouNianQing2011:ClearDesktop()
	if (SubWorldID2Idx(self.nMapId) >= 0) then		-- 如果已经有桌子的地图，把它删除
		for _, dwNpcId in pairs(self.tbJiaYaoNpcs) do
			local pNpc = KNpc.GetById(dwNpcId);
			if (pNpc) then
				pNpc.Delete();
			end
		end
		self.tbJiaYaoNpcs = {};			-- 清空npc
	end
end

-- 关闭当天活动
function ZhouNianQing2011:CloseJiaYao()
	self:ClearDesktop();
end

-- 广告,gc通知
function ZhouNianQing2011:Announce(nState)
	if (nState == 1) then
		KDialog.NewsMsg(1, Env.NEWSMSG_NORMAL, self.tbMsg[nState]);
	else
		KDialog.Msg2SubWorld(self.tbMsg[nState]);
	end
end

-- todo 调试用
function ZhouNianQing2011:GetNearJiaYao()
	local tbNpcList = KNpc.GetAroundNpcList(me, 10);
	for _, pNpc in ipairs(tbNpcList) do
		if (pNpc.nTemplateId == self.nJiaYaoTemplateId) then
			return pNpc;
		end
	end
	return nil;
end

--------------------------- 红娘处理开始 ---------------------------------------------
-- 构建红娘周年庆选项
function ZhouNianQing2011:BuildHongNiangZhouNianQingOption()
	if self:CheckTime() == 0 then
		return nil;
	else
		return {"<color=yellow>【领取周年庆同心礼包】<color>", self.OnGetZhouNianQingGift, self};
	end	
end

-- 获取周年庆礼物
function ZhouNianQing2011:OnGetZhouNianQingGift()
	local bRet, szMsg = self:CheckCanGetGift();
	if (bRet == 0) then
		Dialog:Say(szMsg);
		return;
	end

	-- 给礼物，记录任务变量，礼物是随机宝箱
	me.AddExp(math.floor(me.GetBaseAwardExp() * 120));		-- 2小时经验
	if (not me.AddItemEx(18, 1, 1325, 1, {bForceBind = 1}, Player.emKITEMLOG_TYPE_JOINEVENT)) then
		Dbg:WriteLog("ZhouNianQing2011", "AddItemEx marry failed", me.szName);
	end
	me.SetTask(self.TASKGID, self.TASK_GETGIFT, 1);
	StatLog:WriteStatLog("stat_info", "cele_3year", "join", me.nId, 4);
end

-- 检查是否可以领取奖励
function ZhouNianQing2011:CheckCanGetGift()
	local nFlag = Player:CheckTask(self.TASKGID, self.TASK_GIFT_DATE, "%Y%m%d", self.TASK_GETGIFT, 1);
	if (nFlag == 0) then
		return 0, "你今天已经领过同心礼包了，不要太贪心哦。";
	end

	if (me.nLevel < ZhouNianQing2011.nPlayerLevelLimit or me.nFaction <= 0) then
		return 0, "只有达到60级并且加入门派的玩家才能参加。";
	end
	-- 活动是否开着
	if self:CheckTime() == 0 then
		return 0, "活动没有开启。";
	end
	local tblMemberList, nMemberCount = me.GetTeamMemberList()
	-- 玩家必须处于组队状态，且队伍中只有两个人
	if (nMemberCount ~= 2) then
		return 0, "您必须跟你的心上人一起组队前来领取。";
	end
	
	for i = 1, #tblMemberList do
		local cTeamMate = tblMemberList[i]
		if (cTeamMate.szName ~= me.szName) then
			-- 检查是否已经是指定密友
			if (KPlayer.CheckRelation(me.szName, cTeamMate.szName, Player.emKPLAYERRELATION_TYPE_COUPLE) == 0) then
				return 0, "您必须跟你的心上人一起组队前来领取。";
			elseif (me.nMapId ~= cTeamMate.nMapId) then
				return 0, "您必须跟你的心上人一起组队前来领取。";
			end
		end
	end

	if (me.CountFreeBagCell() < 1) then
		return 0, "请留下至少1个背包空间再领取礼物。";			-- 背包空间不足
	end

	return 1;
end

---------------------------- 修炼珠处理开始 -----------------------------
-- 领取三周年称号
function ZhouNianQing2011:GetPlayerTitle()
	if (me.nLevel < ZhouNianQing2011.nPlayerLevelLimit or me.nFaction <= 0) then
		Dialog:Say("只有达到60级并且加入门派的玩家才能领取。");
		return;
	end
	local nSec = TimeFrame:GetStartServerTime();
	local nYear = tonumber(os.date("%Y", nSec));
	-- 判断玩家是否有这个称号
	if (me.FindTitle(unpack(self.tb3YearTitle)) == 1) then
		Dialog:Say("你已经领取过称号了。");
		return;
	elseif (me.FindTitle(unpack(self.tbHappyTitle)) == 1) then
		Dialog:Say("你已经领取过称号了。");
		return;
	end
	-- 08年的服务器
	if (nYear <= 2008) then
		me.AddTitle(unpack(self.tb3YearTitle));
	else
		me.AddTitle(unpack(self.tbHappyTitle));
	end
	Dialog:Say("恭喜你领取了剑侠世界三周年庆典的尊贵称号。");
end


--------------------------- 祝福树处理开始 ---------------------------------
function ZhouNianQing2011:OpenZhuFuShu()
	if (self.bHasZhuFuShu == 1) then			-- 已经call过祝福树了
		return;
	end
	
	if (SubWorldID2Idx(ZhouNianQing2011.nZhuFuShuMapId) >= 0) then			-- 刷出桌子和菜肴
		self.bHasZhuFuShu = 1;
		self.pZhuFuShuNpc = KNpc.Add2(self.nZhuFuShuTemplateId, 1, -1, ZhouNianQing2011.nZhuFuShuMapId, 1477, 3774);
	end
end

-- 关闭祝福树
function ZhouNianQing2011:CloseZhuFuShu()
	if (not self.pZhuFuShuNpc) then
		return;
	else
		self.pZhuFuShuNpc.Delete();
	end
end


----------------------------- 锦簇花团开始  ---------------------------------
local tbMatGdpl = {18,1,1327,1};			-- 一簇鲜花的材料gdpl
local tbYueYingGdpl = {18,1,476,1};			-- 月影之石gdpl
local tbFlowerGdpl = {18,1,1328,1};			-- 庆典献花的gdpl	
local tbYueYingSpeGdpl = {18,1,1330,1};			-- 月影的替代品
local MAKEFLOWER_CONSUME_MAT = 3;			-- 消耗花簇数量
local MAKEFLOWER_CONSUME_YUEYING = 1;		-- 消耗月影数量


-- 身上是否有指定道具，有的话返回数量
local function HasItemInBags(tbItemGdpl)
	return me.GetItemCountInBags(unpack(tbItemGdpl));
end

function ZhouNianQing2011:HuaTuanCheckTime()
	local nNowTime = tonumber(GetLocalDate("%Y%m%d"));
	if nNowTime < self.nHuaTuanJinCuStartTime or nNowTime > self.nHuaTuanJinCuEndTime then
		return 0;
	end
	
	return 1;
end

-- 检测自己是否可以使用道具
function ZhouNianQing2011:CheckCanMakeFlower()
	if (self:HuaTuanCheckTime() ~= 1) then
		return 0, "不在活动期间，不能使用物品。";
	end
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	if (nNowDate == self.nHuaTuanJinCuEndTime) then
		local nNowTime = tonumber(GetLocalDate("%H%M"));
		if (nNowTime >= self.nFlowerEndTimePerDay) then
			return 0, "不在活动期间，不能使用物品。";
		end
	end

	if (me.nLevel < ZhouNianQing2011.nPlayerLevelLimit or me.nFaction <= 0) then
		return 0, "只有达到60级并且加入门派的玩家才能使用。";
	end
	local nCount = HasItemInBags(tbMatGdpl);
	if (nCount <= 0) then		-- 庆典献花
		return 0, "您没有<color=yellow>美丽花束<color>，无法制作庆典鲜花。请通过参加逍遥谷、宋金战场、白虎堂、军营副本获得。";
	end
	if (nCount < MAKEFLOWER_CONSUME_MAT) then
		return 0, "您没有足够的<color=yellow>美丽花束<color>，需要"..MAKEFLOWER_CONSUME_MAT.."束美丽花束来制作3簇<color=yellow>庆典鲜花<color>。";
	end
	
	nCount = HasItemInBags(tbYueYingSpeGdpl);
	if (nCount < MAKEFLOWER_CONSUME_YUEYING) then		-- 月影之石替代品
		nCount = HasItemInBags(tbYueYingGdpl);
		if (nCount < MAKEFLOWER_CONSUME_YUEYING) then		-- 月影之石
			if TimeFrame:GetState("OpenLevel150") == 1 then
				return 0, "您没有足够的<color=yellow>月影之石<color>，制作3簇庆典鲜花需要"..MAKEFLOWER_CONSUME_YUEYING.."个<color=yellow>月影之石<color>。";
			else
				return 0, "您没有足够的<color=yellow>周年庆绿叶<color>，制作3簇庆典鲜花需要"..MAKEFLOWER_CONSUME_YUEYING.."个<color=yellow>周年庆绿叶<color>。该物品可以在奇珍阁里面购买。";
			end
		end
	end
	
	local nFlag = Player:CheckTask(self.TASKGID, self.TASK_MAKEFLOWER_DATE, "%Y%m%d", self.TASK_MAKEFLOWERCOUNT, self.nMaxMakeFlower);
	if (nFlag == 0) then
		return 0, "每天只能制作<color=yellow>"..self.nMaxMakeFlower.."簇<color>庆典鲜花。";
	end
	-- 地图判断
	if (GetMapType(me.nMapId) ~= "city" and GetMapType(me.nMapId) ~= "village") then
		return 0, "只能在城市和新手村制作鲜花。";
	end
	-- 背包判断
	if (me.CountFreeBagCell() < 3) then
		return 0, "需要<color=yellow>3格<color>背包空间，整理下再来！";
	end

	return 1;
end

function ZhouNianQing2011:MakeFlower(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end
	Setting:SetGlobalObj(pPlayer);
	-- 检测玩家是否能够做花，需要3个道具加上2个月影
	local bRet, szMsg = ZhouNianQing2011:CheckCanMakeFlower();
	if (bRet == 0) then
		Dialog:Say(szMsg);
		Setting:RestoreGlobalObj();
		return 0;
	end
	-- 消耗物品
	local nCount = me.ConsumeItemInBags(MAKEFLOWER_CONSUME_MAT, unpack(tbMatGdpl));
	if (nCount ~= 0) then
		-- 扣除失败，写日志
		Dbg:WriteLog("ZhouNianQing2011", "Consume Material failed", me.szName, nCount);
		Setting:RestoreGlobalObj();
		return 0;
	end
	-- 先扣除月影的替代品，再扣除月影
	nCount = me.ConsumeItemInBags(MAKEFLOWER_CONSUME_YUEYING, unpack(tbYueYingSpeGdpl));
	if (nCount ~= 0) then
		nCount = me.ConsumeItemInBags(MAKEFLOWER_CONSUME_YUEYING, unpack(tbYueYingGdpl));
		if (nCount ~= 0) then
			Dbg:WriteLog("ZhouNianQing2011", "Consume YueYing failed", me.szName, nCount);
			Setting:RestoreGlobalObj();
			return 0;
		end
	end
	-- 增加物品
	local nAddCount = me.AddStackItem(tbFlowerGdpl[1], tbFlowerGdpl[2], tbFlowerGdpl[3], tbFlowerGdpl[4], {bForceBind = 1}, 3);
	if (nAddCount ~= 3) then
		Dbg:WriteLog("ZhouNianQing2011", "MakeFlower failed", me.szName);
		Setting:RestoreGlobalObj();
		return 0;
	end
	StatLog:WriteStatLog("stat_info", "cele_3year", "item_get", me.nId, 1);
	me.SetTask(self.TASKGID, self.TASK_MAKEFLOWERCOUNT, me.GetTask(self.TASKGID, self.TASK_MAKEFLOWERCOUNT) + 3);
	Setting:RestoreGlobalObj();
	return 1;
end

-- 刷新花圃
function ZhouNianQing2011:RefreshWreathNpc()
	if (self.tbWreathNpcs) then -- 已经刷过了
		return 0;
	end
	self.tbWreathNpcs = {}; -- 所有花坛npc列表
	local tbTempFile = Lib:LoadTabFile(self.szWreathFilePath);
	if not tbTempFile or #tbTempFile == 0 then
		Dbg:WriteLog("ZhouNianQing2011", "load wreathpos file failure");
		return 0;
	end
	for i = 1, #tbTempFile do
		local nMapId = tonumber(tbTempFile[i]["MAPID"]);
		local nX = tonumber(tbTempFile[i]["POSX"]) / 32;
		local nY = tonumber(tbTempFile[i]["POSY"]) / 32;
		if (SubWorldID2Idx(nMapId) >= 0) then
			local pNpc = KNpc.Add2(self.nWreathTemplateId, 100, -1, nMapId, nX, nY);
			if (pNpc) then
				table.insert(self.tbWreathNpcs, pNpc);
				-- 初始化下npc的临时表
			else
				Dbg:WriteLog("ZhouNianQing2011", "add wreath failure");
				return 0;
			end
		end
	end
	Timer:Register(self.nYanHuaInterval, self.UpdateYanHua, self);
	return 1;
end

-- 检测小女孩是否该放烟花了
function ZhouNianQing2011:UpdateYanHua()
	if (self.tbWreathNpcs) then
		for _, pGirl in pairs(self.tbWreathNpcs) do
			pGirl.CastSkill(1957, 1, -1, pGirl.nIndex, 1);
		end
		return nil;				-- 继续定时器
	else
		return 0;
	end
end

function ZhouNianQing2011:OpenWreath()
	self:RefreshWreathNpc();
end

-- 活动结束
function ZhouNianQing2011:CloseWreath()
	-- 删除所有献花npc
	if (self.tbFlowerNpcs) then
		for _, tbFlower in pairs(self.tbFlowerNpcs) do
			if (tbFlower.pFlowerNpc) then
				tbFlower.pFlowerNpc.Delete();
			end
		end
		self.tbFlowerNpcs = nil;
	end
	-- 删除所有花坛npc
	if (self.tbWreathNpcs) then
		for _, pNpc in pairs(self.tbWreathNpcs) do
			pNpc.Delete();
		end
		self.tbWreathNpcs = nil;
	end
end

-- 检查是否能够摆放鲜花
function ZhouNianQing2011:CheckCanShowFlower(pPlayer)
	-- 活动期间
	if (self:HuaTuanCheckTime() ~= 1) then
		return 0, "现在不在活动期间，请于7月6日～7月13日早上9点～晚上11点来献花。";
	end 
	local nNowTime = tonumber(GetLocalDate("%H%M"));
	if (nNowTime < self.nFlowerStartTimePerDay or nNowTime >= self.nFlowerEndTimePerDay) then
		return 0, "现在不在活动期间，请于7月6日～7月13日早上9点～晚上11点来献花。";
	end

	if (pPlayer.nLevel < ZhouNianQing2011.nPlayerLevelLimit or pPlayer.nFaction <= 0) then
		return 0, "只有达到60级并且加入门派的玩家才能使用。";
	end
	Setting:SetGlobalObj(pPlayer);
	local nFlag = Player:CheckTask(self.TASKGID, self.TASK_SHOWFLOWER_DATE, "%Y%m%d", self.TASK_SHOWFLOWERCOUNT, self.nMaxShowFlower);
	if (nFlag == 0) then
		Setting:RestoreGlobalObj();
		return 0, "每天只能摆放<color=yellow>"..self.nMaxShowFlower.."次<color>庆典鲜花。";
	end
	Setting:RestoreGlobalObj();

	-- 背包判断
	if (pPlayer.CountFreeBagCell() < 2) then
		return 0, "需要<color=yellow>2格<color>背包空间，整理下再来！";
	end
	
	if (pPlayer.GetItemCountInBags(unpack(tbFlowerGdpl)) < 1) then
		return 0, "你身上没有庆典鲜花。请通过加工<color=yellow>美丽花束<color>获得。";
	end
	
	-- 地图判断
	if (GetMapType(pPlayer.nMapId) ~= "city") then
		return 0, "只能在城市的花童附近摆放鲜花。";
	end
	-- 找到一个合适的位置，添加npc
	local bRet, dwWreathId, nPos = self:CheckWreathNearly(pPlayer);
	if (bRet == -1) then
		return 0, "这里摆满了鲜花，换个地方吧。";
	elseif (bRet == 0) then
		return 0, "请走到放烟花的小女孩附近，在她旁边摆放鲜花。";
	end
	return 1, dwWreathId, nPos;
end

-- 摆放鲜花
function ZhouNianQing2011:ShowFlower(dwPlayerId, dwFlowerId)
	local pPlayer = KPlayer.GetPlayerObjById(dwPlayerId);
	if (not pPlayer) then
		return;
	end

	local bRet, dwWreathId, nPos = self:CheckCanShowFlower(pPlayer);
	if (bRet == 0) then			-- 失败，dwWreathId返回错误描述
		Setting:SetGlobalObj(pPlayer);
		Dialog:Say(dwWreathId);
		Setting:RestoreGlobalObj();
		return;
	end
	
	-- 消耗庆典献花
	local pItem = KItem.GetObjById(dwFlowerId);
	if (not pItem) then
		Dbg:WriteLog("ZhouNianQing2011", "Consume Flower failed", me.szName, dwWreathId, nCount);
		return;
	end
	local bRet = pItem.Delete(pPlayer);
	if (bRet ~= 1) then
		Dbg:WriteLog("ZhouNianQing2011", "Consume Flower failed", me.szName, dwWreathId, nCount);
		return;
	end
	-- 给奖励,三周年感恩鲜花，随机箱子
	if (not me.AddItemEx(18,1,1329,1, {bForceBind = 1}, Player.emKITEMLOG_TYPE_JOINEVENT)) then
		Dbg:WriteLog("ZhouNianQing2011", "AddItemEx Flower failed", me.szName);
	end
	-- 和氏玉产出
	local nRand = MathRandom(1, 1000);
	if (nRand == 1) then			-- 千分之一的概率获得
		me.AddItemEx(22,1,81,1, nil, Player.emKITEMLOG_TYPE_JOINEVENT);
		StatLog:WriteStatLog("stat_info", "cele_3year", "award", me.nId, 5, 1);
		KDialog.NewsMsg(1, Env.NEWSMSG_NORMAL, me.szName.."参加剑侠世界三周年活动，摆放庆典献花后惊喜地获得了和氏玉（不绑定），真是可喜可贺啊！");
	end
	StatLog:WriteStatLog("stat_info", "cele_3year", "join", me.nId, 3);
	pPlayer.SetTask(self.TASKGID, self.TASK_SHOWFLOWERCOUNT, pPlayer.GetTask(self.TASKGID, self.TASK_SHOWFLOWERCOUNT) + 1);
	
	-- 添加一个鲜花npc
	local pWreathNpc = KNpc.GetById(dwWreathId);			-- 找到花坛npc，计算偏移
	if (not pWreathNpc) then
		return;
	end
	-- 计算该位置在3×3矩阵里面的坐标
	local tbMapPos = {1, 3, 7, 9};	-- 鲜花位置对应的映射表
	local nRealPos = tbMapPos[nPos];
	if (not nRealPos) then		-- 有异常了
		Dbg:WriteLog("ZhouNianQing2011", "calc flower position error", me.szName, nPos);
		return;
	end
	local nX = ((nRealPos - 1) % 3) + 1;
	local nY = math.floor((nRealPos - 1) / 3) + 1;
	-- 中心点是2，2(3*3的格子)
	local nOffset = 2;			-- 每个格子的偏移量
	local _, nPosX, nPosY = pWreathNpc.GetWorldPos();
	nPosX = nPosX + (nX - 2) * nOffset;
	nPosY = nPosY + (nY - 2) * nOffset;
	local nTotal = #self.tbFlowerTemplateId;			-- 随机一下鲜花
	local nNpcIdx = MathRandom(1, nTotal);
	local pFlowerNpc = KNpc.Add2(self.tbFlowerTemplateId[nNpcIdx], 1, -1, me.nMapId, nPosX, nPosY);
	if (not pFlowerNpc) then
		Dbg:WriteLog("ZhouNianQing2011", "AddFlower  failed", me.szName, nNpcIdx, me.nMapId, nPosX, nPosY);
		return;
	end
	-- 给花圃npc修改下临时表
	if (self:RecordFlowerInfo(dwWreathId, nPos, pFlowerNpc) == 0) then
		Dbg:WriteLog("ZhouNianQing2011", "RecordFlower  failed", me.szName, dwWreathId, nPos);
	end
	-- 记录所有的鲜花npc，注册定时器
	if (not self.tbFlowerNpcs) then
		self.tbFlowerNpcs = {};
		Timer:Register(self.nCheckFlowerTime, self.UpdateFlower, self);
	end
	table.insert(self.tbFlowerNpcs, {nCreateTime = GetTime(), pFlowerNpc = pFlowerNpc});
end

-- 检测献花是否应该消失
function ZhouNianQing2011:UpdateFlower()
	if (not self.tbFlowerNpcs) then
		return 0;
	end
	-- 由于已经是按照生成时间排序，所以可以不用完全遍历
	local nNowTime = GetTime();
	for i, v in pairs(self.tbFlowerNpcs) do
		if (nNowTime - v.nCreateTime >= self.nFlowerLiveTime) then		-- 过期了，删除鲜花
			if (v.pFlowerNpc) then
				self:RemoveFlowerInfo(v.pFlowerNpc);			-- 移除花坛信息
				v.pFlowerNpc.Delete();							-- 删除献花
			end
			self.tbFlowerNpcs[i] = nil;
		else
			break;
		end
	end
	if (Lib:IsEmptyTB(self.tbFlowerNpcs) == 0) then
		return nil;		-- 继续定时器
	else
		self.tbFlowerNpcs = nil;
		return 0;		-- 结束定时器
	end
end

-- 检查周围是否有花坛
function ZhouNianQing2011:CheckWreathNearly(pPlayer)
	local bHasNpc = 0;
	local tbNpcList = KNpc.GetAroundNpcList(pPlayer, self.nMaxWreathRound);
	for _, pNpc in ipairs(tbNpcList) do
		if (pNpc.nTemplateId == self.nWreathTemplateId) then
			local bRet, nPos = self:CheckWreath(pNpc.dwId);
			if (bRet == 1) then
				return 1, pNpc.dwId, nPos;
			end
			bHasNpc = 1;
		end
	end
	if (bHasNpc == 1) then
		return -1;
	else
		return 0;
	end
end

-- 检测这个npc是否可以摆放鲜花,如果可以，返回1和可以摆放的位置
function ZhouNianQing2011:CheckWreath(dwNpcId)
	local pNpc = KNpc.GetById(dwNpcId);
	if (not pNpc) then
		return 0;
	end
	local tbFlower = pNpc.GetTempTable("SpecialEvent");
	if (not tbFlower) then			-- 还没鲜花呢
		tbFlower = {};
		return 1, 1;
	end
	for i = 1, self.nMaxFlowerCountPerWreath do
		if (not tbFlower[i]) then
			return 1, i;
		end
	end
	return 0;
end

-- 记录献花的归属信息
function ZhouNianQing2011:RecordFlowerInfo(dwWreathId, nPos, pFlowerNpc)
	if (not dwWreathId or not nPos or not pFlowerNpc) then
		return 0;
	end
	local pNpc = KNpc.GetById(dwWreathId);
	if (not pNpc) then
		return 0;
	end
	local tbUseInfo = pNpc.GetTempTable("SpecialEvent");
	Lib:ShowTB(tbUseInfo);
	if (not tbUseInfo) then
		return 0;
	else
		tbUseInfo[nPos] = 1;			-- 标记被占用了
	end
	local tbInfo = pFlowerNpc.GetTempTable("SpecialEvent");
	if (not tbInfo) then
		return 0;
	end
	tbInfo.dwWreathId = dwWreathId;
	tbInfo.nPos = nPos;
	return 1;
end

-- 移除献花相关的记录信息
function ZhouNianQing2011:RemoveFlowerInfo(pFlowerNpc)
	if (not pFlowerNpc) then
		return 0;
	end
	local tbInfo = pFlowerNpc.GetTempTable("SpecialEvent");
	if (not tbInfo) then
		return 0;
	end
	
	local pNpc = KNpc.GetById(tbInfo.dwWreathId);
	if (not pNpc) then
		return 0;
	end
	local tbUseInfo = pNpc.GetTempTable("SpecialEvent");
	if (not tbUseInfo) then
		return 0;
	else
		tbUseInfo[tbInfo.nPos] = nil;			-- 标记没被占用
	end	
	return 1;
end

-------------------------------------- 杂项 --------------------------------
function ZhouNianQing2011:OnServerStart()
	-- 服务器启动，需要开启的活动
	self.tbJiaYaoNpcs = self.tbJiaYaoNpcs or {};		-- 用来存放菜和桌子
	-- 祝福树的NPC调出来
	if (self:CheckTime() == 1) then
		self:OpenZhuFuShu();
	end
	-- 花圃npc调出来
	if (self:HuaTuanCheckTime() == 1) then
		self:OpenWreath();
	end
end

-- 启动服务器后需要做些事情
ServerEvent:RegisterServerStartFunc(ZhouNianQing2011.OnServerStart, ZhouNianQing2011);

