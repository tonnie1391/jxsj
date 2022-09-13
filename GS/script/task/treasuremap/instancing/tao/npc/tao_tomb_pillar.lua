
-- ====================== 文件信息 ======================

-- 陶朱公疑冢符文柱脚本
-- Edited by peres
-- 2008/03/04 PM 08:26

-- 她的眼泪轻轻地掉落下来
-- 抚摸着自己的肩头，寂寥的眼神
-- 是，褪掉繁华和名利带给的空洞安慰，她只是一个一无所有的女子
-- 不爱任何人，亦不相信有人会爱她

-- ======================================================

local tbNpc = Npc:GetClass("tao_tomb_pillar");

tbNpc.tbLightName	= {
	["西面柱子"]	= 1,	
	["南面柱子"]	= 2,
	["东面柱子"]	= 3,
	["北面柱子"]	= 4,
}

function tbNpc:OnDialog()

	local nSubWorld, _, _	= him.GetWorldPos();
	
	local tbInstancing = TreasureMap:GetInstancing(nSubWorld);
	assert(tbInstancing);
	
	local nOpen = 0;
	
	if not tbInstancing.tbLightOpen or tbInstancing.tbLightOpen[self.tbLightName[him.szName]] == 0 then
		
		local tbEvent = 
		{
			Player.ProcessBreakEvent.emEVENT_MOVE,
			Player.ProcessBreakEvent.emEVENT_ATTACK,
			Player.ProcessBreakEvent.emEVENT_SITE,
			Player.ProcessBreakEvent.emEVENT_USEITEM,
			Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
			Player.ProcessBreakEvent.emEVENT_DROPITEM,
			Player.ProcessBreakEvent.emEVENT_SENDMAIL,		
			Player.ProcessBreakEvent.emEVENT_TRADE,
			Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
			Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
			Player.ProcessBreakEvent.emEVENT_ATTACKED,
			Player.ProcessBreakEvent.emEVENT_DEATH,
			Player.ProcessBreakEvent.emEVENT_LOGOUT,
		}
		
		GeneralProcess:StartProcess("正在解开柱子上的符咒……", 15 * 18, {self.OnOpen, self, me.nId, him.dwId}, {me.Msg, "Mở gián đoạn"}, tbEvent);
		return;
	
	elseif tbInstancing.tbLightOpen[self.tbLightName[him.szName]] == 1 then
		Dialog:SendInfoBoardMsg(me, "<color=red>该柱子上的符咒已经被解开！<color>");
		return;
	end;
	
end;


function tbNpc:OnOpen(nPlayerId, nNpcId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc) then
		return;
	end
	
	local nSubWorld, _, _	= pNpc.GetWorldPos();
	local tbInstancing = TreasureMap:GetInstancing(nSubWorld);
	assert(tbInstancing);
	
	if self.tbLightName[pNpc.szName] then
		if not tbInstancing.tbLightOpen then
			
			tbInstancing.tbLightOpen = {};
			
			-- 第一次点柱子时初始化
			for name, i in pairs(self.tbLightName) do
				tbInstancing.tbLightOpen[i] = 0;
			end;
			
		end;
		
		tbInstancing.tbLightOpen[self.tbLightName[pNpc.szName]] = 1;
		
		Dialog:SendInfoBoardMsg(me, "<color=green>你已经解开了"..pNpc.szName.."上的符咒！<color>");
		
		-- 把这个符文柱删了
		pNpc.Delete();
		
		local nNum = 0;
		for j, i in pairs(tbInstancing.tbLightOpen) do
			nNum = nNum + i;
		end;
		-- 四栈灯都开了，把石碑删了
		if nNum == 4 then
			if tbInstancing.tbStele_1_Idx then
				for i=1, #tbInstancing.tbStele_1_Idx do
					local nTempNpcId	= tbInstancing.tbStele_1_Idx[i];
					local pTempNpc		= KNpc.GetById(nTempNpcId);
					if pTempNpc then
						pTempNpc.Delete();
					end;
				end;
			end;
			return;
		end;
	end;
	
end;
