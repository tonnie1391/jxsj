--额外奖励通用函数GS,Client
--孙多良 2008.07.24
--*_Check可单独出现..
--DoExecute必须和*_Check成对出现.
--接口：local nFreeCount, tbFunExecute = SpecialEvent.ExtendAward:DoCheck("szType") 
--接口：SpecialEvent.ExtendAward:DoExecute(tbFunExecute);

SpecialEvent.ExtendAward = SpecialEvent.ExtendAward or {};
local ExtendAward = SpecialEvent.ExtendAward;

--已有接口
ExtendAward.tbInterFaceFun = 
{
	["Battle"]			= "Battle_Check",		--战场奖励
	["FactionBattle"]	= "FactionBattle_Check",--门派竞技
	["GuessGame"]		= "GuessGame_Check",	--猜灯谜
	["LinkTask"]		= "LinkTask_Check",		--包万同
	["KinGame"]			= "KinGame_Check",		--家族关卡
	["LifeSkill"]		= "LifeSkill_Check",	--生活技能配方
	["WantedBoss"]		= "WantedBoss_Check",	--官府通缉boss掉落
	["FinishWanted"]	= "FinishWanted_Check",	--完成官府通缉任务(交任务时)
	["KinQizi"]			= "KinQizi_Check",		--家族烤棋子	--houxuan: 08.11.10
	["EnhanceEquip"]	= "EnhanceEquip_Check",	--装备强化费用  --houxuan: 08.11.10
	["MerchantTask"]	= "MerchantTask_Check",	--完成一轮商会任务；
	["ArmyCampTask"]	= "ArmyCampTask_Check",	--完成一次军营剧情任务
	["BaiHuTang"]		= "BaiHuTang_Check",	--白虎堂通过第几层
	["BaiHuTangBoss"]	= "BaiHuTangBoss_Check",--白虎堂Boss死亡时,杀死boss的玩家和队伍成员触发
	["XoyoGame"]		= "XoyoGame_Check",		--逍遥谷通关
	["Wlls"]			= "Wlls_Check",			--武林联赛单场胜利领奖
	["JYAndSLDeath"]	= "JYAndSLDeath_Check", --精英和首领死亡时
	["PickGouhuoTeam"]	= "PickGouhuoTeam_Check",
	["ArmyCampBoss"]	= "ArmyCampBoss_Check",	--击杀军营最终boss
	["QinlingBoss"]		= "QinlingBoss_Check",	--击杀秦陵各种boss
	["DomainbattleTask"] = "DomainbattleTask_Check", --领土争夺
	["BattleFirst"]			= "BattleFirst_Check",		--战场名次奖励
	["EverQuest"] = "EverQuest_Check",	--无尽的征程
	["SuperBattle"] = "SuperBattle_Check",	--跨服宋金领奖
	["KinPlantGetFruit"] = "KinPlantGetFruit_Check",	--家族种树收获果实
	["TreasureMapComplete"] = "TreasureMapComplete_Check",	--藏宝图通关
	["WeeklyFish"] = "WeeklyFish_Check",	--钓鱼交任务
	["XiaKeDaily"] = "XiaKeDaily_Check",	--侠客交任务
	["XoyoGameFinish"]		= "XoyoGameFinish_Check",		--逍遥谷通关
}

ExtendAward.tbFunExecute 		= ExtendAward.tbFunExecute or {};
ExtendAward.tbFreeCount 		= ExtendAward.tbFreeCount or {};
ExtendAward.tbFreeCountScript	= ExtendAward.tbFreeCountScript or {};

function ExtendAward:Init()
	self.tbInit = self.tbInit or {};
	for szType, szFun in pairs(self.tbInterFaceFun) do
		self.tbInit[szFun] = {};
	end
end
ExtendAward:Init();

function ExtendAward:GetInitTable(szFun)
	return self.tbInit[szFun] or {};
end

ExtendAward:GetInitTable("KinQizi_Check").nBaseExp = 1;

