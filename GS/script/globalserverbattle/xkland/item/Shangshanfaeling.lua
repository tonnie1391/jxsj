--文件名  : Shangshanfaeling.lua
--创建者  : jiazhenwei
--创建日期: 2010-06-02 14:18:00
--描 述 :赏善罚恶令

local tbItem = Xkland.tbItem or {};

tbItem.Thursday 		= 4;		--周四
tbItem.Sunday 			= 7;		--周日
tbItem.nBufferId 		= 1629;		--buffId
tbItem.tbBufferLevel 	= {2, 1};	--buffLevel 城主是2，侍卫是1

tbItem.tbTitle = 
{	
	{"铁浮城主·傲世凌天","255,255,0"},	--城主Title-傲世凌天
	{"铁浮勇士·群雄逐日","255,181,0"}	--侍卫Title-群雄逐日
};

--计算披风buff的时间
function tbItem:CaleBuffTime()
	local nNowTime = tonumber(os.date("%w", GetTime()));
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));	
	if nNowTime >= self.Thursday and nNowTime <= self.Sunday then
		return Lib:GetDate2Time(nNowDate + self.Sunday - nNowTime) - GetTime();
	else		
		return Lib:GetDate2Time(nNowDate + self.Thursday - nNowTime) - GetTime();
	end
end

--没有绑定的令牌
local tbItemBase = Item:GetClass("xiakedaolingpai");

function tbItemBase:OnUse()
	if me.GetTask(1025, 17) == 1 and it.nParticular == 869 then
		local nRemainTime = tbItem:CaleBuffTime() * Env.GAME_FPS;
		me.AddSkillState(tbItem.nBufferId, tbItem.tbBufferLevel[1], 1, nRemainTime, 1);
		me.AddSpeTitle(tbItem.tbTitle[1][1], GetTime() + tbItem:CaleBuffTime(), tbItem.tbTitle[1][2]);
		me.Msg("恭喜您获得使用铁浮城城主披风的资格！");
		return 1;
	end
	if me.GetTask(1025, 18) == 1 and it.nParticular == 870 then
		local nRemainTime = tbItem:CaleBuffTime() * Env.GAME_FPS;
		me.AddSkillState(tbItem.nBufferId, tbItem.tbBufferLevel[2], 1, nRemainTime, 1);
		me.AddSpeTitle(tbItem.tbTitle[2][1], GetTime() + tbItem:CaleBuffTime(), tbItem.tbTitle[2][2]);
		me.Msg("恭喜您获得使用铁浮城勇士披风的资格！");
		return 1;
	end
	local szMsg = string.format("  您可以带着这个<color=yellow>%s<color>到各大城市找铁浮城佑鲁使者<color=yellow>修木泽<color>处领取一个任务。", it.szName);
	Dialog:Say(szMsg, {"知道了"});
	return 0;
end

function tbItemBase:InitGenInfo()	
	it.SetTimeOut(0, GetTime() + tbItem:CaleBuffTime());
	return {};
end

-----------------------------------------------------------------------------------------------------
--绑定后的令牌
local tbItemBaseEx = Item:GetClass("xiakedaolingpaiEx");

function tbItemBaseEx:OnUse()
	local nRemainTime = tbItem:CaleBuffTime() * Env.GAME_FPS;
	me.AddSkillState(tbItem.nBufferId, tbItem.tbBufferLevel[it.nLevel], 1, nRemainTime, 1);
	if it.nLevel == 1 then
		me.Msg("恭喜您获得使用铁浮城城主披风的资格！");
	else
		me.Msg("恭喜您获得使用铁浮城勇士披风的资格！");
	end
	me.AddSpeTitle(tbItem.tbTitle[it.nLevel][1], GetTime() + tbItem:CaleBuffTime(), tbItem.tbTitle[it.nLevel][2]);
	return 1;
end

function tbItemBaseEx:InitGenInfo()	
	it.SetTimeOut(0, GetTime() + tbItem:CaleBuffTime());
	return {};
end
