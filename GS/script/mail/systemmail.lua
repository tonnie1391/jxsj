-----------------------------------------------------
--文件名		：	mailnew.lua
--创建者		：	ZouYing@kingsoft.net
--创建时间		：	2007-10-25
--功能描述		：	系统信件脚本
------------------------------------------------------

------------------------------------------------------
-- 信件内容格式说明
-- szTitle : 信件标题
-- szContent : <Sender>XXX<Sender> ：表示发件人，在信件内容前必须填写，不填默认为 系统, XXX:就是发件人名字,比如 澄惠，季叔班。。。。。。。。。
------------------------------------------------------

Mail.tbMail = 
{
	[Env.FACTION_ID_SHAOLIN] = 
	{
		szTitle   = "入室弟子诫书"; --少林
		szContent = "<Sender>澄惠<Sender>各位入室弟子：\n\n    经过数月考察，众位入室弟子均得以正式成为我少林弟子，得授少林无上佛法和精深武学。\n\n    本派武学为强身健体，除魔卫道之用。无论是出家弟子还是俗家弟子均要牢记戒令，不得妄杀，不得心生好胜之心，不得将本门武学随意授人，更不得用本门武学为非作歹，为祸武林。若有违者，必按少林门规，严惩不怠。\n\n     <color=green> 此部入门心法，每位入室弟子人手一份，可相互参详钻研，扶持共进。切莫心魔横生，贪功冒进，抑或是挟私偷练，错解经文，以致走火入魔，悔之晚矣！\n\n<color>";
	},
	[Env.FACTION_ID_TIANWANG] = 
	{
		szTitle   = "回帮密令"; --天王
		szContent = "<Sender>季叔班<Sender>    你加入本帮也有些日子，在这段时间中，本帮曾多次派人暗查你的行迹，对于你的表现，帮中长老个个赞口不绝。因此，<color=green>本帮决定从即日起将你正式收归天王，并传你一些较为深奥的武艺。一来助你行走江湖；二来他日遇上强敌也不至于堕了我天王帮的威风。此部功法为我天王帮上乘武学的入门心法，你要牢记苦练，不可怠慢松懈，以免落后于新晋的其他同门。<color>\n\n   另外，掌门人瑛姑不日将返回帮中。本帮全赖帮主呕心沥血才得有今日的威望，迎接帮主是本帮近年来的头等大事，本帮弟子无论身处何处，必须返回帮中，亲迎帮主。\n\n    此刻距离帮主回帮还有些时日，本帮弟子可在料理完手中诸事之后从容返回，无需急赶。\n\n"
	},
	[Env.FACTION_ID_TANGMEN] = 
	{
		szTitle   = "唐鹤手书"; --(唐门)
		szContent = "<Sender>唐鹤<Sender>     唐门历来非唐姓弟子不收，想必你也知悉此事。当日念在你是义军后裔，又有白秋琳极力保举方才将你收入门下，以作察看。\n\n    如今你既可以和我唐门弟子和睦相处，又能潜心励志，身体力行，实为我唐门弟子所不及。因此，<color=green>本门决定授以你唐门绝技之入门功法，你要勤学苦练，若有不解之处，可向众位长老求教。\n\n    本门严禁弟子私下传授武学，即便是唐姓弟子亦是如此，你要切记，以免无心误犯。\n\n<color>";
	},
	[Env.FACTION_ID_WUDU] = 
	{
		szTitle   = "五毒圣令"; --(五毒)
		szContent = "<Sender>胡献姬<Sender>本教为朝廷和武林合力追杀，避入这蛮夷之地，历时已经数年。这数年的蛰伏和等待已经让本教教众濒临绝望。好在教主洪福齐天，圣容广智，已为本教谋好了出头之策，成功指日可待。\n\n     入我教来，必须听领教主，舍己卫教，若有违抗，蛇蚁噬心，万劫不复，此话你等要牢牢记住，以免将来自毁前程。\n\n    <color=green>兴教之举迫在眉睫，也正是因此新晋弟子才得以蒙受圣恩，得赐本教无上毒功的入门心法，你们要潜心苦练，以备将来卫教之用。<color>另外，天王帮和本教仇深似海，杨瑛这个老虔婆更是可恨之极。近闻杨瑛重返天王，本教弟子务须各方查探，留意天王帮的一举一动，若有异象，极早回报。\n\n                       \n";
	},
	
	[Env.FACTION_ID_EMEI] = 
	{
		szTitle   = "峨嵋诫书"; -- (峨嵋)  
		szContent = "<Sender>无念师太<Sender>本派弟子皆为佛祖指引才得以共存于一派，实为前世修来的缘分，门下弟子均须相敬相爱，互持互进，共修佛门大业。\n\n    本派武功为门下弟子护身之用，若有敢恃技凌人，品行不端者，武功收回，逐出师门，永不再录。\n\n     本派弟子入派之后，按资质和进境授以武学。<color=green>如今掌门亲令授你上层武学的入门心法，你要戒骄戒躁，习武之时，不忘佛法，不忘慈悲，不忘芸芸苦难众生，方能成就正果。<color>\n\n    修行一道，不外乎身体力行，亲身感悟。如若得暇，可回转师门，听取掌门教诲，亦能深得裨益。\n\n";
	},
	
	[Env.FACTION_ID_CUIYAN] = 
	{
		szTitle   = "紫烟谕令"; --(翠烟门)
		szContent = "<Sender>郦秋水<Sender>翠烟弟子听令：\n\n    数月之后，本门将有大事发生。<color=green>为防事起突变，门主特许门下弟子入手修习本门神功的入门心法。各弟子要潜心苦练，以备将来守护本门之用。各弟子可相互钻研参悟，共勉共进；不可贪学藏私，急功冒进，以致走火入魔，悔之晚矣！<color>\n\n";
	},
	[Env.FACTION_ID_GAIBANG] = 
	{
		szTitle   = "来自冷秋云的密函"; --(丐帮)
		szContent = "<Sender>冷秋云<Sender>自采石叽一战之后，我丐帮雄风已不复当年，想我丐帮为了武林正义，为了山河社稷，壮士断腕是何等的高义和惨烈，却因此役帮力衰退，无力再如当年般号令群雄，挑起天下第一帮的担子！悲之！叹之！\n\n    冷某一介书生，蒙石帮主不弃收归门下，共创一番事业，重振我丐帮往日雄风，心诚惶恐。不过，今日看到本帮新晋的这些弟子，冷某不再惶恐，且深信本帮在石帮主的率领下，在各位兄弟的共同努力下，振兴丐帮指日可待。\n\n    <color=green>随信附上本帮上乘武学的入门心法，你要勤学苦练，莫要怠慢，他日将视你进境提升负袋，切记！切记！<color>\n\n    另外听闻天王帮帮主杨瑛不日即要返回天王，此人乃是巾帼中的翘楚，见识高远，武艺超凡，若能得她指点一二，必定终身受益。你若无要事在身，定要前往天王帮，以待机缘。\n\n";
	},
	[Env.FACTION_ID_TIANREN] = 
	{
		szTitle		= "教主亲谕"; --(天忍)
		szContent   = "<Sender>完颜襄<Sender>各位兄弟想我天忍教，也曾多次为朝廷立下汗马功劳，却因前任教主驱策不力而致采石叽巨败，多年名号付诸流水，叹之！憾之！\n\n    如今，完颜襄承蒙皇恩，力挑重振天忍雄风之重担，复蒙各位兄弟不弃，入我天忍，当是天助我天忍复兴。\n\n    如今本教主决定一改教中往日陈规，令谕教内兄弟皆能修习本教无上神功，以武会友，决出佼佼者。\n\n  <color=green>此物为神功之入门心法，各位兄弟可潜心体悟，当会各有进境。待到略有所成，当相赠中级心法。<color>\n\n";
	},
	[Env.FACTION_ID_WUDANG] = 
	{
		szTitle   = "洞虚手书"; --(武当)
		szContent = "<Sender>洞虚真人<Sender>你入我武当，当有数月了吧？这数月来你的一举一动都有本派俗家弟子回报掌门。掌门对你颇为赞许，特许你提早开始修行本门上乘武学。\n\n    <color=green>随信附带的便是本门上乘武学的入门诀要，你要用心体悟，潜心苦练。<color>\n\n    武当弟子行走江湖，定要行得端，坐得正，不畏强权，不受诱惑，仗剑行侠，济世救人，才是我道门本色！\n\n";
	},
	[Env.FACTION_ID_KUNLUN] = 
	{
		szTitle   = "合宗大典邀请函"; --(昆仑)
		szContent = "<Sender>谢雨田<Sender>各位昆仑弟子：\n    我昆仑一派，自叹息老人之后便陷入多年的内斗之中。这十数年来，每次内斗便使我昆仑元气大伤一次，实为昆仑不幸，昆仑弟子的不幸。\n\n    如今在掌门人宋秋石的大力主持之下，我昆仑派终于停止了多年的内斗纷争，复归一统。\n\n    九月九日本派将要举行合宗大典，将散乱的各派各系归于一门。请各位散落在外的昆仑弟子届时回转昆仑，认派归宗，一统昆仑。\n\n    <color=green>另外，掌门人鉴于本门弟子武学繁杂，师承各家，难以尽展威力；特手书一份武学心法，请门下弟子苦心研习，势必可以将散乱的真气和驳杂的武学融为一体，大增威力。此书为本门之秘，不得外泄，切记！切记！<color>\n\n";
	},
	[Env.FACTION_ID_MINGJIAO] = 
	{
		szTitle   = "善母令"; --(明教)
		szContent = "<Sender>善母<Sender>诸位教众：\n	入我教来，即我兄弟，均享平等之教规庇护，均受宗主之圣令开示。如今四方邪教兴起，惑乱民众；各大门派又视本教为异端，图谋不轨。此为圣教兴盛使然，亦乃众兄弟修行之因。<color=red>本尊奉宗主圣谕授众兄弟护身法门，务需勤加练习，不可怠慢，早日同归大光明世界。<color>\n";
	},
	[Env.FACTION_ID_DALIDUANSHI] = 
	{
		szTitle   = "段氏手谕"; --(大理段氏)
		szContent = "<Sender>段智兴<Sender>字谕众弟子：\n	尔等因慕我段氏武学而求学至此，入门虽不久，也当知学艺之艰辛。本王授艺不分亲疏，唯靠尔等自觉自悟。<color=red>今特赐师门秘籍一册，尔等须详加参悟，静心体会，<color>莫要辜负本王成全之心。\n";
	},
	[Env.FACTION_ID_GUMU] = 
	{
		szTitle   = "古墓谕令"; --(古墓)
		szContent = "<Sender>林烟卿<Sender>字谕众弟子：\n	夫天道盈缺，人事多屯。居处屯危，不能自慎而能鮨济者，天下无之。欲知自慎，须当去之于微。<color=red>先师传下古经一卷，见微知著，慎独养德。<color>坦荡于天地之间。\n";
	},
}

