-- 文件名　：vipreturn_6m.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-07-02 10:24:20
-- 描  述  ：

SpecialEvent.VipReturn_6M = SpecialEvent.VipReturn_6M or {};
local tbVip = SpecialEvent.VipReturn_6M;

tbVip.nCreateDate = 20091215;
tbVip.nStart 		= 20120110;
tbVip.nEnd 		= 20120131;
tbVip.nTsk_Group	= 2083;
tbVip.nTsk_Id1	= 7;	--激活变量
tbVip.nTsk_Id2	= 8;	--领取称号光环
tbVip.nTsk_Id3	= 9;	--领取面具
tbVip.nTsk_Id4	= 10;	--领取同伴
tbVip.nTsk_batch= 11;   --批次
tbVip.tbLevel = 
{
	[1] = "银卡",
	[2] = "金卡",
	[3] = "钻石卡",
}

--称号
tbVip.tbHalo = 
{
	[1] = {5,14,1,9},
	[2] = {5,15,1,9},
	[3] = {5,16,1,9},
}

tbVip.tbMask =
{
	[1] = {1,13,33,1},
	[2] = {1,13,34,1},
}

tbVip.tbHorse = {{1,12,42,4}, {1,12,59,4}};
tbVip.tbSignet = {1,16,13,2};

tbVip.tbPartner = {18,1,666,11};

tbVip.tbYoulongItem = {18, 1, 553, 1, nil, 1800};

tbVip.nBatchNum = 3;		--当前批次
tbVip.nLevelLimit = 69;


function tbVip:GetTypeLevel()
	return self.tbVip[string.upper(me.szAccount)] or 0;
end

function tbVip:Check()
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	if nCurDate < self.nStart or nCurDate > self.nEnd then
		return 0;
	end
	if not self.tbVip then
		return 0;
	end
	local nLevel = self:GetTypeLevel();
	if nLevel == 0 then
		return 0;
	end

	--if tonumber(me.GetRoleCreateDate()) >= self.nCreateDate and VipPlayer.VipTransfer:CheckQualification(me) == 0 then
	--	return 0;
	--end

	return 1;
end

function tbVip:OnDialog()	
	--清批次
	if me.GetTask(self.nTsk_Group, self.nTsk_batch) ~= self.nBatchNum then
		me.SetTask(self.nTsk_Group, self.nTsk_batch,self.nBatchNum);
		me.SetTask(self.nTsk_Group, self.nTsk_Id1,0);
		me.SetTask(self.nTsk_Group, self.nTsk_Id2,0);
		me.SetTask(self.nTsk_Group, self.nTsk_Id3,0);
		me.SetTask(self.nTsk_Group, self.nTsk_Id4,0);
	end
	
	local nLevel = self:GetTypeLevel();
	if nLevel == 0 then
		return 0;
	end	
	local szMsg = "您好，在2011年度充值达到3000元以上的玩家可以领取特殊称号及光环，达到18000元以上有特殊坐骑，达到50000元以上更有7技能同伴（燕小楼），赶快激活领奖吧！";
	local tbOpt = {};
	if me.GetTask(self.nTsk_Group, self.nTsk_Id1) == 0 then	
		table.insert(tbOpt,	{"<color=yellow>激活领奖资格<color>", self.Activation, self});	
	end
		
	if me.GetTask(self.nTsk_Group, self.nTsk_Id2) == 0 then	
		table.insert(tbOpt,	{"<color=yellow>领取VIP称号光环及游龙古币<color>", self.GetAward1, self, nLevel});	
	end
	
	if nLevel > 1 then
		if me.GetTask(self.nTsk_Group, self.nTsk_Id3) == 0 then
			table.insert(tbOpt,{"<color=yellow>领取特殊坐骑<color>", self.GetAwardMask,self});		
		end
	end
	
	if nLevel > 2 then
		if me.GetTask(self.nTsk_Group, self.nTsk_Id4) == 0 then
			table.insert(tbOpt,{"<color=yellow>领取7技能同伴（燕小楼）<color>", self.GetAwardPartner,self});		
		end
	end	
	table.insert(tbOpt,{"Ta chỉ xem qua"});

	Dialog:Say(szMsg, tbOpt);
