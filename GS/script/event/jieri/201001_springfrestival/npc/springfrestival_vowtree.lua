-- 文件名　：vowtree.lua
-- 创建者　：jiazhenwei
-- 创建时间：2009-12-28 11:12:16
-- 描  述  ：许愿树

local tbNpc= Npc:GetClass("xinnian_vowtree");
SpecialEvent.SpringFrestival = SpecialEvent.SpringFrestival or {};
local SpringFrestival = SpecialEvent.SpringFrestival or {};

function tbNpc:OnDialog()
	local nData = tonumber(GetLocalDate("%Y%m%d"));
	if nData < SpringFrestival.VowTreeOpenTime or nData > SpringFrestival.VowTreeCloseTime then	--活动期间外
		Dialog:Say("时机还不成熟！", {"知道了"});
		return;
	end
	--玩家当天许愿次数
	local nDateEx = me.GetTask(SpringFrestival.TASKID_GROUP_EX, SpringFrestival.TASKID_VOWTREE_TIME) or 0;
	local nTimes = 0;
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	if nDateEx ~= nNowDate then
		me.SetTask(SpringFrestival.TASKID_GROUP_EX, SpringFrestival.TASKID_VOWTREE_TIME, nNowDate);
		me.SetTask(SpringFrestival.TASKID_GROUP, SpringFrestival.TASKID_COUNT, 0);
	else
		nTimes = me.GetTask(SpringFrestival.TASKID_GROUP, SpringFrestival.TASKID_COUNT) or 0;
	end	
	local nCount =  KGblTask.SCGetDbTaskInt(DBTASD_EVENT_SPRINGFRESTIVAL_VOWNUM);	
	local szMsg = string.format("你今年有什么愿望呢？在这里记下来，说不定就可以实现哦。注意，你可以将你的愿望发布到不同的聊天频道，请仔细选择！\n<color=red>目前已接受愿望数量：%s个<color>\n<color=red>您当天已许愿的数量：%s个<color>", nCount, nTimes);
	Dialog:Say(szMsg,
		{
			{"随便许个愿吧", self.Vow, self, 1, him.dwId},
			{"虔诚地许愿[好友公告]", self.Vow, self, 2, him.dwId},
			{"虔诚地许愿[家族帮会公告]", self.Vow, self, 3, him.dwId},
			{"虔诚地许愿[好友家族帮会公告]", self.Vow, self, 4, him.dwId},
			--{"领取奖励", self.GetEncouragement, self, him.dwId},
			{"Ta chỉ xem qua"}
		});
end

function tbNpc:Check()
	--等级判断
	if me.nLevel < SpringFrestival.nLevel  then
		Dialog:Say(string.format("您的等级不足%s级，不能许愿！",SpringFrestival.nLevel),{"知道了"});
		return 0;
	end
	
	--需要有“希望之种”
	local tbItem = me.FindItemInBags(unpack(SpringFrestival.tbXiWang));
	if #tbItem == 0 then
		Dialog:Say("需要有“希望之种”才能进行许愿！",{"知道了"});
		return 0;
	end
	
	--背包判定
	if me.CountFreeBagCell() < 4 then
		Dialog:Say("请预留4格背包空间再来许愿！",{"知道了"});
		return 0;
	end
end

--许愿
function tbNpc:Vow(nType, nNpcId)
	if self:Check() == 0 then
		return 0;
	end
	local tbItem = me.FindItemInBags(unpack(SpringFrestival.tbXiWang));
	Dialog:AskString("新年愿望(10个字) ", 20, self.InputInformation, self, nType, tbItem, nNpcId);
	return;
end	

