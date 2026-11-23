-- ═════════════════════════
-- ██╗ ██╗    ██╗ ██████╗ 
-- ╚═╝ ██║    ██║ ██╔══██╗
-- ██║ ██║ █╗ ██║ ██████╔╝
-- ██║ ██║███╗██║ ██  ██╔
-- ██║ ╚███╔███╔╝ ██   ██╗ 
-- ╚═╝  ╚══╝╚══╝  ╚══════╝ 
-- ═════════════════════════

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                     Colors                                     │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

local addonName, addon = ...
-- Translator ZamestoTV
if GetLocale() ~= "ruRU" then return end

local L = LibStub("AceLocale-3.0"):NewLocale("iWR", "ruRU")
if not L then return end

local Colors = {
    -- Standard Colors
    iWR = "|cffff9716",
    White = "|cFFFFFFFF",
    Black = "|cFF000000",
    Red = "|cFFFF0000",
    Green = "|cFF00FF00",
    Blue = "|cFF0000FF",
    Yellow = "|cFFFFFF00",
    Cyan = "|cFF00FFFF",
    Magenta = "|cFFFF00FF",
    Orange = "|cFFFFA500",
    Gray = "|cFF808080",

    -- WoW Class Colors
    Classes = {
        WARRIOR = "|cFFC79C6E",
        PALADIN = "|cFFF58CBA",
        HUNTER = "|cFFABD473",
        ROGUE = "|cFFFFF569",
        PRIEST = "|cFFFFFFFF",
        SHAMAN = "|cFF0070DE",
        MAGE = "|cFF40C7EB",
        WARLOCK = "|cFF8788EE",
        DRUID = "|cFFFF7D0A",
        DEATHKNIGHT = "|cFFC41F3B",
        MONK = "|cFF00FF98",
        DEMONHUNTER = "|cFFA330C9",
        EVOKER = "|cFF33937F"
    },

    -- Reset Color
    Reset = "|r"
}

