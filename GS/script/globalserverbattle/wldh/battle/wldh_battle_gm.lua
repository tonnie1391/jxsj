-------------------------------------------------------
-- 文件名　：wldh_battle_gm.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-08-25 09:59:03
-- 文件描述：
-------------------------------------------------------

function Wldh.Battle:GM()
	
	local tbOpt	= {};
	
	local tbMission	= nil;
	for i = 1, 6 do
		tbMission	= self:GetMission(i);
		if tbMission then
			break;
		end
	end
		
	if tbMission then
		if tbMission.nState == 1 then
			tbOpt[#tbOpt + 1]	= {"结束报名，强制开战", "Wldh.Battle:GM_Start"};
		end
		tbOpt[#tbOpt + 1]	= {"结束当前战役", "Wldh.Battle:GM_Close"};
	end
	
	tbOpt[#tbOpt + 1]	= {"去报名点", "Wldh.Battle:GM_GotoSignUp"};
	tbOpt[#tbOpt + 1]	= {"Kết thúc đối thoại"};

	Dialog:Say("武林大会团体赛GM！<pic=42>", tbOpt);
end

function Wldh.Battle:GM_Start()

	for i = 1, 6 do
		
		local tbMission	= self:GetMission(i);
		
		if not tbMission then
			me.Msg(string.format("--武林大会团体赛[%s] 未开启，无法开战！", i));
			
		elseif tbMission.nState ~= 1 then
			me.Msg(string.format("--武林大会团体赛[%s] 状态不对，无法开战！", tbMission:GetFullName()));
		else
			tbMission.nSignUpMsgCount = 1;
			tbMission:GoNextState();
			me.Msg(string.format("--武林大会团体赛[%s] 报名结束，开始战斗！", tbMission:GetFullName()));
		end
	end
end

function Wldh.Battle:GM_Close()
	
	for i = 1, 6 do
		
		local tbMission	= self:GetMission(i);
		
		if tbMission then
			self:CloseBattle(tbMission.nBattleKey, i);
			me.Msg(string.format("--武林大会团体赛[%s] 关闭成功！", tbMission:GetFullName()));
		else
			me.Msg(string.format("--武林大会团体赛[%s] 未开启，无法关闭！", i));
		end
	end
end

function Wldh.Battle:GM_GotoOneSignUp(nBattleIndex)
	
	if self.MAPID_SIGNUP[nBattleIndex] then
		local nMapId = self.MAPID_SIGNUP[nBattleIndex];
		me.NewWorld(nMapId, 1686, 3276);
	end	
end

function Wldh.Battle:GM_GotoSignUp()
	local tbOpt = {};
	for i = 1, #self.MAPID_SIGNUP do
		tbOpt[#tbOpt + 1] = { string.format("报名点%d", i), "Wldh.Battle:GM_GotoOneSignUp", i};
	end
	Dialog:Say("你要选择哪场战场？", tbOpt);
end