--输入愿望
function tbNpc:InputInformation(nType, tbItem, nNpcId, szText)
	--是否包含敏感字串
	if IsNamePass(szText) ~= 1 then
		Dialog:Say("您的许愿含有非法的敏感字符。",{"知道了"});
		return 0;
	end

	if GetNameShowLen(szText) > 20 then
		Dialog:Say("您的愿望字符过长，还是简洁点好。",{"知道了"});
		return 0;
	end
	local szMsg = string.format("确定将您的愿望：<color=yellow>%s<color>发送到",szText);
	if nType == 1 then		
		self:SentInformation(nType, szText, nNpcId, tbItem);
		return;
	elseif nType == 2 then
		szMsg = szMsg.."(<color=yellow>好友<color>)吗？";
	elseif nType == 3 then
		szMsg = szMsg.."(<color=yellow>家族帮会<color>)吗？";
	else
		szMsg = szMsg.."(<color=yellow>好友家族帮会<color>)吗？";
	end
	Dialog:Say(szMsg,
		{
			{"Xác nhận", self.SentInformation, self, nType, szText, nNpcId, tbItem},		
			{"取消"}
		})
end

function tbNpc:CheckPosition(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end	
	if self:Check() == 0 then
		return 0;
	end
	local nMapId, nPosX, nPosY = me.GetWorldPos();	       		     
	local nMapId2, nPosX2, nPosY2 = unpack(SpringFrestival.tbVowTreePosition)
	local nDisSquare = (nPosX - nPosX2)^2 + (nPosY - nPosY2)^2;
	if nMapId2 ~= nMapId or nDisSquare > 400 then
		Dialog:Say("必须在许愿树附近才能许愿。");
		return 0;
	end
	return 1;
end

--发送频道
function tbNpc:SentInformation(nType, szText, nNpcId, tbItem)
	if  self:CheckPosition(nNpcId) == 0 then
		return 0;
	end
	--频道发送
	local szMsg = string.format("%s在永乐镇许愿树处许下了愿望：",me.szName).."<color=purple>"..szText.."<color>";	
	me.Msg("您在永乐镇许愿树处许下了愿望：<color=yellow>"..szText.."<color>");
	if nType == 2 then		--好友频道
		me.SendMsgToFriend(szMsg);
	elseif nType == 3 then	--帮会、家族频道
		if me.dwKinId ~= 0 then
			KKin.Msg2Kin(me.dwKinId, szMsg);
		end
		if me.dwTongId ~= 0  then
			KTong.Msg2Tong(me.dwTongId, szMsg);
		end
	elseif nType == 4 then	--好友、帮会、家族频道
		me.SendMsgToFriend(szMsg);
		if me.dwKinId ~= 0 then
			KKin.Msg2Kin(me.dwKinId, szMsg);
		end
		if me.dwTongId ~= 0  then
			KTong.Msg2Tong(me.dwTongId, szMsg);
		end
	end
	self:GetAward(tbItem)
end

function tbNpc:GetAward(tbItem)
	tbItem[1].pItem.Delete(me);	--删除希望之种
	local nCount = KGblTask.SCGetDbTaskInt(DBTASD_EVENT_SPRINGFRESTIVAL_VOWNUM);
	GCExcute({"SpecialEvent.SpringFrestival:AddGTask"});
	
	--玩家当天许愿次数
	local nDate = me.GetTask(SpringFrestival.TASKID_GROUP_EX, SpringFrestival.TASKID_VOWTREE_TIME);
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	if nDate < nNowDate then
		me.SetTask(SpringFrestival.TASKID_GROUP_EX, SpringFrestival.TASKID_VOWTREE_TIME, nNowDate);
		me.SetTask(SpringFrestival.TASKID_GROUP, SpringFrestival.TASKID_COUNT, 0);
	end
	local	nTimes = me.GetTask(SpringFrestival.TASKID_GROUP, SpringFrestival.TASKID_COUNT);
	if nTimes < SpringFrestival.nGetFudaiMaxNum then		--前五次给福袋和随机一种有几率的奖励
		me.AddItem(18,1,80,1); 				--福袋
		self:AddLuckyStone();
		local nRant = MathRandom(100);
		for i = 1 ,#SpringFrestival.tbXiWangAward do
			if nRant > SpringFrestival.tbXiWangAward[i][2] and nRant <= SpringFrestival.tbXiWangAward[i][3]  then
				local pItemEx = me.AddItem(unpack(SpringFrestival.tbXiWangAward[i][1]));
				EventManager:WriteLog(string.format("[新年活动·许愿树许愿]获得随机物品:%s",pItemEx.szName), me);
				me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("[新年活动·许愿树许愿]获得随机物品:%s",pItemEx.szName));
			end
		end
	end
	me.SetTask(SpringFrestival.TASKID_GROUP, SpringFrestival.TASKID_COUNT, nTimes + 1);
	
	--满足1001个愿望，给第1001个愿望的玩家奖励，通知全服去领奖
	if (nCount + 1) == SpringFrestival.nTrapNumber then
		Dialog:GlobalNewsMsg_GS(string.format("%s许下了许愿树的第%s个愿望，美好的愿望一定会实现！", me.szName, SpringFrestival.nTrapNumber));
		me.AddTitle(unpack(SpringFrestival.tbVowTree_Title));
		me.SetCurTitle(unpack(SpringFrestival.tbVowTree_Title));
	end
