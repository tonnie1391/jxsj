--充值送江湖威望令牌
--孙多良
--当月充值玩家，根据充值额度可在npc礼官处有一次机会领取江湖威望令牌；
--充值15元以上48元以下可领取1个绑定的江湖威望令牌，充值48元以上可领取3个绑定的江湖威望令牌。

SpecialEvent.ChongZhiRepute = {};
local tbChongZhi = SpecialEvent.ChongZhiRepute;
tbChongZhi.TSK_GROUP = 2027;
tbChongZhi.TSK_DATE	 = 52;
tbChongZhi.TSK_COUNT = 53;
tbChongZhi.DEF_COUNT_MAX = {1,3};

tbChongZhi.DEF_WEEK_REPUTE = {10,30};
tbChongZhi.TSK_WEEK 		= 54;
tbChongZhi.TSK_REPUTE_SUM 	= 55;


function tbChongZhi:Check2()
	local nExt = me.GetExtMonthPay();
	if nExt < IVER_g_nPayLevel1 then
		return -1, 0;
	end	
	local nCurWeek = tonumber(GetLocalDate("%Y%W"));
	if nCurWeek > me.GetTask(self.TSK_GROUP, self.TSK_WEEK) then
		me.SetTask(self.TSK_GROUP, self.TSK_WEEK, nCurWeek);
		me.SetTask(self.TSK_GROUP, self.TSK_REPUTE_SUM, 0);		
	end
	local nMaxSum = 0;
	local nSum	= me.GetTask(self.TSK_GROUP, self.TSK_REPUTE_SUM);	
	if  nExt >= IVER_g_nPayLevel1 and nExt < IVER_g_nPayLevel2 then
		nMaxSum = self.DEF_WEEK_REPUTE[1];
	elseif nExt >= IVER_g_nPayLevel2 then
		nMaxSum = self.DEF_WEEK_REPUTE[2];
	end
	local nNum = nMaxSum - nSum;
	if nNum < 0 then
		nNum = 0;
	end
	return 	nNum, nSum;
end

function tbChongZhi:CheckIsSetExt()
	return me.GetActiveValue(3);
end

function tbChongZhi:CheckISCanGetRepute()
	if (IVER_g_nSdoVersion == 1) then
		return 1;
	end
	local nDate = me.GetTask(Player.TSK_PAYACTION_GROUP, Player.TSK_PAYACTION_EXT_ID[3]);
	local nCurDate = tonumber(GetLocalDate("%Y%m"));
	if nDate == nCurDate then
		return 1;
	end
	return 0;
end

function tbChongZhi:SetJiHuoPerMonth()
	me.SetActiveValue(3,1);
	local nCurDate = tonumber(GetLocalDate("%Y%m"));
	me.SetTask(Player.TSK_PAYACTION_GROUP, Player.TSK_PAYACTION_EXT_ID[3], nCurDate);
	Dbg:WriteLog("SpecialEvent.ChongZhiRepute", "Nhan Uy Danh", me.szName, "Kich hoat thanh cong", nCurDate);
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("Kich hoat thanh cong: %s", nCurDate));
end

function tbChongZhi:OnDialog()
	local szExMsg = "";
	local tbOpt = {
		{"Nhận uy danh", self.GetRepute, self},
		{"Để ta suy nghĩ thêm"},
	};
	if (IVER_g_nSdoVersion == 0) then
		szExMsg = string.format("<color=yellow>Chỉ một nhân vật trong tài khoản có thể kích hoạt mỗi tháng 1 lần<color>");
		table.insert(tbOpt, 1, {"Kích hoạt nhân vật này", self.OnJiHuoGetRepute, self});
	end
	local szMsg = string.format("等级达到60级的玩家%s可享受如下福利：\n\n每月%s<color=yellow>满%s<color>每周送<color=yellow>10点江湖威望<color>；\n\n%s<color=yellow>满%s<color>每周送<color=yellow>30点江湖威望<color>。\n\n%s", IVER_g_szPayName, IVER_g_szPayName, IVER_g_szPayLevel1, IVER_g_szPayName, IVER_g_szPayLevel2, szExMsg);


	Dialog:Say(szMsg, tbOpt);	
end

function tbChongZhi:OnJiHuoGetRepute(nFlag)
	if self:CheckISCanGetRepute() == 1 then
		Dialog:Say("Nhân vật hiện tại đã kích hoạt thành công tư cách nhận Uy danh giang hồ", {{"Quay lại", self.OnDialog, self},{"Kết thúc đối thoại"}});
		return 0;
	end
	
	if self:CheckIsSetExt() == 1 then
		Dialog:Say("Một nhân vật khác trong tài khoản đã kích hoạt thành công tư cách nhận Uy danh giang hồ.", {{"Quay lại", self.OnDialog, self},{"Kết thúc đối thoại"}});
		return 0;
	end

	if not nFlag then
		local szMsg = "Mỗi tháng, tài khoản sẽ chọn 1 nhân vật để kích hoạt nhận Uy danh.\n\nBạn có muốn kích hoạt nhân vật này không? Sau khi kích hoạt, bạn sẽ không thể thay đổi cho nhân vật khác.<color=red>Bạn chắc chắn chứ?<color>";
		local tbOpt = {
			{"Chắc chắn kích hoạt", self.OnJiHuoGetRepute, self, 1},
			{"Để ta nghĩ thêm"},
			};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	self:SetJiHuoPerMonth();
	Dialog:Say("Nhân vật của bạn đã kích hoạt thành công tư cách nhận Uy danh giang hồ.", {{"Quay lại", self.OnDialog, self},{"Kết thúc đối thoại"}});
end

function tbChongZhi:GetRepute()
	--local nResult, nCount = self:Check();
	if self:CheckISCanGetRepute() == 0 then
		Dialog:Say("Nhân vật chưa kích hoạt tư cách nhận Uy danh tháng này", {{"Quay lại", self.OnDialog, self},{"Kết thúc đối thoại"}});
		return 0;
	end
	
	local nResultRepute, nSumRepute = self:Check2();
	
	if me.nLevel < 60 then
		Dialog:Say("Nhân vật chưa đạt cấp độ 60");
		return 0;
	end	
	
	if nResultRepute < 0 then
		local szMsg = string.format("本月%s达到%s才可以领取江湖威望哦, xin chào!像并没有充这么多。", IVER_g_szPayName, IVER_g_szPayLevel1);
		Dialog:Say(szMsg, {{"Quay lại", self.OnDialog, self},{"Kết thúc đối thoại"}});
		return 0;
	end
	
	if nResultRepute == 0 then
		Dialog:Say(string.format("按你的%s额度，您本周已经领取了%s点江湖威望了。", IVER_g_szPayName, nSumRepute), {{"Quay lại", self.OnDialog, self},{"Kết thúc đối thoại"}});
		return 0;		
	end
	local nOrgRepute = me.nPrestige;
	me.SetTask(self.TSK_GROUP, self.TSK_REPUTE_SUM, me.GetTask(self.TSK_GROUP, self.TSK_REPUTE_SUM) + nResultRepute);
	me.AddKinReputeEntry(nResultRepute);
	Dbg:WriteLog("SpecialEvent.ChongZhiRepute", "Nhan Uy Danh", me.szName, "Da nhan uy danh:", nResultRepute);
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("Nhan phuc loi，[%s] Uy danh: %s thay doi thanh %s", me.szName, nOrgRepute, nOrgRepute + nResultRepute));	
	Dialog:Say(string.format("Nhận Uy danh giang hồ thành công!", nResultRepute), {{"Quay lại", self.OnDialog, self},{"Kết thúc đối thoại"}});
end
