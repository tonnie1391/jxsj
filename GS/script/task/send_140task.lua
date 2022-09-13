
local tbSend = Npc:GetClass("send_140task");

tbSend.tbPos = {569,1590,3199}

function tbSend:OnDialog()
	if (me.nLevel >= 135) then
		local szMsg = "现在就去灵壁泊吗？";
		Dialog:Say(szMsg, {
				{"是的", self.NewPos, self, me.nId},
				{"Kết thúc đối thoại"}
				});
		return;
	end;
	
	local szMsg = me.szName ..", xin chào!";
	Dialog:Say(szMsg, {
				{"Kết thúc đối thoại"}
				});
end

function tbSend:NewPos(nId)
	local pPlayer = KPlayer.GetPlayerObjById(nId);
	if (not pPlayer) then
		return;
	end;
	
	pPlayer.NewWorld(tbSend.tbPos[1], tbSend.tbPos[2], tbSend.tbPos[3]);	
	pPlayer.SetFightState(1);	
end;