<?php
/**
 * Telegram Server Monitoring System (PHP)
 *
 * Überwacht:
 * 1. Security (SSH-Logins, brute force)
 * 2. System-Status (CPU, RAM, Disk)
 * 3. Backup-Status
 * 4. Web-App-Status (bei Fehler)
 * 5. Zusätzliche Checks (SSL, PHP-Fehler)
 * 6. System-Updates (VERBESSERT)
 */

// ===== KONFIGURATION =====
$CONFIG = [
    'telegram' => [
        'bot_token' => '8218652700:AAFyez3gfj_z3GaLdxNN141159RD98wjUgw',
        'chat_id' => '6022997475'
    ],

    'thresholds' => [
        'disk_warning' => 80,      // %
        'disk_critical' => 90,     // %
        'ram_warning' => 85,       // %
        'cpu_warning' => 80,       // %
        'ssh_attempts' => 5,       // in 10 Min
        'response_time' => 3000,   // ms
        'php_errors' => 10,        // pro Stunde
        'ssl_days' => 30,          // Tage bis Ablauf
        'security_update_age' => 2 // Tage bis Warnung
    ],

    'urls' => [
        'webapp' => 'https://praxis-olszewski.de/soziotherapie/',
        'health_check' => 'https://praxis-olszewski.de/soziotherapie/index.php'
    ],

    'update_tracking' => '/tmp/security_updates.json'
];

// ===== TELEGRAM API =====
function sendTelegram($message, $priority = 'INFO') {
    global $CONFIG;

    $emoji = [
        'CRITICAL' => '🚨',
        'WARNING' => '⚠️',
        'INFO' => 'ℹ️',
        'SUCCESS' => '✅'
    ];

    $formatted = ($emoji[$priority] ?? 'ℹ️') . " **{$priority}**\n\n{$message}";

    $url = "https://api.telegram.org/bot{$CONFIG['telegram']['bot_token']}/sendMessage";

    $data = [
        'chat_id' => $CONFIG['telegram']['chat_id'],
        'text' => $formatted,
        'parse_mode' => 'Markdown'
    ];

    $options = [
        'http' => [
            'method' => 'POST',
            'header' => 'Content-Type: application/x-www-form-urlencoded',
            'content' => http_build_query($data)
        ]
    ];

    $context = stream_context_create($options);
    $result = @file_get_contents($url, false, $context);

    return $result !== false;
}

// ===== 1. SECURITY CHECKS =====
function checkSecurity() {
    global $CONFIG;

    echo "🔒 Security-Check...\n";

    // Failed SSH logins
    $failedLogins = (int)shell_exec("grep 'Failed password' /var/log/auth.log | tail -20 | wc -l");

    if ($failedLogins > $CONFIG['thresholds']['ssh_attempts']) {
        $topIPs = shell_exec("grep 'Failed password' /var/log/auth.log | tail -50 | grep -oP '\\d+\\.\\d+\\.\\d+\\.\\d+' | sort | uniq -c | sort -rn | head -3");

        sendTelegram(
            "🔒 **SECURITY ALERT**\n\n" .
            "❌ {$failedLogins} fehlgeschlagene SSH-Logins!\n\n" .
            "**Top IPs:**\n```\n{$topIPs}```",
            'CRITICAL'
        );
    }

    // Root-Login-Versuche
    $rootAttempts = (int)shell_exec("grep 'Failed password for root' /var/log/auth.log | tail -10 | wc -l");

    if ($rootAttempts > 0) {
        sendTelegram(
            "🚨 **ROOT LOGIN ATTEMPTS**\n\n" .
            "{$rootAttempts} Versuche als root einzuloggen!\n" .
            "Dies ist ein Angriff!",
            'CRITICAL'
        );
    }
}

