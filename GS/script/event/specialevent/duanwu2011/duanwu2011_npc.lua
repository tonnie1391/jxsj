-- 文件名　：define.lua
-- 创建者　：huangxiaoming
-- 创建时间：2011-05-17 09:46:10
-- 描  述  ：

Require("\\script\\event\\specialevent\\duanwu2011\\duanwu2011_def.lua");
SpecialEvent.DuanWu2011 = SpecialEvent.DuanWu2011 or {};
local tbDuanWu2011 = SpecialEvent.DuanWu2011 or {};

local tbDuanWuNpc = Npc:GetClass("npc_duanwu2011");

function tbDuanWuNpc:OnDialog()
	if tbDuanWu2011.IS_OPEN ~= 1 then
		Dialog:Say(me.szName .. ",你好！");
		return 0;
	end
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	if nDate < tbDuanWu2011.OPEN_DAY then
		Dialog:Say(me.szName .. ",你好！");
		return 0;
	end
	local szMsg = me.szName .. "你好！有什么能帮到你的？\n";
	local tbOpt = {};
	if nDate <= tbDuanWu2011.RANK_CLOSE_DAY then
		szMsg = "   6月2日-6月8日，秦洼和大家一起吃粽子，过端午节。侠客们参加各种活动可获得制作粽子的材料，粽子可以投给河里的鱼儿食用，我听说用这种方法能捕到很多鱼。把鱼统统交给我吧，奖励绝对让你满意！";
		if tbDuanWu2011:CheckOpen() == 1 then
			table.insert(tbOpt, {"<color=yellow>我想用鱼儿兑换奖励<color>", self.ChangeFish2Award, self});
		end
		if tbDuanWu2011:CheckViewTodayMedalsRank() == 1 then
			table.insert(tbOpt, {"查询今日积分榜", tbDuanWu2011.ViewTodayKinMedalsRank, tbDuanWu2011});
		else
			table.insert(tbOpt, {"<color=gray>查询今日积分榜<color>", tbDuanWu2011.ViewTodayKinMedalsRank, tbDuanWu2011});
		end
		if tbDuanWu2011:CheckViewYestodayMedalsRank() == 1 then
			table.insert(tbOpt, {"查询昨日积分榜", tbDuanWu2011.ViewYestoryMedalsRank, tbDuanWu2011});
		else
			table.insert(tbOpt, {"<color=gray>查询昨日积分榜<color>", tbDuanWu2011.ViewYestoryMedalsRank, tbDuanWu2011});
		end
		if tbDuanWu2011:CheckGetMedalAward() == 1 then
			table.insert(tbOpt, {"<color=yellow>领取端午忠魂令<color>", tbDuanWu2011.GetMedalAward, tbDuanWu2011});
		else
			table.insert(tbOpt, {"<color=gray>领取端午忠魂令<color>", tbDuanWu2011.GetMedalAward, tbDuanWu2011});
		end
	end
	table.insert(tbOpt, {"端午忠魂商店", tbDuanWu2011.OpenShop, tbDuanWu2011});
	table.insert(tbOpt, {"兑换忠魂腰带", tbDuanWu2011.ChangeDuanWuBelt, tbDuanWu2011});
	table.insert(tbOpt, {"我只是路过"});
	
	Dialog:Say(szMsg, tbOpt);
	return 1;
end

-- 鱼兑换奖励
function tbDuanWuNpc:ChangeFish2Award()
	Dialog:OpenGift("把你钓到鱼放进来吧，我不会亏待你的", nil, {tbDuanWu2011.OnFishAward, tbDuanWu2011});
end

