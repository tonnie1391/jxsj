-- 文件名　：201108_tanabata_book.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-07-25 18:11:01
-- 描述：散落书页&书卷

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

SpecialEvent.Tanabata201108 =  SpecialEvent.Tanabata201108 or {};
local Tanabata201108 = SpecialEvent.Tanabata201108;

local tbBookPart = Item:GetClass("QX_book_part");

function tbBookPart:OnUse()
	local nLevel = it.nLevel;
	local szBookName = KItem.GetNameById(unpack(Tanabata201108.tbBookInfo[nLevel]));
	local szMsg = string.format("您可以消耗精力、活力各%s点，制作成一本<color=yellow>%s<color>。\n\n确定制作么？",Tanabata201108.nMakeBookJinghuo,szBookName);
	local tbOpt = 
	{
		{"确定制作", self.MakeBook, self,it.dwId},
		{"Để ta suy nghĩ thêm"},	
	};
	Dialog:Say(szMsg, tbOpt);
	return 0;
end

function tbBookPart:MakeBook(nItemId)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	local bCanMake,szError = self:CheckCanMake();
	if bCanMake ~= 1 then
		Dialog:Say(szError);
		return 0;
	end
	GeneralProcess:StartProcess("制作中...", 1 * Env.GAME_FPS, {self.DoMake, self,pItem.dwId}, nil, tbEvent);
end

function tbBookPart:DoMake(nItemId)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	local bCanMake,szError = self:CheckCanMake();
	if bCanMake ~= 1 then
		Dialog:Say(szError);
		return 0;
	end
	local nLevel = pItem.nLevel;
	local tbBookInfo = Tanabata201108.tbBookInfo[nLevel];
	local nNeedGTPMKP = Tanabata201108.nMakeBookJinghuo;
	if me.DelItem(pItem,Player.emKLOSEITEM_USE) ~= 1 then
		return 0;
	end
	me.ChangeCurGatherPoint(-nNeedGTPMKP);
	me.ChangeCurMakePoint(-nNeedGTPMKP);
	local pItem = me.AddItem(tbBookInfo[1],tbBookInfo[2],tbBookInfo[3],tbBookInfo[4]);
	if pItem then
		StatLog:WriteStatLog("stat_info", "qixi_2011","item_proc", me.nId, pItem.nLevel,1);
	end
end


function tbBookPart:CheckCanMake()
	if GetMapType(me.nMapId) ~= "city" and GetMapType(me.nMapId) ~= "village" then
		return 0, "该物品只能在各大新手村和城市使用";
	end
	local szErrMsg = "";
	if me.CountFreeBagCell() < 1 then
		szErrMsg = "Hành trang không đủ <color=yellow>1 ô<color> trống!";
		return 0, szErrMsg;
	end
	local nNeedGTPMKP = Tanabata201108.nMakeBookJinghuo;
	if me.dwCurGTP < nNeedGTPMKP or me.dwCurMKP < nNeedGTPMKP then
		szErrMsg = string.format("你的精活不足，制作书卷需要消耗精力和活力各<color=yellow>%s点<color>。",nNeedGTPMKP);
		return 0, szErrMsg;
	end
	return 1;
end

function tbBookPart:InitGenInfo()
	local nSec = Lib:GetDate2Time(tonumber(os.date("%Y%m%d",GetTime()))) + 3600 * (23 + 55/60);
	it.SetTimeOut(0, nSec);
	StatLog:WriteStatLog("stat_info", "qixi_2011","item_output", 0, it.nLevel);
	return	{};
end

----书卷----------------
local tbBook = Item:GetClass("QX_book");

function tbBook:OnUse()
	--弹出ui
	me.CallClientScript{"UiManager:OpenWindow","UI_TANABATABOOK",it.nLevel};
	return 0;
end

function tbBook:InitGenInfo()
	local nSec = Lib:GetDate2Time(tonumber(os.date("%Y%m%d",GetTime()))) + 3600 * (23 + 55/60);
	it.SetTimeOut(0, nSec);
	return	{};
end
