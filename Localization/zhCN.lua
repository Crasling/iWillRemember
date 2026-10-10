-- ═════════════════════════
-- ██╗ ██╗    ██╗ ██████╗ 
-- ╚═╝ ██║    ██║ ██╔══██╗
-- ██║ ██║ █╗ ██║ ██████╔╝
-- ██║ ██║███╗██║ ██  ██╔
-- ██║ ╚███╔███╔╝ ██   ██╗ 
-- ╚═╝  ╚══╝╚══╝  ╚══════╝ 
-- ═════════════════════════

local addonName, addon = ...
if GetLocale() ~= "zhCN" then return end

local L = LibStub("AceLocale-3.0"):NewLocale("iWR", "zhCN")
if not L then return end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                     颜色配置                                     │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
local Colors = {
    -- 标准颜色
    iWR = "|cffff9716",  -- 插件主色调
    White = "|cFFFFFFFF", -- 白色
    Black = "|cFF000000", -- 黑色
    Red = "|cFFFF0000",   -- 红色
    Green = "|cFF00FF00", -- 绿色
    Blue = "|cFF0000FF",  -- 蓝色
    Yellow = "|cFFFFFF00",-- 黄色
    Cyan = "|cFF00FFFF",  -- 青色
    Magenta = "|cFFFF00FF",-- 品红
    Orange = "|cFFFFA500",-- 橙色
    Gray = "|cFF808080",  -- 灰色

    -- 魔兽世界职业颜色
    Classes = {
        WARRIOR = "|cFFC79C6E",       -- 战士
        PALADIN = "|cFFF58CBA",       -- 圣骑士
        HUNTER = "|cFFABD473",        -- 猎人
        ROGUE = "|cFFFFF569",         -- 潜行者
        PRIEST = "|cFFFFFFFF",        -- 牧师
        SHAMAN = "|cFF0070DE",        -- 萨满祭司
        MAGE = "|cFF40C7EB",          -- 法师
        WARLOCK = "|cFF8788EE",       -- 术士
        DRUID = "|cFFFF7D0A",         -- 德鲁伊
        DEATHKNIGHT = "|cFFC41F3B",   -- 死亡骑士
        MONK = "|cFF00FF98",          -- 武僧
        DEMONHUNTER = "|cFFA330C9",   -- 恶魔猎手
        EVOKER = "|cFF33937F"         -- 唤魔师
    },

    -- 重置颜色
    Reset = "|r"
}

