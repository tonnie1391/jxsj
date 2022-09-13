-- 文件名　：youlong.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-06-16 15:02:28
-- 描述：每个关卡完成后的游龙猜数

local tbNpc  = Npc:GetClass("youlong_kin");


function tbNpc:OnDialog()
	self:Switch(him.dwId);
end


function tbNpc:Switch(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local szMsg = "    恭喜你们通过了本关考验，请尽快选择一个幸运选项。";
	local tbOpt = {};
	for i = 1 , #KinGame2.RANDOM_EVENT_LEVEL_NAME do
		tbOpt[i] = {KinGame2.RANDOM_EVENT_LEVEL_NAME[i],self.EnsureSelect,self,i,nNpcId};
	end
	Dialog:Say(szMsg,tbOpt);
end

function tbNpc:EnsureSelect(nSelect,nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local pGame = KinGame2:GetGameObjByMapId(pNpc.nMapId) --获得对象
	if not pGame then
		return 0;
	end
	if not nSelect then
		return 0;
	end
	local nPlayerId = pGame.nSelectPlayerId;
	local tbLuck = pGame.tbSelectLuck;
	if me.nId ~= nPlayerId then
		Dialog:Say("您不是本轮抽到的前来幸运选点的玩家。");
		return 0;
	end
	local nLevel = 1;
	if tbLuck then
		for i = 1,#tbLuck do
			if nSelect == tbLuck[i] then
				nLevel = i;
				break;
			end
		end
	end
	KinGame2:EndRandomGame(nLevel,pNpc.nMapId);
end