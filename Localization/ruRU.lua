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

    -- Translator ZamestoTV
local L = LibStub("AceLocale-3.0"):NewLocale("iWR", "ruRU", true)
local DefaultMessageStart = Colors.iWR .. "[iWR]: "
local function Msg(message)
    return DefaultMessageStart .. message
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                 Text Templates                                 │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["NoteToolTip"] = Colors.iWR .. "[iWR]: "
L["DefaultNameInput"] = "Введите имя игрока..."
L["DefaultNoteInput"] = "Введите заметку..."
L["MinimapButtonLeftClick"] = (Colors.Yellow .. "ЛКМ: " .. Colors.Orange .. "Открыть меню iWR")
L["MinimapButtonShiftLeftClick"] = (Colors.Yellow .. "Shift+ЛКМ: " .. Colors.Orange .. "Открыть базу данных iWR")
L["MinimapButtonRightClick"] = (Colors.Yellow .. "ПКМ: " .. Colors.Orange .. "Открыть настройки")
L["CharNoteCreated"] = Colors.iWR .. "] добавлен в базу данных iWR.|r"
L["CharNoteUpdated"] = Colors.iWR .. "] обновлён в базе данных iWR.|r"
L["CharNoteRemoved"] = Colors.iWR .. "] удалён из базы данных iWR.|r"
L["CharNoteClassMissing"] = " Информация о классе отсутствует, будет добавлена при следующем таргете игрока."
L["CharNoteColorUpdate"] = Colors.iWR .. "] найден с отсутствующей информацией о классе в базе iWR. Цвет класса добавлен."
L["Translations"] = "Переводы"
L["DiscordLinkMessage"] = "Скопируйте ссылку, чтобы присоединиться к нашему Discord для поддержки и обновлений."
L["CreatedBy"] = "Автор: " 
L["AboutMessageInfo"] = Colors.iWR .. "iWillRemember " .. Colors.Reset .. "- аддон для ведения и обмена заметками об игроках с друзьями."
L["AboutMessageEarlyDev"] = Colors.iWR .. "iWR " .. Colors.Reset .. "находится на ранней стадии разработки. Присоединяйтесь к Discord за помощью, вопросами и предложениями."
L["Tab1General"] = "Общие"
L["Tab2Sync"] = "Синхронизация"
L["Tab3Backup"] = "Резервные копии"
L["Tab4About"] = "О аддоне"
L["NoBackup"] = "Резервная копия отсутствует"
L["LastBackup1"] = "Последняя копия: "
L["at"] = " в "
L["BackupRestoreError"] = Colors.Red .. "[iWR]: Резервная копия не найдена."
L["BackupRestore"] = Colors.iWR .. "[iWR]: База данных восстановлена из копии от "
L["RestoreConfirm"] = Colors.Red .. "Вы уверены, что хотите перезаписать текущую базу данных iWR данными из резервной копии?|nЭто действие необратимо.\n\nКопия сделана "
L["UnknownDate"] = "Неизвестная дата"
L["UnknownTime"] = "Неизвестное время"
L["Yes"] = "Да"
L["No"] = "Нет"
L["RestoreDatabase"] = "Восстановить базу"
L["EnableBackup"] = "Включить автосохранение"
L["WhiteListTitle"] = Colors.iWR .. "Белый список"
L["AddtoWhitelist"] = Colors.iWR .. "Добавить друзей в белый список:"
L["Friends"] = "Друзья"
L["AllFriends"] = "Все друзья"
L["Whitelist"] = "Белый список"
L["OnlyWhitelist"] = "Только белый список"
L["EnableSync"] = "Включить синхронизацию с друзьями"
L["SyncSettings"] = Colors.iWR .. "Настройки синхронизации"
L["ShowAuthor"] = "Показывать автора в подсказке"
L["ToolTipSettings"] = Colors.iWR .. "Настройки подсказки"
L["EnableSoundWarning"] = "Включить звуковые предупреждения"
L["EnableGroupWarning"] = "Включить предупреждения о группе"
L["WarningSettings"] = Colors.iWR .. "Настройки предупреждений"
L["ShowChatIcons"] = "Показывать иконки в чате"
L["SimpleMenu"] = "Простое меню"
L["EnhancedFrame"] = "Показывать улучшенный TargetFrame"
L["DisplaySettings"] = Colors.iWR .. "Настройки отображения"
L["SettingsTitle"] = Colors.iWR .. " Настройки"
L["VersionWarning"] = Colors.iWR .. "[iWR]: " .. Colors.Yellow.. "ВНИМАНИЕ" .. Colors.iWR .. ": Это альфа-версия, может быть нестабильной и вызывать проблемы с базой данных. Если не хотите использовать эту версию - вернитесь к последнему релизу."
L["DBNameNotFound1"] = Colors.iWR .. "[iWR]: Имя [|r"
L["DBNameNotFound2"] = Colors.iWR .. "] не найдено в базе данных."

