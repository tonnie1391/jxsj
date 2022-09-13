
Require("\\script\\player\\xisuidao\\xisuidao.lua");

local tbXiMS= Xisuidao.tbMission or Mission:New();

Xisuidao.tbMission = tbXiMS;

function tbXiMS:Init()
	-- 设定Mission可选配置项
	self.tbMisCfg	= {
		tbDeathRevPos	= Xisuidao.tbDeathRevPos ,			-- 死亡重生点
		nDeathPunish	= 1,								-- 无死亡惩罚
		nFightState		= 1,
	};
end

function tbXiMS:OnOpen()
end

-- 在Mission被关闭“前”被调用
function tbXiMS:OnClose()

end;

-- 当玩家加入Mission“后”被调用
function tbXiMS:OnJoin(nGroupId)

end;

-- 当玩家离开Mission“前”被调用
function tbXiMS:BeforeLeave(nGroupId, szReason)

end

-- 当玩家离开Mission“后”被调用
function tbXiMS:OnLeave(nGroupId, szReason)

end

function tbXiMS:OpenXisuidao()
end

tbXiMS:Init();
Xisuidao.tbMission:Open();