local DefaultMessageStart = Colors.iWR .. "[iWR]: "
local function Msg(message)
    return DefaultMessageStart .. message
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                 Text Templates                                 │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["NoteToolTip"] = Colors.iWR .. "[iWR]: "
L["ChatIconTooltipTitle"] = "iWR: %s"
L["ChatIconTooltipPlayer"] = "Игрок: %s"
L["ChatIconTooltipClick"] = "Нажмите на значок, чтобы открыть полную заметку iWR."
L["DefaultNameInput"] = "Введите имя игрока..."
L["DefaultNoteInput"] = "Введите заметку..."
L["MinimapButtonLeftClick"] = (Colors.Yellow .. "ЛКМ: " .. Colors.Orange .. "Открыть меню iWR")
L["MinimapButtonShiftLeftClick"] = (Colors.Yellow .. "Shift-ЛКМ: " .. Colors.Orange .. "Открыть базу данных iWR")
L["MinimapButtonRightClick"] = (Colors.Yellow .. "ПКМ: " .. Colors.Orange .. "Открыть настройки")
L["CharNoteCreated"] = Colors.iWR .."] добавлен в базу данных iWR.|r"
L["CharNoteUpdated"] = Colors.iWR .."] обновлен в базе данных iWR.|r"
L["CharNoteAppended"] = Colors.iWR .."] новая заметка добавлена в базу данных iWR.|r"
L["CharNoteRemoved"] = Colors.iWR .."] удален из базы данных iWR.|r"
L["CharNoteClassMissing"] = " Информация о классе отсутствует и будет добавлена при следующем выборе игрока в цель."
L["CharNoteColorUpdate"] = Colors.iWR .."] обнаружен в базе данных iWR без информации о классе. Цвет класса добавлен в базу данных iWR."
L["CharNoteFactionMissing"] = " Информация о фракции отсутствует и будет добавлена при следующем выборе игрока в цель."
L["CharNoteFactionUpdate"] = Colors.iWR .."] обнаружен в базе данных iWR без информации о фракции. Фракция добавлена."
L["Translations"] = "Переводы"
L["DiscordLinkMessage"] = "Скопируйте эту ссылку, чтобы присоединиться к нашему Discord для получения поддержки и обновлений."
L["CreatedBy"] = "Автор: " 
L["AboutMessageInfo"] = Colors.iWR .. "iWillRemember " .. Colors.Reset .. "- это аддон, созданный для отслеживания заметок об игроках и удобного обмена ими с друзьями."
L["AboutMessageEarlyDev"] = Colors.iWR .. "iWR " .. Colors.Reset .. "находится на ранней стадии разработки. Присоединяйтесь к Discord для помощи с проблемами, вопросов или предложений."
L["Tab1General"] = "Общие"
L["Tab2Sync"] = "Синхронизация"
L["Tab3Backup"] = "Резервная копия"
L["Tab4About"] = "Об аддоне"
L["NoBackup"] = "Резервная копия недоступна"
L["LastBackup1"] = "Последняя резервная копия: "
L["at"] = " в "
L["BackupRestoreError"] = Colors.Red .. "[iWR]: Резервная копия для восстановления не найдена."
L["BackupRestore"] = Colors.iWR .. "[iWR]: База данных восстановлена из резервной копии от "
L["RestoreConfirm"] = Colors.Red .. "Вы уверены, что хотите перезаписать текущую базу данных iWR данными из резервной копии?|nЭто действие необратимо.\n\nРезервная копия создана "
L["UnknownDate"] = "Неизвестная дата"
L["UnknownTime"] = "Неизвестное время"
L["Yes"] = "Да"
L["No"] = "Нет"
L["KeepAsPersonal"] = "Оставить личной"
L["RestoreDatabase"] = "Восстановить базу данных"
L["EnableBackup"] = "Включить автоматическое резервное копирование"
L["WhiteListTitle"] = Colors.iWR .. "Белый список"
L["AddtoWhitelist"] = Colors.iWR .. "Добавить друзей в белый список:"
L["Friends"] = "Друзья"
L["AllFriends"] ="Все друзья"
L["Whitelist"] = "Белый список"
L["OnlyWhitelist"] = "Только белый список"
L["EnableWhitelistSharing"] = "Включить обмен по белому списку"
L["WhitelistSharingDescription"] = "|cFF808080Делиться неличными заметками только с игроками, которых вы добавили в белый список.|r"
L["WhitelistSharingHelp"] = "Оба игрока должны добавить друг друга в белый список и использовать iWR 0.24.3 или новее. Наличие в списке друзей не обязательно. Обмен объединяет ваши заметки. Заметки и контакты для обмена хранятся отдельно для каждого типа игрового мира. Проверка доступности может занять некоторое время."
L["WhitelistAddPlayer"] = "Добавить игрока"
L["WhitelistNameHint"] = "Введите полное имя персонажа или выберите из предложенных вариантов."
L["WhitelistAdded"] = "Игрок добавлен. Нажмите Обновить статус для проверки доступности."
L["WhitelistRefreshStatus"] = "Обновить статус"
L["WhitelistSyncNow"] = "Синхронизировать сейчас"
L["WhitelistEmpty"] = "В белом списке для этого типа игрового мира нет игроков."
L["WhitelistRuleset"] = "Тип игрового мира: "
L["WhitelistLastSeen"] = "Последний отклик iWR: "
L["WhitelistNotSeen"] = "Отклик iWR еще не зафиксирован."
L["EnableSync"] = "Включить синхронизацию с друзьями"
L["SyncSettings"] = Colors.iWR .. "Настройки синхронизации"
L["ShowAuthor"] = "Показывать автора в подсказке"
L["ToolTipSettings"] = Colors.iWR .. "Настройки подсказок"
L["EnableSoundWarning"] = "Включить звуковые предупреждения"
L["EnableGroupWarning"] = "Включить предупреждения в группе"
L["WarningSettings"] = Colors.iWR .. "Настройки предупреждений"
L["ShowChatIcons"] = "Показывать значки в чате"
L["ShowGroupFinderNotes"] = "Показывать заметки в поиске группы"
L["ShowWhoNotes"] = "Показывать заметки в поиске Кто"
L["GroupFinderNoteTitle"] = "Заметка iWillRemember"
L["GroupFinderNotedMembers"] = "iWillRemember: %d с заметками"
L["ShowPlatynatorIcons"] = "Показывать значки на индикаторах здоровья Platynator"
L["TabPlatynator"] = "Platynator"
L["PlatynatorSettings"] = Colors.iWR .. "Индикаторы здоровья Platynator"
L["PlatynatorSettingsInfo"] = "Настройте отображение значков отношения iWillRemember на индикаторах здоровья Platynator. Изменения сразу отображаются на видимых индикаторах."
L["PlatynatorIconOffsetX"] = "Положение по горизонтали"
L["PlatynatorIconOffsetY"] = "Положение по вертикали"
L["SimpleMenu"] = "Упрощенное меню"
L["MenuModeSimple"] = "Упрощенный"
L["MenuModeAdvanced"] = "Расширенный"
L["LevelColor"] = "Цвет"
L["LevelAppearanceHeader"] = "Значки и цвета драконов"
L["ResetLevelColor"] = "Сбросить цвет"
L["LevelColorHint"] = "Выберите цвет дракона и рамки кнопки для этого уровня."
L["LevelColorsDesc"] = "Выберите значки и цвета драконов для каждого уровня. Эти же цвета отображаются на кнопках оценки."
L["AppearanceRating"] = "Оценка"
L["AppearanceIcon"] = "Значок"
L["AppearanceColor"] = "Дракон и рамка"
L["AppearanceChooseColor"] = "Выбрать"
L["AppearanceResetIconHint"] = "Восстановить стандартный значок для этой оценки."
L["AppearanceResetColorHint"] = "Восстановить стандартный цвет дракона и рамки кнопки."
L["MenuModeToggleHint"] = "Переключение между быстрыми кнопками и подробным ползунком оценки. Текущее имя и заметка сохраняются."
L["EnhancedFrame"] = "Показывать улучшенную рамку цели"
L["DisplaySettings"] = Colors.iWR .. "Настройки отображения"
L["SettingsTitle"] = Colors.iWR .." Настройки"
L["SettingsSavedAutomatically"] = "Изменения сохраняются автоматически."
L["SettingsGeneralSummary"] = "Выберите, где отображаются заметки и как вы получаете предупреждения."
L["SettingsSyncSummary"] = "Обменивайтесь заметками с игроками из вашего белого списка."
L["SettingsBackupSummary"] = "Храните резервную копию заметок или восстановите более раннюю версию."
L["SettingsCustomizeSummary"] = "Настройте уровни оценок, значки и цвета драконов по своему вкусу."
L["SettingsAboutSummary"] = "Информация об аддоне, поддержка и отладка."
L["SettingsCompanionSummary"] = "Управляйте установленным аддоном или узнайте о нем подробнее."
L["SettingsNameplateSummary"] = "Выберите, как сохраненные оценки отображаются над игроками."
L["SettingsMenuAndHistory"] = "Меню и история"
L["SettingsChooseCharacter"] = "Выберите персонажа..."
L["VersionWarning"] = Colors.iWR .. "[iWR]: " .. Colors.Yellow.. "ВНИМАНИЕ" .. Colors.iWR .. ": Это альфа-версия, она может работать нестабильно и вызвать проблемы с вашей базой данных. Если вы не хотите использовать эту версию, пожалуйста, откатитесь до последнего стабильного релиза."
L["DBNameNotFound1"] = Colors.iWR .. "[iWR]: Имя [|r"
L["DBNameNotFound2"] = Colors.iWR .. "] отсутствует в базе данных."