end

function tbVip:Activation()
	if me.GetTask(self.nTsk_Group, self.nTsk_Id1) > 0 then
		Dialog:Say("您的角色已经激活了，请领取VIP奖励吧。");
		return 0;
	end
	
	--local nExtBit = me.GetActiveValue(2);
	local nExtBit = Account:GetIntValue(me.szAccount, "VipReturn.ActiveValue");
	if nExtBit == self.nBatchNum then
		Dialog:Say("您的帐号下其他角色已经激活了领取VIP返还奖励。");
		return 0;
	end
	
	if me.nLevel < self.nLevelLimit then
		Dialog:Say(string.format("您的等级未到%s级，不能激活领奖资格！",self.nLevelLimit));
		return 0;
	end	

	local szMsg = "您确定激活当前角色领奖资格么？激活后账号下其他角色就不能激活了。";
	local tbOpt = {
		{"确定激活", self.ActivationEx, self},
		{"Để ta suy nghĩ lại"},
	};
	Dialog:Say(szMsg, tbOpt);
end


function tbVip:ActivationEx()	
	Dialog:SendBlackBoardMsg(me, "恭喜您成功激活当前角色的领奖资格！");
	me.Msg("恭喜您成功激活当前角色的领奖资格！");
	--me.SetActiveValue(2,1);
	Account:ApplySetIntValue(me.szAccount, "VipReturn.ActiveValue", self.nBatchNum);
	me.SetTask(self.nTsk_Group, self.nTsk_Id1, 1);
	EventManager:WriteLog(string.format("VipReturn.ActiveValue—%s", self.nBatchNum), me);
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("[VIP返还]成功激活领取角色"));	
	local tbOpt ={
		{"返回上一层", self.OnDialog,self},
		{"Xác nhận"},
	};
	Dialog:Say("你的角色已成功激活了。",tbOpt);
end

function tbVip:GetAward1(nLevel)
	if me.GetTask(self.nTsk_Group, self.nTsk_Id1) ~= 1 then
		Dialog:Say("当前角色未激活领奖资格，不能领奖！");
		return 0;
	end
	if me.GetTask(self.nTsk_Group, self.nTsk_Id2) > 0 then
		Dialog:Say("您已经领取过该项奖励了，不能再领奖！");
		return 0;		
	end
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("领奖需要1格背包空间，去整理下再来吧！");
		return 0;
	end	
	me.AddTitle(unpack(self.tbHalo[nLevel]));
	me.AddStackItem(unpack(self.tbYoulongItem));
	me.SetCurTitle(unpack(self.tbHalo[nLevel]));
	me.SetTask(self.nTsk_Group, self.nTsk_Id2, 1);
	Dbg:WriteLog("Vip返还", me.szName.."领取称号等级："..tostring(nLevel));
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("[VIP返还]领取称号等级：%s", nLevel));
	Dialog:SendBlackBoardMsg(me, "恭喜您成功领取了称号光环及1800游龙古币奖励！");
	me.Msg("恭喜您成功领取了称号光环及1800游龙古币奖励！");
end

function tbVip:GetAwardMask(nFlag)	
	if me.GetTask(self.nTsk_Group, self.nTsk_Id1) ~= 1 then
		Dialog:Say("当前角色未激活领奖资格，不能领奖！");
		return 0;
	end
	
	if me.GetTask(self.nTsk_Group, self.nTsk_Id3) > 0 then
		Dialog:Say("您已经领取过该项奖励了，不能再领奖！");
		return 0;
	end
	
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("领奖需要1格背包空间，去整理下再来吧！");
		return 0;
	end	
	if not nFlag then
		Dialog:Say("请选择坐骑类型：", {{"追风使者", self.GetAwardMask, self, 1},{"火麒麟", self.GetAwardMask, self, 2},{"Để ta suy nghĩ thêm"}});
		return;
	end
	local pItem = me.AddItem(unpack(self.tbHorse[nFlag]));
	if pItem then
		pItem.Bind(1);
		pItem.SetTimeOut(0, GetTime() + 6*30*24*60*60);
		pItem.Sync();
		me.SetTask(self.nTsk_Group, self.nTsk_Id3, 1);
		Dbg:WriteLog("Vip返还", me.szName.."Nhận"..pItem.szName);
		me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "[VIP返还]领取"..pItem.szName);			
		Dialog:SendBlackBoardMsg(me, "恭喜您获得"..pItem.szName.."！");
		me.Msg("恭喜您获得"..pItem.szName.."！");
	end
	
