-- 文件名　：vowtree.lua
-- 创建者　：jiazhenwei
-- 创建时间：2009-12-28 11:12:16
-- 描  述  ：许愿树

local tbNpc= Npc:GetClass("zhenzai_vowtree");
SpecialEvent.ZhenZai = SpecialEvent.ZhenZai or {};
local ZhenZai = SpecialEvent.ZhenZai or {};

tbNpc.tbMsg = {[1] = "心手相连抗震抗旱，风雨同舟重建家园。",		
			  [2] = "我们的心永远和你们在一起，祝愿灾区人民平安！<color>",
			  [3] = "亿万祝福远相传，心心相连；亿万双手送温暖，驱散灾难；亿万中国人一条心，共度难关。",			
			  [4] = "华夏儿女，手拉手团结抗灾； 共祈福，好心人一生平安！ "
			 };

function tbNpc:OnDialog()
	local nData = tonumber(GetLocalDate("%Y%m%d"));
	if nData < ZhenZai.VowTreeOpenTime or nData > ZhenZai.VowTreeCloseTime then	--活动期间外
		Dialog:Say("心诚则灵，还是到日期把大家都聚起来了再开始吧！", {"知道了"});
		return;
	end
	--玩家当天许愿次数
	local nDateEx = me.GetTask(ZhenZai.TASKID_GROUP, ZhenZai.TASKID_TIME) or 0;
	local nTimes = 0;
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	if nDateEx ~= nNowDate then
		me.SetTask(ZhenZai.TASKID_GROUP, ZhenZai.TASKID_TIME, nNowDate);
		me.SetTask(ZhenZai.TASKID_GROUP, ZhenZai.TASKID_COUNT, 0);
	else
		nTimes = me.GetTask(ZhenZai.TASKID_GROUP, ZhenZai.TASKID_COUNT) or 0;
	end	
	local nCount =  KGblTask.SCGetDbTaskInt(DBTASD_EVENT_ZHENZAI_VOWNUM);	
	local szMsg = string.format("    西南大部份地区遭受百年不遇的旱灾，万亩良田绝收。青海玉树地区更是遭受了7.1级强烈地震。快为灾区的人民祈愿吧！你也会有意外的收获。\n\n<color=red>    目前已接受愿望数量：%s个<color>\n<color=red>    您当天已许愿的数量：%s个<color>", nCount, nTimes);
	Dialog:Say(szMsg,
		{
			{"默默的祝福", self.Vow, self, 1, him.dwId},
			{"为灾区人民祈愿[好友公告]", self.Vow, self, 2, him.dwId},
			{"为灾区人民祈愿[家族帮会公告]", self.Vow, self, 3, him.dwId},
			{"为灾区人民祈愿[好友家族帮会公告]", self.Vow, self, 4, him.dwId},			
			{"领取平安香",self.GetPingAn, self},
			{"2010次祈愿后领取奖励", self.GetEncouragement, self, him.dwId},		
			{"Ta chỉ xem qua"}
		});
end

function tbNpc:GetPingAn()
	if me.nLevel < ZhenZai.nLevel  then
		Dialog:Say(string.format("您的等级不足%s级，不能祈愿！",ZhenZai.nLevel),{"知道了"});
		return 0;
	end	
	if me.GetTask(ZhenZai.TASKID_GROUP, ZhenZai.TASKID_GETPINGAN) == 1 then
		Dialog:Say("你已经领取过了！",{"知道了"});
		return 0;
	end
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("请预留1格背包空间再来祈愿！",{"知道了"});
		return 0;
	end
	local pItem = me.AddItem(18,1,958,1);   --平安香
	if pItem then
		me.AddTitle(unpack(ZhenZai.tbPingAnYiJia));
		me.SetCurTitle(unpack(ZhenZai.tbPingAnYiJia));
		local nSec = Lib:GetDate2Time(ZhenZai.nOutTime)	
		pItem.SetTimeOut(0, nSec);
		pItem.Sync();		
		me.SetTask(ZhenZai.TASKID_GROUP, ZhenZai.TASKID_GETPINGAN, 1);
	end
end

function tbNpc:Check()
	--等级判断
	if me.nLevel < ZhenZai.nLevel  then
		Dialog:Say(string.format("您的等级不足%s级，不能祈愿！",ZhenZai.nLevel),{"知道了"});
		return 0;
	end
	
	--需要有“希望之种”
	local tbItem = me.FindItemInBags(unpack(ZhenZai.tbXiWang));
	if #tbItem == 0 then
		Dialog:Say("需要有“希望之水”才能进行祈愿！",{"知道了"});
		return 0;
	end
	
	--背包判定
	if me.CountFreeBagCell() < 2 then
		Dialog:Say("请预留2格背包空间再来祈愿！",{"知道了"});
		return 0;
	end
end