function tbDuanWu2011:OnFishAward(tbItem)
	if tbDuanWu2011:CheckOpen() ~= 1 then
		Dialog:Say("不在活动期间，无法兑换");
	end
	if #tbItem <= 0 then
		return 0;
	end
	for _, tbTemp in pairs(tbItem) do
		local pItem = tbTemp[1];
		local szKey = string.format("%s,%s,%s,%s", pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel);
		local nRet = 0;
		for i = 1, #self.ITEM_TBALBE_FISH_ID do
			if szKey == string.format("%s,%s,%s,%s", unpack(self.ITEM_TBALBE_FISH_ID[i])) then
				nRet = 1
				break;
			end
		end
		if nRet ~= 1 then
			Dialog:Say("我只要青鱼，鲤鱼，鲫鱼，霸王鱼四种鱼，其他东西就不要给我拉。");
			return 0;
		end
	end
	local tbCount = {0,0,0,0};
	for _, tbTemp in pairs(tbItem) do
		local pItem = tbTemp[1];
		local nCount = pItem.nCount;
		local nType = pItem.nLevel;
		if me.DelItem(pItem) ~= 1 then
			Dbg:WriteLog("DuanWu2011", "fish2award_failure", me.szName, string.format("%s,%s,%s,%s", pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel));
		else
			tbCount[nType] = tbCount[nType] + nCount;
		end
	end
	for i = 1, 4 do
		if tbCount[i] > 0 then
			local nMaxCount = tbCount[i];
			local nDuiHuanCount = me.GetTask(self.TASK_GROUP_ID, self.TASK_DUIHUAN_NUM);
			if nDuiHuanCount + tbCount[i] > self.TOTAL_FISH_NUM_LIMIT then
				nMaxCount = self.TOTAL_FISH_NUM_LIMIT - nDuiHuanCount;
			end
			if nMaxCount <= 0 then
				Dialog:Say("你怎么还有这么多鱼？我这里是不会要了，你自己留着吃吧。");
				Dbg:WriteLog("DuanWu2011", "fish_remain", me.szName, nDuiHuanCount, nMaxCount);
				return 0;
			end
			--local nCount = me.AddStackItem(self.ITEM_AWARDBOX_ID[i][1], self.ITEM_AWARDBOX_ID[i][2], self.ITEM_AWARDBOX_ID[i][3], self.ITEM_AWARDBOX_ID[i][4], {bForceBind = 1}, nMaxCount);
			local nCount = 0;
			for j = 1, nMaxCount do
				local pItem = me.AddItem(unpack(self.ITEM_AWARDBOX_ID[i]));
				if pItem then
					pItem.Bind(1);
					local szDate = os.date("%Y/%m/%d/%H/%M/%S", GetTime() + self.ITEM_VALIDITY_BOX);
	   				me.SetItemTimeout(pItem, szDate);
					nCount = nCount + 1;
				end
			end
			me.SetTask(self.TASK_GROUP_ID, self.TASK_DUIHUAN_NUM, nDuiHuanCount + nCount);
			if nCount ~= tbCount[i] then
				Dbg:WriteLog("DuanWu2011", "add_award_fail", me.szName, tbCount[i], nCount, unpack(self.ITEM_AWARDBOX_ID[i]));
			end
		end
	end
end

-- 查询今日积分
function tbDuanWu2011:ViewTodayKinMedalsRank()
	local nRet, szErrorMsg = self:CheckViewTodayMedalsRank();
	if nRet ~= 1 then
		Dialog:Say(szErrorMsg);
		return 0;
	end
	if not self.tbTodayRank or #self.tbTodayRank == 0 then
		Dialog:Say("今日还没有家族拿到端午忠魂积分，大家赶紧去做活动，投粽喂鱼吧！");
		return 0;
	end
	local szMsg = "";
	local nKinId, nMemberId = me.GetKinMember();
	if nKinId ~= 0 then
		local nTempRank = self.tbKinId2Rank[nKinId];
		if nTempRank then
			szMsg = szMsg .. string.format("你家族今日端午忠魂积分：<color=green>%s<color>\n", self.tbTodayRank[nTempRank][2]);
		end
	end
	szMsg = "<color=yellow>------2011端午忠魂今日积分排行-----<color>\n\n";
	for nRank = 1, self.MAX_VALID_RANK do
		if not self.tbTodayRank[nRank] or nRank > 7 then
			break;
		end
		szMsg = szMsg .. string.format("第<color=yellow>%d<color>名：<color=green>%s分<color>\n", nRank, self.tbTodayRank[nRank][2]);
		local nTempKinId = self.tbTodayRank[nRank][1];
		local cKin = KKin.GetKin(nTempKinId);
		local szKinName = "未知";
		if cKin then
			szKinName = cKin.GetName();
		end
		szMsg = szMsg .. string.format("家 族：<color=green>%s<color>\n\n", szKinName);
	end
	local tbOpt = {};
	if #self.tbTodayRank > 7 then
		table.insert(tbOpt, {"Trang sau", tbDuanWu2011.ViewTodayKinMedalsRankNextPage, tbDuanWu2011});
	end
	table.insert(tbOpt, {"Kết thúc đối thoại"});
	Dialog:Say(szMsg, tbOpt);
