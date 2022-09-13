-- 文件名  : SeventhEvening_wangmu.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-07-07 16:27:35
-- 描述    : 鹊羽 琉璃石 道具脚本

local tbItem = Item:GetClass("QX_wangmu");

SpecialEvent.SeventhEvening = SpecialEvent.SeventhEvening or {};
local SeventhEvening = SpecialEvent.SeventhEvening or {};

 tbItem.IdentifyDuration 	= Env.GAME_FPS * 10; 
 
 function tbItem:OnUse()
 	local nData = tonumber(GetLocalDate("%Y%m%d"));
	if nData < SeventhEvening.OpenTime or nData > SeventhEvening.CloseTime then	--活动期间外
		Dialog:Say("没有在活动期间，您还不能使用该物品！", {"知道了"});
		return;
	end
	Dialog:Say(string.format("您要合成金鹊琉璃钗吗？需要消耗精活各%s点。\n<color=green>3个鹊羽+3个琉璃石+%s点精活=1个金鹊琉璃钗<color>", SeventhEvening.nGTPMkPMin_Couplet, SeventhEvening.nGTPMkPMin_Couplet),
				{"合成", self.ComposeItem, self, 0},
				{"Để ta suy nghĩ thêm"}
			);
end
 
 --合成进度条
 function tbItem:ComposeItem(nFlag)
 	if self:Check() == 0 then
 		return;
 	end
 	--执行
	if nFlag == 1 then
		self:SuccessIdentify();
		return;
	end
	
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
		
	GeneralProcess:StartProcess("合成金鹊琉璃钗...", self.IdentifyDuration, {self.ComposeItem, self,  1}, nil, tbEvent);
end
 
 --成功加道具，删道具，减精活
 function tbItem:SuccessIdentify()
	me.ConsumeItemInBags2(3, SeventhEvening.tbXiYu[1], SeventhEvening.tbXiYu[2], SeventhEvening.tbXiYu[3], SeventhEvening.tbXiYu[4], nil, -1);--删掉3个鹊羽
	me.ConsumeItemInBags2(3, SeventhEvening.tbLiuLiShi[1], SeventhEvening.tbLiuLiShi[2], SeventhEvening.tbLiuLiShi[3], SeventhEvening.tbLiuLiShi[4], nil, -1);--删掉3个琉璃石
	me.ChangeCurGatherPoint(-SeventhEvening.nGTPMkPMin_Couplet);	--减精力
	me.ChangeCurMakePoint(-SeventhEvening.nGTPMkPMin_Couplet);		--减活力
	local pItem = me.AddItem(unpack(SeventhEvening.tbChai));
	if pItem then
		me.SetItemTimeout(pItem, 60*24*30, 0);
		Dbg:WriteLog("SeventhEvening", "10年七夕", "合成金鹊琉璃钗", string.format("玩家：%s合成一个金鹊琉璃钗。", me.szName));
	end
end
 
 --相关检查
 function tbItem:Check()
 	--等级判断
	if me.nLevel < SeventhEvening.nLevel  then
		Dialog:Say(string.format("您的等级不足%s级，不能合成！", SeventhEvening.nLevel), {"知道了"});
		return 0;
	end	
	--背包判断
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("需要1格背包空间，整理下吧！",{"知道了"});
		return 0;
	end
	--精活判断
	if me.dwCurGTP < SeventhEvening.nGTPMkPMin_Couplet or me.dwCurMKP < SeventhEvening.nGTPMkPMin_Couplet then
		Dialog:Say(string.format("您的精活不足，需要精活各%s点。", SeventhEvening.nGTPMkPMin_Couplet), {"知道了"});
		return 0;
	end
	--身上物品的判断
	local tbFind_XiYu = me.FindItemInBags(unpack(SeventhEvening.tbXiYu));
	local nCountXiYu = 0;
	for i = 1, #tbFind_XiYu do
		nCountXiYu = nCountXiYu + tbFind_XiYu[i].pItem.nCount;
	end
	
 	local tbFind_LiuLiShi = me.FindItemInBags(unpack(SeventhEvening.tbLiuLiShi));
 	local nCountLiuLiShi = 0;
	for i = 1, #tbFind_LiuLiShi do
		nCountLiuLiShi = nCountLiuLiShi + tbFind_LiuLiShi[i].pItem.nCount;
	end
	
 	if nCountXiYu < SeventhEvening.nCount_XiYu or  nCountLiuLiShi < SeventhEvening.nCount_LiuLiShi then
 		Dialog:Say("<color=green>合成需要三个鹊羽和三个琉璃石<color>，您身上的物品不足。", {"知道了"});
		return 0;
 	end
 	return 1;
end
 