--tbExe: {回调函数, arg1, arg2 ...}
--执行时，还会把对应check收到的参数放到tbExe后再执行
--例如 tbExe = {fun, a, b}, 对应check为 function fun_check(c,d)
--最终fun会按顺序收到 a,b,c,d四个参数
function ExtendAward:RegExecute(nId, nPId, szType, tbExe, nNeedFree, tbExeCheckFree)
	self.tbFunExecute[szType] = self.tbFunExecute[szType] or {};
	self.tbFreeCount[szType] = self.tbFreeCount[szType] or {};
	self.tbFreeCountScript[szType] = self.tbFreeCountScript[szType] or {};
	local nRegId = nId*1000+nPId;
	self.tbFunExecute[szType][nRegId] = tbExe;
	self.tbFreeCount[szType][nRegId]  = tonumber(nNeedFree) or 0;
	self.tbFreeCountScript[szType][nRegId] = tbExeCheckFree;
end

function ExtendAward:UnRegExecute(nId, nPId, szType, tbExe, nNeedFree, tbExeCheckFree)
	if self.tbFunExecute[szType] then
		local nRegId = nId*1000+nPId;
		self.tbFunExecute[szType][nRegId] = nil;
		self.tbFreeCount[szType][nRegId]  = nil;
		self.tbFreeCountScript[szType][nRegId] = nil;
	end
end

function ExtendAward:DoCheck(szType, ...)
	if not self.tbInterFaceFun[szType] then
		return 0;
	end
	
	if self[self.tbInterFaceFun[szType]] then
		local nFreeCount, tbFunExecute, szExtendInfo, tbProductSet = self[self.tbInterFaceFun[szType]](self, unpack(arg))
		if self.tbFunExecute[szType] then
			local tbFun = {};
			for nRegId, tbExe in pairs(self.tbFunExecute[szType]) do
				
				local tbTempExe = {}
				for _, v in ipairs(tbExe) do
					table.insert(tbTempExe, v);
				end
				for _, v in ipairs(arg) do
					table.insert(tbTempExe, v);
				end
				table.insert(tbFun, tbTempExe);
			end
			
			for _, tbExe in pairs(self:RegistrationExecute(tbFun)) do
				table.insert(tbFunExecute, tbExe);
			end
		end
		
		--宠物系统
		tbFunExecute = tbFunExecute or {};
		table.insert(tbFunExecute, {["fun"] = Npc.tbFollowPartner.AddAward, ["tbParam"] = {Npc.tbFollowPartner, arg[1] or me, szType}});
		
		if self.tbFreeCountScript[szType] then
			for nRegId, tbExe in pairs(self.tbFreeCountScript[szType]) do
				local tbTempExe = {}
				for _, v in ipairs(tbExe) do
					table.insert(tbTempExe, v);
				end
				for _, v in ipairs(arg) do
					table.insert(tbTempExe, v);
				end
				nFreeCount = nFreeCount + tbTempExe[1](unpack(tbTempExe,2))
			end
		end
		if self.tbFreeCount[szType] then
			for nRegId, nTmpFreeCount in pairs(self.tbFreeCount[szType]) do
				nFreeCount = nFreeCount + (tonumber(nTmpFreeCount) or 0)
			end
		end
		return nFreeCount, tbFunExecute, szExtendInfo, tbProductSet;
	end
	return 0;
end

function ExtendAward:DoExecute(tbExecute)
	Lib:CallBack({self.DoExecuteBase, self, tbExecute});
end

function ExtendAward:DoExecuteBase(tbExecute)
	if not tbExecute then
		return 0; 
	end
	for _, tbfun in ipairs(tbExecute) do
		tbfun.fun(unpack(tbfun.tbParam));
	end
end

function ExtendAward:RegistrationExecute(tbExecute)
	local tbFunExecute = {};
	for _, tbFunParam in ipairs(tbExecute) do
		if tbFunParam[1] then
			local tbTemp = {fun=tbFunParam[1], tbParam={}}
			for nId, param in ipairs(tbFunParam) do
				if nId ~= 1 then
					table.insert(tbTemp.tbParam, param);
				end
			end
			table.insert(tbFunExecute, tbTemp);
		end
	end
	return tbFunExecute;
end