L["HelpSync"] = Colors.Yellow .. "Как синхронизировать: " .. Colors.iWR .. "Добавьте друзей во внутриигровой вкладке Общение. Обмен не работает с друзьями по Battle.Net (Настоящее имя), только с друзьями, добавленными в список друзей персонажа в World of Warcraft. Для синхронизации вы оба должны добавить друг друга."
L["HelpUse"] = Colors.Yellow .. "Игрок: " .. Colors.White .. "Выберите игрока в цель, нажмите Создать заметку в контекстном меню по ПКМ или введите его полное имя. При желании добавьте текст заметки."
L["HelpSave"] = Colors.Yellow .. "Сохранить: " .. Colors.White .. "В расширенном режиме выберите ненулевой уровень отношения и нажмите Сохранить заметку. В упрощенном режиме просто нажмите на кнопку отношения."
L["HelpSharing"] = Colors.Yellow .. "Обмен: " .. Colors.White .. "Оба игрока должны добавить друг друга в белый список. Параметр Оставить личной исключает заметку из обмена."
L["HelpClear"] = Colors.Yellow .. "Очистить: " .. Colors.White .. "Удаляет сохраненную запись и историю заметок введенного игрока. Откройте Базу данных для просмотра или редактирования сохраненных заметок."
L["HelpSettings"] = Colors.Yellow .. "Миникарта: " .. Colors.White .. "ПКМ - открыть настройки. Shift-ЛКМ - открыть базу данных."
L["HelpDiscord"] = Colors.Yellow .. "Discord: " .. Colors.White .. "Оставив поле имени игрока пустым, нажмите ?, чтобы вставить ссылку на поддержку в поле заметки для копирования."