--	local tbOpt = 
--	{
--		{"男性外观", self.OnGetMask, self, 1},
--		{"女性外观", self.OnGetMask, self, 2},
--		{"再想想（离开）"},
--	};
--	
--	Dialog:Say("本面具有男女两种外观，您想要哪种？", tbOpt);
end

function tbVip:OnGetMask(nType)	
	local pItem = me.AddItem(unpack(self.tbMask[nType]));
	if pItem then
		pItem.Bind(1);
		me.SetItemTimeout(pItem, 30*24*60*3, 0);
		me.SetTask(self.nTsk_Group, self.nTsk_Id3, 1);
		Dbg:WriteLog("Vip返还", me.szName.."领取新年面具");
		me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "[VIP返还]领取新年面具");			
		Dialog:SendBlackBoardMsg(me, "恭喜您获得了新年面具奖励！");
		me.Msg("恭喜您获得了新年面具奖励！");
	end
end



function tbVip:GetAwardPartner()
	if me.GetTask(self.nTsk_Group, self.nTsk_Id1) ~= 1 then
		Dialog:Say("当前角色未激活领奖资格，不能领奖！");
		return 0;
	end
	
	if me.GetTask(self.nTsk_Group, self.nTsk_Id4) > 0 then
		Dialog:Say("您已经领取过该项奖励了，不能再领奖！");
		return 0;
	end
	
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("领奖需要1格背包空间，去整理下再来吧！");
		return 0;
	end	
	
	local pItem = me.AddItem(unpack(self.tbPartner));
	if pItem then
		pItem.Bind(1);
		me.SetTask(self.nTsk_Group, self.nTsk_Id4, 1);
		pItem.SetTimeOut(0, GetTime() + 30*24*60*60);
		pItem.Sync();
		Dbg:WriteLog("Vip返还", me.szName.."领取7技能同伴（燕小楼）");
		me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "[VIP返还]领取7技能同伴（燕小楼）");			
		Dialog:SendBlackBoardMsg(me, "恭喜您获得7技能同伴（燕小楼）！");
		me.Msg("恭喜您获得7技能同伴（燕小楼）！");
		StatLog:WriteStatLog("stat_info", "senior_seal", "award", me.nId, "1");
	end
end


function tbVip:LoadFile()
	self.tbVip = {};	
	local tbFile = Lib:LoadTabFile("\\setting\\event\\vipplayerlist\\jsplayerlist.txt");
	if tbFile then
		for _, tbRole in pairs(tbFile) do
			local szAccount = string.upper(tbRole.ACCOUNT);
			local nMoney 	= tonumber(tbRole.MONEY) or 0;
			nMoney = nMoney * 7;
			if nMoney >= 2500 then				
				if  nMoney < 17500 then
					self.tbVip[szAccount] = 1;	
				elseif nMoney < 49500 then
					self.tbVip[szAccount] = 2;
				else
					self.tbVip[szAccount] = 3;
				end
			end
		end
	end
	
	tbFile = Lib:LoadTabFile("\\setting\\event\\vipplayerlist\\vipplayerlist.txt");
	if not tbFile then
		return 0;
	end
	for _, tbRole in pairs(tbFile) do
		local szAccount = string.upper(tbRole.ACCOUNT);
		local nMoney 	= tonumber(tbRole.MONEY) or 0;
		if nMoney >= 3000 then
			if  nMoney < 18000 then
				self.tbVip[szAccount] = 1;	
			elseif nMoney < 50000 then
				self.tbVip[szAccount] = 2;
			else
				self.tbVip[szAccount] = 3;
			end
		end
	end
end

tbVip:LoadFile();
