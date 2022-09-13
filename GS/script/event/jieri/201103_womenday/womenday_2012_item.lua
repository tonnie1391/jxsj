-- 文件名　：womenday_2012_item.lua
-- 创建者　：zhangjunjie
-- 创建时间：2012-02-29 11:21:52
-- 描述：


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
	Player.ProcessBreakEvent.emEVENT_LOGOUT,
	Player.ProcessBreakEvent.emEVENT_DEATH,
	Player.ProcessBreakEvent.emEVENT_ATTACKED,
}

---通用宝箱
local tbCommonBox = Item:GetClass("womenday_box_common");

tbCommonBox.nMaxExtRand = 100;

tbCommonBox.tbExtPrize = {{1,13,133,1},2,14 * 24 * 60 * 60};

tbCommonBox.tbRose = {{18,1,1694,1},3};

function tbCommonBox:OnUse()
	local nNeedCell = it.GetExtParam(3) or 0;
	if nNeedCell <= 0 then
		nNeedCell = 1;
	end
	if me.CountFreeBagCell() < nNeedCell then
		Dialog:Say(string.format("请保证留出<color=green>%s格<color>背包空间！",nNeedCell));
		return 0;
	end
	return self:OpenBox(it.dwId);
end

function tbCommonBox:OpenBox(nItemId)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		me.Msg("道具使用错误！")
		return 0;
	end
	local nRandId = pItem.GetExtParam(1) or 0;
	if nRandId <= 0 then
		me.Msg("道具使用错误！")
		return 0;
	end
	local tbRandomItem = Item:GetClass("randomitem");
	tbRandomItem:SureOnUse(nRandId);
	local tbRoseGdpl = self.tbRose[1];
	local nRoseCount = MathRandom(self.tbRose[2]);
	me.AddStackItem(tbRoseGdpl[1],tbRoseGdpl[2],tbRoseGdpl[3],tbRoseGdpl[4],nil,nRoseCount);
	local nIsExtern =  pItem.GetExtParam(2) or 0;
	--额外奖品
	if nIsExtern > 0 then
		local nRand = MathRandom(self.nMaxExtRand);
		local nRegion = self.tbExtPrize[2];
		if nRand <= nRegion then
			local tbGdpl = self.tbExtPrize[1];
			local pExt = me.AddItem(unpack(tbGdpl));
			if pExt then
				StatLog:WriteStatLog("stat_info","funvjie2012","spe_item",me.nId,pExt.szName);
				local nRemainTime = self.tbExtPrize[3];
				pExt.SetTimeOut(0,GetTime() + nRemainTime);	--绝对时间
				pExt.Sync();
				local szMsg = string.format("%s打开%s获得一个<color=green>%s<color>,真是可喜可贺呀！",me.szName,pItem.szName,pExt.szName);
				local szFMsg = string.format("Hảo hữu [<color=yellow>%s<color>]打开%s获得一个%s,真是可喜可贺呀！",me.szName,pItem.szName,pExt.szName);
				local szKMsg = string.format("打开%s获得一个%s,真是可喜可贺呀！",pItem.szName,pExt.szName);
				Player:SendMsgToKinOrTong(me,szKMsg,0);
				me.SendMsgToFriend(szFMsg);		
				KDialog.NewsMsg(1,Env.NEWSMSG_NORMAL,szMsg);					
			end
		end
	end
	return 1;
end


----玫瑰花瓣
local tbRose = Item:GetClass("womenday_rose");

tbRose.tbMake2Gdpl = {18,1,373,1};

tbRose.nNeedJinghuo = 500;

function tbRose:OnUse()
	local szName = KItem.GetNameById(unpack(self.tbMake2Gdpl));
	local szMsg = string.format("您可以消耗精力、活力各%s点，将它加工成一朵<color=yellow>%s<color>。\n\n确定制作么？",self.nNeedJinghuo,szName);
	local tbOpt = 
	{
		{"确定制作", self.MakeRose,self,me.nId,it.dwId},
		{"Để ta suy nghĩ thêm"},	
	};
	Dialog:Say(szMsg, tbOpt);
	return 0;
end

function tbRose:MakeRose(nPlayerId,nItemId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	local bCanMake,szError = self:CheckCanMake(pPlayer);
	if bCanMake ~= 1 then
		Dialog:Say(szError);
		return 0;
	end
	GeneralProcess:StartProcess("制作中...", 2 * Env.GAME_FPS, {self.DoMake,self,nPlayerId,pItem.dwId},nil,tbEvent);
end

function tbRose:DoMake(nPlayerId,nItemId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	local bCanMake,szError = self:CheckCanMake(pPlayer);
	if bCanMake ~= 1 then
		Dialog:Say(szError);
		return 0;
	end
	local tbInfo = self.tbMake2Gdpl;
	local nNeedGTPMKP = self.nNeedJinghuo;
	local nCount = pItem.nCount or 0;
	if nCount <= 0 then
		return 0;
	end
	if nCount > 1 then
		if pItem.SetCount(nCount - 1) ~= 1 then
			return 0;
		end	
	else 
		if me.DelItem(pItem,Player.emKLOSEITEM_USE) ~= 1 then
			return 0;
		end	
	end
	me.ChangeCurGatherPoint(-nNeedGTPMKP);
	me.ChangeCurMakePoint(-nNeedGTPMKP);
	local pItem = me.AddItem(tbInfo[1],tbInfo[2],tbInfo[3],tbInfo[4]);
	if pItem then
		StatLog:WriteStatLog("stat_info","funvjie2012","get_rose",me.nId,1);
	end
	return 1;
end

function tbRose:CheckCanMake(pPlayer)
	if not pPlayer then
		return 0;
	end
	if GetMapType(pPlayer.nMapId) ~= "city" and GetMapType(pPlayer.nMapId) ~= "village" then
		return 0, "Chỉ có thể chế tạo tại Thành Thị và Tân Thủ Thôn!";
	end
	local szErrMsg = "";
	if pPlayer.CountFreeBagCell() < 1 then
		szErrMsg = "Hành trang không đủ <color=yellow>1 ô<color> trống!";
		return 0, szErrMsg;
	end
	local nNeedGTPMKP = self.nNeedJinghuo;
	if pPlayer.dwCurGTP < nNeedGTPMKP or pPlayer.dwCurMKP < nNeedGTPMKP then
		szErrMsg = string.format("你的精活不足，制作玫瑰花需要消耗精力和活力各<color=yellow>%s点<color>。",nNeedGTPMKP);
		return 0, szErrMsg;
	end
	return 1;
end