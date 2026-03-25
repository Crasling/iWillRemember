-- ═════════════════════════
-- ██╗ ██╗    ██╗ ██████╗ 
-- ╚═╝ ██║    ██║ ██╔══██╗
-- ██║ ██║ █╗ ██║ ██████╔╝
-- ██║ ██║███╗██║ ██  ██╔
-- ██║ ╚███╔███╔╝ ██   ██╗ 
-- ╚═╝  ╚══╝╚══╝  ╚══════╝ 
-- ═════════════════════════

local addonName, addon = ...

-- Translator ZamestoTV
-- Lines marked "AI translated" may not be fully correct.
-- Only load Russian localization on Russian clients
if GetLocale() ~= "ruRU" then return end

local L = LibStub("AceLocale-3.0"):NewLocale("iWR", "ruRU")
if not L then return end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                     Цвета                                     │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
local Colors = {
    -- Стандартные цвета
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

    -- Цвета классов WoW
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

    -- Сброс цвета
    Reset = "|r"
}

local DefaultMessageStart = Colors.iWR .. "[iWR]: "
local function Msg(message)
    return DefaultMessageStart .. message
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                 Текстовые шаблоны                             │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["NoteToolTip"] = Colors.iWR .. "[iWR]: "
L["DefaultNameInput"] = "Введите имя игрока..."
L["DefaultNoteInput"] = "Введите заметку..."
L["MinimapButtonLeftClick"] = (Colors.Yellow .. "ЛКМ: " .. Colors.Orange .. "Открыть меню iWR")
L["MinimapButtonShiftLeftClick"] = (Colors.Yellow .. "Shift-ЛКМ: " .. Colors.Orange .. "Открыть базу данных iWR")
L["MinimapButtonRightClick"] = (Colors.Yellow .. "ПКМ: " .. Colors.Orange .. "Открыть настройки")
L["CharNoteCreated"] = Colors.iWR .."] добавлен в базу данных iWR.|r"
L["CharNoteUpdated"] = Colors.iWR .."] обновлен в базе данных iWR.|r"
L["CharNoteRemoved"] = Colors.iWR .."] удален из базы данных iWR.|r"
L["CharNoteClassMissing"] = " Информация о классе отсутствует, будет добавлена при следующем выборе игрока."
L["CharNoteColorUpdate"] = Colors.iWR .."] найден с отсутствующей информацией о классе в базе данных iWR. Цвет класса был добавлен в базу данных iWR."
L["CharNoteFactionMissing"] = " Информация о фракции отсутствует, будет добавлена при следующем выборе игрока." -- ИИ перевод
L["CharNoteFactionUpdate"] = Colors.iWR .."] найден с отсутствующей фракцией в базе данных iWR. Фракция была добавлена." -- ИИ перевод
L["Translations"] = "Перевод"
L["DiscordLinkMessage"] = "Скопируйте эту ссылку, чтобы присоединиться к нашему Discord для поддержки и обновлений."
L["CreatedBy"] = "Создано: "
L["AboutMessageInfo"] = Colors.iWR .. "iWillRemember " .. Colors.Reset .. "— это аддон, разработанный для того, чтобы помочь вам отслеживать и легко делиться заметками о игроках с друзьями."
L["AboutMessageEarlyDev"] = Colors.iWR .. "iWR " .. Colors.Reset .. "находится на ранней стадии разработки. Присоединяйтесь к Discord для получения помощи по вопросам, проблемам или предложениям."
L["Tab1General"] = "Общие"
L["Tab2Sync"] = "Синхронизация"
L["Tab3Backup"] = "Резервное копирование"
L["Tab4About"] = "О аддоне"
L["NoBackup"] = "Резервная копия недоступна"
L["LastBackup1"] = "Последняя резервная копия: "
L["at"] = " в "
L["BackupRestoreError"] = Colors.Red .. "[iWR]: Не найдено резервной копии для восстановления."
L["BackupRestore"] = Colors.iWR .. "[iWR]: База данных восстановлена из резервной копии, созданной "
L["RestoreConfirm"] = Colors.Red .. "Вы уверены, что хотите перезаписать текущую базу данных iWR данными из резервной копии?|nЭто действие необратимо.\n\nРезервная копия создана "
L["UnknownDate"] = "Неизвестная дата"
L["UnknownTime"] = "Неизвестное время"
L["Yes"] = "Да"
L["No"] = "Нет"
L["RestoreDatabase"] = "Восстановить базу данных"
L["EnableBackup"] = "Включить автоматическое резервное копирование"
L["WhiteListTitle"] = Colors.iWR .. "Белый список"
L["AddtoWhitelist"] = Colors.iWR .. "Добавить друзей в белый список:"
L["Friends"] = "Друзья"
L["AllFriends"] = "Все друзья"
L["Whitelist"] = "Белый список"
L["OnlyWhitelist"] = "Только белый список"
L["EnableSync"] = "Включить синхронизацию с друзьями"
L["SyncSettings"] = Colors.iWR .. "Настройки синхронизации"
L["ShowAuthor"] = "Показывать автора во всплывающей подсказке"
L["ToolTipSettings"] = Colors.iWR .. "Настройки всплывающих подсказок"
L["EnableSoundWarning"] = "Включить звуковые предупреждения"
L["EnableGroupWarning"] = "Включить предупреждения для группы"
L["WarningSettings"] = Colors.iWR .. "Настройки предупреждений"
L["ShowChatIcons"] = "Показывать иконки в чате"
L["EnhancedFrame"] = "Показывать улучшенный фрейм цели"
L["DisplaySettings"] = Colors.iWR .. "Настройки отображения"
L["SettingsTitle"] = Colors.iWR .. "Настройки"
L["VersionWarning"] = Colors.iWR .. "[iWR]: " .. Colors.Yellow.. "ПРЕДУПРЕЖДЕНИЕ" .. Colors.iWR .. ": Это альфа-версия, которая может быть нестабильной и вызывать проблемы с вашей базой данных. Если вы не хотите использовать эту версию, пожалуйста, вернитесь к последнему стабильному релизу."
L["DBNameNotFound1"] = Colors.iWR .. "[iWR]: Имя [|r"
L["DBNameNotFound2"] = Colors.iWR .. "] не найдено в базе данных."

