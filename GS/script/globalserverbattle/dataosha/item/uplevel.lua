-- 文件名　：uplevel.lua
-- 创建者　：zounan
-- 创建时间：2009-10-23
-- 描  述  ：
local tbItem = Item:GetClass("menpailingpai");

function tbItem:OnUse()
	self:OnUseEx(it.dwId);
end

function tbItem:OnUseEx(nItemId)
	local tbMission = DaTaoSha:GetPlayerMission(me);
	if not tbMission then
		return;
	end
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return;
	end	
	local nSeries = tbMission:GetPlayerSelecetSeries(me); -- 看玩家是否已经选择了五行
	if nSeries then
		self:SelectSeries(nItemId, nSeries);
		return;
	end	
	local tbSeries = tbMission:GetGroupSeries(me);
	local tbOpt = {};
	for nSeries, _  in pairs(tbSeries) do
		table.insert(tbOpt, {DaTaoSha.FACTION[nSeries].szSeriesName, self.OnSelectSeries, self, nItemId, nSeries});
	end
	table.insert(tbOpt, {"Để ta suy nghĩ lại"});
	local szMsg = "Hãy chọn môn phái bạn yêu thích\n<color=yellow>mỗi thành viên chỉ có thể chọn 1 trong những ngũ hành dưới đây, không thể chọn cùng ngũ hành!<color>";
	Dialog:Say(szMsg, tbOpt); 
end

function tbItem:OnSelectSeries(nItemId, nSeries)
	local tbMission = DaTaoSha:GetPlayerMission(me);
	if not tbMission then
		return;
	end
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return;
	end	
	local tbSeries = tbMission:GetGroupSeries(me); -- 拿到本组现还可以选择的五行
	if not tbSeries[nSeries] then
		local tbOpt = {
			{"Chọn ngũ hành khác",self.OnUseEx, self, nItemId},
			{"Kết thúc đối thoại"},
		};
		local szMsg = "Ngũ hành này đã được đồng đội chọn trước, hãy chọn ngũ hành khác.";
		Dialog:SendInfoBoardMsg(me, szMsg);
		Dialog:Say(szMsg, tbOpt);
		return;
	end
	self:SelectSeries(nItemId, nSeries);
end

function tbItem:SelectSeries(nItemId, nSeries) 
	local tbMission = DaTaoSha:GetPlayerMission(me);
	if not tbMission then
		return;
	end
	local nFaction = tbMission:GetPlayerFaction(me);   -- 门派不为空说明玩家已经选择过五行了
	if not nFaction then
	 	nFaction = tbMission:SelectSeries(me, nSeries);	     -- 设置玩家五行 并且返回一个门派 
	end
	local tbFaction = DaTaoSha.FACTION[nSeries][nFaction];
	local szMsg = string.format("Bạn chọn %s theo hướng tu luyện nào?", tbFaction.szFactionName);
	local tbOpt = {
			{tbFaction[1],self.OnSelectRoute ,self, nItemId,1},
			{tbFaction[2],self.OnSelectRoute ,self, nItemId,2},
		};
	Dialog:Say(szMsg, tbOpt);
end

--选择路线
function tbItem:OnSelectRoute(nItemId, nRoute)  
	local tbMission = DaTaoSha:GetPlayerMission(me);
	if not tbMission then
		return;
	end
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return;
	end	
	if tbMission:SelectRoute(me, nRoute) == 1 then
		pItem.Delete(me);
	end
end
