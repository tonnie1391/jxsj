-------------------------------------------------------------------
--File: 	
--Author: 	sunduoliang
--Date: 	2008-4-14 9:00
--Describe:	乾坤符
-------------------------------------------------------------------
Require("\\script\\item\\class\\qiankunfulogic.lua");

-- 乾坤符
local tbItem = Item:GetClass("qiankunfu");
tbItem.nTime = 10;							-- 延时的时间(秒)
function tbItem:OnUse()
	local pPlayer = me;
	self:ShowOnlineMember(it.dwId, pPlayer.nId);
	return 0;
end

function tbItem:ShowOnlineMember(nItemId, nPlayerId)

	local tbOnlineMember = {};
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if pPlayer == nil then
		return 0;
	end
	local tbTeamMemberList = KTeam.GetTeamMemberList(pPlayer.nTeamId);
	if tbTeamMemberList == nil then
		Dialog:Say("Không có đồng đội, không thể dùng Càn Khôn Phù!");
		return 0;
	else
		for _, nMemPlayerId in pairs(tbTeamMemberList) do
			if nMemPlayerId ~= nPlayerId then
				local szMemName = KGCPlayer.GetPlayerName(nMemPlayerId);
				local nOnline = KGCPlayer.OptGetTask(nMemPlayerId, KGCPlayer.TSK_ONLINESERVER);
				local szOnline = "[Rời mạng]";
				if nOnline > 0 then
					szOnline = "[Online]";
				end
				tbOnlineMember[#tbOnlineMember + 1]= {string.format("%s%s", szMemName, szOnline), self.SelectMember, self, nMemPlayerId, nPlayerId, nOnline, nItemId};
			end
		end	
	end	
	
	if (#tbOnlineMember <= 0) then
		Dialog:Say("Không có đồng đội, không thể dùng Càn Khôn Phù!");
		return 0;
	end
	tbOnlineMember[#tbOnlineMember + 1] = {"Đóng"};
	Dialog:Say("Bạn muốn đến đồng đội nào?", tbOnlineMember);
end


function tbItem:SelectMember(nMemberPlayerId, nPlayerId, nOnline, nItemId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if pPlayer == nil then
		return 0;
	end	
	if nOnline <= 0 then
		Dialog:Say("Đồng đội này không online, không thể đến.");
		return 0;
	end
	local szMemberName = KGCPlayer.GetPlayerName(nMemberPlayerId);
	local nNowOnline = KGCPlayer.OptGetTask(nMemberPlayerId, KGCPlayer.TSK_ONLINESERVER);
	if nNowOnline <= 0 then
		Dialog:Say("Đồng đội này đã offline, không thể đến.");
		return 0;
	end
	
	GlobalExcute({"Item.tbQianKunFu:ReCordPlayerMapId_GS", nMemberPlayerId, nPlayerId, nItemId});
	
	local tbEvent	= {						-- 会中断延时的事件
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
	};
	if (0 == pPlayer.nFightState) then				-- 玩家在非战斗状态下传送无延时正常传送
		self:DoSelectMember(nMemberPlayerId, nPlayerId, nItemId)
		return 0;
	end
	GeneralProcess:StartProcess(string.format("Đang đến đồng đội [%s]...",szMemberName), self.nTime * Env.GAME_FPS, {self.DoSelectMember, self, nMemberPlayerId, nPlayerId, nItemId}, nil, tbEvent);	-- 在战斗状态下需要nTime秒的延时
end

-- 功能:	传送玩家去报名点
-- 参数:	nMapId 要传至的报名点的Id
function tbItem:DoSelectMember(nMemberPlayerId, nPlayerId, nItemId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	local nOnline = KGCPlayer.OptGetTask(nMemberPlayerId, KGCPlayer.TSK_ONLINESERVER);
	if nOnline <= 0 then
		Dialog:Say("Đồng đội này đã offline, không thể đến.");
		return 0;
	end	
	if Item.tbQianKunFu:CheckMember(nPlayerId,nMemberPlayerId) ~= 1 then
		pPlayer.Msg("Đồng đội này không có, hoặc đã rời khỏi đội!");
		return 0;		
	end
	GCExcute({"Item.tbQianKunFu:SelectMemberPos", nMemberPlayerId, nPlayerId, nItemId, nMapId});
end


function tbItem:GetTip(nState)
	local nUseCount = it.GetGenInfo(1,0)
	local nLastCount = Item.tbQianKunFu.tbItemList[it.nParticular] - nUseCount;
	local szTip = "";
	szTip = szTip..string.format("<color=0x8080ff>Nhấn chuột phải dùng<color>\n");
	szTip = szTip..string.format("<color=yellow>Số lần dùng còn: %s<color>",nLastCount);
	return szTip;
end

tbItem.tbQianKunFuSet =
{
	{18, 1, 85, 1},
	{18, 1, 91, 1},	
};

-- 客户端直接传送到某一个玩家
function tbItem:OnClientCall(nTargerPlayerID, nSure)
	local nFlag = KItem.CheckLimitUse(me.nMapId, "chuansong");
	if nFlag ~= 1 then
		me.Msg("Bản đồ này cấm sử dụng Càn Khôn Phù");
		return 0;
	end
	local tbTeamMemberList = KTeam.GetTeamMemberList(me.nTeamId);
	if tbTeamMemberList == nil then
		return 0;
	end
	local tbFind = {};
	for i = 1, #self.tbQianKunFuSet do
		local tbTempFind = me.FindItemInBags(unpack(self.tbQianKunFuSet[i]));
		Lib:MergeTable(tbFind, tbTempFind);
	end
	if not tbFind or #tbFind <= 0 then
		local szMsg = "Tính năng \"Chuyển\" có thể truyền tống ngươi đến cạnh đồng đội một cách nhanh chóng. Một <color=yellow>Càn Khôn Phù<color> sẽ có <color=yellow>10 lần<color> cơ hội truyền tống. Sử dụng tính năng này, trong túi cần có Càn Khôn Phù.";
		local tbOpt =
		{
			{"<color=yellow>Tốn 200 Đồng mua 1 {Càn Khôn Phù}<color>", self.ApplyBuyQiankunfu, self},
			{"Tạm thời chưa mua"},	
		};
		Dialog:Say(szMsg, tbOpt);
	end
	local nItemId = tbFind[1].pItem.dwId;
	local nRemainTimes = Item.tbQianKunFu.tbItemList[tbFind[1].pItem.nParticular] - tbFind[1].pItem.GetGenInfo(1,0);
	for _, tbTemp in pairs(tbFind) do 
		local nTempRemainTime = Item.tbQianKunFu.tbItemList[tbTemp.pItem.nParticular] - tbTemp.pItem.GetGenInfo(1,0);
		if nTempRemainTime < nRemainTimes then
			nItemId = tbTemp.pItem.dwId;
			nRemainTimes = nTempRemainTime;
		end
	end
	local nPlayerId = me.nId;
	local nFlag = 0;
	local nOnline = 0;
	local szMemberName = "";
	for _, nMemPlayerId in pairs(tbTeamMemberList) do
		if nMemPlayerId ~= nPlayerId and nMemPlayerId == nTargerPlayerID then
			szMemberName = KGCPlayer.GetPlayerName(nMemPlayerId);
			nOnline = KGCPlayer.OptGetTask(nMemPlayerId, KGCPlayer.TSK_ONLINESERVER);
			nFlag = 1;
			break;
		end
	end
	if nFlag == 1 then
		if nOnline <= 0 then
			Dialog:Say("Đồng đội này đã offline, không thể đến.");
			return;
		end
		if nSure == 1 then
			self:SelectMember(nTargerPlayerID, nPlayerId, nOnline, nItemId);
		else
			local szMsg = string.format("Đồng ý truyền tống đến cạnh đồng đội [%s] chứ?", szMemberName);
			local tbOpt =
			{
				{"Đồng ý", self.OnClientCall, self, nTargerPlayerID, 1},
				{"Ta muốn suy nghĩ lại"},	
			};
			Dialog:Say(szMsg, tbOpt);
		end
	else
		Dialog:Say("Đồng đội này không có, hoặc đã rời khỏi đội!");
	end
end

function tbItem:ApplyBuyQiankunfu()
	if (me.IsAccountLock() ~= 0) then
		me.Msg("Tài khoản đang bị khóa, không thể thao tác!");
		Account:OpenLockWindow(me);
		return 0 ;
	end
	if me.CountFreeBagCell() < 1 then
		me.Msg("Túi đã đầy, cần 1 ô trống!");
		return 0;
	end
	if me.nCoin < 200 then
		me.Msg("Số lượng Đồng không đủ");
		return 0;
	end
	me.ApplyAutoBuyAndUse(22, 1, 0);
	Dbg:WriteLog("Player", me.szName, "ApplyBuyQiankunfu", 22);
end