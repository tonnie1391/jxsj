-- 文件名　：girl_daily.lua
-- 创建者　：jiazhenwei
-- 创建时间：2012-04-18 14:16:22
-- 功能    ：美女认证日常功能

SpecialEvent.Girl_Vote = SpecialEvent.Girl_Vote or {};
local tbGirl = SpecialEvent.Girl_Vote;
tbGirl.SZ_UPLOAD_PHOTO_URL = "http://zt.xoyo.com/jxsj/girlchoice/index.php";

function tbGirl:IsDailyOpen()
	local nDay = TimeFrame:GetServerOpenDay();
	if nDay >=self.nOpenTime and nDay <= self.nEndTime then
		return 1;
	elseif nDay < self.nOpenTime then
		return 0, "活动还没有开启。";
	elseif nDay > self.nEndTime then
		return 2, "免费活动已经截止。";
	end
end

if (MODULE_GAMESERVER) then

--日常功能上线事件
--16天-29天之间第一次上线的女玩家提示+邮件去临安参加活动
--报名24小时后上线提示+邮件去官网上传资料
--获得美女认证的玩家上线加认证标志
function tbGirl:OnLogin_Daily()
	if me.nSex ~= Env.SEX_FEMALE then
		return 0;
	end
	local nLastTime = me.GetTask(self.TSK_GROUP, self.TSK_Renzheng_Buff);
	--有上次buff的不做其他处理
	if nLastTime > 0 and self.nGirlLogoTime + nLastTime > GetTime() then
		return 0;
	end
	local nRet,szRetMsg = self:IsDailyOpen();
	local nAttendTime = me.GetTask(self.TSK_GROUP, self.TSK_AttendTime);
	local bMail = me.GetTask(self.TSK_GROUP, self.TSK_Mail);
	local nLogoIndex = me.GetTask(self.TSK_GROUP, self.TSK_LogoIndex);
	local nLogoTime = me.GetTask(self.TSK_GROUP, self.TSK_nLogoTime);
	--参加了活动没发过填写资料的邮件
	if nAttendTime > 0 and GetTime() - nAttendTime > 24*3600 and bMail ~= 2 then
		local szMsg = string.format("恭喜！您的报名请求已成功上传到官网，请尽快到官网完善个人资料，即可获得最终认证。<enter>唯美光环、限量面具、V字标识等美女专享特权，尽在剑侠世界美女认证。<enter><link=url:美女认证官网,前往官网上传资料,%s>", self.SZ_UPLOAD_PHOTO_URL);
		KPlayer.SendMail(me.szName, "美女认证报名成功",szMsg);
		me.SetTask(self.TSK_GROUP, self.TSK_Mail, 2);
	end
	--活动开启提示玩家去临安参加活动
	if nRet >= 1 and bMail == 0 then
		local szMsg = string.format("武林美女认证，让你携手佳人，共闯最真实的剑侠世界。<enter><enter><color=green>活动接引人：<color><link=npcpos:丁丁,29,3655><enter><color=green>参加条件：<color>所有女性玩家都可报名<enter><color=green>活动奖励：<color>唯美光环、限量面具、美女专享V字认证等。<enter><link=url:美女认证专题,前往官网了解活动详情,%s>", self.SZ_UPLOAD_PHOTO_URL);
		KPlayer.SendMail(me.szName, "美女认证正式开启",szMsg);
		me.SetTask(self.TSK_GROUP, self.TSK_Mail, 1);
	end
	local tbInfoLogo = self.tbInfoLogo[nLogoIndex];
	if not tbInfoLogo then
		return;
	end
	if nLogoTime > 0  and nLogoTime + tbInfoLogo[2] > GetTime() then
		me.SetNpcSpeTitleImage(tbInfoLogo[1], nLogoTime + tbInfoLogo[2]);	--设置美女认证图标
	end
end

function tbGirl:OnDialog_Daily()
	local szMsg = "武林美女认证，让你携手佳人，共闯最真实的剑侠世界。<enter><enter><color=green>参加条件：<color>所有女性玩家都可报名<enter><color=green>活动奖励：<color>唯美光环、限量面具、美女专享V字认证等。 ";
	local tbOpt = {
		{"<color=pink>我要参加<color>  ", self.AttendDailyEvent, self},
		{"上传照片", self.UpPic,self},
		--{"活动详情", self.Help,self},
		{"我再想想"}};
	local nRet,szRetMsg = self:IsDailyOpen();
	if nRet == 1 then
		table.insert(tbOpt, 2, {"领取海洋之心碎片", self.GetFreeItem, self});
	end
	Dialog:Say(szMsg, tbOpt);
