-- 文件名　：kingame_lulutong.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-07-09 15:43:06
-- 描述：路路通

local tbNpc  =  Npc:GetClass("kingame_lulutong");

function tbNpc:OnDialog()
	local pGame = KinGame2:GetGameObjByMapId(me.nMapId);
	if not pGame then
		return 0;
	end
	local nMaxRoomId = pGame.nCurrentStepRoom;
	if nMaxRoomId <= 4 or pGame:IsStart() ~= 1 then
		local szMsg = "    你好，路程不算太远，自己跑过去，就当锻炼身体了。第四关挑战完成后，我可以免费送你一程！"
		Dialog:Say(szMsg,{"Ta hiểu rồi"});
		return 0;
	end
	if nMaxRoomId > 4 then
		local szMsg = "    日行百里不含糊，想去哪，我可以免费送你一程！"
		local tbPosInfo = KinGame2.TRANSPORT_POS;
		local tbOpt = {};
		for _,tbInfo in pairs(tbPosInfo) do 
			if nMaxRoomId > tbInfo[2] then
				tbOpt[#tbOpt + 1] = {"送我去<color=yellow>" .. tbInfo[1] .. "<color>",self.Transfer,self,pGame.nMapId,tbInfo[3]};
			end
		end
		tbOpt[#tbOpt + 1] = {"我还是自己跑过去吧"};
		Dialog:Say(szMsg,tbOpt);
		return 0;
	end
end

function tbNpc:Transfer(nMapId,tbPos)
	if not tbPos then
		return 0;
	end
	me.NewWorld(nMapId,tbPos[1],tbPos[2]);
	if me.nFightState == 0 then
		me.SetFightState(1);
	end
end