--许愿
function tbNpc:Vow(nType, nNpcId)	
	if self:Check() == 0 then
		return 0;
	end
	local tbItem = me.FindItemInBags(unpack(ZhenZai.tbXiWang));
	if nType == 1 then
		self:GetAward(tbItem);
		me.Msg("您默默的祝福了灾区人民！");
		return;
	end
	local szMsg = string.format("    西南大部份地区遭受百年不遇的旱灾，万亩良田绝收。青海玉树地区更是遭受了7.1级强烈地震。快为灾区的人民祈愿吧！你也会有意外的收获。\n");
	local tbObt = {};
	for i =1, #self.tbMsg do
		table.insert(tbObt,{self.tbMsg[i],self.SentInformation, self,  nType, i, nNpcId, tbItem})
	end
	table.insert(tbObt,{"Ta chỉ xem qua"});
	Dialog:Say(szMsg,tbObt);	
	return;
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
	local nMapId2, nPosX2, nPosY2 = unpack(ZhenZai.tbVowTreePosition)
	local nDisSquare = (nPosX - nPosX2)^2 + (nPosY - nPosY2)^2;
	if nMapId2 ~= nMapId or nDisSquare > 400 then
		Dialog:Say("必须在平安佛附近才能许愿。");
		return 0;
	end
	return 1;
end

--发送频道
function tbNpc:SentInformation(nType, nTextId, nNpcId, tbItem)
	if  self:CheckPosition(nNpcId) == 0 then
		return 0;
	end
	--频道发送
	local szMsg = string.format("%s在平安佛处许下了愿望：",me.szName).."<color=purple>"..self.tbMsg[nTextId].."<color>";	
	me.Msg("您在平安佛处许下了愿望：<color=yellow>"..self.tbMsg[nTextId].."<color>");
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
	self:GetAward(tbItem);
end

function tbNpc:GetAward(tbItem)
	tbItem[1].pItem.Delete(me);	--删除希望之种
	local nCount = KGblTask.SCGetDbTaskInt(DBTASD_EVENT_ZHENZAI_VOWNUM);
	GCExcute({"SpecialEvent.ZhenZai:AddGTask", me.nId}); --有GC仲裁
	
	--玩家当天许愿次数
	local nDate = me.GetTask(ZhenZai.TASKID_GROUP, ZhenZai.TASKID_TIME);
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	if nDate < nNowDate then
		me.SetTask(ZhenZai.TASKID_GROUP, ZhenZai.TASKID_TIME, nNowDate);
		me.SetTask(ZhenZai.TASKID_GROUP, ZhenZai.TASKID_COUNT, 0);
	end
	local	nTimes = me.GetTask(ZhenZai.TASKID_GROUP, ZhenZai.TASKID_COUNT);
	if nTimes < ZhenZai.nGetFudaiMaxNum then		--前五次给宝箱
		me.AddItem(18,1,80,1);			--福袋
	end
	me.SetTask(ZhenZai.TASKID_GROUP, ZhenZai.TASKID_COUNT, nTimes + 1);
end


--获得奖励
function tbNpc:GetEncouragement(nNpcId)	
	if me.nLevel < ZhenZai.nLevel  then
		Dialog:Say(string.format("您的等级不足%s级，不能祈愿！",ZhenZai.nLevel),{"知道了"});
		return 0;
	end
	
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return;
	end	
	
	--玩家当天是否领过奖了
	local nDate = me.GetTask(ZhenZai.TASKID_GROUP, ZhenZai.TASKID_TIMEEx) or 0;
	local nFlag = 0;
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	if nDate ~= nNowDate then
		me.SetTask(ZhenZai.TASKID_GROUP, ZhenZai.TASKID_TIMEEx, nNowDate);
		me.SetTask(ZhenZai.TASKID_GROUP, ZhenZai.TASKID_ISGETAWARD, 0);
	else
		nFlag = me.GetTask(ZhenZai.TASKID_GROUP, ZhenZai.TASKID_ISGETAWARD) or 0;		
	end
	if nFlag == 1 then
		Dialog:Say("您今天已经领取过奖励了，不能再领奖了！",{"知道了"});
		return;
	end
	
	--愿望个数是否满足
	local nCount = KGblTask.SCGetDbTaskInt(DBTASD_EVENT_ZHENZAI_VOWNUM);
	if nCount < ZhenZai.nTrapNumber then
		Dialog:Say(string.format("平安佛还没有收到%s个愿望，无奖励可领取！", ZhenZai.nTrapNumber),{"知道了"});
		return;
	end
	
	--给奖励	
	me.AddSkillState(880, 1, 1, 60 * 60 * Env.GAME_FPS, 1, 0, 1);
	me.AddSkillState(385, 6, 1, 60 * 60 * Env.GAME_FPS, 1, 0, 1);
	me.AddSkillState(386, 6, 1, 60 * 60 * Env.GAME_FPS, 1, 0, 1);
	me.AddSkillState(387, 6, 1, 60 * 60 * Env.GAME_FPS, 1, 0, 1);					
	me.SetTask(ZhenZai.TASKID_GROUP, ZhenZai.TASKID_ISGETAWARD, 1);
end
