--圣诞老人（城市）
--孙多良
--2008.12.16
if  MODULE_GC_SERVER then
	return;
end
local tbNpc = Npc:GetClass("xmas_laoren");
tbNpc.TSK_GROUP = 2027;
tbNpc.TSK_ID = 97;
tbNpc.DEF_ITEM = {18,1,269,1};	--袜子Id
tbNpc.SNOW_ITEM = {18,1,213,1}; -- 雪花Id

function tbNpc:OnDialog()
	local nCheck = SpecialEvent.Xmas2008:Check();
	if nCheck == -1 then
		Dialog:Say("圣诞老人：活动还没开始，我还要准备一段时间才有礼物呢。")
		return 0;		
	end
	if nCheck == 0 then
		Dialog:Say("圣诞老人：礼物都送完了，休息一会就离开。")
		return 0;
	end
	local szMsg = "圣诞老人：哈哈，大家圣诞快乐哦！";
	local tbOpt = {
		{"领取圣诞袜子", self.GetSocks, self},
		{"用雪花兑换圣诞袜子",self.ChargeSocks, self},
		{"了解圣诞活动",self.About, self},
		{"Ta chỉ xem qua"},
	};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:GetSocks(nSure)
	if not nSure then
		local tbOpt = 
		{
			{"我要圣诞袜子", self.GetSocks, self, 1},
			{"Ta chỉ xem qua"},
		}
		Dialog:Say("在活动期间，各位每天可以在我这里领取一只袜子，里面有很多礼物哦，呵呵！", tbOpt);
		return 0;
	end
	
	if me.nLevel < 60 then
		Dialog:Say("你的江湖历练不够，到了60级再来吧。");
		return 0;
	end
	
	local nCurDate = tonumber(GetLocalDate("%y%m%d"));
	if me.GetTask(self.TSK_GROUP, self.TSK_ID) >= nCurDate then
		Dialog:Say("今天你已经拿了袜子了哦，礼物不多，要给其他人留点嘛！", {{"哦，我忘了"}});
		return 0;
	end
	
	if me.CountFreeBagCell() < 1 then
		local szAnnouce = "Hành trang không đủ ，请留出1格空间再试。";
		Dialog:Say(szAnnouce);
		return 0;
	end
	
	local pItem = me.AddItem(unpack(self.DEF_ITEM));
	if pItem then
		pItem.Bind(1);
		me.SetTask(self.TSK_GROUP, self.TSK_ID, nCurDate);
	end
	
	Dialog:Say("这是你今天的礼物，拿好不要弄丢了哦，哈哈，记得明天再来啊", {{"谢谢圣诞老人"}});
end


function tbNpc:ChargeSocks()
	if me.nLevel < 60 then
		Dialog:Say("你的江湖历练不够，到了60级再来吧。");
		return 0;
	end

	local szContent = "请放入雪花。每<color=yellow>5个雪花<color>换取一个<color=yellow>圣诞袜子<color>。";
	Dialog:OpenGift(szContent, nil, {self.OnOpenGiftOk, self});
end

function tbNpc:OnOpenGiftOk(tbItemObj)
	local tbItemCount = {};
	local szName = string.format("%s,%s,%s,%s",self.SNOW_ITEM[1], self.SNOW_ITEM[2], self.SNOW_ITEM[3], self.SNOW_ITEM[4]);
	for _, tbItem in pairs(tbItemObj) do
		local pItem = tbItem[1];
		local szKey = string.format("%s,%s,%s,%s",pItem.nGenre,pItem.nDetail,pItem.nParticular,pItem.nLevel);
		if not  tbItemCount [szKey] then
			tbItemCount[szKey] = 0;
		end
		tbItemCount[szKey] = tbItemCount[szKey] + pItem.nCount;
	end
	local nSockCount = math.floor(tbItemCount[szName]/5);
	if nSockCount == 0 then
		me.Msg("没有足够的雪花");
		return 0;
	end

	if me.CountFreeBagCell() < nSockCount then
		me.Msg("Hành trang không đủ ，请留出足够的空间再试。");		
		return 0;
	end
	
	-- 检查背包
	me.ConsumeItemInBags2(nSockCount * 5, self.SNOW_ITEM[1], self.SNOW_ITEM[2], self.SNOW_ITEM[3], self.SNOW_ITEM[4], nil, -1);
	me.AddStackItem(self.DEF_ITEM[1],self.DEF_ITEM[2],self.DEF_ITEM[3],self.DEF_ITEM[4],nil,nSockCount);
end

tbNpc.tbAbout = 
{
[1] = [[
  活动期间，60级以上的角色每天都可以到<color=yellow>圣诞老人<color>这里来领取一个<color=yellow>圣诞袜子<color>，今天你领了吗？]],

[2] = [[
  活动期间，在逍遥谷，宋金战场，白虎堂，门派竞技场地， 你都有可能遇到<color=yellow>圣诞老人<color>，他会给你一个装满礼物的<color=yellow>圣诞袜子<color>哦！]],

[3] = [[
  活动期间，在逍遥谷，宋金战场，白虎堂，门派竞技场地 ，你都有可能遇到挂满礼物的<color=yellow>圣诞树<color>，从树上你可能获得<color=yellow>小雪团<color>或者<color=yellow>圣诞袜子<color>。]],

[4] = [[
  活动期间，你可以用5个<color=yellow>雪花<color>在我这兑换一只<color=yellow>圣诞袜子<color>，雪花你可以使用生活技能制作。
  雪花如何得到啊？你可以从<color=yellow>雪堆<color>采集或<color=yellow>圣诞树<color>上摘取 ，再加工得到“<color=yellow>小雪块<color>”，进而制作出“<color=yellow>雪花<color>”即可。
	]],

[5] = [[
  打开<color=yellow>圣诞袜子<color>，你可以获得奖励，还有一定几率获得一个<color=yellow>圣诞礼盒<color>哦,不过每个人最多只能使用<color=yellow>100只袜子<color>。]],

[6] = [[
  你自己获得的<color=yellow>圣诞礼盒<color>只能送人，但是呢，你可以使用别人送你的<color=yellow>圣诞礼盒<color>进而获得奖励，所以礼尚往来才是王道啊，哈哈~~~
  话说回来，每个人最多能用<color=yellow>10个<color>礼盒，多的怎么办呢？转送别人嘛！不够怎么办呢？据说<color=yellow>奇珍阁<color>有卖。]],
}

function tbNpc:About()
	local szMsg = "圣诞活动多多，你要了解哪个呢？";
	local tbOpt = {
		{"圣诞老人的每日礼物", self.OnAbout, self, 1},
		{"邂逅圣诞老人", self.OnAbout, self, 2},
		{"偶遇圣诞树", self.OnAbout, self, 3},
		{"雪花换圣诞袜子", self.OnAbout, self, 4},
		{"圣诞袜子的奖励", self.OnAbout, self, 5},
		{"圣诞礼盒的用途", self.OnAbout, self, 6},
		{"Tôi hiểu"},
	}
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:OnAbout(nNo)
	local szMsg = self.tbAbout[nNo];
	local tbOpt = {
		{"Quay lại", self.About, self},
		{"Kết thúc đối thoại"},
	}
	Dialog:Say(szMsg, tbOpt);
end