local DefaultMessageStart = Colors.iWR .. "[iWR]: "
local function Msg(message)
    return DefaultMessageStart .. message
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                 文本模板                                       │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["NoteToolTip"] = Colors.iWR .. "[iWR]: "
L["DefaultNameInput"] = "输入玩家名称..."
L["DefaultNoteInput"] = "输入备注..."
L["MinimapButtonLeftClick"] = (Colors.Yellow .. "左键点击: " .. Colors.Orange .. "打开iWR主菜单")
L["MinimapButtonShiftLeftClick"] = (Colors.Yellow .. "Shift+左键点击: " .. Colors.Orange .. "打开iWR数据库")
L["MinimapButtonRightClick"] = (Colors.Yellow .. "右键点击: " .. Colors.Orange .. "打开设置界面")
L["CharNoteCreated"] = Colors.iWR .."] 已添加至iWR数据库。|r"
L["CharNoteUpdated"] = Colors.iWR .."] 已在iWR数据库中更新。|r"
L["CharNoteAppended"] = Colors.iWR .."] 新备注已追加至iWR数据库。|r"
L["CharNoteRemoved"] = Colors.iWR .."] 已从iWR数据库中移除。|r"
L["CharNoteClassMissing"] = " 职业信息缺失，下次选中该玩家时将自动补充。"
L["CharNoteColorUpdate"] = Colors.iWR .."] 在iWR数据库中检测到缺失职业信息，已为其补充职业颜色标记。"
L["CharNoteFactionMissing"] = " 阵营信息缺失，下次选中该玩家时将自动补充。"
L["CharNoteFactionUpdate"] = Colors.iWR .."] 在iWR数据库中检测到缺失阵营信息，已为其补充阵营标记。"
L["Translations"] = "语言翻译"
L["DiscordLinkMessage"] = "复制此链接加入我们的Discord服务器，获取支持与更新通知。"
L["CreatedBy"] = "创建者: " 
L["AboutMessageInfo"] = Colors.iWR .. "iWillRemember " .. Colors.Reset .. "是一款帮助你记录并与好友共享玩家备注的插件。"
L["AboutMessageEarlyDev"] = Colors.iWR .. "iWR " .. Colors.Reset .. "目前处于早期开发阶段。如遇问题、有疑问或建议，欢迎加入Discord反馈。"
L["Tab1General"] = "通用设置"
L["Tab2Sync"] = "同步设置"
L["Tab3Backup"] = "备份设置"
L["Tab4About"] = "关于插件"
L["NoBackup"] = "暂无可用备份"
L["LastBackup1"] = "最后备份时间: "
L["at"] = " 于 "
L["BackupRestoreError"] = Colors.Red .. "[iWR]: 未找到可恢复的备份文件。"
L["BackupRestore"] = Colors.iWR .. "[iWR]: 已从备份恢复数据库，备份创建时间为 "
L["RestoreConfirm"] = Colors.Red .. "确定要使用备份数据覆盖当前的iWR数据库吗？|n此操作不可撤销。|n|n备份创建时间："
L["UnknownDate"] = "未知日期"
L["UnknownTime"] = "未知时间"
L["Yes"] = "是"
L["No"] = "否"
L["RestoreDatabase"] = "恢复数据库"
L["EnableBackup"] = "启用自动备份"
L["WhiteListTitle"] = Colors.iWR .. "白名单"
L["AddtoWhitelist"] = Colors.iWR .. "添加好友至白名单："
L["Friends"] = "好友"
L["AllFriends"] ="全部好友"
L["Whitelist"] = "白名单"
L["OnlyWhitelist"] = "仅同步白名单"
L["EnableSync"] = "启用与好友同步"
L["SyncSettings"] = Colors.iWR .. "同步设置"
L["ShowAuthor"] = "在提示框显示备注创建者"
L["ToolTipSettings"] = Colors.iWR .. "提示框设置"
L["EnableSoundWarning"] = "启用声音提醒"
L["EnableGroupWarning"] = "启用小队提醒"
L["WarningSettings"] = Colors.iWR .. "提醒设置"
L["ShowChatIcons"] = "在聊天框显示名声图标"
L["SimpleMenu"] = "简易菜单模式"
L["EnhancedFrame"] = "显示增强目标框体"
L["DisplaySettings"] = Colors.iWR .. "显示设置"
L["SettingsTitle"] = Colors.iWR .." 插件选项"
L["VersionWarning"] = Colors.iWR .. "[iWR]: " .. Colors.Yellow.. "警告" .. Colors.iWR .. "：当前版本为测试版，可能存在数据库不稳定或异常问题。如不想使用测试版，请降级至最新正式版本。"
L["DBNameNotFound1"] = Colors.iWR .. "[iWR]: 名称 [|r"
L["DBNameNotFound2"] = Colors.iWR .. "] 不存在于数据库中。"

L["HelpSync"] = Colors.Yellow .. "同步方法： " .. Colors.iWR .. "在游戏社交面板添加好友（仅支持魔兽世界好友列表，不支持战网实名好友），且双方互加好友后即可完成同步。"
L["HelpUse"] = Colors.Yellow .. "使用方法： " .. Colors.iWR .. "选中目标玩家或手动输入其名称，可选择添加备注，然后点击“尊敬”、“喜欢”、“不喜欢”或“厌恶”按钮，即可将该玩家保存至数据库。"
L["HelpClear"] = Colors.Yellow .. "清除方法： " .. Colors.iWR .. "点击“清除”按钮可将玩家名称输入框中的角色从数据库移除；也可在数据库中通过“移除”按钮删除，或直接编辑对应记录。"
L["HelpSettings"] = Colors.Yellow .. "设置菜单： " .. Colors.iWR .. "右键点击小地图图标可打开设置菜单。"
L["HelpDiscord"] = Colors.Yellow .."Discord帮助： " .. Colors.iWR .. "未输入玩家名称时点击问号按钮，可将链接代码复制到备注栏，以便复制加入[https://discord.gg/8nnt25aw8B]"