Mail.tbZhongJiMiJiMail = {
	szTitle = "Mật tịch Trung cấp",
	tbItem = {18, 1, 1844, 1},
	szContent = [[
《百尺经》是一位有大智慧的禅师由佛经中参悟出来的武经，是武林各派均想借阅的奇书。近年来因义军多行善事，此为禅师便将这百尺经送给我义军，望将来有缘之人可悟得其中奥妙。你已帮义军和百姓做过许多有意义的事，希望你能悟得这本秘籍中的奥妙，让武艺更上一层楼。
恭喜侠士达到70级，现在你可以直接在此封邮件处领取中级秘籍，当前门派的两条路线各一本。需要注意的是，只能领取一次，即在领取过当前门派的中级秘籍后，就不能再领取其他多修门派的中级秘籍了。所以请谨慎选择。
一本秘籍无法将秘籍技能修炼满，可以在龙五太爷处用游龙古币换取更多的中级秘籍。
]],
};

Mail.tbGaoJiMiJiMail = {
	szTitle = "Mật tịch Cao cấp",
	tbItem = {18, 1, 1845, 1},
	szContent = [[
天之道，损有余而补不足，是故虚胜实，不足胜有余。
你的武功修为已经渐入佳境，秋姨早已为你准备好了新的武学技艺——高级秘籍。潜心研习，若要彻底参透其中妙法，还可入游龙阁一探虚实，练成秘籍中的武功，行走江湖，护己救人！
恭喜侠士达到100级，现在你可以直接在此封邮件处领取高级秘籍，当前门派的两条路线各一本。需要注意的是，只能领取一次，即在领取过当前门派的高级秘籍后，就不能再领取其他多修门派的高级秘籍了。所以请谨慎选择。
一本秘籍无法将秘籍技能修炼满，可以在龙五太爷处用游龙古币换取更多的高级秘籍。
]],
};