L["Russian"] = "Русский"

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                           Options Panel Descriptions                           │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["OptionsPanelSubtitle"] = "|cFF808080Отслеживайте заметки об игроках и делитесь ими с друзьями.|r"
L["DescEnhancedFrame"] = "|cFF808080Отображает цветную рамку поверх индикатора цели для отслеживаемых игроков.|r"
L["DescShowChatIcons"] = "|cFF808080Показывает значки репутации рядом с именами отслеживаемых игроков в сообщениях чата.|r"
L["DescShowGroupFinderNotes"] = "|cFF808080Показывает сохраненные значки отношения рядом с отслеживаемыми игроками в поиске группы. Наведите курсор на строку, чтобы прочитать заметку перед тем, как написать или пригласить игрока.|r"
L["DescShowWhoNotes"] = "|cFF808080Показывает сохраненные значки отношения рядом с отслеживаемыми игроками в результатах поиска Кто.|r"
L["DescShowPlatynatorIcons"] = "|cFF808080Показывает сохраненный значок отношения рядом с индикаторами здоровья отслеживаемых игроков, если загружен аддон Platynator.|r"
L["DescPlatynatorIconOffsetX"] = "|cFF808080Сдвинуть значок влево или вправо относительно полосы здоровья.|r"
L["DescPlatynatorIconOffsetY"] = "|cFF808080Сдвинуть значок вниз или вверх относительно полосы здоровья.|r"
L["DescSimpleMenu"] = "|cFF808080Используйте пять быстрых кнопок с подписями под значками, чтобы сохранить или очистить заметку. Настроить их названия и значки можно на вкладке Настройка.|r"
L["GoodLevels"] = "Положительные уровни"
L["BadLevels"] = "Отрицательные уровни"
L["SimpleLevelsHeader"] = Colors.iWR .. "Уровни упрощенного меню"
L["DescSimpleLevels"] = "|cFF808080Укажите количество положительных и отрицательных уровней для кнопок упрощенного меню. Значки и подписи для каждого уровня можно настроить ниже.|r"
L["RelationLevelsHeader"] = Colors.iWR .. "Уровни отношения"
L["DescRelationLevels"] = "|cFF808080Укажите количество положительных и отрицательных уровней отношения. Базовые уровни (Превознесение, Уважение, Дружелюбие, Неприязнь, Ненависть) присутствуют всегда.|r"
L["DescEnableGroupWarning"] = "|cFF808080Предупреждает вас, когда в группе или рейде появляются игроки с отрицательной оценкой.|r"
L["DescEnableSoundWarning"] = "|cFF808080Воспроизводит звуковое оповещение вместе со всплывающими предупреждениями в группе.|r"
L["DescShowAuthor"] = "|cFF808080Отображает автора заметки при наведении курсора на отслеживаемого игрока.|r"
L["MinimapSettings"] = Colors.iWR .. "Настройки миникарты"
L["ShowMinimapButton"] = "Показывать кнопку у миникарты"
L["DescShowMinimapButton"] = "|cFF808080Включает или отключает отображение кнопки iWillRemember у миникарты.|r"
L["DescEnableSync"] = "|cFF808080Синхронизирует вашу базу данных с друзьями, у которых также установлен iWillRemember. Оба игрока должны быть в списках друзей друг друга.|r"
L["DescEnableBackup"] = "|cFF808080Автоматически создает резервную копию вашей базы данных каждый час.|r"
L["DatabaseStats"] = Colors.iWR .. "Статистика базы данных"
L["ResetSettingsHeader"] = Colors.iWR .. "Сброс"
L["ResetToDefaults"] = "Сбросить настройки по умолчанию"
L["ResetConfirm"] = "Вы уверены, что хотите сбросить все настройки к значениям по умолчанию?\n\nВаша база данных игроков НЕ будет затронута."
L["SettingsResetSuccess"] = Msg("Настройки сброшены по умолчанию. Введите /reload для применения.")
L["ButtonLabelsSettings"] = Colors.iWR .. "Подписи кнопок"
L["DescButtonLabels"] = "|cFF808080Настройте текст, отображаемый для каждой оценки. Изменения применяются к кнопкам, подсказкам, предупреждениям и всем остальным элементам.|r"
L["ResetLabels"] = "Сбросить подписи по умолчанию"
L["Tab5Customize"] = "Настройка"
L["DescCustomizeInfo"] = "|cFF808080Все изменения на этой странице являются локальными и чисто визуальными. Они не синхронизируются с другими игроками и не влияют на общие данные.|r"
L["CustomIconsSettings"] = Colors.iWR .. "Пользовательские значки"
L["DescCustomIcons"] = "|cFF808080Выберите собственные значки для каждой оценки. Изменения применяются к кнопкам, подсказкам и отображению в базе данных.|r"
L["ChangeIcon"] = "Изменить"
L["ResetIcon"] = "Сбросить"
L["SelectIcon"] = "Выбрать значок"
L["IconPathHelpInline"] = "Введите путь к значку, например: Interface\\Icons\\Spell_Fire_Fire - названия можно найти на wowhead.com"
L["TabINIF"] = "Настройки iNIF"
L["INIFSettingsHeader"] = Colors.iWR .. "Настройки iNeedIfYouNeed"
L["INIFInstalledDesc1"] = Colors.iWR .. "iNeedIfYouNeed" .. Colors.Reset .. " установлен! Вы можете открыть настройки iNIF отсюда."
L["INIFInstalledDesc2"] = "|cFF808080Примечание: эти параметры управляются аддоном iNIF и влияют на его работу.|r"
L["INIFOpenSettingsButton"] = "Открыть настройки iNIF"
L["INIFPromoDesc"] = Colors.iWR .. "iNeedIfYouNeed" .. Colors.Reset .. " - это умный аддон для розыгрыша добычи. Он автоматически нажимает Мне это нужно, если предмет нужен участникам группы, а в остальных случаях выбирает Не откажусь. Вы больше не упустите случайные предметы (персональные при надевании), которые все должны были разыгрывать через Не откажусь.\n\n" .. Colors.Reset .. "Простой флажок в окне добычи - отметьте его и нажмите Не откажусь, чтобы включить отслеживание."
L["INIFPromoLink"] = "Доступно в приложении CurseForge и на сайте curseforge.com/wow/addons/ineedifyouneed"
L["TabINIFPromo"] = "iNeedIfYouNeed"
L["TabIST"] = "Настройки iST"
L["TabISTPromo"] = "iSealTwist"
L["ISTSettingsHeader"] = Colors.iWR .. "iSealTwist"
L["ISTInstalledDesc"] = Colors.iWR .. "iSealTwist" .. Colors.Reset .. " установлен. Откройте его настройки, чтобы настроить таймер замаха и окно твиста."
L["ISTOpenSettingsButton"] = "Открыть настройки iST"
L["ISTPromoHeader"] = Colors.iWR .. "iSealTwist"
L["ISTPromoDesc"] = Colors.iWR .. "iSealTwist" .. Colors.Reset .. " - помощник по таймингам твиста печатей для паладинов в TBC. Наглядный таймер замаха с индикатором окна твиста с учетом задержки. Переключайте печати идеально вовремя."
L["ISTPromoLink"] = "Доступно в приложении CurseForge и на сайте curseforge.com/wow/addons/isealtwist"
L["TabIRC"] = "Настройки iRC"
L["TabIRCPromo"] = "iRC: Guild Connect"
L["IRCSettingsHeader"] = Colors.iWR .. "iRC: Guild Connect"
L["IRCInstalledDesc"] = Colors.iWR .. "iRC: Guild Connect" .. Colors.Reset .. " установлен. Откройте его настройки для управления инструментами гильдии, общими правилами и личными предпочтениями."
L["IRCOpenSettingsButton"] = "Открыть настройки iRC"
L["IRCPromoDesc"] = Colors.iWR .. "iRC: Guild Connect" .. Colors.Reset .. " объединяет статистику гильдии, профессии участников, общие правила и инструменты управления. Поддерживает как обычные, так и хардкор/челлендж-гильдии."
L["IRCPromoLink"] = "Доступно в приложении CurseForge. Ищите по названию iRC: Guild Connect."
L["SidebarHeaderiWR"] = Colors.iWR .. "iWillRemember|r"
L["SidebarHeaderOtherAddons"] = Colors.iWR .. "Другие аддоны|r"
L["SetButton"] = "Задать"
L["SyncModeLabel"] = "Режим синхронизации"
L["RemoveFromWhitelist"] = "Удалить из белого списка"
L["NoFriendsWhitelist"] = "|cFF808080В белом списке нет друзей.|r"
L["BackupSettingsHeader"] = Colors.iWR .. "Настройки резервного копирования"
L["INIFPromoHeader"] = Colors.iWR .. "iNeedIfYouNeed"
L["AboutHeader"] = Colors.iWR .. "Об аддоне"
L["DiscordHeader"] = Colors.iWR .. "Discord"
L["DeveloperHeader"] = Colors.iWR .. "Разработчик"
L["EnableDebugMode"] = "Включить режим отладки"
L["DescEnableDebugMode"] = "|cFF808080Включает подробные отладочные сообщения в чате. Не рекомендуется при обычном использовании.|r"
L["ResetSettingsDesc"] = "|cFF808080Сбрасывает все настройки аддона к значениям по умолчанию. Ваша база данных игроков и белый список затронуты не будут.|r"
L["SettingsPanelStubDesc"] = "Нажмите ПКМ по кнопке у миникарты или введите |cFFFFFF00/iwr settings|r, чтобы открыть панель настроек."
L["GameVersionLabel"] = Colors.iWR .. "Версия игры: |r"
L["TOCVersionLabel"] = Colors.iWR .. "Версия TOC: |r"
L["BuildVersionLabel"] = Colors.iWR .. "Версия сборки: |r"
L["BuildDateLabel"] = Colors.iWR .. "Дата сборки: |r"