L["HelpSync"] = Colors.Yellow .. "Как синхронизировать: " .. Colors.iWR .. "Добавьте своих друзей в социальную панель в игре, это не будет распространяться на друзей Battle.Net (REAL ID), только на друзей, добавленных в список друзей World of Warcraft, и вам обоим нужно добавить друг друга для успешной синхронизации."
L["HelpUse"] = Colors.Yellow .. "Как использовать: " .. Colors.iWR .. "Выберите игрока или введите его имя вручную, при необходимости добавьте заметку и нажмите Уважаемый, Нравится, Не нравится или Ненавижу, чтобы сохранить игрока в базе данных."
L["HelpClear"] = Colors.Yellow .. "Как очистить: " .. Colors.iWR .. "При нажатии кнопки Очистить имя в текстовом поле имени игрока будет удалено из базы данных, вы также можете удалить их из базы данных с помощью кнопки удаления или просто отредактировать из базы данных."
L["HelpSettings"] = Colors.Yellow .. "Меню настроек: " .. Colors.iWR .. "ПКМ по иконке на миникарте, чтобы открыть меню настроек."
L["HelpDiscord"] = Colors.Yellow .."Помощь в Discord: " .. Colors.iWR .. "Нажмите кнопку с вопросительным знаком без имени игрока, чтобы вставить код в поле заметки для копирования [https://discord.gg/8nnt25aw8B]"