// ===== 2. SYSTEM STATUS =====
function checkSystemStatus() {
    global $CONFIG;

    echo "💻 System-Status-Check...\n";

    // Disk Space
    $diskPercent = (int)trim(shell_exec("df -h / | tail -1 | awk '{print $5}' | sed 's/%//'"));

    // RAM Usage
    $ramPercent = (int)trim(shell_exec("free | grep Mem | awk '{print ($3/$2) * 100.0}'"));

    // CPU Load
    $cpuPercent = (int)trim(shell_exec("top -bn1 | grep 'Cpu(s)' | sed 's/.*, *\\([0-9.]*\\)%* id.*/\\1/' | awk '{print 100 - $1}'"));

    // Uptime
    $uptime = trim(shell_exec("uptime -p"));

    // Warnungen
    $warnings = [];
    $priority = 'INFO';

    if ($diskPercent >= $CONFIG['thresholds']['disk_critical']) {
        $warnings[] = "💾 **DISK CRITICAL**: {$diskPercent}%";
        $priority = 'CRITICAL';
    } elseif ($diskPercent >= $CONFIG['thresholds']['disk_warning']) {
        $warnings[] = "💾 Disk Warning: {$diskPercent}%";
        $priority = 'WARNING';
    }

    if ($ramPercent >= $CONFIG['thresholds']['ram_warning']) {
        $warnings[] = "🧠 RAM hoch: {$ramPercent}%";
        $priority = ($priority === 'CRITICAL') ? 'CRITICAL' : 'WARNING';
    }

    if ($cpuPercent >= $CONFIG['thresholds']['cpu_warning']) {
        $warnings[] = "⚙️ CPU hoch: {$cpuPercent}%";
        $priority = ($priority === 'CRITICAL') ? 'CRITICAL' : 'WARNING';
    }

    // Nur bei Warnungen oder täglich um 8:00
    $hour = (int)date('H');
    if (count($warnings) > 0 || $hour === 8) {
        $message = count($warnings) > 0
            ? "**System-Warnungen:**\n\n" . implode("\n", $warnings) . "\n\n" .
              "📊 **Status:**\n" .
              "💾 Disk: {$diskPercent}%\n" .
              "🧠 RAM: {$ramPercent}%\n" .
              "⚙️ CPU: {$cpuPercent}%\n" .
              "🔄 Uptime: {$uptime}"
            : "**Täglicher System-Status** ✅\n\n" .
              "💾 Disk: {$diskPercent}%\n" .
              "🧠 RAM: {$ramPercent}%\n" .
              "⚙️ CPU: {$cpuPercent}%\n" .
              "🔄 Uptime: {$uptime}";

        sendTelegram($message, $priority);
    }
}

// ===== 3. BACKUP-STATUS =====
function checkBackupStatus() {
    echo "💾 Backup-Check...\n";

    $lastBackup = trim(shell_exec("ls -lt /var/backups/soziotherapie/ 2>/dev/null | head -2 | tail -1 | awk '{print \$6\" \"\$7\" \"\$8\" \"\$9}'"));

    if (empty($lastBackup)) {
        sendTelegram(
            "⚠️ **Backup-Warnung**\n\nKein Backup-Verzeichnis gefunden!",
            'WARNING'
        );
        return;
    }

    // Backup-Alter prüfen
    $backupAge = (int)shell_exec("find /var/backups/soziotherapie/ -type f -mtime -1 2>/dev/null | wc -l");

    if ($backupAge === 0) {
        sendTelegram(
            "❌ **Backup-Fehler**\n\nLetztes Backup älter als 24h!\n\n" .
            "Letztes Backup: {$lastBackup}",
            'CRITICAL'
        );
    }
}

// ===== 4. WEB-APP-STATUS (nur bei Fehler) =====
function checkWebAppStatus() {
    global $CONFIG;

    echo "🌐 Web-App-Check...\n";

    $start = microtime(true);
    $headers = @get_headers($CONFIG['urls']['health_check']);
    $responseTime = (int)((microtime(true) - $start) * 1000);

    if ($headers === false || strpos($headers[0], '200') === false) {
        $status = $headers ? $headers[0] : 'Connection failed';
        sendTelegram(
            "❌ **Web-App Fehler**\n\n" .
            "URL: {$CONFIG['urls']['health_check']}\n" .
            "Status: {$status}\n" .
            "Response Time: {$responseTime}ms",
            'CRITICAL'
        );
        return false;
    }

    if ($responseTime > $CONFIG['thresholds']['response_time']) {
        sendTelegram(
            "⚠️ **Web-App langsam**\n\n" .
            "Response Time: {$responseTime}ms\n" .
            "Schwellwert: {$CONFIG['thresholds']['response_time']}ms",
            'WARNING'
        );
    }

    return true;
}