end

function tbGirl:Help()
	me.CallClientScript({"OpenWebSite", self.SZ_UPLOAD_PHOTO_URL});
end

function tbGirl:UpPic()
	me.CallClientScript({"OpenWebSite", self.SZ_UPLOAD_PHOTO_URL});
end

function tbGirl:GetFreeItem()
	if me.nSex ~= Env.SEX_FEMALE then
		Dialog:Say("只有女性角色才可以了领取该道具。");
		return 0;
	end
	if me.GetTask(self.TSK_GROUP, self.TSK_GetFreeItem) >= 1 then
		Dialog:Say("每个角色只能获取一次免费道具机会。");
		return;
	end
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("背包空间不足，需要1格背包空间！");
		return;
	end	
	local pItem = me.AddItem(18,1,1708,1);
	if pItem then
		pItem.Bind(1);
		me.SetTask(self.TSK_GROUP, self.TSK_GetFreeItem, 1);
	end
end 

function tbGirl:AttendDailyEvent(nType, bOk)
	if not nType then
		--默认为“v”字标志
		if Lib:CountTB(self.tbInfoLogo) <= 1 then
			self:AttendDailyEvent(1);
			return;
		end
		local tbOpt = {{"我再想想"}};
		for i, tbInfo in ipairs(self.tbInfoLogo) do
			table.insert(tbOpt, 1, {tbInfo[4], self.AttendDailyEvent, self, i});
		end
		Dialog:Say("请选择您要获得的美女标识类型。", tbOpt);
		return;
	end
	local nAttendTime = me.GetTask(self.TSK_GROUP, self.TSK_AttendTime);
	local nLogoIndex = me.GetTask(self.TSK_GROUP, self.TSK_LogoIndex);
	local nLogoTime = me.GetTask(self.TSK_GROUP, self.TSK_nLogoTime);
	local tbInfoLogo = self.tbInfoLogo[nType];
	local nLastTime = me.GetTask(self.TSK_GROUP, self.TSK_Renzheng_Buff);
	if nAttendTime < 0 then
		Dialog:Say("由于您的违规操作，您的美女认证资格已经被取消。", {{"那就去网站看看美女吧 ", self.UpPic,self},{"结束对话"}});
		return 0;
	end
	if me.nSex ~= Env.SEX_FEMALE then
		Dialog:Say("只有美女才可以参加认证，你这小子，是想糊弄本姑娘吗？", {{"那就去网站看看美女吧 ", self.UpPic,self},{"结束对话"}});
		return 0;
	end
	if nLastTime > 0 and self.nGirlLogoTime + nLastTime > GetTime() then
		Dialog:Say("您已经有第二届美女认证标志，待标志过期后才能参加此活动。");
		return;
	end
	if nAttendTime > 0 then
		Dialog:Say("恭喜你，已成功报名！<enter>您的资料正在上传，请于报名<color=green>24小时后前往官网<color>补填资料、上传个人照片方可获得最终认证。", {{"去官网看看 ", self.UpPic,self},{"结束对话"}});
		return 0;
	end
	if (nLogoIndex > 0 and nLogoTime + self.tbInfoLogo[nLogoIndex][2] > GetTime()) then
		Dialog:Say("你已经是认证的美女了，还是把机会让给其他MM吧。\n<color=red>注：认证过期后可重新报名。<color>");
		return;
	end
	local tbFind = me.FindItemInBags(unpack(tbInfoLogo[3]));
	if #tbFind <= 0 then
		Dialog:Say("您的包裹内没有[海洋之心碎片]，无法进行美女认证。<enter><color=yellow>是否要花费2999金币购买一个[海洋之心碎片]<color>？", {{"购买碎片",self.BuyItem, self},{"我再看看"}});
		return;
	end
	if #tbFind > 1 then
		Dialog:Say("你背包好像有很多[海洋之心碎片]，请携带单个海洋之心碎片再来报名。");
		return;
	end
	if not bOk then
		Dialog:Say("您确认报名参加美女认证活动，将扣除您身上的<color=yellow>海洋之心碎片<color>？", {{"是的，我要参加",self.AttendDailyEvent, self, nType, 1},{"我再想想"}});
		return;
	end
	local pItem = tbFind[1].pItem;
	local bIbItem = pItem.IsIbItem();
	if me.ConsumeItemInBags2(1, unpack(tbInfoLogo[3])) == 0 then
		me.SetTask(self.TSK_GROUP, self.TSK_AttendTime, GetTime());
		GCExcute({"SpecialEvent.Girl_Vote:AddBuff_Daily", me.szName, me.szAccount, nType, GetTime(), bIbItem});
		me.Msg("恭喜您成功报名美女认证活动，请您24小时后去官网上传资料，资料通过审核后将会获得精美美女标志和奖励。");
		local szMsgWorld = "报名参加了<color=yellow>“美女认证”<color>活动，唯美光环、限量面具、美女专享V字认证等着她，大家快去临安丁丁处看看吧！"
		Player:SendMsgToKinOrTong(me, szMsgWorld, 1);
		szMsgWorld = string.format("您的好友<color=yellow>%s<color>", me.szName) ..szMsgWorld;
		me.SendMsgToFriend(szMsgWorld);
		Dialog:SendBlackBoardMsg(me, "恭喜您成功报名美女认证活动，请您24小时后去官网上传资料");
	end