L["iWRLoaded"] = Msg("iWillRemember")
L["DiscordCopiedToNote"] = Msg("Ссылка на Discord скопирована в поле заметки.")
L["DiscordLink"] = ("https://discord.gg/8nnt25aw8B")
L["InCombat"] = Msg("Нельзя использовать в бою.")
L["CharNoteStart"] = Msg("Заметка о персонаже [")
L["DebugError"] = Msg(Colors.Red .. "ОШИБКА: " .. Colors.iWR)
L["DebugWarning"] = Msg(Colors.Yellow .. "ПРЕДУПРЕЖДЕНИЕ: " .. Colors.iWR)
L["DebugInfo"] = Msg(Colors.White .. "ИНФО: " .. Colors.iWR)
L["NameInputError"] = Msg("Не удалось добавить игрока: имя пустое или содержит недопустимые символы. Удалите пробелы, цифры или специальные символы и повторите попытку.")
L["ClearInputError"] = Msg("Не удалось удалить игрока: имя пустое или содержит недопустимые символы. Удалите пробелы, цифры или специальные символы и повторите попытку.")
L["RestrictedNoteInput"] = Msg("Сейчас невозможно прочитать это имя или заметку. Введите данные вручную и повторите попытку.")
L["GroupWarning"] = Msg((Colors.Red .. "Внимание: в группе обнаружены игроки из базы данных.|r"))
L["NewVersionAvailable"] = Msg("На CurseForge доступна новая версия.")
L["FullDBSendSuccess"] = Msg("База данных успешно отправлена игроку: ")
L["FullDBRetrieve"] = Msg("Примерное время получения полной базы данных: ")
L["FullDBRetrieveSuccess"] = Msg("Данные успешно синхронизированы с игроком: ")
L["WhitelistFriendsAdded"] = Msg("Отсутствующие друзья из белого списка в этом игровом мире были автоматически добавлены в список друзей.")

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                  Group Log                                     │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["NotesTab"] = "Заметки"
L["GroupLogTab"] = "Журнал групп"
L["GroupLogEmpty"] = "Игроки еще не записаны. Вступите в группу, и они появятся здесь!"
L["GroupLogDismiss"] = "Скрыть"
L["GroupLogAddNote"] = "Добавить заметку"
L["GroupLogClearAll"] = "Очистить журнал"
L["GroupLogClearConfirm"] = Colors.iWR .. "Вы уверены, что хотите полностью очистить журнал групп?"
L["GroupLogCleared"] = Msg("Журнал групп очищен.")
L["EnableGroupLog"] = "Включить журнал групп"
L["DescEnableGroupLog"] = "|cFF808080Автоматически записывать игроков, с которыми вы вступаете в группу. Просмотреть их можно в базе данных на вкладке Журнал групп.|r"

