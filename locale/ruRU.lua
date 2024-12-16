-- Bartender4 Locale
-- Please use the Localization App on WoWAce to Update this
-- http://www.wowace.com/projects/bartender4/localization/ ;¶

local L = LibStub("AceLocale-3.0"):NewLocale("RememberYouAddon", "ruRU")
if not L then return end

L["RYStartNote"] = "\124TInterface\\AddOns\\RememberYouAddon\\Img\\Icons\\Custom.blp:14\124t Заметка: "
L["RYNotifyBase"] = "|cffff9716Заметка для персонажа: [|r"
L["RYNotifyEnd"] = "|cffff9716] создана.|r"
L["RYEditboxName"] = "Ник персонажа"
L["RYEditboxNote"] = "Заметка"
L["RYDataReset"] = "|cffff9716[Заметки]: База данных удалена.|r"
L["RYDataSendRecent"] = "|cffff9716[Заметки]: Высланы заметки не старше 30 дней.|r"
L["RYDataSendFull"] = "|cffff9716[Заметки]: Высланы заметки за все время. Обновление может занять некоторое время.|r"
L["RYDataImportOn"] = "|cffff9716[Заметки]: Теперь вы получаете обновления от других  игроков.|r"
L["RYDataImportOff"] = "|cffff9716[Заметки]: Вы больше не получаете обновления от других  игроков.|r"
L["RYSetSkin"] = "|cffff9716[Заметки]: Обложка установлена.|r"

L["RYNoTarget"] = "|cffff9716[Заметки]: Возьмите игрока в цель либо введите ник.|r"
L["RememberYouDefaultNotes"] = {
"PlaceHolder", --// First index 1
"\124TInterface\\AddOns\\RememberYouAddon\\Img\\Icons\\Custom.blp:14\124t Заметка: |cffff2121Ненавистный|r \124TInterface\\AddOns\\RememberYouAddon\\Img\\Icons\\Skull.blp:14\124t",
"\124TInterface\\AddOns\\RememberYouAddon\\Img\\Icons\\Custom.blp:14\124t Заметка: |cffff2121Неприятель|r \124TInterface\\AddOns\\RememberYouAddon\\Img\\Icons\\Dislike.blp:14\124t",
"\124TInterface\\AddOns\\RememberYouAddon\\Img\\Icons\\Custom.blp:14\124t Заметка: |cff80f451Дружественный \124TInterface\\AddOns\\RememberYouAddon\\Img\\Icons\\Like.blp:14\124t",
"\124TInterface\\AddOns\\RememberYouAddon\\Img\\Icons\\Custom.blp:14\124t Заметка: |cff80f451Превозносимый|r \124TInterface\\AddOns\\RememberYouAddon\\Img\\Icons\\Friend.blp:14\124t",
}


L["RYHelp1"] = "|cffff9716[Заметки]: /rememberyou /ry|r"
L["RYHelp2"] = "|cffff9716/ry help|r"
L["RYHelp3"] = "|cffff9716/ry data reset|r **Очищает всю базу заметок."
L["RYHelp4"] = "|cffff9716/ry data send recent|r **Остылает базу за последний месяц в гильдию."
L["RYHelp5"] = "|cffff9716/ry data send full|r **Остылает всю базу в гильдию."
L["RYHelp6"] = "|cffff9716/ry import on|r **Включает обмен данными."
L["RYHelp7"] = "|cffff9716/ry import off|r **Выключает обмен данными."
L["RYHelp8"] = "|cffff9716/ry skin 1-4|r *Изменяет обложку."