--公用函数,获得物品
function ExtendAward:AddItems(pPlayer, nGenre, nDetail, nParticular, nLevel, nSeries, nCount, nEnhTimes, nLucky, tbGenInfo, nVersion, uRandSeed, nWay)
	nCount = nCount or 1;
	for i=1, nCount do
		pPlayer.AddItem(nGenre, nDetail, nParticular, nLevel, nSeries, nCount, nEnhTimes, nLucky, tbGenInfo, nVersion, uRandSeed, nWay)
	end
	return nCount;
end	


--宋金额外奖励 nPoint=宋金积分,nLevel战场等级，1初级，2中级，3高级
function ExtendAward:Battle_Check(pPlayer, nPoint, nLevel)
	local tbExecute = {};
	local nFreeCount = 0;
	local szExtendInfo = "";
	--额外函数插入
	
	--额外函数插入
	local tbFunExecute = self:RegistrationExecute(tbExecute)
	return nFreeCount, tbFunExecute, szExtendInfo;
end


--门派竞技额外奖励 nPoint=积分, nRank=名次, nTrunk=箱子数量
function ExtendAward:FactionBattle_Check(pPlayer, nPoint, nRank, nTrunk)
	local tbExecute = {};
	local nFreeCount = 0;
	local szExtendInfo = "";
	--额外函数插入

	--门派竞技找旗子2400分以上奖励2个福袋。
	if nPoint >= 2400 then
		table.insert(tbExecute, {self.AddItems, self, pPlayer, 18, 1, 80, 1, 0, 2 * FactionBattle.AWARD_TIMES});
		nFreeCount = nFreeCount + 2 * FactionBattle.AWARD_TIMES;
	end
	
	--额外函数插入
	local tbFunExecute = self:RegistrationExecute(tbExecute)
	return nFreeCount, tbFunExecute, szExtendInfo;
end

--猜灯谜额外奖励 nPoint=积分
function ExtendAward:GuessGame_Check(pPlayer, nPoint)
	local tbExecute = {};
	local nFreeCount = 0;
	--额外函数插入
	
	--额外函数插入
	local tbFunExecute = self:RegistrationExecute(tbExecute)
	return nFreeCount, tbFunExecute;
end


--包万同额外奖励 nTaskNum=完成次数
function ExtendAward:LinkTask_Check(pPlayer, nTaskNum)
	local tbExecute = {};
	local nFreeCount = 0;
	--额外函数插入
	
	--额外函数插入
	local tbFunExecute = self:RegistrationExecute(tbExecute)
	return nFreeCount, tbFunExecute;
end

--家族关卡额外奖励 nCoinNum=钱袋金钱的数量,关卡每兑换一个箱子，nCoinNum固定传入100, nType(1,初级家族关卡，2高级家族关卡)
function ExtendAward:KinGame_Check(pPlayer, nCoinNum, nType)
	local tbExecute = {};
	local nFreeCount = 0;
	--额外函数插入

	--家族关卡,每换一个箱子，给一个福袋
	table.insert(tbExecute, {self.AddItems, self, pPlayer, 18, 1, 80, 1, 0, 1});
	nFreeCount = nFreeCount + 1;
	
	--额外函数插入
	local tbFunExecute = self:RegistrationExecute(tbExecute)
	return nFreeCount, tbFunExecute;
end

--生活技能配方更改,nRecipeId=配方Id
function ExtendAward:LifeSkill_Check(pPlayer, nRecipeId)
	local tbExecute = {};
	local nCanProduct = 0;
	local szExtendInfo = "";
	local tbProductSet = {};
	--额外函数插入
	if nRecipeId == SpecialEvent.ZhongQiu2008.RECIPEID_MOONCAKE then
		nCanProduct = -1;
		szExtendInfo = "<color=yellow>活动已经结束，该配方已失效。<color>";
		if SpecialEvent.ZhongQiu2008:CheckTime() == 1 then
			nCanProduct = 1;
			if pPlayer then
				tbProductSet, szExtendInfo = SpecialEvent.ZhongQiu2008:GetProductSet(pPlayer);
			end
		end
	end
	
	--额外函数插入
	local tbFunExecute = self:RegistrationExecute(tbExecute)
	return nCanProduct, tbFunExecute, szExtendInfo, tbProductSet;	
