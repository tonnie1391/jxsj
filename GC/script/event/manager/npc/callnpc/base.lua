
do return end
Require("\\script\\event\\manager\\define.lua");

local EventKind = {};
EventManager.EventKind.Npc.CallNpc = EventKind;

function EventKind:ExeNpcStartFun(tbParam)
	local tbNpc = tbParam[1];
	--执行召唤怪物开始；
	if type(tbNpc) ~= "table" then
		return 0;
	end
	local nMapId 	= tbNpc.nMapId;
	local nPosX 	= tbNpc.nPosX;
	local nPosY 	= tbNpc.nPosY;
	local nNpcId 	= tbNpc.nNpcId;
	local nLevel 	= tbNpc.nLevel;
	local nSeries 	= tbNpc.nSeries;
	local szAnnouce = tbNpc.szAnnouce;
	local szName	= tbNpc.szName;
	if SubWorldID2Idx(nMapId) < 0 then
		return 0;
	end
	local pNpc	= KNpc.Add2(nNpcId, nLevel, nSeries, nMapId, nPosX, nPosY);
	if pNpc then
		self.tbNpcId = self.tbNpcId  or {};
		table.insert(self.tbNpcId, pNpc.dwId);
		if szName ~= "" then
			pNpc.szName = szName;
		end
		if szAnnouce ~= "" then
			KDialog.NewsMsg(1, Env.NEWSMSG_NORMAL, szAnnouce);
		end
	end
	return 0;
end

function EventKind:ExeNpcEndFun(tbNpc)
	--执行召唤怪物结束;
	if self.tbNpcId ~= nil then
		for ni, nNpcId in ipairs(self.tbNpcId) do
			local pNpc = KNpc.GetById(nNpcId);
			if pNpc then
				pNpc.Delete();
			end
		end
	end
	self.tbNpcId = {};
	return 0;
end