local szSignetMailTitle = "Chưởng môn truyền dụ";
local szSignetMail = [[
Tự dụ chúng đệ tử:

   Các phái võ học có phân chia ngũ hành, tương sinh tương khắc; nếu gặp môn phái tương khắc ngũ hành cố thị vạn hạnh, nhiên không khỏi gặp phải khắc chế bản môn ngũ hành cao thủ, rất dễ thảm bại. Nay đặc biệt ban thưởng ngươi "Ngũ Hành Ấn", đeo vật ấy, có thể khả giải tương sinh tương khắc. Vật ấy lưỡng trọng diệu dụng, nếu gặp môn phái tương khắc ngũ hành, khả lệnh bản môn võ học uy lực xoay mình tăng; như ngộ bản môn khắc tinh, chuyển khả lệnh bản môn đệ tử ít bị thương tổn, có thể may mắn còn tồn tại.

   Các đệ tử được ban thưởng vật ấy, phải cẩn thận sử dụng, không được dùng vào việc ác, gieo hại sư môn.

                   Chưởng môn kính bút
]];

local  szYuanXiao09Mail = [[
<color=red>“庆元宵，玩家回馈活动”隆重开启<color>
<color=yellow>活动时间：<color>
  2月6日更新维护后~2月20日0点
<color=yellow>活动基本条件：<color>
  2月份充值达到15元或者角色江湖威望达到200，角色等级69级以上。
<color=yellow>活动一：礼官元宵送好礼<color>
  活动期间，每个角色有可以去礼官处领取奖励，奖励共三种：新春礼盒，新年红包，新春大福袋，每种可领一次。奖励丰厚，不可错过。
<color=yellow>活动二：新春的祝福<color>
  活动期间，每个角色有10次获得好友祝福的机会。玩家需要与送出祝福方组队去和礼官对话，成功后被祝福方能获得奖励。
<color=yellow>活动三：晏若雪的礼物<color>
  新年活动结束后，在活动时间内飞絮崖荣誉排行榜前20名的玩家能在晏若雪处获得她送出的礼物。
	
以上内容详询各大城市新手村礼官或查阅帮助锦囊（F12）。
]]


