# claude-system

Claude Code System-Konfiguration: Agenten, Workflow-Regeln, Docs.

## Setup auf neuem PC / Laptop

### 1. Repo klonen
```bash
git clone https://github.com/RangRang416/claude-system.git /root/.claude
```

### 2. Secrets anlegen (manuell, nicht im Repo)
```bash
mkdir -p /root/.claude/secrets
echo "DEIN_N8N_API_KEY" > /root/.claude/secrets/n8n-api-key
```

### 3. SSH-Zugang zu Hetzner einrichten
```bash
# SSH-Key kopieren (von altem PC oder 1Password)
mkdir -p ~/.ssh
# bernd_ed25519 und bernd_ed25519.pub nach ~/.ssh/ kopieren

# SSH-Config anlegen
cat >> ~/.ssh/config << 'EOF'
Host hetzner
    HostName 46.224.220.236
    Port 2222
    User bernd
    IdentityFile ~/.ssh/bernd_ed25519
EOF

chmod 600 ~/.ssh/config ~/.ssh/bernd_ed25519
```

### 4. GitHub CLI einrichten
```bash
gh auth login
```

### 5. Fertig
Claude Code starten → alles da.

---

## Struktur

```
/root/.claude/
├── CLAUDE.md           ← Globale Workflow-Regeln (Agenten-Matrix, Session-Start, etc.)
├── agents/             ← Native Agent-Definitionen (Claude Code lädt diese automatisch)
│   ├── scout.md
│   ├── planner.md
│   ├── implementer.md
│   ├── tester.md
│   ├── reviewer.md
│   ├── documenter.md
│   └── deployer.md
├── docs/               ← Workflow-Dokumentation
│   ├── eskalation.md
│   ├── projekt-start.md
│   ├── projektabschluss.md
│   ├── rollback.md
│   └── templates/      ← Agent-Templates (Referenz)
├── memory/             ← Auto-Memory (Session-übergreifend)
├── scripts/            ← Utility Scripts (Server-Monitoring, n8n-Tunnel, etc.)
└── secrets/            ← Credentials (gitignored, manuell anlegen)
```

## Was NICHT im Repo ist

| Was | Wo | Warum |
|-----|----|-------|
| `secrets/` | Manuell anlegen | Credentials nie in Git |
| SSH-Keys | `~/.ssh/` | Privat |
| Projekt-Code | Eigene Repos | Getrennte Repos pro Projekt |

## Aktive Projekte

| Projekt | Repo | Status |
|---------|------|--------|
| Vorgangs-Manager | [vorgangs-manager](https://github.com/RangRang416/vorgangs-manager) | ✅ LIVE |
| Soziotherapie App | [soziotherapie_demo](https://github.com/RangRang416/soziotherapie_demo) | ✅ LIVE |
| N8N Email-Analyzer | [n8n-email-analyzer](https://github.com/RangRang416/n8n-email-analyzer) | 🔄 In Entwicklung |

## Server

- **Hetzner:** `ssh hetzner` → 46.224.220.236:2222, User: bernd
