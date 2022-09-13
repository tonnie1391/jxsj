-------------------------------------------------------------------
--File: playerprofile.lua
--Author: Brianyao
--Date: 2008-9-24 10:39
--Describe: 个人信息定义
-------------------------------------------------------------------
local preEnv = _G	--保存旧的环境
setfenv(1, PProfile)	--设置当前环境为PProfile

--以下值可以在 kplayerprofileagentprotocol.h 中同步允许最大范围内取值，这些值将在数据被修改的时候做判断
MAX_REAL_NAME_LEN=12    --真实姓名最大长度
MAX_NICK_NAME_LEN=12    --昵称最大长度
MAX_PROFESSION_LEN=12   --职业最大长度
MAX_SLEFTIPS_LEN=20     --口头禅
MAX_CITY_LEN=32         --城市
MAX_FAVOR_LEN=160       --爱好
MAX_BLOG_LEN=40         --博客地址
MAX_DIARY_LEN=200       --点滴
MAX_SNS_ACCOUNT_LEN=20	--SNS帐号名最大长度

--针对一条字符串记录进行操作的枚举
emPF_BUFTASK_NAME=1      --姓名
emPF_BUFTASK_AGNAME=2    --绰号
emPF_BUFTASK_PROFESSION=3  --职业
emPF_BUFTASK_CITY=4       --居住城市
emPF_BUFTASK_TAG=5        --口头禅
emPF_BUFTASK_FAVORITE=6   --爱好
emPF_BUFTASK_BLOGURL=7    --博客地址
emPF_BUFTASK_COMMENT=8    --随笔
emPF_BUFTASK_TTENCENT=9   --腾讯微博帐号名
emPF_BUFTASK_TSINA=10     --新浪微博帐号名

--针对INT值记录进行操作的枚举
emPF_TASK_SEX=1                              --性别
emPF_TASK_BIRTHD=2                           --生日
emPF_TASK_REINS=3                            --感情，由枚举构成，用于选择
emPF_TASK_ONLINE=4                           --核心在线时间，由掩码构成，可以多选
emPF_TASK_FRIEND_ONLY=5                      --是否仅仅是好友可见
ememPF_TASK_VER=6                            --版本号
emPF_TASK_PROFILE_EDITED=7					 --是否已填写过个人信息(此值只用于服务端，客户端无权修改)

preEnv.setfenv(1, preEnv)	--恢复全局环境