local szFuliMail = string.format([[
    "Kiếm Thế" đang có hoạt động tặng phúc lợi cho người chơi
    Hiện giờ, nếu bạn đã đạt được những điều kiện nhất định để nhận được phúc lợi sau:
    Uy danh giang hồ trong ngày đạt điểm nhất định: Mua Hoạt Khí Tán với giá ưu đãu giảm 60 phần trăm
    Uy danh giang hồ trong tuần đạt điểm nhất định: 12 vạn bạc khóa đổi 12 vạn bạc thường
    Hàng tháng %s đến mức nhất định: Nhận Lệnh bài Uy danh giang hồ
<color=red>    Lưu ý: Điểm uy danh giang hồ được xác định dựa trên xếp hạng người chơi của server, vì vậy các bạn hãy tham gia nhiều hoạt động trong trò chơi để nhận uy danh giang hồ nhé.<color>
    Thông tin chi tiết xem cẩm nang trợ giúp(F12).
 Đến Lễ Quan Tân Thủ Thôn nhận phúc lợi trên càng sớm càng tốt. Chúc bạn vui vẻ!
]], IVER_g_szPayName)

local szHighbookMailTitle = "Tu luyện Mật Tịch cao cấp";
local szHighbookMail = [[
Thiên chi nói, tổn hại có thừa mà bổ bất túc, thị cố hư thắng thực, bất túc thắng có thừa.
Của ngươi võ công tu vi đã rơi vào cảnh đẹp, có thể bạch thu lâm chỗ tìm kiếm một quyển cao cấp bí tịch, chuyên tâm nghiên tập, nếu yếu triệt để hiểu thấu đáo trong đó diệu pháp, hoàn khả nhập du long các tìm tòi hư thực, luyện thành bí tịch trung đích võ công, đi đi giang hồ, hộ mình cứu người!
Chúc mừng hiệp sĩ đạt được 100 cấp, hiện tại ngươi khả dĩ hoa bạch thu lâm lĩnh cao cấp bí tịch, trước mặt môn phái đích lưỡng con đường tuyến các một quyển. Nhu phải chú ý chính là, chỉ có thể lĩnh một lần, tức tại trước mặt môn phái lĩnh quá cao cấp bí tịch hậu, sẽ không năng tái lĩnh cái khác đa tu môn phái đích cao cấp bí tịch liễu. Sở dĩ thỉnh cẩn thận tuyển trạch.
Một quyển bí tịch vô pháp tương bí tịch kỹ năng tu luyện mãn, khả dĩ tại long ngũ ông chỗ dùng du long cổ tệ đổi lấy càng nhiều đích cao cấp bí tịch.
]];