// ===== 5. ZUSÄTZLICHE CHECKS =====
function checkAdditional() {
    global $CONFIG;

    echo "🔍 Zusätzliche Checks...\n";

    // SSL-Zertifikat prüfen
    $sslExpiry = trim(shell_exec("echo | openssl s_client -servername praxis-olszewski.de -connect praxis-olszewski.de:443 2>/dev/null | openssl x509 -noout -dates | grep notAfter | cut -d= -f2"));

    if (!empty($sslExpiry)) {
        $expiryDate = strtotime($sslExpiry);
        $daysUntilExpiry = (int)(($expiryDate - time()) / 86400);

        if ($daysUntilExpiry <= $CONFIG['thresholds']['ssl_days']) {
            sendTelegram(
                "🔒 **SSL-Zertifikat läuft ab**\n\n" .
                "Noch {$daysUntilExpiry} Tage!\n" .
                "Ablaufdatum: " . date('d.m.Y', $expiryDate),
                $daysUntilExpiry <= 7 ? 'CRITICAL' : 'WARNING'
            );
        }
    }

    // PHP-Fehler im Error-Log
    $phpErrors = (int)shell_exec("grep -i 'PHP Fatal\\|PHP Warning' /var/log/apache2/error.log 2>/dev/null | grep '$(date +%d/%b/%Y:%H)' | wc -l");

    if ($phpErrors > $CONFIG['thresholds']['php_errors']) {
        sendTelegram(
            "🐛 **PHP-Fehler häufen sich**\n\n" .
            "{$phpErrors} Fehler in der letzten Stunde!\n" .
            "Schwellwert: {$CONFIG['thresholds']['php_errors']}/h",
            'WARNING'
        );
    }
}