end


--官府通缉掉落
function ExtendAward:WantedBoss_Check(pPlayer)
	local tbExecute = {};
	local nFreeCount = 0;
	local szExtendInfo = "";
	local tbProductSet = {};
	
	--额外函数插入
	local tbFunExecute = self:RegistrationExecute(tbExecute)
	return nFreeCount, tbFunExecute, szExtendInfo, tbProductSet;	
end

function ExtendAward:FinishWanted_Check(pPlayer)
	local tbExecute = {};
	local nFreeCount = 0;
	local szExtendInfo = "";
	local tbProductSet = {};
	
	--额外函数插入
	local tbFunExecute = self:RegistrationExecute(tbExecute)
	return nFreeCount, tbFunExecute, szExtendInfo;	
end

--装备强化费用
function ExtendAward:EnhanceEquip_Check(pPlayer)
	local tbExecute = {};
	local nFreeCount = 0;
	local nExpMultipe  = 1;
	local nFlag1 = pPlayer.GetSkillState(881);	--公测活动技能
	local nFlag2 = pPlayer.GetSkillState(892);  --金山20周年活动技能ID
	
	if (nFlag1 == 1) then
		nExpMultipe = nExpMultipe * 0.8;
	elseif (nFlag2 == 1) then
		nExpMultipe = nExpMultipe * 0.8;
	end;
	
	--额外函数插入
	local tbFunExecute = self:RegistrationExecute(tbExecute)
	return nFreeCount, tbFunExecute, nExpMultipe;
end;

--家族令牌（烤旗子经验）
function ExtendAward:KinQizi_Check(pPlayer)
	local tbExecute = {};
	local nFreeCount = 0;
	local nBaseExp = 1;
	nBaseExp = nBaseExp * (self:GetInitTable("KinQizi_Check").nBaseExp or 1);
	
	--额外函数插入
	local tbFunExecute = self:RegistrationExecute(tbExecute)
	return nFreeCount, tbFunExecute, nBaseExp;
end;

--完成一轮商会任务(无法判断背包空间，Check完直接执行)
function ExtendAward:MerchantTask_Check(pPlayer)
	local tbExecute = {};
	local nFreeCount = 0;
	--额外函数插入
	
	local tbFunExecute = self:RegistrationExecute(tbExecute)
	return nFreeCount, tbFunExecute;	
end

--完成一次军营剧情任务（1剧情任务，2日常任务）
function ExtendAward:ArmyCampTask_Check(pPlayer, nType)
	local tbExecute = {};
	local nFreeCount = 0;
	--额外函数插入	

	local tbFunExecute = self:RegistrationExecute(tbExecute)
	return nFreeCount, tbFunExecute;		
end

--通过白虎堂第几层(nLevel:1:初级,2高级; nFloor层数)
function ExtendAward:BaiHuTang_Check(pPlayer, nLevel, nFloor)
	local tbExecute = {};
	local nFreeCount = 0;
	--额外函数插入
	
	local tbFunExecute = self:RegistrationExecute(tbExecute)
	return nFreeCount, tbFunExecute;	
end

--白虎堂Boss死亡时(nLevel:1:初级,2高级; nFloor层数)
function ExtendAward:BaiHuTangBoss_Check(pPlayer, nLevel, nFloor)
	local tbExecute = {};
	local nFreeCount = 0;
	--额外函数插入
	
	local tbFunExecute = self:RegistrationExecute(tbExecute)
	return nFreeCount, tbFunExecute;	
end

--逍遥谷通关(nFloor层数)
function ExtendAward:XoyoGame_Check(pPlayer, nFloor, nDiff, nWinCount, nCount)
	local tbExecute = {};
	local nFreeCount = 0;
	--额外函数插入	
	
	local tbFunExecute = self:RegistrationExecute(tbExecute)
	return nFreeCount, tbFunExecute;	
end

--武林联赛单场奖励
function ExtendAward:Wlls_Check(pPlayer)
	local tbExecute = {};
	local nFreeCount = 0;
	
	local tbFunExecute = self:RegistrationExecute(tbExecute)
	return nFreeCount, tbFunExecute;	