local szFightPowerMailTitle = "Sức chiến đấu";
local szFightPowerMail = [[
狭路相逢勇者胜！
一名真正的侠士不仅需要勇气，还应具备强悍的战斗力作为后盾！
按<color=orange>“Y”<color>查看你的<color=orange>战斗力<color>，其高低会影响你在PK时受到的伤害。
<color=orange>更多请查看F12-详细帮助-战斗力<color>
]];

Mail.tbMailItem_Gumu_Horse = {
	[20] = {
		[1] = {
			szTitle = "【剑初】林烟卿字谕众弟子",
			szContent = "古墓一派不愿涉足江湖，奈何是非难断，偏卷我入江湖纷争。既以入尘，自不可任人轻看。古墓派武学以《玉女心经》最为上乘，却也惧内力驱使之时，热劲失散走火入魔。予你雪山白鹿，有它时时相伴，辅以本派养生法门，自可身心清净，益助修习。",
			[Env.SEX_MALE] = {1,12,65,1},
			[Env.SEX_FEMALE] = {1,12,65,1},
		},
		[2] = {
			szTitle = "【针初】林烟卿字谕众弟子",
			szContent = "古墓一派不愿涉足江湖，奈何是非难断，偏卷我入江湖纷争。既以入尘，自不可任人轻看。古墓派武学以《玉女心经》最为上乘，却也惧内力驱使之时，热劲失散走火入魔。予你御魂沙砾，以它时时相克，辅以本派养生法门，自可身心清净，益助修习。",
			[Env.SEX_MALE] = {1,12,66,1},
			[Env.SEX_FEMALE] = {1,12,67,1},
		},
	},
	[50] = {
		[1] = {
			szTitle = "【剑中】林烟卿字谕众弟子",
			szContent = "古墓一派不愿涉足江湖，奈何是非难断，偏卷我入江湖纷争。既以入尘，自不可任人轻看。古墓派武学以《玉女心经》最为上乘，却也惧内力驱使之时，热劲失散走火入魔。如今，你习古墓武学已有时日，予你冰原白鹿，有它时时相伴，辅以本派养生法门，自可身心清净，益助修习。",
			[Env.SEX_MALE] = {1,12,65,2},
			[Env.SEX_FEMALE] = {1,12,65,2},
		},
		[2] = {
			szTitle = "【针中】林烟卿字谕众弟子",
			szContent = "古墓一派不愿涉足江湖，奈何是非难断，偏卷我入江湖纷争。既以入尘，自不可任人轻看。古墓派武学以《玉女心经》最为上乘，却也惧内力驱使之时，热劲失散走火入魔。如今，你习古墓武学已有时日，予你御魂之石，以它时时相克，辅以本派养生法门，自可身心清净，益助修习。",
			[Env.SEX_MALE] = {1,12,66,2},
			[Env.SEX_FEMALE] = {1,12,67,2},
		},	
	},
	[100] = {
		[1] = {
			szTitle = "【剑高】林烟卿字谕众弟子",
			szContent = "古墓一派不愿涉足江湖，奈何是非难断，偏卷我入江湖纷争。既以入尘，自不可任人轻看。古墓派武学以《玉女心经》最为上乘，却也惧内力驱使之时，热劲失散走火入魔。如今，你习古墓武学尚达臻镜，已能驾驭寒冰白鹿，有它时时相伴，辅以本派养生法门，自可身心清净，益助修习。",
			[Env.SEX_MALE] = {1,12,65,3},
			[Env.SEX_FEMALE] = {1,12,65,3},
		},
		[2] = {
			szTitle = "【针高】林烟卿字谕众弟子",
			szContent = "古墓一派不愿涉足江湖，奈何是非难断，偏卷我入江湖纷争。既以入尘，自不可任人轻看。古墓派武学以《玉女心经》最为上乘，却也惧内力驱使之时，热劲失散走火入魔。如今，你习古墓武学尚达臻镜，已能驾驭御魂之佩，以它时时相克，辅以本派养生法门，自可身心清净，益助修习。";
			[Env.SEX_MALE] = {1,12,66,3},
			[Env.SEX_FEMALE] = {1,12,67,3},
		},
	},
};

