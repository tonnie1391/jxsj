-- 文件名　：event_item.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-09-05 21:35:16
-- 功能    ：幸运礼包

local tbItem = Item:GetClass("gift_newgate");
function tbItem:OnUse()
	
	--60Level
	if me.nLevel < SpecialEvent.tbNewGateEvent.nMinLevel then
		Dialog:Say(string.format("您的等级不足%s级，不能使用这个道具！", SpecialEvent.tbNewGateEvent.nMinLevel),{"知道了"});
		return;
	end	
	
	--组队判定
	if me.nTeamId == 0  then
		Dialog:Say("道具只能赠送给队友，你还没组队呢。", {"知道了"});
		return;		
	end
	
	--背包判定
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("赠送道具，需要预留1格背包空间，去整理下再使用吧。",{"知道了"});
		return;
	end	
	
	local tbOpt = {};
	local tbPlayerList = KTeam.GetTeamMemberList(me.nTeamId)
	for i = 1 , #tbPlayerList do
		local pPlayer = KPlayer.GetPlayerObjById(tbPlayerList[i]);
		if pPlayer and pPlayer.szName == it.szCustomString then		
			table.insert(tbOpt, {string.format("%s",pPlayer.szName), self.Present, self, it.dwId, tbPlayerList[i]});		
		end
	end
	if #tbOpt ~= 0 then
		table.insert(tbOpt, {"取消"});
		Dialog:Say("赠送给队友，请选择要赠送的人。",tbOpt);
	else
		Dialog:Say(string.format("该道具只能赠送给<color=yellow>%s<color>。", it.szCustomString));
	end
end

--赠送礼物
function tbItem:Present(nItemId, nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return;
	end
	local nMapId, nPosX, nPosY = me.GetWorldPos();	       		     
	local nMapId2, nPosX2, nPosY2	= pPlayer.GetWorldPos();
	local nDisSquare = (nPosX - nPosX2)^2 + (nPosY - nPosY2)^2;
	if nMapId2 ~= nMapId or nDisSquare > 400 then
		Dialog:Say("队友必须在这附近。");
		return 0;
	end
	
	--60Level
	if pPlayer.nLevel < SpecialEvent.tbNewGateEvent.nMinLevel then
		Dialog:Say(string.format("对方等级不足%s级，不能送给他！", SpecialEvent.tbNewGateEvent.nMinLevel),{"知道了"});
		return;
	end
		
	--背包判断	
	if pPlayer.CountFreeBagCell() < 1 then
		Dialog:Say("赠送的好友需要有1格背包空间，等他整理下再送给他吧！",{"知道了"});
		return;
	end
	
	pItem.Delete(me);
	local pItemEx = pPlayer.AddItem(18,1,1468,3);
	if pItemEx then
		pPlayer.SetItemTimeout(pItemEx, 60*24*3, 0);
	end	
	Dialog:SendBlackBoardMsg(me, string.format("您将幸运送给了%s，对方很开心！",pPlayer.szName));
	Dialog:SendBlackBoardMsg(pPlayer, string.format("您收到了来自%s的幸运礼包，真开心！",me.szName));	
end

function tbItem:GetTip()	
	return "<color=red>可交易给："..it.szCustomString.."<color>";
end


local tbItemEx = Item:GetClass("gift_newgateEx");
function tbItemEx:OnUse()
	local nType = it.nLevel;
	if me.CountFreeBagCell() < 1  then
		Dialog:Say("Hành trang không đủ 1 ô trống.", {"Ta hiểu rồi"});
		return 0;
	end
	if 1000000 + me.GetBindMoney() > me.GetMaxCarryMoney() then
		Dialog:Say("您的身上的绑定银两即将达到上限，请清理一下身上的绑定银两。", {"Ta hiểu rồi"});
		return 0;
	end
	me.AddWaitGetItemNum(1);
	GCExcute({"SpecialEvent.tbNewGateEvent:GetStudentAward", me.nId, nType, IpStatistics:IsStudioRole(me)});	
	return 1;
end