L["HelpSync"] = Colors.Yellow .. "Как синхронизировать: " .. Colors.iWR .. "Добавьте друзей в социальную панель в игре (не Battle.Net). Оба должны добавить друг друга."
L["HelpUse"] = Colors.Yellow .. "Как использовать: " .. Colors.iWR .. "Выберите игрока в цель или введите имя вручную, добавьте заметку и нажмите Уважение / Дружелюбие / Недружелюбие / Ненависть."
L["HelpClear"] = Colors.Yellow .. "Как очистить: " .. Colors.iWR .. "Кнопка Очистить удаляет имя из поля. Можно также удалить кнопкой Удалить или отредактировать в базе."
L["HelpSettings"] = Colors.Yellow .. "Меню настроек: " .. Colors.iWR .. "ПКМ по иконке у миникарты."
L["HelpDiscord"] = Colors.Yellow .."Помощь в Discord: " .. Colors.iWR .. "Нажмите кнопку с вопросительным знаком без имени игрока - ссылка вставится в поле заметки."

L["Russian"] = "Русский"

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                           Options Panel Descriptions                           │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["OptionsPanelSubtitle"] = "|cFF808080Ведите заметки об игроках и делитесь ими с друзьями.|r"
L["DescEnhancedFrame"] = "|cFF808080Показывает цветную рамку на фрейме цели для отслеживаемых игроков.|r"
L["DescShowChatIcons"] = "|cFF808080Показывает иконки репутации рядом с именами отслеживаемых игроков в чате.|r"
L["DescSimpleMenu"] = "|cFF808080Заменяет ползунок на простые кнопки (Ненависть, Недружелюбие, Дружелюбие, Уважение, Почтение).|r"
L["DescEnableGroupWarning"] = "|cFF808080Оповещает, когда в группе или рейде есть игроки с негативной репутацией.|r"
L["DescEnableSoundWarning"] = "|cFF808080Воспроизводит звуковое оповещение вместе с предупреждением о группе.|r"
L["DescShowAuthor"] = "|cFF808080Показывает, кто создал заметку, при наведении на игрока.|r"
L["MinimapSettings"] = Colors.iWR .. "Настройки миникарты"
L["ShowMinimapButton"] = "Показывать кнопку у миникарты"
L["DescShowMinimapButton"] = "|cFF808080Включает/отключает кнопку iWillRemember у миникарты.|r"
L["DescEnableSync"] = "|cFF808080Делится базой данных с друзьями, у которых тоже стоит iWillRemember. Оба должны быть в списках друзей друг у друга.|r"
L["DescEnableBackup"] = "|cFF808080Автоматически создаёт резервную копию базы данных каждый час.|r"
L["DatabaseStats"] = Colors.iWR .. "Статистика базы данных"
L["ResetSettingsHeader"] = Colors.iWR .. "Сброс"
L["ResetToDefaults"] = "Сбросить настройки по умолчанию"
L["ResetConfirm"] = "Вы уверены, что хотите сбросить все настройки на значения по умолчанию?\n\nБаза данных игроков и белый список НЕ будут затронуты."
L["SettingsResetSuccess"] = Msg("Настройки сброшены по умолчанию. Выполните /reload для применения.")
L["ButtonLabelsSettings"] = Colors.iWR .. "Подписи кнопок"
L["DescButtonLabels"] = "|cFF808080Измените текст для каждой оценки. Изменения применятся ко всем кнопкам, подсказкам, предупреждениям и отображениям.|r"
L["ResetLabels"] = "Сбросить подписи по умолчанию"
L["Tab5Customize"] = "Кастомизация"
L["DescCustomizeInfo"] = "|cFF808080Все изменения на этой странице локальные и визуальные. Они не синхронизируются и не влияют на общую базу данных.|r"
L["CustomIconsSettings"] = Colors.iWR .. "Свои иконки"
L["DescCustomIcons"] = "|cFF808080Выберите свои иконки для каждой оценки. Изменения применятся к кнопкам, подсказкам и базе.|r"
L["ChangeIcon"] = "Сменить"
L["ResetIcon"] = "Сбросить"
L["SelectIcon"] = "Выбрать иконку"
L["IconPathHelpInline"] = "Введите путь к иконке, например Interface\\Icons\\Spell_Fire_Fire (ищите на wowhead.com)"
L["TabINIF"] = "Настройки iNIF"
L["INIFSettingsHeader"] = Colors.iWR .. "Настройки iNeedIfYouNeed"
L["INIFInstalledDesc1"] = Colors.iWR .. "iNeedIfYouNeed" .. Colors.Reset .. " установлен! Настройки доступны отсюда."
L["INIFInstalledDesc2"] = "|cFF808080Внимание: эти настройки управляются самим аддоном iNIF.|r"
L["INIFOpenSettingsButton"] = "Открыть настройки iNIF"
L["INIFPromoDesc"] = Colors.iWR .. "iNeedIfYouNeed" .. Colors.Reset .. " - умный аддон для лута. Автоматически роллит Need, если кто-то в группе нуждается, иначе Greed. Никогда не упустите случайный BoE.\n\n" .. Colors.Reset .. "Простой чекбокс на фрейме лута."
L["INIFPromoLink"] = "Доступен в CurseForge App и на curseforge.com/wow/addons/ineedifyouneed"
L["TabISP"] = "Настройки iSP"
L["ISPSettingsHeader"] = Colors.iWR .. "Настройки iSoundPlayer"
L["ISPInstalledDesc1"] = Colors.iWR .. "iSoundPlayer" .. Colors.Reset .. " установлен! Настройки доступны отсюда."
L["ISPInstalledDesc2"] = "|cFF808080Внимание: эти настройки управляются самим аддоном iSP.|r"
L["ISPOpenSettingsButton"] = "Открыть настройки iSP"
L["ISPPromoDesc"] = Colors.iWR .. "iSoundPlayer" .. Colors.Reset .. " - аддон для воспроизведения своих MP3-файлов при игровых событиях (убийства, левел-ап, боссы и т.д.).\n\n" .. Colors.Reset .. "Добавляйте свои звуки и назначайте их на триггеры."
L["ISPPromoLink"] = "Доступен в CurseForge App и на curseforge.com/wow/addons/isoundplayer"
L["TabINIFPromo"] = "iNeedIfYouNeed"
L["TabISPPromo"] = "iSoundPlayer"
L["SidebarHeaderiWR"] = Colors.iWR .. "iWillRemember|r"
L["SidebarHeaderOtherAddons"] = Colors.iWR .. "Другие аддоны|r"
L["SetButton"] = "Сохранить"
L["SyncModeLabel"] = "Режим синхронизации"
L["RemoveFromWhitelist"] = "Удалить из белого списка"
L["NoFriendsWhitelist"] = "|cFF808080В белом списке пока никого нет.|r"
L["BackupSettingsHeader"] = Colors.iWR .. "Настройки резервного копирования"
L["INIFPromoHeader"] = Colors.iWR .. "iNeedIfYouNeed"
L["ISPPromoHeader"] = Colors.iWR .. "iSoundPlayer"
L["AboutHeader"] = Colors.iWR .. "О аддоне"
L["DiscordHeader"] = Colors.iWR .. "Discord"
L["DeveloperHeader"] = Colors.iWR .. "Разработчик"
L["EnableDebugMode"] = "Включить режим отладки"
L["DescEnableDebugMode"] = "|cFF808080Включает подробные отладочные сообщения в чат. Не рекомендуется для обычного использования.|r"
L["ResetSettingsDesc"] = "|cFF808080Сбрасывает все настройки аддона на значения по умолчанию. База данных игроков и белый список не затрагиваются.|r"
L["SettingsPanelStubDesc"] = "ПКМ по кнопке у миникарты или введите |cFFFFFF00/iwr settings|r для открытия настроек."
L["GameVersionLabel"] = Colors.iWR .. "Версия игры: |r"
L["TOCVersionLabel"] = Colors.iWR .. "TOC версия: |r"
L["BuildVersionLabel"] = Colors.iWR .. "Версия сборки: |r"
L["BuildDateLabel"] = Colors.iWR .. "Дата сборки: |r"