function Mail:OnLevelUp(nLevel)
	
--	if (nLevel == 20) then
--		if(me.nFaction < 1 or me.nRouteId < 1) then
--			Dbg:WriteLogEx(Dbg.LOG_ERROR, "Mail", "路线，门派不正确！");
--			return;
--		end
--		local nMijiId = Npc.tbMenPaiNpc.tbFcts[me.nFaction].tbMiji[me.nRouteId];
--		
--		if (not nMijiId) then
--			Dbg:WriteLogEx(Dbg.LOG_ERROR, "Mail", "路线，门派不正确！");	
--			return;
--		end
--	
--		local tbMijiItem = { Item.EQUIP_GENERAL, 14, nMijiId, 1, -1 };
--		
--
--		local nRet = KPlayer.SendMail(me.szName, Mail.tbMail[me.nFaction].szTitle, Mail.tbMail[me.nFaction].szContent, 
--				0, 0, 1, unpack(tbMijiItem));
--		if (nRet == 0) then
--			Dbg:WriteLogEx(Dbg.LOG_ERROR, "Mail", "系统信件发送失败！");  
--		end		
--	end

	-- if nLevel == 25 then
		-- local szMsg = [[    恭喜侠士已经达到25级，您现在可以去挑战新的<color=yellow>【碧落谷】藏宝图副本<color>了！您可以按下“<color=yellow>K<color>”键来呼出活动日历窗口，在藏宝图功能部分点选<color=yellow>领取您的藏宝图挑战次数<color>，每天都能领取，不要忘记哦！然后您可以前往<color=yellow>江津村、云中镇、永乐镇<color>，在<color=yellow>藏宝图军需官<color>处查询使用藏宝图功能，并组队报名参加<color=yellow>【挑战碧落谷】<color>了！
-- 整理好您的包裹，召集您的队友，一同前往碧落谷探秘吧！]];
		-- KPlayer.SendMail(me.szName, "新藏宝图开户，25级即可挑战！", szMsg);
	-- end

	if nLevel == 60 then
		-- 发放五行印
		if(me.nFaction < 1) then
			Dbg:WriteLogEx(Dbg.LOG_ERROR, "Mail", "发五行印，门派不正确！");
			return;
		end
		local tbSignet = {Item.EQUIP_GENERAL, 16, me.nFaction, 1, 0 };
		local nRet = KPlayer.SendMail(me.szName, szSignetMailTitle, szSignetMail, 
				0, 0, 1, unpack(tbSignet));
		if (nRet == 0) then
			Dbg:WriteLogEx(Dbg.LOG_ERROR, "Mail", "系统信件发送失败！");  
		else
			me.SetTask(2023, 5, 1);
		end	
	end
	
	if (nLevel == 70) then
		local nRet = KPlayer.SendMail(me.szName, self.tbZhongJiMiJiMail.szTitle, self.tbZhongJiMiJiMail.szContent, 
				0, 0, 1, unpack(self.tbZhongJiMiJiMail.tbItem));
		if (nRet == 0) then
			Dbg:WriteLogEx(Dbg.LOG_ERROR, "Mail", me.szName, "中级秘籍信件发送失败！");  
		end
		me.SetTask(Npc.tbMenPaiNpc.nTaskGroup_Miji, Npc.tbMenPaiNpc.nTaskId_ZhongMiji, GetTime());
	end
	
	if nLevel == 100 then
		-- KPlayer.SendMail(me.szName, szHighbookMailTitle, szHighbookMail);
		if Player.tbFightPower:IsFightPowerValid() == 1 then
			KPlayer.SendMail(me.szName, szFightPowerMailTitle, szFightPowerMail);
		end

		local nRet = KPlayer.SendMail(me.szName, self.tbGaoJiMiJiMail.szTitle, self.tbGaoJiMiJiMail.szContent, 
				0, 0, 1, unpack(self.tbGaoJiMiJiMail.tbItem));
		if (nRet == 0) then
			Dbg:WriteLogEx(Dbg.LOG_ERROR, "Mail", me.szName, "高级秘籍信件发送失败！");  
		end
		me.SetTask(Npc.tbMenPaiNpc.nTaskGroup_Miji, Npc.tbMenPaiNpc.nTaskId_GaoMiji, GetTime());
	end
	-- 设置等级排行榜小数位
	-- 全局服没有应用战斗力等级排行榜，全局服时也不用同步经验百分比
	if (IsGlobalServer() == false) then	
		GCExecute({"Player.tbFightPower:UpdatePlayerExp", me.nId, me.nLevel, me.GetExpPercent(0)});
	end

	self:SendGumuMail();