L["Russian"] = "Русский язык"

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                           Описания панели настроек                            │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["OptionsPanelSubtitle"] = "|cFF808080Отслеживайте и делитесь заметками о игроках с друзьями.|r"
L["DescEnhancedFrame"] = "|cFF808080Отображает цветную рамку на фрейме цели для отслеживаемых игроков.|r"
L["DescShowChatIcons"] = "|cFF808080Показывает иконки репутации рядом с именами отслеживаемых игроков в чате.|r"
L["DescSimpleMenu"] = "|cFF808080Заменяет ползунок настраиваемыми кнопками уровней. Настройте уровни во вкладке «Настройка».|r" -- ИИ перевод
L["GoodLevels"] = "Положительные уровни" -- ИИ перевод
L["BadLevels"] = "Отрицательные уровни" -- ИИ перевод
L["SimpleLevelsHeader"] = Colors.iWR .. "Уровни простого меню" -- ИИ перевод
L["DescSimpleLevels"] = "|cFF808080Задайте количество положительных и отрицательных уровней для кнопок простого меню. Иконки и названия для каждого уровня можно настроить ниже.|r" -- ИИ перевод
L["RelationLevelsHeader"] = Colors.iWR .. "Уровни отношений" -- ИИ перевод
L["DescRelationLevels"] = "|cFF808080Задайте количество положительных и отрицательных уровней. Базовые уровни (Превосходный, Уважаемый, Нравится, Неприязнь, Ненависть) всегда присутствуют.|r" -- ИИ перевод
L["DescEnableGroupWarning"] = "|cFF808080Предупреждает вас, когда в группе или рейде есть игроки с негативным рейтингом.|r"
L["DescEnableSoundWarning"] = "|cFF808080Воспроизводит звуковое уведомление вместе с всплывающими предупреждениями о группе.|r"
L["DescShowAuthor"] = "|cFF808080Показывает, кто создал заметку, при наведении на отслеживаемого игрока.|r"
L["MinimapSettings"] = Colors.iWR .. "Настройки миникарты"
L["ShowMinimapButton"] = "Показывать кнопку на миникарте"
L["DescShowMinimapButton"] = "|cFF808080Переключает видимость кнопки iWillRemember на миникарте.|r"
L["DescEnableSync"] = "|cFF808080Делится вашей базой данных с друзьями, у которых также установлен iWillRemember. Оба игрока должны быть в списке друзей друг друга.|r"
L["DescEnableBackup"] = "|cFF808080Автоматически создаёт резервную копию вашей базы данных каждый час.|r"
L["DatabaseStats"] = Colors.iWR .. "Статистика базы данных"
L["ResetSettingsHeader"] = Colors.iWR .. "Сброс"
L["ResetToDefaults"] = "Сбросить настройки по умолчанию"
L["ResetConfirm"] = "Вы уверены, что хотите сбросить все настройки до значений по умолчанию?\n\nВаша база данных игроков НЕ будет затронута."
L["SettingsResetSuccess"] = Msg("Настройки сброшены по умолчанию. Введите /reload для применения.")
L["ButtonLabelsSettings"] = Colors.iWR .. "Названия кнопок"
L["DescButtonLabels"] = "|cFF808080Настройте текст для каждой категории рейтинга. Изменения применяются к кнопкам, подсказкам, предупреждениям и всем отображениям.|r"
L["ResetLabels"] = "Сбросить названия по умолчанию"
L["Tab5Customize"] = "Настройка"
L["DescCustomizeInfo"] = "|cFF808080Все изменения на этой странице являются локальными и визуальными. Они не синхронизируются с другими игроками и не влияют на общие данные.|r"
L["CustomIconsSettings"] = Colors.iWR .. "Пользовательские иконки"
L["DescCustomIcons"] = "|cFF808080Выберите пользовательские иконки для каждого рейтинга. Изменения применяются к кнопкам, подсказкам и отображению базы данных.|r"
L["ChangeIcon"] = "Изменить"
L["ResetIcon"] = "Сброс"
L["SelectIcon"] = "Выбор иконки"
L["IconPathHelpInline"] = "Введите путь, напр. Interface\\Icons\\Spell_Fire_Fire - названия на wowhead.com"
L["TabINIF"] = "iNIF Settings"
L["INIFSettingsHeader"] = Colors.iWR .. "Настройки iNeedIfYouNeed"
L["INIFInstalledDesc1"] = Colors.iWR .. "iNeedIfYouNeed" .. Colors.Reset .. " установлен! Вы можете получить доступ к настройкам iNIF отсюда."
L["INIFInstalledDesc2"] = "|cFF808080Примечание: Эти настройки управляются iNIF и влияют на аддон iNIF.|r"
L["INIFOpenSettingsButton"] = "Открыть настройки iNIF"
L["INIFPromoDesc"] = Colors.iWR .. "iNeedIfYouNeed" .. Colors.Reset .. " — умный аддон для лута. Автоматически бросает Need, когда другие участники группы нуждаются, иначе Greed. Не упустите шанс на случайный BoE лут.\n\n" .. Colors.Reset .. "Простой чекбокс на окне лута — отметьте и нажмите Greed для мониторинга."
L["INIFPromoLink"] = "Доступно в CurseForge App и на curseforge.com/wow/addons/ineedifyouneed"
L["TabISP"] = "iSP Settings"
L["ISPSettingsHeader"] = Colors.iWR .. "Настройки iSoundPlayer"
L["ISPInstalledDesc1"] = Colors.iWR .. "iSoundPlayer" .. Colors.Reset .. " установлен! Вы можете получить доступ к настройкам iSP отсюда."
L["ISPInstalledDesc2"] = "|cFF808080Примечание: Эти настройки управляются iSP и влияют на аддон iSP.|r"
L["ISPOpenSettingsButton"] = "Открыть настройки iSP"
L["ISPPromoDesc"] = Colors.iWR .. "iSoundPlayer" .. Colors.Reset .. " — аддон для воспроизведения звуков. Проигрывайте свои MP3-файлы при событиях в игре: убийства, повышение уровня, встречи с боссами и многое другое.\n\n" .. Colors.Reset .. "Добавьте звуковые файлы и назначьте триггеры — полностью настраиваемый."
L["ISPPromoLink"] = "Доступно в CurseForge App и на curseforge.com/wow/addons/isoundplayer"