L["Russian"] = "俄语"

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                           选项面板描述                                         │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["OptionsPanelSubtitle"] = "|cFF808080记录并与好友共享玩家备注信息。|r"
L["DescEnhancedFrame"] = "|cFF808080为已记录玩家的目标框体显示彩色边框覆盖层。|r"
L["DescShowChatIcons"] = "|cFF808080在聊天消息中已记录玩家名称旁显示名声图标。|r"
L["DescSimpleMenu"] = "|cFF808080用等级按钮替换滑块控件，可在“自定义设置”标签页中配置等级。|r"
L["GoodLevels"] = "正面评价等级"
L["BadLevels"] = "负面评价等级"
L["SimpleLevelsHeader"] = Colors.iWR .. "简易菜单等级设置"
L["DescSimpleLevels"] = "|cFF808080设置简易菜单按钮的正面/负面评价等级数量，可在下方自定义各等级的图标与标签。|r"
L["RelationLevelsHeader"] = Colors.iWR .. "关系等级设置"
L["DescRelationLevels"] = "|cFF808080设置正面/负面关系等级数量，基础等级（卓越、尊敬、喜欢、不喜欢、厌恶）始终显示。|r"
L["DescEnableGroupWarning"] = "|cFF808080当小队/团队中出现含负面评价的玩家时发出提醒。|r"
L["DescEnableSoundWarning"] = "|cFF808080在小队提醒弹窗触发时播放声音提示。|r"
L["DescShowAuthor"] = "|cFF808080鼠标悬停至已记录玩家时显示该备注的创建者。|r"
L["MinimapSettings"] = Colors.iWR .. "小地图设置"
L["ShowMinimapButton"] = "显示小地图按钮"
L["DescShowMinimapButton"] = "|cFF808080切换iWillRemember小地图按钮的显示/隐藏状态。|r"
L["DescEnableSync"] = "|cFF808080与同样安装iWillRemember的好友共享数据库，双方必须互加好友才能同步。|r"
L["DescEnableBackup"] = "|cFF808080每小时自动创建一次数据库备份。|r"
L["DatabaseStats"] = Colors.iWR .. "数据库统计"
L["ResetSettingsHeader"] = Colors.iWR .. "重置设置"
L["ResetToDefaults"] = "恢复默认设置"
L["ResetConfirm"] = "确定要将所有设置恢复为默认值吗？|n|n玩家数据库不会受到影响。"
L["SettingsResetSuccess"] = Msg("设置已恢复默认值，输入/reload重载界面生效。")
L["ButtonLabelsSettings"] = Colors.iWR .. "按钮标签设置"
L["DescButtonLabels"] = "|cFF808080自定义各评价等级显示的文本，修改将同步应用至按钮、提示框、提醒及所有显示区域。|r"
L["ResetLabels"] = "恢复默认标签"
L["Tab5Customize"] = "自定义设置"
L["DescCustomizeInfo"] = "|cFF808080此页面的所有修改仅对本地视觉效果生效，不会同步给其他玩家或影响共享数据。|r"
L["CustomIconsSettings"] = Colors.iWR .. "自定义图标设置"
L["DescCustomIcons"] = "|cFF808080为各评价等级选择自定义图标，修改将应用至按钮、提示框和数据库显示界面。|r"
L["ChangeIcon"] = "修改"
L["ResetIcon"] = "重置"
L["SelectIcon"] = "选择图标"
L["IconPathHelpInline"] = "输入图标路径，例如：Interface\\Icons\\Spell_Fire_Fire - 可在wowhead.com查询图标名称"
L["TabINIF"] = "iNIF 设置"
L["INIFSettingsHeader"] = Colors.iWR .. "iNeedIfYouNeed 设置"
L["INIFInstalledDesc1"] = Colors.iWR .. "iNeedIfYouNeed" .. Colors.Reset .. " 已安装！可从此处进入iNIF设置界面。"
L["INIFInstalledDesc2"] = "|cFF808080注：这些设置由iNIF管理，修改将影响iNIF插件的功能。|r"
L["INIFOpenSettingsButton"] = "打开iNIF设置"
L["INIFPromoDesc"] = Colors.iWR .. "iNeedIfYouNeed" .. Colors.Reset .. " 是一款智能拾取插件。当队友需要某件物品时自动需求，否则贪婪。再也不会错过本该全体贪婪的随机装绑装备！|n|n" .. Colors.Reset .. "只需在拾取框体勾选复选框，再点击贪婪即可启用监控。"
L["INIFPromoLink"] = "可在CurseForge客户端或官网获取：curseforge.com/wow/addons/ineedifyouneed"
L["TabISP"] = "iSP 设置"
L["ISPSettingsHeader"] = Colors.iWR .. "iSoundPlayer 设置"
L["ISPInstalledDesc1"] = Colors.iWR .. "iSoundPlayer" .. Colors.Reset .. " 已安装！可从此处进入iSP设置界面。"
L["ISPInstalledDesc2"] = "|cFF808080注：这些设置由iSP管理，修改将影响iSP插件的功能。|r"
L["ISPOpenSettingsButton"] = "打开iSP设置"
L["ISPPromoDesc"] = Colors.iWR .. "iSoundPlayer" .. Colors.Reset .. " 是一款自定义音效播放插件。可绑定游戏事件（击杀、升级、首领战等）播放自定义MP3文件。|n|n" .. Colors.Reset .. "添加音效文件并绑定触发条件——完全自定义你的游戏音效。"
L["ISPPromoLink"] = "可在CurseForge客户端或官网获取：curseforge.com/wow/addons/isoundplayer"
L["TabINIFPromo"] = "iNeedIfYouNeed"
L["TabISPPromo"] = "iSoundPlayer"
L["TabICC"] = "iCC 设置"
L["TabICCPromo"] = "iCommunityChat"
L["ICCSettingsHeader"] = Colors.iWR .. "iCommunityChat 设置"
L["ICCInstalledDesc1"] = Colors.iWR .. "iCommunityChat" .. Colors.Reset .. " 已安装！可从此处进入iCC设置界面。"
L["ICCInstalledDesc2"] = "|cFF808080注：这些设置由iCC管理，修改将影响iCC插件的功能。|r"
L["ICCOpenSettingsButton"] = "打开iCC设置"
L["ICCPromoHeader"] = Colors.iWR .. "iCommunityChat"
L["ICCPromoDesc"] = Colors.iWR .. "iCommunityChat" .. Colors.Reset .. " 是一款跨公会社区插件。可创建并管理自定义社区，实现跨公会聊天、成员列表和等级体系——突破公会边界。|n|n" .. Colors.Reset .. "你的社区，你的专属聊天频道。"
L["ICCPromoLink"] = "可在CurseForge客户端或官网获取：curseforge.com/wow/addons/icommunitychat"
L["TabIST"] = "iST 设置"
L["TabISTPromo"] = "iSealTwist"
L["ISTSettingsHeader"] = Colors.iWR .. "iSealTwist"
L["ISTInstalledDesc"] = Colors.iWR .. "iSealTwist" .. Colors.Reset .. " 已安装。打开其设置界面可配置攻击计时条和圣印舞窗口。"
L["ISTOpenSettingsButton"] = "打开iST设置"
L["ISTPromoHeader"] = Colors.iWR .. "iSealTwist"
L["ISTPromoDesc"] = Colors.iWR .. "iSealTwist" .. Colors.Reset .. " 是一款为TBC圣骑士打造的圣印舞计时辅助插件。可视化攻击计时条搭配延迟补偿的圣印舞窗口指示器，助你完美把控圣印切换时机。"
L["ISTPromoLink"] = "可在CurseForge客户端或官网获取：curseforge.com/wow/addons/isealtwist"
L["SidebarHeaderiWR"] = Colors.iWR .. "iWillRemember|r"
L["SidebarHeaderOtherAddons"] = Colors.iWR .. "其他插件|r"
L["SetButton"] = "确认设置"
L["SyncModeLabel"] = "同步模式"
L["RemoveFromWhitelist"] = "从白名单移除"
L["NoFriendsWhitelist"] = "|cFF808080白名单中暂无好友。|r"
L["BackupSettingsHeader"] = Colors.iWR .. "备份设置"
L["INIFPromoHeader"] = Colors.iWR .. "iNeedIfYouNeed"
L["ISPPromoHeader"] = Colors.iWR .. "iSoundPlayer"
L["AboutHeader"] = Colors.iWR .. "关于插件"
L["DiscordHeader"] = Colors.iWR .. "Discord社区"
L["DeveloperHeader"] = Colors.iWR .. "开发者信息"
L["EnableDebugMode"] = "启用调试模式"
L["DescEnableDebugMode"] = "|cFF808080在聊天框显示详细调试信息，不建议普通用户启用。|r"
L["ResetSettingsDesc"] = "|cFF808080将所有插件设置恢复为默认值，玩家数据库和白名单不会受到影响。|r"
L["SettingsPanelStubDesc"] = "右键点击小地图按钮，或输入 |cFFFFFF00/iwr settings|r 打开选项面板。"
L["GameVersionLabel"] = Colors.iWR .. "游戏版本：|r"
L["TOCVersionLabel"] = Colors.iWR .. "TOC版本：|r"
L["BuildVersionLabel"] = Colors.iWR .. "构建版本：|r"
L["BuildDateLabel"] = Colors.iWR .. "构建日期：|r"

