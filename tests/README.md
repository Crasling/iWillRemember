# Whitelist sharing checks

Run `sharing.lua` and `sharing_ui.lua` from the addon directory with a Lua 5.4 runner. The UI script also runs the network checks before testing the real sharing-page controls and autocomplete.

The network checks use independent environments and the bundled AceSerializer, plus the real identity, history, and tombstone helpers. They cover mutual whitelisting without friendship, new WoW friend presence, manual lookups, private notes and history, incremental updates, concurrent senders, lost fragments, malformed snapshots, late replies, receiver resets, transport errors, offline replies, restrictions, a thousand-note transfer, migration, and ruleset changes.

## Ruleset storage

The scope includes the WoW project, region, game-mode record, active game mode, and server category. `C_GameRules.IsGameRuleActive` reads `HardcoreRuleset`, `PvPRuleset`, and `RPRuleset` to distinguish Normal (PvE), PvP, Hardcore, RP-PvP, and RP-PvE. Personal PvP flags, War Mode, Classic/Enhanced experience presets, zones, and layer IDs are not server identities and are not used. Missing or unreadable server rule flags block sharing instead of defaulting to PvE.

`iWRRulesetStores` keeps separate notes, backups, Group Logs, whitelists, character lists, guild watchlists, and deletion history. The existing globals refer to the active store. Unlabelled saves from older versions are assigned only to the first confirmed ruleset, with an untouched copy in `legacy`. Unsupported old contacts are archived rather than authorized as character names.

Early 0.24.1 test builds recorded only a Hardcore/non-Hardcore scope. Those buckets are adopted once into the currently confirmed full server category, and their originals are retained. They are never duplicated into every PvE/PvP/RP category. The UI regression check also opens and reopens the parent Settings window to exercise its complete refresh callback.

The real Refresh status and Share now buttons are tested with Debug Mode on and off. Diagnostics include contact counts, the server ruleset, and reasons for waiting or skipping an action, including an empty whitelist or disabled sharing. Transport debug messages distinguish a queued handshake from an actual successful API send or failed send attempts.

## Wire and limits

Only `iWRShareV1`, wire version 1, is registered. Old friend-sharing prefixes are removed. HELLO/READY exchange ruleset and session IDs before DATA is accepted. ACK confirms a complete, validated transfer. Duplicate parts are harmless; incomplete or malformed snapshots cannot partially merge. Reloading a receiver restarts the session and pending transfer. A removed contact loses access to queued packets and open removal confirmations immediately.

Packets are at most 255 bytes, paced at ten packets per second. There are at most eight simultaneous transfers, 4,096 parts per transfer, and 100 whitelist contacts per ruleset. Replies and acknowledgements can take fifteen minutes; an unconfirmed transfer retries at most twice and expires after one hour. There are no periodic discovery whispers. The hourly share uses the whitelist and native availability checks.

Availability uses player GUID preflights, guild/group observations, and current-region WoW game accounts. Unknown manually entered names use exact-name Who searches only for a manual check/share or an active transfer. Searches are paced ten seconds apart and do not change Blizzard's Who routing or run while the Who window is open. An empty result stays Unknown; it is not proof of offline status. An offline server reply pauses further traffic to that contact for five minutes.

## In-game checks before release

1. On two 0.24.1 clients in the same ruleset, add each other by full name without adding friends. Check status and share notes in both directions.
2. Confirm name suggestions, Add/Enter, removal, last-seen tooltips, and the enabled/disabled sharing checkbox.
3. Test one guild member and one player outside the guild/group. Keep the Who window closed for the latter's first lookup.
4. Confirm private notes and private history stay local. Remove a shared entry and check that the other client asks for confirmation after combat. Check Yes, No, and Keep as personal; the personal choice must retain the note and history locally, ignore repeated shared deletions, and exclude queued and future copies from sharing.
5. Start a larger share and reload the receiver. Confirm it finishes once and idle clients do not keep whispering.
6. Log into another ruleset, then back. Confirm the database, whitelist, backups, and deleted notes stay with their ruleset.
7. Check Debug Mode on the live client for native API restrictions or unusual server delivery delays. Simulated tests do not establish live server behaviour.