end

--获得奖励
function tbNpc:GetEncouragement(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return;
	end	
	
	if me.nLevel < SpringFrestival.nLevel  then
		Dialog:Say(string.format("您的等级不足%s级，不能领奖！", SpringFrestival.nLevel),{"知道了"});
		return;
	end
	
	--玩家当天是否领过奖了
	local nDate = me.GetTask(SpringFrestival.TASKID_GROUP, SpringFrestival.TASKID_TIME) or 0;
	local nFlag = 0;
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	if nDate ~= nNowDate then
		me.SetTask(SpringFrestival.TASKID_GROUP, SpringFrestival.TASKID_TIME, nNowDate);
		me.SetTask(SpringFrestival.TASKID_GROUP, SpringFrestival.TASKID_ISGETAWARD, 0);
	else
		nFlag = me.GetTask(SpringFrestival.TASKID_GROUP, SpringFrestival.TASKID_ISGETAWARD) or 0;
	end
	if nFlag == 1 then
		Dialog:Say("您今天已经领取过奖励了，不能再领奖了！",{"知道了"});
		return;
	end
	
	--愿望个数是否满足
	local nCount = KGblTask.SCGetDbTaskInt(DBTASD_EVENT_SPRINGFRESTIVAL_VOWNUM);
	if nCount < SpringFrestival.nTrapNumber then
		Dialog:Say(string.format("许愿树还没有收到%s个愿望，无奖励可领取！", SpringFrestival.nTrapNumber),{"知道了"});
		return;
	end
	
	--背包判断
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("领奖需要1格背包空间，整理下再来！",{"知道了"});
		return;
	end
	
	--给奖励
	local pItem = me.AddItem(unpack(SpringFrestival.tbVowXiang));
	me.SetItemTimeout(pItem, 60*24*30, 0);	
	me.SetTask(SpringFrestival.TASKID_GROUP, SpringFrestival.TASKID_ISGETAWARD, 1);
	EventManager:WriteLog("[新年活动·许愿树1001个愿望]从许愿树上获得愿望盒子", me);
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "[新年活动·许愿树1001个愿望]从许愿树上获得愿望盒子");
end

function tbNpc:AddLuckyStone()
	local nStoneCount = me.GetTask(SpringFrestival.TASKID_GROUP, SpringFrestival.TASKID_STONE_COUNT_MAX);
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	local nCurSec  = Lib:GetDate2Time(nCurDate);
	local nCurWeek = Lib:GetLocalWeek(nCurSec);
	local nWeek = me.GetTask(SpringFrestival.TASKID_GROUP, SpringFrestival.TASKID_STONE_WEEK);
	if nWeek ~= nCurWeek then
		me.SetTask(SpringFrestival.TASKID_GROUP, SpringFrestival.TASKID_STONE_WEEK,nCurWeek);
		me.SetTask(SpringFrestival.TASKID_GROUP, SpringFrestival.TASKID_STONE_COUNT_MAX,0);
		nStoneCount = 0;
	end
		
	if nStoneCount < SpringFrestival.STONE_COUNT_MAX then
		me.SetTask(SpringFrestival.TASKID_GROUP, SpringFrestival.TASKID_STONE_COUNT_MAX,nStoneCount+1);
		local pLucky = 	me.AddItem(unpack(SpringFrestival.tbLuckyStone));  --宝石
		if pLucky then
			pLucky.Bind(1);
		end
	end
end