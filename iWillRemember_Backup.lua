-- ═════════════════════════
-- ██╗ ██╗    ██╗ ██████╗
-- ╚═╝ ██║    ██║ ██╔══██╗
-- ██║ ██║ █╗ ██║ ██████╔╝
-- ██║ ██║███╗██║ ██  ██╔
-- ██║ ╚███╔███╔╝ ██   ██╗
-- ╚═╝  ╚══╝╚══╝  ╚══════╝
-- ═════════════════════════

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                              iWR Backup System                                │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

function iWR:BackupDatabase()
    -- Make a copy of the database for backup
    iWRDatabaseBackup = CopyTable(iWRDatabase)
    -- Get the current date and time
    local backupDate = date("%Y-%m-%d")
    local backupTime = date("%H:%M:%S")
    -- Save the backup metadata
    iWRSettings.iWRDatabaseBackupInfo = {
        backupDate = backupDate,
        backupTime = backupTime
    }
    -- Debug message to notify the user
    iWR:DebugMsg("Backup completed on " .. backupDate .. " at " .. backupTime .. "!",3)
end

function iWR:StartHourlyBackup()
    if self.backupTicker then
        iWR:DebugMsg("Automatic backup is already running.",2)
        return
    end

    -- Ticker that runs every hour (3600 seconds)
    self.backupTicker = C_Timer.NewTicker(3600, function()
        iWR:BackupDatabase()
    end)

    iWR:DebugMsg("Automatic backup started.",3)
end

function iWR:StopHourlyBackup()
    if self.backupTicker then
        self.backupTicker:Cancel()
        self.backupTicker = nil
        iWR:DebugMsg("Automatic backup stopped.",3)
    else
        iWR:DebugMsg("No active Automatic backup to stop.",2)
    end
end

function iWR:ToggleHourlyBackup(enabled)
    if enabled then
        self:StartHourlyBackup()
    else
        self:StopHourlyBackup()
    end
end