end

function tbDuanWu2011:ViewTodayKinMedalsRankNextPage()
	local nRet, szErrorMsg = self:CheckViewTodayMedalsRank();
	if nRet ~= 1 then
		Dialog:Say(szErrorMsg);
		return 0;
	end
	local szMsg = "<color=yellow>------2011端午忠魂今日积分排行-----<color>\n\n";
	for nRank = 8, self.MAX_VALID_RANK do
		if not self.tbTodayRank[nRank]then
			break;
		end
		szMsg = szMsg .. string.format("第<color=yellow>%d<color>名：<color=green>%s分<color>\n", nRank, self.tbTodayRank[nRank][2]);
		local nTempKinId = self.tbTodayRank[nRank][1];
		local cKin = KKin.GetKin(nTempKinId);
		local szKinName = "未知";
		if cKin then
			szKinName = cKin.GetName();
		end
		szMsg = szMsg .. string.format("家 族：<color=green>%s<color>\n\n", szKinName);
	end
	Dialog:Say(szMsg);
end

-- 检查今日分数查询
function tbDuanWu2011:CheckViewTodayMedalsRank()
	if self.IS_OPEN ~= 1 then
		return 0, "Sự kiện chưa mở";
	end
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	if nDate < self.OPEN_DAY then
		return -1, "Sự kiện chưa bắt đầu";
	end
	if nDate > self.CLOSE_DAY then
		return -1, "Sự kiện đã kết thúc";
	end
	if not self.nDataVer or self.nDataVer ~= Lib:GetLocalDay(GetTime()) then
		return 0, "今日家族积分还没有统计出来，大家先去做活动吧。";
	end
	return 1;
end

function tbDuanWu2011:ViewYestoryMedalsRank()
	local nRet, szErrorMsg = self:CheckViewYestodayMedalsRank();
	if nRet ~= 1 then
		Dialog:Say(szErrorMsg);
		return 0;
	end
	
	local szMsg = "<color=yellow>------2011端午忠魂昨日积分排行-----<color>\n\n";
	for nRank = 1, self.MAX_AWARD_RANK do
		if not self.tbYestodayRank[nRank] or nRank > 5 then
			break;
		end
		szMsg = szMsg .. string.format("第<color=yellow>%d<color>名：<color=green>%s分<color>\n", nRank, self.tbYestodayRank[nRank][2]);
		local nTempKinId = self.tbYestodayRank[nRank][1];
		local cKin = KKin.GetKin(nTempKinId);
		local szKinName = "未知";
		if cKin then
			szKinName = cKin.GetName();
		end
		szMsg = szMsg .. string.format("家 族：<color=green>%s<color>\n\n", szKinName);
	end
	local tbOpt = {};
	if #self.tbYestodayRank > 5 then
		table.insert(tbOpt, {"Trang sau", tbDuanWu2011.ViewYestoryMedalsRankNextPage, tbDuanWu2011});
	end
	table.insert(tbOpt, {"Kết thúc đối thoại"});
	Dialog:Say(szMsg, tbOpt);
end

function tbDuanWu2011:ViewYestoryMedalsRankNextPage()
	local nRet, szErrorMsg = self:CheckViewYestodayMedalsRank();
	if nRet ~= 1 then
		Dialog:Say(szErrorMsg);
		return 0;
	end
	local szMsg = "<color=yellow>------2011端午忠魂昨日积分排行-----<color>\n\n";
	for nRank = 6, self.MAX_AWARD_RANK do
		if not self.tbYestodayRank[nRank]then
			break;
		end
		szMsg = szMsg .. string.format("第<color=yellow>%d<color>名：<color=green>%s分<color>\n", nRank, self.tbYestodayRank[nRank][2]);
		local nTempKinId = self.tbYestodayRank[nRank][1];
		local cKin = KKin.GetKin(nTempKinId);
		local szKinName = "未知";
		if cKin then
			szKinName = cKin.GetName();
		end
		szMsg = szMsg .. string.format("家 族：<color=green>%s<color>\n\n", szKinName);
	end
	Dialog:Say(szMsg);