L["TabICC"] = "Настройки iCC" -- ИИ перевод
L["TabICCPromo"] = "iCommunityChat"
L["ICCSettingsHeader"] = Colors.iWR .. "Настройки iCommunityChat" -- ИИ перевод
L["ICCInstalledDesc1"] = Colors.iWR .. "iCommunityChat" .. Colors.Reset .. " установлен! Вы можете открыть настройки iCC отсюда." -- ИИ перевод
L["ICCInstalledDesc2"] = "|cFF808080Примечание: Эти настройки управляются iCC и влияют на аддон iCC.|r" -- ИИ перевод
L["ICCOpenSettingsButton"] = "Открыть настройки iCC" -- ИИ перевод
L["ICCPromoHeader"] = Colors.iWR .. "iCommunityChat"
L["ICCPromoDesc"] = Colors.iWR .. "iCommunityChat" .. Colors.Reset .. " — аддон для межгильдейских сообществ. Создавайте и управляйте сообществами с общим чатом, составом и рангами — за пределами гильдий.\n\n" .. Colors.Reset .. "Ваше сообщество, ваш чат." -- ИИ перевод
L["ICCPromoLink"] = "Доступно в CurseForge App и на curseforge.com/wow/addons/icommunitychat" -- ИИ перевод

-- Guild Watchlist
L["GuildsTab"] = "Гильдии"
L["GuildWatchlistHeader"] = "Список гильдий"
L["GuildWatchlistDesc"] = "|cFF808080Добавьте название гильдии и тип отношения. Игроки из отслеживаемых гильдий автоматически добавляются при нацеливании или в группе.|r"
L["GuildNameLabel"] = "Название гильдии:"
L["GuildNoteLabel"] = "Заметка по умолчанию:" -- ИИ перевод
L["GuildWatchlistAdd"] = "Добавить"
L["GuildWatchlistEmpty"] = "Список гильдий пуст."
L["GuildWatchlistAdded"] = Msg("Гильдия добавлена: %s (%s)")
L["GuildWatchlistRemoved"] = Msg("Гильдия удалена: %s")
L["GuildWatchlistAutoImport"] = Msg("Список гильдий: Автоимпорт %s (Гильдия: %s)")
L["GuildWatchlistDefaultNote"] = "Автоимпорт из гильдии: %s"

