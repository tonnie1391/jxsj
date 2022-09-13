-----------------------------------------------------
--文件名		：	battle_trap.lua
--创建者		：	FanZai, zhouchenfei
--创建时间		：	2007-10-23
--功能描述		：	trap点脚本
------------------------------------------------------
-- 本结构在设计时有很多尝试性的写法，可能并不符合规范。
-- 如果会对您的优良代码风格产生误导，请当作没看见……

Require("\\script\\mission\\battle\\camp.lua");

-- 宋金战场用地图基类
local tbMapBase	= Battle.tbMapBase or Lib:NewClass(Map.tbMapBase);	-- 基于公用地图基类

tbMapBase.tbTrapNameMap	= {	-- Trap点 => 功能 映射
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
	--	-_-#
end

-- Trap点事件定义在Camp上
local tbCampBase	= Battle.tbCampBase;

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
	local tbBattleInfo	= Battle:GetPlayerData(pPlayer);
	local nBackTime		= tbBattleInfo.nBackTime;
	local nRemainTime	= Battle.TIME_DEATHWAIT - (GetTime() - nBackTime);
	if (nRemainTime > 0) then
		Dialog:Say(string.format("Thời gian trong doanh trại còn %d giây, chuẩn bị thật kỹ lưỡng, ra trận giết địch.", nRemainTime));
		return;
	end
	self:TransTo(tbBattleInfo.pPlayer, szPosName);
	tbBattleInfo.pPlayer.SetFightState(1);
end

-- 大营/前营 到 后营
function tbCampBase:OnTrap_OuterToBase(pPlayer)
	local tbBattleInfo	= Battle:GetPlayerData(pPlayer);
	if (tbBattleInfo.tbCamp.nCampId ~= self.nCampId) then
		tbBattleInfo.pPlayer.Msg("Phía trước thương kích rất nhiều, được bảo vệ nghiêm ngặt, chắc hẳn là có trọng binh canh gác, ngươi không nên xông vào!");
		return;
	end
	tbBattleInfo.nBackTime	= GetTime()
	self:TransTo(tbBattleInfo.pPlayer, "BaseCamp");
	tbBattleInfo.pPlayer.SetFightState(0);
	if (3 == self.tbMission.tbRule.nRuleType) then
		self.tbMission.tbRule:DeletePlayerFlag(pPlayer);
	elseif (5 == self.tbMission.tbRule.nRuleType) then
		self.tbMission.tbRule:DelPlayerNpc(pPlayer);
	end
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
		Dialog:Say("Đang trong thời gian khai chiến, binh sĩ không được tự ý rời khỏi đại doanh, chờ đến lúc cuộc chiến chính thức bắt đầu hãy ra quân giết địch!");
		self:TransTo(pPlayer, szPosName);
		return;
	end
end

Battle.tbMapBase	= tbMapBase;
