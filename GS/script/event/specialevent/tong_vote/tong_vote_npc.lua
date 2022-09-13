-- 文件名　：tong_vote_npc.lua
-- 创建者　：zounan
-- 创建时间：2010-04-01 15:37:34
-- 描  述  ：
Require("\\script\\event\\specialevent\\tong_vote\\tong_vote_def.lua");
local tbTong = SpecialEvent.Tong_Vote;
tbTong.tbDialogNpc =  tbTong.tbDialogNpc or {};
local tbNpc = tbTong.tbDialogNpc or {};
tbNpc.LEVEL_LIMIT = 60;

function tbNpc:OnDialog()	
	
	if tbTong:IsOpen() ~= 1 then
		Dialog:Say("你好，不在活动期。");
		return 0;			
	end
	if me.nLevel < tbTong.LEVEL_LIMIT then
		Dialog:Say("您的等级不够，还是60级以后再来吧。");
		return 0;
	end
	
	local szMsg = "帮会投票";
	local tbOpt = {
			{"我是来给帮会投票的", self.VoteTickets, self},
			{"查询帮会票数", self.QueryIntPutName, self},
	--		{"领取美女评选奖励", self.GetAward, self},
	--		{"了解详细信息", self.GetDetailInfo, self},
			{"Ta chỉ xem qua Xóa bỏ"},
		};
	Dialog:Say(szMsg, tbOpt);
end


function tbNpc:VoteTickets()
	Dialog:AskString("请输入帮会名", 16, tbTong.VoteTickets, tbTong);	
end


function tbNpc:QueryIntPutName()
	Dialog:AskString("请输入帮会名", 16, self.QueryByName, self);	
end

function tbNpc:QueryByName(szName)	
	local tbBuf = tbTong:GetGblBuf();
	if not tbBuf[szName] then
		Dialog:Say("没有该帮会信息");
		return 0;
	end
	
	local nTickets = tbBuf[szName].nTickets or 0;
	local szTickets = string.format("目前<color=yellow>%s<color>的票数为：<color=white>%s<color>",szName, nTickets);
	Dialog:Say(szTickets);
	return;
end