end

function Mail:SendGumuMail()
	if (me.nFaction ~= Env.FACTION_ID_GUMU) then
		return 0;
	end

	local nLevel = me.nLevel;
	local nRouteId = me.nRouteId;
	if (not self.tbMailItem_Gumu_Horse[nLevel] or not self.tbMailItem_Gumu_Horse[nLevel][nRouteId]) then
		return 0;
	end

	local tbHorse = self.tbMailItem_Gumu_Horse[nLevel][nRouteId][me.nSex];
	
	if (not tbHorse) then
		Dbg:WriteLogEx(Dbg.LOG_ERROR, "Mail", "古墓派系统信件没有物品", me.szName, me.nLevel, me.nFaction, me.nRouteId);  
		return 0;
	end
	
	local szMailContext = self.tbMailItem_Gumu_Horse[nLevel][nRouteId].szContent;
	local szMailTitle = self.tbMailItem_Gumu_Horse[nLevel][nRouteId].szTitle;
	local nRet = KPlayer.SendMail(me.szName, szMailTitle, szMailContext, 0, 0, 1, unpack(tbHorse));
	if (nRet == 0) then
		Dbg:WriteLogEx(Dbg.LOG_ERROR, "Mail", "古墓派系统信件发送失败！");  
	end
	return 1;
end

function Mail:_OnLogin()
	-- TODO 封测使用 临时的
	self:SendSystemMail();
end

function Mail:SendSystemMail()
	
	local bSend	= me.GetTask(2023, 1) or 0;
	local szTime = GetLocalDate("%y%m%d");

	-- 元宵节活动邮件
	if (szTime >= "090206" and szTime <= "090220" and me.GetTask(2023, 6) == 0) then
		KPlayer.SendMail(me.szName, "庆元宵玩家回馈活动", szYuanXiao09Mail);
		me.SetTask(2023, 6, 1);
	end
	-- 福利 每月发送一封
	
	local nMonth = tonumber(GetLocalDate("%m"));
	if (me.GetTask(2023, 7)  ~= nMonth) then
		local nMoney = 12 * CoinExchange.__ExchangeRate_wellfare;
		--KPlayer.SendMail(me.szName, "福利大派送", string.format(szFuliMail, nMoney));
		KPlayer.SendMail(me.szName, "Phúc lợi lớn", szFuliMail, nMoney)
		me.SetTask(2023, 7, nMonth);
	end
	
	bSend = me.GetTask(2023, 5) or 0;
	if (0 == bSend) and me.nLevel >= 60 then
		-- 发放五行印
		if(me.nFaction < 1) then
			Dbg:WriteLogEx(Dbg.LOG_ERROR, "Mail", "发五行印，门派不正确！");
			return;
		end
		local tbSignet = {Item.EQUIP_GENERAL, 16, me.nFaction, 1, 0 };
		KPlayer.SendMail(me.szName, szSignetMailTitle, szSignetMail,
				0, 0, 1, unpack(tbSignet));
		me.SetTask(2023, 5, 1);
	end
end

if (MODULE_GAMESERVER) then	-- GS专用
	-- 注册事件回调
	PlayerEvent:RegisterGlobal("OnLevelUp", Mail.OnLevelUp, Mail);
	PlayerEvent:RegisterGlobal("OnLogin", Mail._OnLogin, Mail);
end