L["iWRLoaded"] = Msg("iWillRemember 已加载")
L["iWRWelcomeStart"] = Msg("感谢你 ")
L["iWRWelcomeEnd"] = Colors.iWR .. (" 参与iWillRemember的开发进程！如遇任何问题，可前往CurseForge评论区或Discord反馈。")
L["DiscordCopiedToNote"] = Msg("Discord链接已复制至备注输入框。")
L["DiscordLink"] = ("https://discord.gg/8nnt25aw8B")
L["InCombat"] = Msg("战斗中无法使用该功能。")
L["CharNoteStart"] = Msg("角色备注 [")
L["DebugError"] = Msg(Colors.Red .. "错误：" .. Colors.iWR)
L["DebugWarning"] = Msg(Colors.Yellow .. "警告：" .. Colors.iWR)
L["DebugInfo"] = Msg(Colors.White .. "信息：" .. Colors.iWR)
L["NameInputError"] = Msg("添加玩家失败：名称包含无效字符或为空。请移除空格、数字或特殊符号后重试。")
L["ClearInputError"] = Msg("清除玩家失败：名称包含无效字符或为空。请移除空格、数字或特殊符号后重试。")
L["GroupWarning"] = Msg((Colors.Red .. "警告：小队中存在数据库匹配的玩家。|r"))
L["NewVersionAvailable"] = Msg("CurseForge上已有新版本可用。")
L["FullDBSendSuccess"] = Msg("数据库已成功发送至：")
L["FullDBRetrieve"] = Msg("全量数据库同步预计耗时：")
L["FullDBRetrieveSuccess"] = Msg("已成功从以下玩家同步数据：")
L["WhitelistFriendsAdded"] = Msg("当前服务器白名单中缺失的好友已自动添加至好友列表。")

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                  小队日志                                       │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["NotesTab"] = "备注列表"
L["GroupLogTab"] = "小队日志"
L["GroupLogEmpty"] = "暂无已记录玩家。加入小队后，队友将自动显示在此处！"
L["GroupLogDismiss"] = "关闭"
L["GroupLogAddNote"] = "添加备注"
L["GroupLogClearAll"] = "清空日志"
L["GroupLogClearConfirm"] = Colors.iWR .. "确定要清空整个小队日志吗？"
L["GroupLogCleared"] = Msg("小队日志已清空。")
L["EnableGroupLog"] = "启用小队日志"
L["DescEnableGroupLog"] = "|cFF808080自动记录你组队的玩家，可在数据库的“小队日志”标签页中查看。|r"

