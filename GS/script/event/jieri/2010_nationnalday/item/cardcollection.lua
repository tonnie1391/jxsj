--=================================================
-- 文件名　：cardcollection.lua
-- 创建者　：furuilei
-- 创建时间：2010-08-24 17:07:12
-- 功能描述：爱我中华集
--=================================================

local tbItem = Item:GetClass("nationalcard_collection");
SpecialEvent.tbNationnalDay = SpecialEvent.tbNationnalDay or {};
local tbEvent = SpecialEvent.tbNationnalDay or {};

function tbItem:OnUse()
	local szMsg = "   神州同贺、爱我中华!\n   在活动期间、参加军营、宋金、逍遥谷、白虎、击杀首领、商会活动可获得爱我中华卡。鉴定爱我中华卡需800点精活。卡片内容为我国34个地域地名，每日最多可鉴定6张卡。鉴定地点若为当日福地可额外获得奖励。\n   爱我中华集中所搜集到的地区越多，活动结束后兑换的奖励也越多。奖励详见（最新活动帮助锦囊）";
	local tbOpt = {
		{"查看我的爱我中华集", self.ViewMyCardCollection, self},
		{"<color=red>神州卡<color>规则", self.Rule_ShenzhouCard, self},
		{"兑换奖励", self.GetAward, self, it.dwId},
		{"Đóng lại"}
		};
	Dialog:Say(szMsg, tbOpt);
end

function tbItem:ViewMyCardCollection()
	me.CallClientScript({"SpecialEvent.tbNationnalDay:OpenCollectionWnd_Client"});
end

function tbItem:Rule_ShenzhouCard()
	local szMsg = "    爱我中华，神州同乐，昆仑屹立、泰山昂首、长城扬眉、黄河高歌。侠客们在爱我中华活动中，进行爱我中华卡鉴定，便有几率鉴定出神州卡。使用神州卡，所收集到的一定是爱我中华集中不曾收集过的地区，爱我中华卡、神州卡都将会在当日消失，祝你好运！";
	Dialog:Say(szMsg);
end

function tbItem:GetAward(nItemId)
	tbEvent:GetAward(nItemId);
end