end

-- 检查昨日分数查询
function tbDuanWu2011:CheckViewYestodayMedalsRank()
	if self.IS_OPEN ~= 1 then
		return 0, "Sự kiện chưa mở";
	end
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	if nDate < self.RANK_OPEN_DAY then
		return -1, "Hôm nay là ngày đầu tiên, chưa có xếp hạng ngày hôm qua!";
	end
	if nDate > self.RANK_CLOSE_DAY then
		return -1, "Sự kiện đã kết thúc";
	end
	if not self.nDataVer or self.nDataVer ~= Lib:GetLocalDay(GetTime()) then
		return 0, "昨日积分还没有统计出来，过一会儿再来查看吧。";
	end
	return 1;
end

-- 检查是否可以领取忠魂袋
function tbDuanWu2011:CheckGetMedalAward()
	if self.IS_OPEN ~= 1 then
		return 0, "Sự kiện chưa mở";
	end
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	if nDate < self.RANK_OPEN_DAY then
		return -1, "Sự kiện chưa bắt đầu";
	end
	if nDate > self.RANK_CLOSE_DAY then
		return -1, "Sự kiện đã kết thúc";
	end
	if not self.nDataVer or self.nDataVer ~= Lib:GetLocalDay(GetTime()) then
		return 0, "Bảng xếp hạng chưa được thống kê, vui lòng đợi."
	end
	local nKinId, nMemberId = me.GetKinMember();
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0, "Hãy vào Gia tộc trước.";
	end
	if Kin:CheckSelfRight(nKinId, nMemberId, 2) ~= 1 then
		return 0, "Hãy để Tộc trưởng hoặc Tộc phó đến tìm ta."
	end
	if not self.tbAwardRecord then
		return 0, "Lỗi không xác định.";
	end
	local nRet = 0;
	for i = 1, self.MAX_AWARD_RANK do
		if self.tbYestodayRank[i] and self.tbYestodayRank[i][1] == nKinId then
			nRet = 1;
			break;
		end
	end
	if nRet ~= 1 then
		return 0, "Điểm tích lũy Trung hồn Đoan ngọ không đạt thứ hạng 10. không có phần thưởng để nhận.";
	end
	if self.tbAwardRecord[nKinId] then
		return 0, "Gia tộc đã lãnh phần thưởng, hãy tiếp tục cố gắng.";
	end
	return 1;
end

function tbDuanWu2011:GetMedalAward()
	local nRet, szErrorMsg = self:CheckGetMedalAward();
	if nRet ~= 1 then
		Dialog:Say(szErrorMsg);
		return 0;
	end
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang không đủ chỗ trống!");
		return 0;
	end
	local nKinId, nMemberId = me.GetKinMember();
	nRet = GCExcute{"SpecialEvent.DuanWu2011:GetMedalsAward_GC", nKinId, nMemberId, me.nId};
	if nRet == 1 then
		me.AddWaitGetItemNum(1);-- 领东西的时候先锁定，防止跨服重复领取
	end
end

function tbDuanWu2011:OpenShop()
	me.OpenShop(197, 1);
end

function tbDuanWu2011:ChangeDuanWuBelt()
	Dialog:OpenGift("Hãy đặt vào:\nĐai lưng Bạch Ngân + Mật lệnh Trung hồn (Trung cấp)\nhoặc Đai lưng Hoàng Kim + Mật lệnh Trung hồn (Cao cấp)\nTa sẽ đổi cho ngươi Đai lưng xịn xò với cấp cường hóa không đổi.", nil, {tbDuanWu2011.OnChangeDuanWuBelt, tbDuanWu2011});
end