L["iWRLoaded"] = Msg("iWillRemember")
L["iWRWelcomeStart"] = Msg("Спасибо ")
L["iWRWelcomeEnd"] = Colors.iWR .. (" за участие в разработке iWillRemember, если у вас возникнут проблемы, пожалуйста, свяжитесь с нами на CurseForge в разделе комментариев или в Discord.")
L["DiscordCopiedToNote"] = Msg("Ссылка на Discord была скопирована в поле заметки.")
L["DiscordLink"] = ("https://discord.gg/8nnt25aw8B")
L["InCombat"] = Msg("Нельзя использовать в бою.")
L["CharNoteStart"] = Msg("Заметка о персонаже [")
L["DebugError"] = Msg(Colors.Red .. "ОШИБКА: " .. Colors.iWR)
L["DebugWarning"] = Msg(Colors.Yellow .. "ПРЕДУПРЕЖДЕНИЕ: " .. Colors.iWR)
L["DebugInfo"] = Msg(Colors.White .. "ИНФОРМАЦИЯ: " .. Colors.iWR)
L["NameInputError"] = Msg("Невозможно добавить игрока: имя содержит недопустимые символы или пустое. Пожалуйста, удалите пробелы, цифры или специальные символы и попробуйте снова.")
L["ClearInputError"] = Msg("Невозможно очистить игрока: имя содержит недопустимые символы или пустое. Пожалуйста, удалите пробелы, цифры или специальные символы и попробуйте снова.")
L["GroupWarning"] = Msg((Colors.Red .. "Предупреждение: В группе найдены совпадения в базе данных.|r"))
L["NewVersionAvailable"] = Msg("Доступна новая версия на CurseForge.")
L["FullDBSendSuccess"] = Msg("База данных успешно отправлена: ")
L["FullDBRetrieve"] = Msg("Примерное время для полного получения базы данных: ")
L["FullDBRetrieveSuccess"] = Msg("Данные успешно синхронизированы с: ")
L["WhitelistFriendsAdded"] = Msg("Отсутствующие друзья из белого списка на этом сервере были автоматически добавлены в список друзей.")

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                              Вывод в чат                                      │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["SectionChatOutput"] = "Вывод в чат" -- ИИ перевод
L["ChatFrameAlwaysOn"] = "(всегда включён)" -- ИИ перевод

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                           Настройки панели параметров                         │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["SimpleMenu"] = "Упрощённое меню" -- ИИ перевод
L["SidebarHeaderiWR"] = Colors.iWR .. "iWillRemember|r"
L["SidebarHeaderOtherAddons"] = Colors.iWR .. "Другие аддоны|r" -- ИИ перевод
L["SetButton"] = "Установить" -- ИИ перевод
L["SyncModeLabel"] = "Режим синхронизации" -- ИИ перевод
L["RemoveFromWhitelist"] = "Удалить из белого списка" -- ИИ перевод
L["NoFriendsWhitelist"] = "|cFF808080Нет друзей в белом списке.|r" -- ИИ перевод
L["BackupSettingsHeader"] = Colors.iWR .. "Настройки резервного копирования" -- ИИ перевод
L["INIFPromoHeader"] = Colors.iWR .. "iNeedIfYouNeed"
L["ISPPromoHeader"] = Colors.iWR .. "iSoundPlayer"
L["TabINIFPromo"] = "iNeedIfYouNeed"
L["TabISPPromo"] = "iSoundPlayer"
L["AboutHeader"] = Colors.iWR .. "О аддоне" -- ИИ перевод
L["DiscordHeader"] = Colors.iWR .. "Discord"
L["DeveloperHeader"] = Colors.iWR .. "Разработчик" -- ИИ перевод
L["EnableDebugMode"] = "Включить режим отладки" -- ИИ перевод
L["DescEnableDebugMode"] = "|cFF808080Включает подробные отладочные сообщения в чат. Не рекомендуется для обычного использования.|r" -- ИИ перевод
L["ResetSettingsDesc"] = "|cFF808080Сбрасывает все настройки аддона до значений по умолчанию. Ваша база данных игроков и белый список не будут затронуты.|r" -- ИИ перевод
L["SettingsPanelStubDesc"] = "ПКМ по иконке на миникарте или введите |cFFFFFF00/iwr settings|r для открытия панели настроек." -- ИИ перевод
L["GameVersionLabel"] = Colors.iWR .. "Версия игры: |r" -- ИИ перевод
L["TOCVersionLabel"] = Colors.iWR .. "Версия TOC: |r" -- ИИ перевод
L["BuildVersionLabel"] = Colors.iWR .. "Версия сборки: |r" -- ИИ перевод
L["BuildDateLabel"] = Colors.iWR .. "Дата сборки: |r" -- ИИ перевод

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                              Журнал группы                                    │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["NotesTab"] = "Заметки" -- ИИ перевод
L["GroupLogTab"] = "Журнал группы" -- ИИ перевод
L["GroupLogEmpty"] = "Игроков пока нет. Вступите в группу, и они появятся здесь!" -- ИИ перевод
L["GroupLogDismiss"] = "Скрыть" -- ИИ перевод
L["GroupLogAddNote"] = "Добавить заметку" -- ИИ перевод
L["GroupLogClearAll"] = "Очистить журнал" -- ИИ перевод
L["GroupLogClearConfirm"] = Colors.iWR .. "Вы уверены, что хотите очистить весь журнал группы?" -- ИИ перевод
L["GroupLogCleared"] = Msg("Журнал группы очищен.") -- ИИ перевод
L["EnableGroupLog"] = "Включить журнал группы" -- ИИ перевод
L["DescEnableGroupLog"] = "|cFF808080Автоматически записывает игроков, с которыми вы были в группе. Просматривайте их в базе данных во вкладке «Журнал группы».|r" -- ИИ перевод

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                              Ползунок меню                                    │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["SaveNote"] = "Сохранить заметку" -- ИИ перевод
L["ClearButton"] = "Очистить" -- ИИ перевод
L["EditButton"] = "Изменить" -- ИИ перевод
L["RemoveButton"] = "Удалить" -- ИИ перевод
L["PlayerNameHeader"] = "Имя игрока" -- ИИ перевод
L["NoteHeader"] = "Заметка" -- ИИ перевод
L["RelationLevelHeader"] = "Уровень отношения" -- ИИ перевод
L["PersonalCheckbox"] = "Личная (не синхронизируется)" -- ИИ перевод
L["PersonalDatabaseTitle"] = "iWillRemember — Личная база данных" -- ИИ перевод
L["CreateNote"] = "Создать заметку" -- ИИ перевод
L["OpenDatabase"] = "Открыть базу данных" -- ИИ перевод
L["FilterAll"] = "Все" -- ИИ перевод
L["FilterMine"] = "Мои" -- ИИ перевод
L["FilterFriends"] = "Друзья" -- ИИ перевод
L["EntriesCount"] = "%d записей" -- ИИ перевод
L["EntriesFiltered"] = "%d из %d записей" -- ИИ перевод
L["SearchPlaceholder"] = "Поиск..." -- ИИ перевод
L["HelpTooltipTitle"] = "Как использовать iWillRemember" -- ИИ перевод
L["RightClickWhisper"] = "ПКМ — написать в шёпот" -- ИИ перевод

