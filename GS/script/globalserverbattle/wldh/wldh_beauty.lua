-- 文件名　：wldh_beauty.lua
-- 创建者　：zounan
-- 创建时间：2010-05-19 20:02:19
-- 描述　  ：武林大会选美上线提示

Wldh.Beauty = Wldh.Beauty or {};
local tbBeauty = Wldh.Beauty;

tbBeauty.HaiXuan_BEGIN = 201006070000;  --海选
tbBeauty.HaiXuan_END   = 201006202400;

tbBeauty.Final_BEGIN = 201006221200;    -- 总决赛
tbBeauty.Final_END   = 201006282400;

tbBeauty.LEVEL_LIMIT = 60;

tbBeauty.TSK_GROUP  = 2093;
tbBeauty.TSK_ID		= 21;

tbBeauty.MSG_STATE = {[1] = "海选", [2] = "总决赛"};

tbBeauty.MSG_RULE = {
	[1] = 
[[海选投票规则：
  1.一个金山通行证一天内只能在专题页面或者游戏中投一票；
  2.在游戏内投票效果为专题页面投票的5倍，游戏内投1票等于网页投5票；
  3.本次选秀活动投票是全区全服进行，你还可以跨越服务器界限为剑侠情缘网络版叁和剑侠贰外传的参与选秀活动的选手进行投票。
]],
    [2] = 
[[总决赛投票规则：
  1.一个金山通行证一天内只能在专题页面或者游戏中投一票；
  2.在游戏内投票效果为专题页面投票的5倍，游戏内投1票等于网页投5票；
  3.本次选秀活动投票是全区全服进行，你还可以跨越服务器界限为剑侠情缘网络版叁和剑侠贰外传的参与选秀活动的选手进行投票；
  4.决赛参赛选手如填写的资料与真实资料不符，将取消排名和全部奖励(包括游戏内各项大奖及实物大奖)，其名次与奖励，将由符合大赛规则的下一名次参赛选手获得。
]],		
};

tbBeauty.MSG		= "《剑侠情缘》电视剧选秀已开启，您可以使用修炼珠进行投票。";
tbBeauty.MSG2		= "《剑侠情缘》电视剧选秀已开启，您可以使用修炼珠进行投票。游戏报名投票期（海选）: 6月7日0:00至6月20日23:59 （决赛）: 6月22日12:00至6月28日23:59";
tbBeauty.szHttp		= "http://zt.xoyo.com/haixuan/index.php?act=client_search&k=";

function tbBeauty:CheckState()
	if me.nLevel < self.LEVEL_LIMIT then
		return 0;
	end	
	local nDate = tonumber(GetLocalDate("%Y%m%d%H%M"));
	if nDate < self.HaiXuan_BEGIN or nDate > self.Final_END then
		return 0;
	end
	if nDate < self.HaiXuan_END then
		return 1;
	end
	if nDate > self.Final_BEGIN then
		return 2;
	end	
	return 0;
end

function tbBeauty:OnLogin(bExchangeServer)
	if bExchangeServer == 1 then
		return;
	end
	
	local nResult = self:CheckState();
	if nResult == 0 then
		return;
	end
	
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	if me.GetTask(self.TSK_GROUP, self.TSK_ID) == nDate then
		return;
	end
	
	me.SetTask(self.TSK_GROUP, self.TSK_ID, nDate);
	Dialog:SendBlackBoardMsg(me, self.MSG);
	me.Msg(string.format(self.MSG2));
end


function tbBeauty:SelBeauty()
	local nResult = self:CheckState();
	if nResult == 0 then
		Dialog:Say("不在活动时间内。");
		return;
	end
	local szMsg = string.format("参加%s投票", self.MSG_STATE[nResult]);	
	local tbOpt = {
	{szMsg, self.OpenIE,self},
	{"查看投票规则", self.RuleInfo,self,nResult},
	{"Kết thúc đối thoại"},
		};
	Dialog:Say("《剑侠情缘》电视剧选秀进行中。", tbOpt);
end

function tbBeauty:OpenIE()
	me.CallClientScript({"UiManager:OpenWindow", "UI_WLDH_BEAUTY", self.szHttp});
end

function tbBeauty:RuleInfo(nResult)
	Dialog:Say(self.MSG_RULE[nResult]);	
end

PlayerEvent:RegisterGlobal("OnLogin", Wldh.Beauty.OnLogin, Wldh.Beauty);
