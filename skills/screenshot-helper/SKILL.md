# Screenshot Helper Skill

Findet und verarbeitet Screenshots automatisch für Bug-Reports und Feature-Dokumentation.

## Wann wird dieser Skill aktiviert?

Der Skill wird NUR aktiviert wenn explizit erwähnt:
- "Screenshot", "Bildschirmfoto", "siehe Bild", "siehe Screenshot"
- "Mockup anbei", "Bild", "[Screenshot]"
- "UI-Problem", "Design-Issue", "Layout-Bug" (visuell)
- "Schau dir den Screenshot an"

**NICHT aktiviert bei:**
- Reinen Text-Bugs ohne visuelle Komponente
- Features ohne Mockup/Screenshot
- Logik-Fehler, API-Probleme, Backend-Bugs

## Was macht der Skill?

### 1. **Screenshot-Suche in gängigen Ordnern:**

Durchsucht automatisch (nach Änderungsdatum sortiert):
- `C:\Users\Ruben\Downloads\` (letzte 10 Dateien)
- `C:\Users\Ruben\Desktop\` (letzte 10 Dateien)
- `C:\Users\Ruben\Pictures\Screenshots\` (Windows Screenshot-Ordner)
- `C:\Users\Ruben\.claude\soziotherapie_demo\Screenshots\` (Projekt-Screenshots)
- Clipboard (falls verfügbar via PowerShell)

**Datei-Typen:** `.png`, `.jpg`, `.jpeg`, `.gif`, `.webp`

### 2. **Screenshot analysieren:**

- Welche Seite ist zu sehen? (anhand UI-Elementen)
- Welche Datei betroffen? (`patient.php`, `index.php`, etc.)
- Was ist das Problem? (visuell erkennbar)

### 3. **Screenshot ins Projekt kopieren:**

```
Screenshots/
├── bugs/
│   └── issue-6-zurueck-button-2025-10-19.png
└── features/
    └── dark-mode-mockup-2025-10-19.png
```

### 4. **GitHub Issue mit Screenshot:**

- Screenshot hochladen als GitHub Issue Attachment
- Oder: Markdown-Link zum Screenshot im Repo

## Workflow-Beispiele:

### **Beispiel 1: Bug mit Screenshot**

```
User: "Bug: Zurück-Button falsch, siehe Screenshot"

Skill:
1. Sucht neueste Screenshots (Downloads/Desktop)
2. Zeigt: "Gefunden: screenshot-2025-10-19-143022.png (vor 2 Min)"
3. Fragt: "Ist das der richtige Screenshot?"
4. User: "ja"
5. Analysiert Screenshot → erkennt "Patienten-Übersicht"
6. Identifiziert: "Das ist index.php, View: patienten-liste"
7. Kopiert nach: Screenshots/bugs/issue-6-zurueck-button.png
8. Erstellt Issue mit Screenshot-Link
9. Aktualisiert Markmap/BACKLOG
```

### **Beispiel 2: Feature-Mockup**

```
User: "Feature: Dark Mode, siehe Mockup-Screenshot"

Skill:
1. Findet Screenshot
2. Kopiert nach: Screenshots/features/dark-mode-mockup.png
3. Issue erstellt mit Screenshot im Body
4. Markmap: "Dark Mode 🔄 [Screenshot: features/dark-mode-mockup.png] (#7)"
```

### **Beispiel 3: Automatische Suche**

```
User: "Bug in der Patientenliste"

Skill:
1. Fragt: "Gibt es einen Screenshot dazu? Ich schaue mal in Downloads..."
2. Zeigt letzten Screenshot
3. User bestätigt oder sagt "nein"
```

## Technische Implementierung:

### **Screenshot-Finder (PowerShell/Bash):**

```bash
# Neueste Screenshots finden
find /mnt/c/Users/Ruben/Downloads -name "*.png" -o -name "*.jpg" -mtime -1 | head -5
find /mnt/c/Users/Ruben/Desktop -name "*.png" -o -name "*.jpg" -mtime -1 | head -5
```

### **Screenshot-Analyse:**

1. Read tool → Screenshot laden
2. Visuelle Analyse:
   - Header erkennbar? → Welche Seite
   - Buttons/URLs sichtbar? → Datei identifizieren
   - Problem visuell klar? → Beschreibung generieren

### **GitHub Integration:**

```bash
# Screenshot zu Issue hinzufügen
gh issue create --title "Bug: ..." --body "![Screenshot](Screenshots/bugs/issue-X.png)"

# Oder: Direkt hochladen (GitHub API)
gh issue create --title "Bug: ..." --body "Siehe Anhang" --attach screenshot.png
```

## Intelligente Features:

### **Auto-Detect letzte Änderungen:**

```
"Ich sehe, vor 3 Minuten wurde ein Screenshot erstellt:
 screenshot-2025-10-19-143022.png

Soll ich den für diesen Bug verwenden?"
```

### **Clipboard-Integration (Windows):**

```powershell
# Screenshot aus Clipboard direkt speichern
Add-Type -AssemblyName System.Windows.Forms
if ([System.Windows.Forms.Clipboard]::ContainsImage()) {
    $img = [System.Windows.Forms.Clipboard]::GetImage()
    $img.Save("temp-screenshot.png")
}
```

### **OCR für Text-Erkennung (optional):**

Falls Screenshot Text enthält (z.B. Fehlermeldung):
- Tesseract OCR nutzen
- Text aus Screenshot extrahieren
- In Issue-Beschreibung einfügen

## Konfiguration:

### **Standard-Screenshot-Ordner:**

```json
// .claude/screenshot-config.json
{
  "search_paths": [
    "C:\\Users\\Ruben\\Downloads",
    "C:\\Users\\Ruben\\Desktop",
    "C:\\Users\\Ruben\\Pictures\\Screenshots"
  ],
  "project_screenshots": "Screenshots/",
  "auto_copy": true,
  "auto_detect_time_minutes": 5
}
```

## Vorteile:

✅ **Keine Pfad-Angabe nötig** - Findet Screenshots automatisch
✅ **Visueller Kontext** - Analysiert, was auf Screenshot zu sehen ist
✅ **Projekt-Archivierung** - Screenshots im Repo gespeichert
✅ **GitHub Integration** - Direkt im Issue sichtbar
✅ **Zeit-gespart** - Kein manuelles Kopieren/Einfügen

## Einschränkungen:

- Funktioniert nur mit lokalen Screenshots (nicht in Cloud)
- Windows Clipboard benötigt PowerShell
- Screenshot-Analyse nicht 100% akkurat (menschliche Bestätigung empfohlen)

## Erweiterbar mit:

- OneNote-Screenshot-Export (via OneNote API/MCP)
- Automatisches Snipping Tool (Screenshot direkt erstellen)
- Video-Recording für komplexe Bugs

---

**🤖 Skill für Screenshot-Management**
**Version:** 1.0
**Erstellt:** 2025-10-19
