-- 文件名  : SeventhEvening_libao.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-07-08 10:25:10
-- 描述    : 金鹊礼包

local tbItem 	= Item:GetClass("QX_libao");
SpecialEvent.SeventhEvening = SpecialEvent.SeventhEvening or {};
local SeventhEvening = SpecialEvent.SeventhEvening or {};

function tbItem:OnUse()
	--Level
	if me.nLevel < SeventhEvening.nLevel  then
		Dialog:Say(string.format("您的等级不足%s级，不能使用这个道具！", SeventhEvening.nLevel),{"知道了"});
		return;
	end
	
	--组队判定
	if me.nTeamId == 0  then
		Dialog:Say("礼包只能赠送给队友，你还没组队呢。", {"知道了"});
		return;
	end
	
	--背包判定
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("赠送礼包，需要预留1格背包空间，去整理下再使用吧。",{"知道了"});
		return;
	end	
	
	local tbOpt = {};
	local tbPlayerList = KTeam.GetTeamMemberList(me.nTeamId);	
	--只有本人一个人
	if #tbPlayerList <= 1 then
		Dialog:Say("您没有队友吧。",{"知道了"});
		return;
	end	
	
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
	if pPlayer.nLevel < SeventhEvening.nLevel  then
		Dialog:Say(string.format("对方等级不足%s级，不能接受你的礼物！", SeventhEvening.nLevel),{"知道了"});
		return;
	end	
--	--亲密度不足2级
--	if me.GetFriendFavorLevel(pPlayer.szName) < 2 then
--		Dialog:Say("您与对方亲密度不到2级，这样送礼未免唐突。",{"知道了"});
--		return;
--	end
	--性别
	if me.nSex == pPlayer.nSex then
		Dialog:Say("金鹊礼包只能赠送给异性同队伍玩家。",{"知道了"});
		return;
	end
	
	--对方接受次数
	local nCount = pPlayer.GetTask(SeventhEvening.TASKID_GROUP, SeventhEvening.TASKID_ACCEPTNUM)
	if nCount >= SeventhEvening.nAcceptCount then
		Dialog:Say(string.format("不能再送礼了，对方已经接受了%s个金鹊礼包！", SeventhEvening.nAcceptCount),{"知道了"});			
		return;
	end
	--背包判断
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("赠送礼包，需要预留1格背包空间，去整理下再使用吧。",{"知道了"});
		return;
	end	
	if pPlayer.CountFreeBagCell() < 1 then
		Dialog:Say("赠送的队友需要有1格背包空间，等队友整理一下背包再赠送吧！！",{"知道了"});
		return;
	end
	
	pItem.Delete(me);
	pPlayer.SetTask(SeventhEvening.TASKID_GROUP, SeventhEvening.TASKID_ACCEPTNUM, nCount +1);
	
	Dialog:SendBlackBoardMsg(me, string.format("您将金鹊礼包送给了%s，对方很开心！",pPlayer.szName));
	Dialog:SendBlackBoardMsg(pPlayer, string.format("您收到了来自%s的金鹊礼包，真开心！",me.szName));
	pPlayer.Msg(string.format("您已经收到%s个金鹊礼包了",nCount+1));
	me.Msg(string.format("您的好友<color=yellow>%s<color>已经收到了你送的金鹊礼包。",pPlayer.szName));
	local nData = tonumber(GetLocalDate("%Y%m%d"));
--	if nData >= SeventhEvening.OpenTime and nData <= SeventhEvening.CloseTime then	--活动期间
--		--随机奖励物品
--		local nRant = MathRandom(100);
--		for i = 1 ,#SeventhEvening.tbQueQiaoAward do
--			if nRant > SeventhEvening.tbQueQiaoAward[i][2] and nRant <= SeventhEvening.tbQueQiaoAward[i][3]  then
--				local pItemEx = me.AddItem(unpack(SeventhEvening.tbBaiAward[i][1]));
--				EventManager:WriteLog(string.format("[七夕]赠送金鹊礼包给好友获得随机物品:%s", pItemEx.szName), me);
--				me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("[七夕]赠送金鹊礼包给好友获得随机物品:%s", pItemEx.szName));
--			end
--		end
--	end
	for i = 1 ,#SeventhEvening.tbQueQiaoAward do
		local pItemEx = me.AddItem(unpack(SeventhEvening.tbQueQiaoAward[i]));
		if pItemEx then
			Dbg:WriteLog("SeventhEvening", "10年七夕", "赠送金鹊礼包", string.format("玩家：%s赠送金鹊礼包给好友获得物品:%s。", me.szName, pItemEx.szName));
		end
	end
		
	--给予对方(新年礼物[馈赠])
	local pItemEx = pPlayer.AddItem(unpack(SeventhEvening.tbLiBaoKuiZeng));
	pPlayer.SetItemTimeout(pItemEx, 60*24*30, 0);
	
	--加幸福榜积分
	local nTime = tonumber(GetLocalDate("%Y%m%d"));
	if me.IsMarried() == 1 and pPlayer.IsMarried() == 1 and me.GetCoupleName() == pPlayer.szName and  nTime < 201000901 then		
		SeventhEvening:AddXialvPoint(me, pPlayer, 3);
	end
	
	--加亲密度
	if me.GetFriendFavorLevel(pPlayer.szName) > 0 then
		Relation:AddFriendFavor(me.szName, pPlayer.szName, SeventhEvening.nFavorNum);
	else
		me.Msg(string.format("您和%s不是好友不能加亲密度啊，好可惜哦！",pPlayer.szName));
		pPlayer.Msg(string.format("您和%s不是好友不能加亲密度啊，好可惜哦！",me.szName));
	end
	Dbg:WriteLog("SeventhEvening", "10年七夕", "赠送金鹊礼包", string.format("玩家：%s收到金鹊礼包[馈赠]从好友%s。", pPlayer.szName, me.szName));
end