end

function ExtendAward:JYAndSLDeath_Check(pPlayer)
	local tbExecute = {};
	local nFreeCount = 0;
	--额外函数插入	
	
	local tbFunExecute = self:RegistrationExecute(tbExecute)
	return nFreeCount, tbFunExecute;		
end

function ExtendAward:PickGouhuoTeam_Check(pPlayer)
	local tbExecute = {};
	local nFreeCount = 0;
	--额外函数插入	
	
	local tbFunExecute = self:RegistrationExecute(tbExecute)
	return nFreeCount, tbFunExecute;	
end

-- 击杀军营最终boss
function ExtendAward:ArmyCampBoss_Check(pPlayer)
	local tbExecute = {};
	local nFreeCount = 0;
	-- extra
	
	-- end
	local tbFunExecute = self:RegistrationExecute(tbExecute)
	return nFreeCount, tbFunExecute;	
end

-- 击杀各种秦陵boss
function ExtendAward:QinlingBoss_Check(pPlayer)
	local tbExecute = {};
	local nFreeCount = 0;
	-- extra
	
	-- end
	local tbFunExecute = self:RegistrationExecute(tbExecute)
	return nFreeCount, tbFunExecute;		
end

--领土争夺
function ExtendAward:DomainbattleTask_Check(pPlayer, nScore, nBoxAward)
	local tbExecute = {};
	local nFreeCount = 0;
	-- extra
	
	-- end
	local tbFunExecute = self:RegistrationExecute(tbExecute)
	return nFreeCount, tbFunExecute;	
end

--战场名次奖励
function ExtendAward:BattleFirst_Check(pPlayer, nGrade)
local tbExecute = {};
	local nFreeCount = 0;
	-- extra
	
	-- end
	local tbFunExecute = self:RegistrationExecute(tbExecute)
	return nFreeCount, tbFunExecute;	
end

--无尽的征程
function ExtendAward:EverQuest_Check(pPlayer)
local tbExecute = {};
	local nFreeCount = 0;
	-- extra
	
	-- end
	local tbFunExecute = self:RegistrationExecute(tbExecute)
	return nFreeCount, tbFunExecute;	
end

--跨服宋金领奖
function ExtendAward:SuperBattle_Check(pPlayer, nPoint)
local tbExecute = {};
	local nFreeCount = 0;
	-- extra
	
	-- end
	local tbFunExecute = self:RegistrationExecute(tbExecute)
	return nFreeCount, tbFunExecute;	
end

--家园种植收获
function ExtendAward:KinPlantGetFruit_Check(pPlayer,nSeedIndex, nNum)
local tbExecute = {};
	local nFreeCount = 0;
	-- extra
	
	-- end
	local tbFunExecute = self:RegistrationExecute(tbExecute)
	return nFreeCount, tbFunExecute;	
end

--藏宝图通关
function ExtendAward:TreasureMapComplete_Check(pPlayer,nTreasureId,nTreasureLevel)
local tbExecute = {};
	local nFreeCount = 0;
	-- extra
	
	-- end
	local tbFunExecute = self:RegistrationExecute(tbExecute)
	return nFreeCount, tbFunExecute;	
end

--周末钓鱼交任务
function ExtendAward:WeeklyFish_Check(pPlayer)
local tbExecute = {};
	local nFreeCount = 0;
	-- extra
	
	-- end
	local tbFunExecute = self:RegistrationExecute(tbExecute)
	return nFreeCount, tbFunExecute;	
end

--侠客交任务
function ExtendAward:XiaKeDaily_Check(pPlayer, nIndex)
local tbExecute = {};
	local nFreeCount = 0;
	-- extra
	
	-- end
	local tbFunExecute = self:RegistrationExecute(tbExecute)
	return nFreeCount, tbFunExecute;	
end

--逍遥谷通关(nFloor层数)
function ExtendAward:XoyoGameFinish_Check(pPlayer, nFloor, nDiff, nWinCount)
	local tbExecute = {};
	local nFreeCount = 0;
	--额外函数插入
	
	local tbFunExecute = self:RegistrationExecute(tbExecute)
	return nFreeCount, tbFunExecute;	
end
