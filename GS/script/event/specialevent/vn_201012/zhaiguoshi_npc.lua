-- 文件名  : zhaiguoshi_npc.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-11-18 14:40:59
-- 描述    : 大树

local tbDaShu = Npc:GetClass("dashu_vnzhaiguoshi");
tbDaShu.tbTao = {18,1,1096,1}		--果实

function tbDaShu:OnDialog()
	local nFlag, szMsg = SpecialEvent.tbZaiGuoShi:CheckCanGaterSeed();
	if nFlag == 0 then
		Dialog:Say(szMsg, {{"Ta hiểu rồi"}});
		return 0;
	end
	local tbOpt= {
		{"摘果实", self.GatherSeed, self, him.dwId},
		{"Ta hiểu rồi"}
		}
	Dialog:Say("树上结满了果实，可以采到果子哦！", tbOpt);
end

function tbDaShu:GatherSeed(nNpcId, bFlag)	
	
	if not bFlag then
	-- 启动进度条
		local tbBreakEvent = 
		{
			Player.ProcessBreakEvent.emEVENT_MOVE,
			Player.ProcessBreakEvent.emEVENT_ATTACK,
			Player.ProcessBreakEvent.emEVENT_SIT,
			Player.ProcessBreakEvent.emEVENT_RIDE,
			Player.ProcessBreakEvent.emEVENT_USEITEM,
			Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
			Player.ProcessBreakEvent.emEVENT_DROPITEM,
			Player.ProcessBreakEvent.emEVENT_CHANGEEQUIP,
			Player.ProcessBreakEvent.emEVENT_SENDMAIL,		
			Player.ProcessBreakEvent.emEVENT_TRADE,
			Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
			Player.ProcessBreakEvent.emEVENT_ATTACKED,
			Player.ProcessBreakEvent.emEVENT_DEATH,
			Player.ProcessBreakEvent.emEVENT_LOGOUT,
			Player.ProcessBreakEvent.emEVENT_REVIVE,
			Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
		}
		GeneralProcess:StartProcess("摘果实...", 1 * Env.GAME_FPS, {self.GatherSeed, self, nNpcId, 1}, nil, tbBreakEvent);
		return 0;
	end	
	
	local nFlag, szMsg = SpecialEvent.tbZaiGuoShi:CheckCanGaterSeed();
	if nFlag == 0 then
		Dialog:Say(szMsg, {{"Ta hiểu rồi"}});
		return 0;
	end
	
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	
	local tbMission =pNpc.GetTempTable("Npc").tbMission;
	if tbMission then
		if tbMission:DelTreeByGatherSeed(pNpc) == 1 then
			local pItem = me.AddItem(unpack(self.tbTao));
			if pItem then
				pItem.SetTimeOut(0, GetTime() + 7 *24 *3600);
				pItem.Sync();
				me.SetTask(SpecialEvent.tbZaiGuoShi.TASKGID, SpecialEvent.tbZaiGuoShi.TASK_TIME, tonumber(GetLocalDate("%H%M")));
			end
		end
	end
end