-- Guild Watchlist
L["GuildsTab"] = "Гильдии"
L["GuildWatchlistHeader"] = "Список отслеживания гильдий"
L["GuildWatchlistDesc"] = "|cFF808080Укажите название гильдии и тип отношения. Игроки из отслеживаемых гильдий будут автоматически импортированы при выборе в цель или вступлении с ними в группу.|r"
L["GuildNameLabel"] = "Название гильдии:"
L["GuildNoteLabel"] = "Заметка по умолчанию:"
L["GuildWatchlistAdd"] = "Добавить"
L["GuildWatchlistEmpty"] = "В списке отслеживания нет гильдий."
L["GuildWatchlistAdded"] = Msg("Гильдия добавлена: %s (%s)")
L["GuildWatchlistRemoved"] = Msg("Гильдия удалена: %s")
L["GuildWatchlistAutoImport"] = Msg("Список отслеживания гильдий: автоматически импортирован %s (Гильдия: %s)")
L["GuildWatchlistDefaultNote"] = "Автоматически импортирован из гильдии: %s"

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                  Menu Slider                                   │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["SaveNote"] = "Сохранить заметку"
L["ClearButton"] = "Очистить"
L["EditButton"] = "Изменить"
L["RemoveButton"] = "Удалить"
L["PlayerNameHeader"] = "Имя игрока"
L["NoteHeader"] = "Заметка"
L["RelationLevelHeader"] = "Уровень отношения"
L["ActionsHeader"] = "Действия"
L["DatabaseRelationshipHeader"] = "Отношение"
L["DatabaseNoteEmpty"] = "Нет текста заметки"
L["DatabaseSingleNote"] = "1 заметка"
L["PersonalCheckbox"] = "Личная (не общая)"
L["PersonalDatabaseTitle"] = "Личная база данных iWillRemember"
L["DatabaseNotesSummary"] = "Поиск и управление сохраненными заметками об игроках."
L["DatabaseGroupLogSummary"] = "Игроки, с которыми вы встречались в группах, сгруппированные по сессиям."
L["DatabaseGuildsSummary"] = "Гильдии, которые вы выбрали для отслеживания."
L["CreateNote"] = "Создать заметку"
L["OpenDatabase"] = "Открыть базу данных"
L["FilterAll"] = "Все"
L["FilterMine"] = "Мои"
L["FilterFriends"] = "Друзья"
L["EntriesCount"] = "Записей: %d"
L["EntriesFiltered"] = "%d из %d записей"
L["SearchPlaceholder"] = "Поиск..."
L["HelpTooltipTitle"] = "Краткая справка iWillRemember"
L["RightClickWhisper"] = "ПКМ - шепнуть"
L["LeftClickNotes"] = "ЛКМ по заметке - раскрыть историю"