-- 公会监视列表
L["GuildsTab"] = "公会管理"
L["GuildWatchlistHeader"] = "公会监视列表"
L["GuildWatchlistDesc"] = "|cFF808080添加公会名称和对应关系类型，当选中/组队该公会玩家时将自动导入至数据库。|r"
L["GuildNameLabel"] = "公会名称："
L["GuildNoteLabel"] = "默认备注："
L["GuildWatchlistAdd"] = "添加"
L["GuildWatchlistEmpty"] = "监视列表中暂无公会。"
L["GuildWatchlistAdded"] = Msg("已添加公会：%s（%s）")
L["GuildWatchlistRemoved"] = Msg("已移除公会：%s")
L["GuildWatchlistAutoImport"] = Msg("公会监视列表：自动导入玩家 %s（公会：%s）")
L["GuildWatchlistDefaultNote"] = "从公会自动导入：%s"

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                  菜单滑块                                       │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["SaveNote"] = "保存备注"
L["ClearButton"] = "清除"
L["EditButton"] = "编辑"
L["RemoveButton"] = "移除"
L["PlayerNameHeader"] = "玩家名称"
L["NoteHeader"] = "备注内容"
L["RelationLevelHeader"] = "关系等级"
L["PersonalCheckbox"] = "私人备注（不共享）"
L["PersonalDatabaseTitle"] = "iWillRemember 私人数据库"
L["CreateNote"] = "创建备注"
L["OpenDatabase"] = "打开数据库"
L["FilterAll"] = "全部"
L["FilterMine"] = "我的备注"
L["FilterFriends"] = "好友备注"
L["EntriesCount"] = "%d 条记录"
L["EntriesFiltered"] = "%d / %d 条记录"
L["SearchPlaceholder"] = "搜索..."
L["HelpTooltipTitle"] = "iWillRemember 使用指南"
L["RightClickWhisper"] = "右键点击发送悄悄话"
L["LeftClickNotes"] = "左键点击备注查看历史记录"

