-- 白虎堂报名NPC
local tbNpc = Npc:GetClass("baihutangbaoming");
tbNpc.tbRVPos	= {};
--tbNpc.MAX_NUMBER = 100;
tbNpc.HIGHLEVEL  = 90;
tbNpc.tbTimeKey = {};

function tbNpc:Init()
	self.tbTimeKey[7]  = 8;		self.tbTimeKey[18] = 21;
	self.tbTimeKey[19] = 21;	self.tbTimeKey[20] = 21;
end

function tbNpc:OnDialog(szParam)
	local tbOpt = {};	
	local szMsg = "";
	local nTime = self:GetTime();
	local nOtherTimes = me.GetTask(BaiHuTang.TSKG_PVP_ACT, BaiHuTang.TSK_BaiHuTang_PKTIMES_Ex) or 0;
	
	if (self:CheckClose() == 1) then
		return;
	end
	if (BaiHuTang.nActionState == BaiHuTang.FIGHTSTATE) then
		if (EventManager.IVER_bOpenTiFu == 1) then
			local nMinute = tonumber(GetLocalDate("%M"));
			if (nMinute > 40) then
				szMsg = string.format("Hoạt động Bạch Hổ Đường chưa mở, thời gian bắt đầu báo danh trận sau là %d:00, hãy quay lại sau.", nTime);
			else
				nMinute = 40 - nMinute;
				szMsg = string.format("Bây giờ một đoàn dũng sĩ đã tiến vào Bạch Hổ Đường, cổng đường đã đóng, %d phút sau hãy quay lại", nMinute);
			end
		else
			local nMinute = 30 - tonumber(GetLocalDate("%M"));
			if (nMinute < 0) then
				--local nTime = self:GetTime();
				szMsg = string.format("Hoạt động Bạch Hổ Đường chưa mở, thời gian bắt đầu báo danh trận sau là %d: 30, hãy quay lại sau.", nTime);
			else
				szMsg = string.format("Bây giờ một đoàn dũng sĩ đã tiến vào Bạch Hổ Đường, cổng đường đã đóng, %d phút sau hãy quay lại", nMinute);
			end
		end

		tbOpt[1] = {"Kết thúc đối thoại"};
	elseif (BaiHuTang.nActionState == BaiHuTang.RESTSTATE) then
		if (EventManager.IVER_bOpenTiFu == 1) then
			szMsg = string.format("Hoạt động Bạch Hổ Đường chưa mở, thời gian bắt đầu báo danh trận sau là %d:00, hãy quay lại sau.", nTime);
		else
			szMsg = string.format("Hoạt động Bạch Hổ Đường chưa mở, thời gian bắt đầu báo danh trận sau là %d: 30, hãy quay lại sau.", nTime);
		end
		tbOpt[1] = {"Kết thúc đối thoại"};
	else
		
		local tbMap = self:GetMapList();
		if (not tbMap or #tbMap <= 0 )then
			return;
		end
		
		local tbMapInfo = {};
		if (szParam == "dong") then
			tbMapInfo.nMapId = tbMap[1][1];
			tbMapInfo.szName =  "Đông Bạch Hổ Đường";
		elseif (szParam == "nan") then
			tbMapInfo.nMapId = tbMap[1][2];
			tbMapInfo.szName =  "Nam Bạch Hổ Đường";
		elseif (szParam == "xi") then
			tbMapInfo.nMapId = tbMap[1][3];
			tbMapInfo.szName =  "Tây Bạch Hổ Đường";
		elseif (szParam == "bei") then	
			tbMapInfo.nMapId = tbMap[1][4];
			tbMapInfo.szName =  "Bắc Bạch Hổ Đường";
		end
		local nRet = MathRandom(#BaiHuTang.tbPKPos);
		tbMapInfo.tbSect = BaiHuTang.tbPKPos[nRet];
		tbOpt[1]	= {"Đúng vậy, ta muốn tham gia!", self.JoinAction, self, tbMapInfo};
		tbOpt[2]	= {"[Quy tắc hoạt động]", self.Rule, self, szParam};
		tbOpt[4]	= {"Nguy hiểm lắm, ta không tham gia đâu."};
		szMsg = string.format("Gần đây trong Bạch Hổ Đường có khá nhiều đạo tặc, nay cần người để tiêu diệt chúng, phải vượt Bạch Hổ Đường 3 mới có thể thoát ra, nhưng 30 phút sau thấy không chút động tĩnh thì ta sẽ vào cứu ngươi! Bạch Hổ Đường mỗi ngày được tham gia <color=yellow>%s<color> lần, còn có thêm <color=yellow>%s<color> lần tham gia đấy", BaiHuTang.MAX_ONDDAY_PKTIMES, nOtherTimes);
	end
	Dialog:Say(szMsg, tbOpt);
end


-- 99级开放的时候，初级01:30之后就关闭
function tbNpc:CheckClose()
	
	if (TimeFrame:GetStateGS("OpenLevel99") == 0) then
		return 0;
	end
	
	local nNowHour = tonumber(GetLocalDate("%H"));
	if (nNowHour >= 1 and nNowHour <= 7) then
		if (me.nLevel < self.HIGHLEVEL) then
			Dialog:Say("Bây giờ trễ rồi, ngươi đi nghỉ sớm đi!", 
				{
					{"Kết thúc đối thoại"}
				});
			return 1;
		end
	end
	return 0;
end

--规则显示
function tbNpc:Rule(szParam)
	local tbOpt = {};
	tbOpt[1] = {"Trở về đối thoại trước đó", self.OnDialog, self, szParam};
	tbOpt[2] =  {"Kết thúc đối thoại"};
	local szMsg = string.format("Thời gian báo danh <color=green>30<color> phút, thời gian hoạt động <color=green>30<color> phút. Sau khi hoạt động bắt đầu, trong Bạch Hổ Đường sẽ xuất hiện rất nhiều <color=red>Sấm Đường Tặc<color>, đánh bại chúng sẽ nhặt được vật phẩm và kinh nghiệm, sau một thời gian nhất định sẽ xuất hiện <color=red>Thủ Lĩnh Sấm Đường Tặc<color>, " .. 
"Đánh bại <color=red>Thủ Lĩnh Sấm Đường Tặc<color> sẽ xuất hiện lối vào tầng 2, Bạch Hổ Đường có 3 tầng, nếu bạn đánh bại thủ lĩnh ở cả 3 tầng thì sẽ mở được lối ra. Lưu ý: Khi vào Bạch Hổ Đường sẽ tự động bật chế độ chiến đấu, nên tốt nhất hãy tham gia hoạt động này cùng với hảo hữu, gia tộc hoặc bang hội. (Mỗi ngày chỉ được tham gia tối đa <color=red>%s lần<color>)\n<color=red>Chú ý: Để vào Bạch Hổ Đường (sơ) phải gia nhập gia tộc<color>", BaiHuTang.MAX_ONDDAY_PKTIMES);
	Dialog:Say(szMsg, tbOpt);
end

--获取当前的小时数
function tbNpc:GetTime()
	local nNowHour = tonumber(GetLocalDate("%H"));
	local nNowMinute = tonumber(GetLocalDate("%M"));
	
	local nHour = nNowHour;
	
	if (EventManager.IVER_bOpenTiFu == 1) then
		nHour = nHour + 1;
	else
		if (nNowHour == 7) then
			nHour = 8;
		elseif (nNowHour == 18 or nNowHour == 19 or nNowHour == 20) then
			nHour = 21;
		elseif (nNowHour == 6) then
			if (nNowMinute >= 30) then
				nHour = 8;
			end
		elseif (nNowHour == 17) then
			if (nNowMinute >= 30) then
				nHour = 21;
			end
		else
			if (nNowMinute >= 30) then
				nHour = nHour + 1;
			end
		end
	end
	
	if (nHour == 24) then
		nHour = 0;
	end
	
	return nHour;
end
--参加PK
function tbNpc:JoinAction(tbMapInfo)
	if me.GetTiredDegree1() == 2 then
		Dialog:Say("Bạn đã quá mệt, hãy nghỉ ngơi!");
		return;
	end
	if (BaiHuTang.nActionState == BaiHuTang.FIGHTSTATE) then
		me.Msg("Hoạt động Bạch Hổ Đường đã bắt đầu, không thể báo danh được nữa.");
		return;
	end
	
	--死亡就不给进 zounan
	local nDead = me.IsDead() or 1;
	if nDead == 1 then
		return;
	end
	
	local nTimes = me.GetTask(BaiHuTang.TSKG_PVP_ACT, BaiHuTang.TSK_BaiHuTang_PKTIMES) or 0;
	local nOtherTimes = me.GetTask(BaiHuTang.TSKG_PVP_ACT, BaiHuTang.TSK_BaiHuTang_PKTIMES_Ex) or 0;
	local szNowDate =  GetLocalDate("%y%m%d");
	local nDate = math.floor(nTimes / 10);
	local nPKTimes = nTimes % 10;
	local nNowDate = tonumber(szNowDate);
	if (nDate == nNowDate) then
		if (nPKTimes >= BaiHuTang.MAX_ONDDAY_PKTIMES) then
			local nTime = tonumber(GetLocalDate("%H%M"));
			-- 当天23：30分钟前已经参加过了三次
			if nOtherTimes <= 0 then
				if (nTime < 2330) then
					me.Msg(string.format("Hoạt động này một ngày chỉ được tham gia %s lần, mai hãy đến.", BaiHuTang.MAX_ONDDAY_PKTIMES));
					return;
				else
					me.SetTask(BaiHuTang.TSKG_PVP_ACT, BaiHuTang.TSK_BaiHuTang_PKTIMES, 0);
				end
			end
		end
	else
		me.SetTask(BaiHuTang.TSKG_PVP_ACT, BaiHuTang.TSK_BaiHuTang_PKTIMES, 0);
	end
	--local nTotal  = BaiHuTang.tbNumber[tbMapInfo.nMapId];
	--if (nTotal and nTotal >= tbNpc.MAX_NUMBER) then
	--	me.Msg("这个地图人数已经超过了上限，请换个报名点吧！");
	--	return;
	--end
	self:OnTrans(tbMapInfo);	
end
--传送玩家到指定地图
function tbNpc:OnTrans(tbMapInfo)
	local tbSect	= tbMapInfo.tbSect;
	local nMapId = tbMapInfo.nMapId
	BaiHuTang:JoinGame(me.nMapId, me, nMapId, tbSect.nX / 32, tbSect.nY / 32);
end

function tbNpc:GetMapList()
	local tbMap = {};
	if (me.nMapId == 821) then
		tbMap = BaiHuTang.tbBatte[BaiHuTang.Goldlen].MapId;
	elseif (me.nLevel >= 90) then
		tbMap = BaiHuTang.tbBatte[BaiHuTang.GaoJi].MapId;
	elseif (me.nMapId == 225) then
		tbMap = BaiHuTang.tbBatte[BaiHuTang.ChuJi].MapId;
	elseif (me.nMapId == BaiHuTang.ChuJi2) then
		-- 第二场初级的
		if (TimeFrame:GetStateGS("CloseBaiHuTangChu2") == 0 ) then
			tbMap = {{275, 276, 277, 278}};
		else
			tbMap = nil;
		end
	end	
	return tbMap;
end
tbNpc:Init();