L["iWRLoaded"] = Msg("iWillRemember загружен")
L["iWRWelcomeStart"] = Msg("Спасибо ")
L["iWRWelcomeEnd"] = Colors.iWR .. (" за участие в развитии iWillRemember. Если возникнут проблемы - пишите в комментариях на CurseForge или в Discord.")
L["DiscordCopiedToNote"] = Msg("Ссылка на Discord скопирована в поле заметки.")
L["DiscordLink"] = ("https://discord.gg/8nnt25aw8B")
L["InCombat"] = Msg("Нельзя использовать в бою.")
L["CharNoteStart"] = Msg("Заметка о персонаже [")
L["DebugError"] = Msg(Colors.Red .. "ОШИБКА: " .. Colors.iWR)
L["DebugWarning"] = Msg(Colors.Yellow .. "ВНИМАНИЕ: " .. Colors.iWR)
L["DebugInfo"] = Msg(Colors.White .. "ИНФО: " .. Colors.iWR)
L["NameInputError"] = Msg("Невозможно добавить игрока: имя содержит недопустимые символы или пустое. Уберите пробелы, цифры и спецсимволы.")
L["ClearInputError"] = Msg("Невозможно очистить игрока: имя содержит недопустимые символы или пустое.")
L["GroupWarning"] = Msg((Colors.Red .. "Внимание: в группе есть игроки с негативной репутацией.|r"))
L["NewVersionAvailable"] = Msg("Доступна новая версия на CurseForge.")
L["FullDBSendSuccess"] = Msg("База данных успешно отправлена: ")
L["FullDBRetrieve"] = Msg("Примерное время полной синхронизации базы: ")
L["FullDBRetrieveSuccess"] = Msg("Успешно синхронизированы данные от: ")
L["WhitelistFriendsAdded"] = Msg("Отсутствующие друзья из белого списка автоматически добавлены в список друзей.")

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                  Group Log                                     │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["NotesTab"] = "Заметки"
L["GroupLogTab"] = "Журнал группы"
L["GroupLogEmpty"] = "Пока никто не записан. Соберите группу - игроки появятся здесь!"
L["GroupLogDismiss"] = "Закрыть"
L["GroupLogAddNote"] = "Добавить заметку"
L["GroupLogClearAll"] = "Очистить журнал"
L["GroupLogClearConfirm"] = Colors.iWR .. "Вы уверены, что хотите полностью очистить журнал группы?"
L["GroupLogCleared"] = Msg("Журнал группы очищен.")
L["EnableGroupLog"] = "Включить журнал группы"
L["DescEnableGroupLog"] = "|cFF808080Автоматически записывать игроков, с которыми вы в группе. Просмотр - во вкладке «Журнал группы» базы данных.|r"

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                  Menu Slider                                   │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["SaveNote"] = "Сохранить заметку"