// ===== 6. UPDATE-CHECK (VERBESSERT) =====
function checkSystemUpdates() {
    global $CONFIG;

    echo "🔄 System-Updates prüfen...\n";

    // Alle verfügbaren Updates abrufen
    exec("apt list --upgradable 2>/dev/null | grep -v 'Listing'", $allUpdatesRaw);
    
    if (empty($allUpdatesRaw)) {
        echo "✅ Keine Updates verfügbar.\n";
        return;
    }

    // Updates kategorisieren
    $securityUpdates = [];
    $dockerUpdates = [];
    $otherUpdates = [];

    foreach ($allUpdatesRaw as $update) {
        // Format: package/repo version arch [upgradable from: old_version]
        preg_match('/^([^\/ ]+)/', $update, $packageMatch);
        $package = $packageMatch[1] ?? '';

        if (empty($package)) continue;

        // Kategorisierung
        if (strpos($update, 'security') !== false || 
            preg_match('/(libssl|openssl|kernel|linux-|openssh)/', $package)) {
            $securityUpdates[] = $update;
        } elseif (preg_match('/(docker|containerd)/', $package)) {
            $dockerUpdates[] = $update;
        } else {
            $otherUpdates[] = $update;
        }
    }

    // Tracking-Datei laden/erstellen
    $trackingFile = $CONFIG['update_tracking'];
    $tracking = file_exists($trackingFile) 
        ? json_decode(file_get_contents($trackingFile), true) 
        : [];

    $now = time();
    $messages = [];

    // 1. Security-Updates prüfen (nur warnen wenn älter als 2 Tage)
    if (!empty($securityUpdates)) {
        $oldSecurityUpdates = [];
        
        foreach ($securityUpdates as $update) {
            preg_match('/^([^\/ ]+)/', $update, $match);
            $package = $match[1];
            
            // Ersten Zeitpunkt tracken
            if (!isset($tracking[$package])) {
                $tracking[$package] = $now;
            }
            
            // Alter berechnen
            $ageInDays = ($now - $tracking[$package]) / 86400;
            
            if ($ageInDays >= $CONFIG['thresholds']['security_update_age']) {
                $oldSecurityUpdates[] = $update . " (seit " . round($ageInDays, 1) . " Tagen)";
            }
        }
        
        if (!empty($oldSecurityUpdates)) {
            $message = "🚨 **SECURITY-UPDATES ÜBERFÄLLIG**\n\n";
            $message .= "Diese Updates sind seit >2 Tagen verfügbar:\n\n";
            $message .= "```\n" . implode("\n", $oldSecurityUpdates) . "\n```\n\n";
            $message .= "⚠️ *Diese werden normalerweise automatisch installiert. Bitte prüfen!*";
            
            sendTelegram($message, 'CRITICAL');
            echo "🚨 Security-Updates überfällig!\n";
        } else {
            echo "✅ Security-Updates vorhanden, aber <2 Tage alt\n";
        }
    } else {
        echo "✅ Keine Security-Updates\n";
    }

    // 2. Docker-Updates (nur sonntags warnen)
    if (!empty($dockerUpdates)) {
        $dayOfWeek = date('N'); // 1=Montag, 7=Sonntag
        
        if (true) { // Immer melden, nicht nur sonntags
            $message = "🐳 **DOCKER-UPDATES VERFÜGBAR**\n\n";
            $message .= "Folgende Docker-Pakete haben Updates:\n\n";
            $message .= "```\n" . implode("\n", array_slice($dockerUpdates, 0, 5)) . "\n```\n\n";
            $message .= "";
            $message .= "💡 Bitte manuell installieren: sudo apt upgrade docker-ce containerd.io";
            
            sendTelegram($message, 'INFO');
            echo "📅 Docker-Updates (Sonntag-Warnung)\n";
        } else {
            echo "🐳 Docker-Updates vorhanden (Warnung nur sonntags)\n";
        }
    }

    // 3. Andere Updates (automatisch, keine Warnung)
    if (!empty($otherUpdates)) {
        echo "📦 " . count($otherUpdates) . " andere Updates (werden automatisch installiert)\n";
    }

    // Tracking speichern (entferne gelöste Updates)
    $currentPackages = array_map(function($u) {
        preg_match('/^([^\/ ]+)/', $u, $m);
        return $m[1];
    }, array_merge($securityUpdates, $dockerUpdates, $otherUpdates));
    
    $tracking = array_intersect_key($tracking, array_flip($currentPackages));
    file_put_contents($trackingFile, json_encode($tracking));
}

// ===== MAIN MONITORING =====
function runMonitoring($checkType = 'all') {
    echo "═══════════════════════════════════════\n";
    echo "Telegram Server Monitoring\n";
    echo "Check-Type: {$checkType}\n";
    echo "Zeit: " . date('Y-m-d H:i:s') . "\n";
    echo "═══════════════════════════════════════\n\n";

    try {
        switch ($checkType) {
            case 'security':
                checkSecurity();
                break;
            case 'system':
                checkSystemStatus();
                break;
            case 'backup':
                checkBackupStatus();
                break;
            case 'webapp':
                checkWebAppStatus();
                break;
            case 'additional':
                checkAdditional();
                break;
            case 'updates':
                checkSystemUpdates();
                break;
            case 'all':
            default:
                checkSecurity();
                checkSystemStatus();
                checkBackupStatus();
                checkWebAppStatus();
                checkAdditional();
                checkSystemUpdates();
                break;
        }

        echo "\n✅ Monitoring abgeschlossen\n\n";

    } catch (Exception $e) {
        echo "Monitoring-Fehler: " . $e->getMessage() . "\n";
        sendTelegram(
            "❌ **Monitoring-Fehler**\n\n{$e->getMessage()}",
            'CRITICAL'
        );
    }
}

// ===== CLI =====
$checkType = $argv[1] ?? 'all';
runMonitoring($checkType);
?>