end

function tbGirl:BuyItem()
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("您的背包空间不足，需要1格背包空间。");
		return 0;
	end
	if me.GetJbCoin() < 2999 then
		Dialog:Say("您的金币不足，购买1个<color=yellow>海洋之心碎片<color>需要2999金币。");
		return 0;
	end
	me.ApplyAutoBuyAndUse(611, 1, 0);
end

PlayerEvent:RegisterGlobal("OnLogin", SpecialEvent.Girl_Vote.OnLogin_Daily, SpecialEvent.Girl_Vote);
end

-------------------------------------------------------------------------------------------------------------------------
if (MODULE_GC_SERVER) then

function tbGirl:AddBuff_Daily(szName, szAccount, nType, nTime, IsIbItem)
	local tbBuff = self:GetBuff_Daily();
	tbBuff[szName] = {szAccount, nType, nTime, IsIbItem};
end

function tbGirl:WriteFile_Daily()
	local tbBuff = self:GetBuff_Daily();
	local szGateWay = GetGatewayName();
	local szOutFile = "\\girldailyevent\\"..szGateWay.."_girldailyevent.txt";
	local szContext = "GateWay\tName\tAccount\tType\tTime\tIsIbItem\n";
	KFile.WriteFile(szOutFile, szContext);
	for szName, tbInfo in pairs(tbBuff) do
		local szOut = string.format("%s\t%s\t%s\t%s\t%s\t%s\n", 
			szGateWay, 
			szName, 
			tbInfo[1], 
			tbInfo[2],
			os.date("%Y-%m-%d %H:%M:%S", tbInfo[3]),
			tbInfo[4]);
		KFile.AppendFile(szOutFile, szOut);
	end
	--每次写完之后把buff删掉
	self.tbBuff_Daily = {};
	SetGblIntBuf(GBLINTBUF_GIRL_DAILY, 0, 0, {});
end

function tbGirl:GetBuff_Daily()
	if not self.tbBuff_Daily then
		self.tbBuff_Daily = GetGblIntBuf(GBLINTBUF_GIRL_DAILY, 0) or {};
	end
	return self.tbBuff_Daily;
end

function tbGirl:SaveBuff_Daily()
	local tbBuff = self:GetBuff_Daily();
	SetGblIntBuf(GBLINTBUF_GIRL_DAILY, 0, 0, tbBuff);
end

function tbGirl:CoZoneUpdateGirlDailyBuf(tbSubBuf)
	self.tbBuff_Daily = GetGblIntBuf(GBLINTBUF_GIRL_DAILY, 0) or {};
	for szName, tbInfo in pairs(tbSubBuf) do
		self.tbBuff_Daily[szName] = tbInfo;
	end
	SetGblIntBuf(GBLINTBUF_GIRL_DAILY, 0, 0, self.tbBuff_Daily);
end

GCEvent:RegisterGCServerShutDownFunc(SpecialEvent.Girl_Vote.SaveBuff_Daily, SpecialEvent.Girl_Vote);

end