-- Detail labels
L["DetailName"] = "Имя:"
L["DetailType"] = "Тип:"
L["DetailNote"] = "Заметка:"
L["DetailAuthor"] = "Автор:"
L["DetailDate"] = "Дата:"
L["DetailStatus"] = "Статус:"
L["DetailFaction"] = "Фракция:"
L["DetailServer"] = "Сервер:"
L["DetailZone"] = "Зона:"
L["DetailInstanceType"] = "Тип подземелья:"
L["DetailPlayerDetails"] = "iWR: Сведения об игроке"
L["DatabaseEntriesLabel"] = "Записей в базе данных:"
L["BackupEntriesLabel"] = "Записей в резервной копии:"
L["AITranslationNote"] = "Некоторые тексты были переведены с помощью ИИ и могут быть не совсем точными."
L["MyCharsRemove"] = "Удалить"
L["StatusPersonal"] = "Личная"
L["StatusShared"] = "Общая"
L["NotesHistory"] = "История заметок"
L["NotesCount"] = "(заметок: %d)"
L["RemoveNoteConfirm"] = "Удалить эту заметку из истории?"

-- Buttons
L["ClearAllButton"] = "Очистить все"

-- Popups
L["ClearDBConfirm"] = "Вы уверены, что хотите очистить текущую базу данных iWR?|nЭто действие необратимо."
L["ClearDBSuccess"] = "[iWR]: База данных очищена."
L["ShareDBConfirm"] = "Синхронизировать заметки с игроками из вашего белого списка? Ваши заметки будут объединены."
L["ShareDBInitiated"] = "[iWR]: Запущен процесс полной синхронизации базы данных. Это может занять до нескольких минут."
L["RemoveConfirmCrossRealm"] = "Вы уверены, что хотите удалить |n|n[%s-%s" .. Colors.iWR .. "] |n|n из базы данных iWR?"
L["RemoveConfirmSameRealm"] = "Вы уверены, что хотите удалить |n|n[%s" .. Colors.iWR .. "] |n|n из базы данных iWR?"

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                Chat Output                                    │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["SectionChatOutput"] = "Вывод в чат"
L["ChatFrameAlwaysOn"] = "(всегда включено)"
L["LanguageSettings"] = Colors.iWR .. "Настройки языка"
L["ForceEnglish"] = "Принудительно английский язык"
L["DescForceEnglish"] = "|cFF808080Принудительно переключает интерфейс аддона на английский язык независимо от языка вашего игрового клиента. Для применения требуется /reload.|r"