-- Подписи деталей -- ИИ перевод
L["DetailName"] = "Имя:"
L["DetailType"] = "Тип:"
L["DetailNote"] = "Заметка:"
L["DetailAuthor"] = "Автор:"
L["DetailDate"] = "Дата:"
L["DetailStatus"] = "Статус:"
L["DetailFaction"] = "Фракция:"
L["StatusPersonal"] = "Личная"
L["StatusShared"] = "Общая"
L["DetailServer"] = "Сервер:" -- ИИ перевод
L["DetailZone"] = "Зона:" -- ИИ перевод
L["DetailInstanceType"] = "Тип подземелья:" -- ИИ перевод
L["DetailPlayerDetails"] = "iWR: Детали игрока" -- ИИ перевод
L["DatabaseEntriesLabel"] = "Записей в базе данных:"  -- ИИ перевод
L["BackupEntriesLabel"] = "Записей в резервной копии:" -- ИИ перевод
L["AITranslationNote"] = "Некоторые тексты были переведены ИИ и могут быть неточными." -- ИИ перевод
L["MyCharsRemove"] = "Удалить" -- ИИ перевод

-- Кнопки -- ИИ перевод
L["ClearAllButton"] = "Очистить всё"
L["ShareFullDBButton"] = "Поделиться БД"

-- Всплывающие окна -- ИИ перевод
L["ClearDBConfirm"] = "Вы уверены, что хотите очистить текущую базу данных iWR?|nЭто действие необратимо."
L["ClearDBSuccess"] = "[iWR]: База данных очищена."
L["ShareDBConfirm"] = "Вы уверены, что хотите поделиться всей базой данных?"
L["ShareDBEmpty"] = "[iWR]: База данных пуста. Нечего отправлять."
L["ShareDBInitiated"] = "[iWR]: Синхронизация базы данных запущена. Это может занять несколько минут."
L["RemoveConfirmCrossRealm"] = "Вы уверены, что хотите удалить |n|n[%s-%s" .. Colors.iWR .. "] |n|n из базы данных iWR?"
L["RemoveConfirmSameRealm"] = "Вы уверены, что хотите удалить |n|n[%s" .. Colors.iWR .. "] |n|n из базы данных iWR?"

-- Language Settings: intentionally NOT localized — always shown in English so users can find the option