-- 详情标签
L["DetailName"] = "名称："
L["DetailType"] = "类型："
L["DetailNote"] = "备注："
L["DetailAuthor"] = "创建者："
L["DetailDate"] = "日期："
L["DetailStatus"] = "状态："
L["DetailFaction"] = "阵营："
L["DetailServer"] = "服务器："
L["DetailZone"] = "区域："
L["DetailInstanceType"] = "副本类型："
L["DetailPlayerDetails"] = "iWR：玩家详情"
L["DatabaseEntriesLabel"] = "数据库记录数："
L["BackupEntriesLabel"] = "备份记录数："
L["AITranslationNote"] = "部分文本由AI翻译生成，可能存在不完全准确的情况。"
L["MyCharsRemove"] = "移除"
L["StatusPersonal"] = "私人"
L["StatusShared"] = "已共享"
L["NotesHistory"] = "备注历史"
L["NotesCount"] = "（共%d条备注）"
L["RemoveNoteConfirm"] = "确定要从历史记录中移除该备注吗？"

-- 按钮文本
L["ClearAllButton"] = "全部清除"
L["ShareFullDBButton"] = "共享完整数据库"

-- 弹窗文本
L["ClearDBConfirm"] = "确定要清空当前iWR数据库吗？|n此操作不可撤销。"
L["ClearDBSuccess"] = "[iWR]：数据库已清空。"
L["ShareDBConfirm"] = "确定要共享整个数据库吗？"
L["ShareDBEmpty"] = "[iWR]：数据库为空，无可共享内容。"
L["ShareDBInitiated"] = "[iWR]：全量数据库同步流程已启动，此过程可能需要数分钟。"
L["RemoveConfirmCrossRealm"] = "确定要移除 |n|n[%s-%s" .. Colors.iWR .. "] |n|n 从iWR数据库中吗？"
L["RemoveConfirmSameRealm"] = "确定要移除 |n|n[%s" .. Colors.iWR .. "] |n|n 从iWR数据库中吗？"

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                聊天输出配置                                     │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["SectionChatOutput"] = "聊天输出设置"
L["ChatFrameAlwaysOn"] = "（始终启用）"
L["LanguageSettings"] = Colors.iWR .. "语言设置"
L["ForceEnglish"] = "强制使用英文"
L["DescForceEnglish"] = "|cFF808080强制插件使用英文文本，无视游戏客户端语言设置，需输入/reload重载界面生效。|r"

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                          保存英文本地化副本（请勿修改）                          │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
-- 存储英文本地化表，以便在覆盖后通过ForceEnglish设置恢复英文文本
local EnglishLocale = {}
for k, v in pairs(L) do
    EnglishLocale[k] = v
end
_G.iWR_EnglishLocale = EnglishLocale