function tbDuanWu2011:OnChangeDuanWuBelt(tbItem)
	if not tbItem or #tbItem <= 0 then
		return 0;
	end
	if not self.tbEquipChangeList then
		local tbTemp = Lib:LoadTabFile(self.EQUIT_CHANGE_FILEPATH);
		if not tbTemp or #tbTemp <= 0 then
			return 0;
		end
		self.tbEquipChangeList = {};
		for i = 1, #tbTemp do
			local szKey1 = string.format("%s,%s,%s,%s", tbTemp[i]["Genre1"], tbTemp[i]["DetailType1"], tbTemp[i]["ParticularType1"], tbTemp[i]["Level1"]);
			local tbKey2 = {tbTemp[i]["Genre2"], tbTemp[i]["DetailType2"], tbTemp[i]["ParticularType2"], tbTemp[i]["Level2"]};
			local nEquipLevel = tonumber(tbTemp[i]["EquipLevel"]);
			self.tbEquipChangeList[szKey1] = {};
			self.tbEquipChangeList[szKey1][1] = tbKey2;
			self.tbEquipChangeList[szKey1][2] = nEquipLevel;
		end
	end
	if not self.tbEquipChangeList then
		Dbg:WriteLog("tbDuanWu2011", "not find equipchange");
		return 0;
	end
	if #tbItem ~= 2 then
		Dialog:Say("Số lượng vật phẩm không đúng, ngươi chỉ cần đưa ta Đai lưng và Mật lệnh Trung hồn là được.");
		return 0;
	end
	local tbItemKey = {};
	local nCount = 0;
	for i, tbTemp in ipairs(tbItem) do
		local pItem = tbTemp[1];
		tbItemKey[i] = string.format("%s,%s,%s,%s", pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel);
		nCount = nCount + pItem.nCount;
	end
	if nCount ~= 2 then
		Dialog:Say("Ngươi đặt không đúng vật phẩm rồi.");
		return 0;
	end
	local nRet = 0;
	local szError = "Hãy đặt Đai lưng và Mật lệnh Trung hồn tương ứng.";
	local pEquip = nil;	-- 初始装备
	local pLianHuaTu = nil;-- 炼化图
	local tbTargetEquip = nil;	-- 目标装备
	if self.tbEquipChangeList[tbItemKey[1]] then
		szError = "Mật lệnh Trung hồn bỏ vào không đúng!";
		local nEquipLevel = self.tbEquipChangeList[tbItemKey[1]][2];
		local szLianHuTuKey = string.format("%s,%s,%s,%s", unpack(self.ITEM_LIANHUATU_ID[nEquipLevel]));
		if szLianHuTuKey == tbItemKey[2] then
			nRet = 1;
			tbTargetEquip = self.tbEquipChangeList[tbItemKey[1]][1];
			pEquip = tbItem[1][1];
			pLianHuaTu = tbItem[2][1];
		end
	elseif self.tbEquipChangeList[tbItemKey[2]] then
		szError = "Mật lệnh Trung hồn bỏ vào không đúng!";
		local nEquipLevel = self.tbEquipChangeList[tbItemKey[2]][2];
		local szLianHuTuKey = string.format("%s,%s,%s,%s", unpack(self.ITEM_LIANHUATU_ID[nEquipLevel]));
		if szLianHuTuKey == tbItemKey[1] then
			nRet = 2;
			tbTargetEquip = self.tbEquipChangeList[tbItemKey[2]][1];
			pEquip = tbItem[2][1];
			pLianHuaTu = tbItem[1][1];
		end
	end
	if nRet == 0 or not tbTargetEquip or not pEquip or not pLianHuaTu then
		Dialog:Say(szError);
		return 0;
	end
	if me.DelItem(pLianHuaTu) ~= 1 then
		Dbg:WriteLog("tbDuanWu2011", "equip_lianhua_error",  tostring(pLianHuaTu.dwId), pLianHuaTu.szName);
		return 0;
	end
	local nRet = pEquip.Regenerate(
		tonumber(tbTargetEquip[1]),
		tonumber(tbTargetEquip[2]),
		tonumber(tbTargetEquip[3]),
		tonumber(tbTargetEquip[4]),
		pEquip.nSeries,
		pEquip.nEnhTimes,
		pEquip.nLucky,
		nil,
		0,
		pEquip.dwRandSeed,
		pEquip.nStrengthen
	);
	if nRet ~= 1 then
		Dbg:WriteLog("tbDuanWu2011", "refine_equip_error");
		return 0;
	end 
	pEquip.Bind(1);
	me.Msg("Chúc mừng, nâng cấp thành công Yêu đái lên <color=gold>"..pEquip.szName.."<color>");
	return 1;
end