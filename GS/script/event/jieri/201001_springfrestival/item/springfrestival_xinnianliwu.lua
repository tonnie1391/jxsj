-- 文件名　：xinnianliwu.lua
-- 创建者　：jiazhenwei
-- 创建时间：2009-12-28 17:12:56
-- 描  述  ：新年礼物

local tbItem 	= Item:GetClass("gift_newyear");
SpecialEvent.SpringFrestival = SpecialEvent.SpringFrestival or {};
local SpringFrestival = SpecialEvent.SpringFrestival or {};

function tbItem:OnUse()
	--local nData = tonumber(GetLocalDate("%Y%m%d"));
	--if nData < SpringFrestival.HuaDengOpenTime or nData > SpringFrestival.HuaDengCloseTime then	--活动期间外
	--	Dialog:Say("没有在活动期间，您还不能使用该物品！", {"知道了"});
	--	return;
	--end
	
	--60Level
	if me.nLevel < SpringFrestival.nLevel  then
		Dialog:Say(string.format("您的等级不足%s级，不能使用这个道具！", SpringFrestival.nLevel),{"知道了"});
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
		if pPlayer and me.nId ~= tbPlayerList[i] then		
			table.insert(tbOpt, {string.format("%s",pPlayer.szName), self.Present, self, it.dwId, tbPlayerList[i]});		
		end
	end
	table.insert(tbOpt, {"取消"});
	Dialog:Say("赠送给队友，请选择要赠送的人。",tbOpt);
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
	if pPlayer.nLevel < SpringFrestival.nLevel  then
		Dialog:Say(string.format("对方等级不足%s级，不能送给他！", SpringFrestival.nLevel),{"知道了"});
		return;
	end	
	--亲密度不足2级
	if me.GetFriendFavorLevel(pPlayer.szName) < 2 then
		Dialog:Say("您与对方亲密度不到2级，这样送礼未免唐突。",{"知道了"});			
		return;
	end
	--对方接受拜年次数
	local nCount = pPlayer.GetTask(SpringFrestival.TASKID_GROUP, SpringFrestival.TASKID_BAINIANNUMBER)
	if nCount >= SpringFrestival.nBaiNianCount then
		Dialog:Say("不能再送礼了，对方已经接受了15个新年礼物！",{"知道了"});			
		return;			
	end
	--背包判断
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("赠送道具，需要预留1格背包空间，去整理下再使用吧。",{"知道了"});
		return;
	end	
	if pPlayer.CountFreeBagCell() < 1 then
		Dialog:Say("赠送的好友需要有1格背包空间，等他整理下再送给他吧！",{"知道了"});
		return;
	end
	
	pItem.Delete(me);	
	pPlayer.SetTask(SpringFrestival.TASKID_GROUP, SpringFrestival.TASKID_BAINIANNUMBER, nCount +1);
	
	Dialog:SendBlackBoardMsg(me, string.format("您将新年礼物送给了%s，对方很开心！",pPlayer.szName));
	Dialog:SendBlackBoardMsg(pPlayer, string.format("您收到了来自%s的新年礼物，真开心！",me.szName));
	pPlayer.Msg(string.format("您已经收到%s个礼物了",nCount+1));
	local nData = tonumber(GetLocalDate("%Y%m%d"));
	if nData >= SpringFrestival.HuaDengOpenTime and nData <= SpringFrestival.HuaDengCloseTime then	--活动期间
		--随机奖励物品
		local nRant = MathRandom(100);
		for i = 1 ,#SpringFrestival.tbBaiAward do
			if nRant > SpringFrestival.tbBaiAward[i][2] and nRant <= SpringFrestival.tbBaiAward[i][3]  then
				local pItemEx = me.AddItem(unpack(SpringFrestival.tbBaiAward[i][1]));
				EventManager:WriteLog(string.format("[新年活动·玩家间拜年]给好友拜年获得随机物品:%s", pItemEx.szName), me);
				me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("[新年活动·玩家间拜年]给好友拜年获得随机物品:%s", pItemEx.szName));
			end
		end
	end
	--给予对方(新年礼物[馈赠])
	local pItemEx = pPlayer.AddItem(unpack(SpringFrestival.tbBaiNianAward));
	pPlayer.SetItemTimeout(pItemEx, 60*24*30, 0);
	EventManager:WriteLog(string.format("[新年活动·玩家间拜年]获得好友%s赠送的新年礼物[馈赠]", me.szName), pPlayer);
	pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("[新年活动·玩家间拜年]获得好友%s赠送的新年礼物[馈赠]", me.szName));
end

function tbItem:InitGenInfo()
	-- 设定有效期限
	local nSec = Lib:GetDate2Time(SpringFrestival.nOutTime + 10000); --加了一天
	it.SetTimeOut(0, nSec);
	return	{ };
end
