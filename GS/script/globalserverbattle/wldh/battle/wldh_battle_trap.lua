-------------------------------------------------------
-- 文件名　：wldh_battle_trap.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-08-21 15:14:24
-- 文件描述：
-------------------------------------------------------

Require("\\script\\globalserverbattle\\wldh\\battle\\wldh_battle_camp.lua");

-- 宋金战场用地图基类
local tbMapBase	= Wldh.Battle.tbMapBase or Lib:NewClass(Map.tbMapBase);	-- 基于公用地图基类
Wldh.Battle.tbMapBase = tbMapBase;

-- Trap点 => 功能 映射
tbMapBase.tbTrapNameMap	= 
{	
	["houying%d_daying%d"]		= "BaseToOuter1",
	["houying%d_qianying%d"]	= "BaseToOuter2",
	["houying%d_daying%d_1"]	= "BaseToOuter3",
	["houying%d_daying%d_2"]	= "BaseToOuter4",
	["daying%d_houying%d"]		= "OuterToBase",
	["qianying%d_houying%d"]	= "OuterToBase",
	["daying%d_yewai"]			= "OuterToField1",
	["qianying%d_yewai"]		= "OuterToField2",
};

-- 初始化
function tbMapBase:init(tbCamp)
	
	local tbOnTrapCall	= {};	
	for nIndex, tbCamp in pairs(tbCamp) do
		
		for szFmtName, szFun in pairs(self.tbTrapNameMap) do
			local szTrapName	= string.format(szFmtName, nIndex, nIndex);
			local szFunName		= "OnTrap_"..szFun;
			tbOnTrapCall[szTrapName]	= function ()	-- 这里生成一个closures（闭包函数）
				tbCamp[szFunName](tbCamp, me);
			end
		end
	end
	self.tbOnTrapCall	= tbOnTrapCall;
end

-- 触发本地图任何Trap点
function tbMapBase:OnPlayerTrap(szClassName)
	self.tbOnTrapCall[szClassName]();
end

function tbMapBase:OnPlayerNpc(szClassName)
	--
end

-- Trap点事件定义在Camp上
local tbCampBase = Wldh.Battle.tbCampBase;

-- 后营 到 大营/前营
function tbCampBase:OnTrap_BaseToOuter1(pPlayer)
	self:_BaseToOuter(pPlayer, "OuterCamp1");
end
function tbCampBase:OnTrap_BaseToOuter2(pPlayer)
	self:_BaseToOuter(pPlayer, "OuterCamp2");
end
function tbCampBase:OnTrap_BaseToOuter3(pPlayer)
	self:_BaseToOuter(pPlayer, "OuterCamp3");
end
function tbCampBase:OnTrap_BaseToOuter4(pPlayer)
	self:_BaseToOuter(pPlayer, "OuterCamp4");
end

function tbCampBase:_BaseToOuter(pPlayer, szPosName)
	
	local tbBattleInfo	= Wldh.Battle:GetPlayerData(pPlayer);
	local nBackTime		= tbBattleInfo.nBackTime;
	local nRemainTime	= Wldh.Battle.TIME_DEATHWAIT - (GetTime() - nBackTime);
	
	if (nRemainTime > 0) then
		Dialog:Say(string.format("请在后营休整%d秒，准备充分后，再去杀敌。", nRemainTime));
		return;
	end
	
	self:TransTo(tbBattleInfo.pPlayer, szPosName);
	tbBattleInfo.pPlayer.SetFightState(1);
end

-- 大营/前营 到 后营
function tbCampBase:OnTrap_OuterToBase(pPlayer)
	
	local tbBattleInfo	= Wldh.Battle:GetPlayerData(pPlayer);
	
	if (tbBattleInfo.tbCamp.nCampId ~= self.nCampId) then
		tbBattleInfo.pPlayer.Msg("前面枪戟林列，戒备森严，想来是有重兵屯守，你还是不要硬闯为妙！");
		return;
	end
	
	tbBattleInfo.nBackTime	= GetTime()
	self:TransTo(tbBattleInfo.pPlayer, "BaseCamp");
	tbBattleInfo.pPlayer.SetFightState(0);
end

-- 大营/前营 到 野外 （没有障碍）
function tbCampBase:OnTrap_OuterToField1(pPlayer)
	self:_OuterToField(pPlayer, "OuterCamp1");
end
function tbCampBase:OnTrap_OuterToField2(pPlayer)
	self:_OuterToField(pPlayer, "OuterCamp2");
end

function tbCampBase:_OuterToField(pPlayer, szPosName)
	local nState = self.tbMission.nState;
	if (2 ~= nState) then
		Dialog:Say("Trước khi trận chiến bắt đầu, không thể rời khỏi Đại Doanh.");
		self:TransTo(pPlayer, szPosName);
		return;
	end
end

