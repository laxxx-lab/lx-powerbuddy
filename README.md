# ⚡ lx PowerBuddy (`LXPowerBuddy`)

> **Dein interaktiver Lern-Coach und intelligenter Alltags-Assistent für die PowerShell.**

`lx PowerBuddy` ist ein modulares PowerShell-Modul, das entwickelt wurde, um den Einstieg in die PowerShell so einfach, verständlich und motivierend wie möglich zu machen. Es verbindet interaktive Quests im Terminal mit praktischen Assistenz-Tools wie Befehls-Erklärern, Fehler-Diagnose und einem Wörterbuch für Linux/CMD-Umsteiger.

---

## ✨ Features im Überblick

### 1. 🎮 Interaktive Quests & Lektionen (`Start-LXLesson` / `lx-quest`)
- **6 strukturierte Level**:
  - **Level 1**: Grundlagen, Navigation (`Get-Location`, `Get-ChildItem`) & Hilfe (`Get-Help`, `Get-Command`)
  - **Level 2**: Das Herzstück – Die Objekt-Pipeline (`|`, `Get-Member`, `Select-Object`)
  - **Level 3**: Filtern & Sortieren wie ein Profi (`Where-Object`, `-eq`, `-gt`, `Sort-Object`)
  - **Level 4**: Dateisystem & Textdateien (`New-Item`, `Set-Content`, `Get-Content`, `Test-Path`)
  - **Level 5**: Fortgeschrittene Objekt-Manipulation (`-ExpandProperty`, `Measure-Object`, `Group-Object`)
  - **Level 6**: Skripting, Schleifen & Eigene Funktionen (`$Variablen`, `ForEach-Object`, `function`)
- **Echtes Live-Feedback**: Deine Eingaben werden direkt geprüft und im Terminal ausgeführt.
- **XP & Ränge**: Sammle Erfahrungspunkte und steige vom *PowerShell Novizen* zum *PowerShell Großmeister* auf!

### 2. 🔍 Befehls-Dolmetscher (`explain <befehl>` / `Explain-LXCommand`)
- Zerlegt jeden PowerShell-Einzeiler und jede Pipeline mittels AST (Abstract Syntax Tree).
- Erklärt jede Stufe der Pipeline, alle Parameter und Schalter im Klartext auf Deutsch.
- Beispiel:
  ```powershell
  explain "Get-Process | Where-Object CPU -gt 10 | Select-Object -First 5 Name, CPU"
  ```

### 3. 💡 "Wie mache ich..." Assistent (`howdo <suche>` / `Find-LXHowTo`)
- Schnelle Suche nach Lösungen für typische Aufgaben (z.B. Ports prüfen, JSON-APIs abfragen, große Dateien finden, Prozesse killen).
- Liefert fertige Einzeiler und Pro-Tipps.
- Beispiel:
  ```powershell
  howdo "port testen"
  howdo "dateien rekursiv"
  howdo -ListCategories
  ```

### 4. 🩺 Fehler-Doktor (`why-error` / `was-los` / `Trace-LXError`)
- Versteht die oft kryptischen roten PowerShell-Fehlermeldungen.
- Analysiert automatisch den letzten Fehler (`$Error[0]`) und schlägt verständliche Lösungen vor.
- Beispiel:
  ```powershell
  why-error
  ```

### 5. 📖 Linux / CMD ➔ PowerShell Wörterbuch (`ps-dict` / `Get-LXCheatSheet`)
- Suchst du das PowerShell-Pendant zu `grep`, `ls`, `cat`, `rm`, `curl` oder `ps`?
- Zeigt das richtige Cmdlet, Aliase, Beispiele und erklärt den zentralen Unterschied (Objekte statt Text).
- Beispiel:
  ```powershell
  ps-dict "grep"
  ps-dict -All
  ```

### 6. 📊 Dashboard (`lx-buddy` / `Show-LXDashboard`)
- Zeigt deinen aktuellen XP-Stand, deinen Rang, deinen Fortschrittsbalken und den Tipp des Tages.

---

## 🚀 Schnellstart & Installation

### Option 1: Für die aktuelle Sitzung importieren
Klone das Repository oder wechsle in den Ordner und führe aus:
```powershell
Import-Module .\LXPowerBuddy.psd1 -Force
```

### Option 2: Dauerhaft im PowerShell-Profil laden
Damit `lx PowerBuddy` in jedem neuen Terminal sofort verfügbar ist:
```powershell
# Ergänze dein PowerShell-Profil:
Add-Content $PROFILE "`nImport-Module 'G:\Offen\lx ps\LXPowerBuddy.psd1'"
```

---

## 🛠️ Befehls-Kurzübersicht (Cheat Sheet)

| Befehl / Alias | Funktion |
| :--- | :--- |
| `lx-buddy` | Öffnet das PowerBuddy Dashboard & Status |
| `Start-LXLesson` / `lx-quest` | Startet den interaktiven Lektionsmodus |
| `Start-LXLesson -Level 1` | Startet direkt ein bestimmtes Level |
| `explain "<Befehl>"` | Analysiert und erklärt einen Befehl |
| `howdo "<Suchbegriff>"` | Sucht nach PowerShell-Rezepten & Beispielen |
| `why-error` / `was-los` | Erklärt den letzten aufgetretenen Fehler |
| `ps-dict <Befehl>` | Schlägt Linux-/CMD-Befehle im Wörterbuch nach |

---

## 🧪 Tests ausführen

Das Modul enthält automatisierte Validierungstests für alle Funktionen und Datenbanken:
```powershell
.\Tests\LXPowerBuddy.Tests.ps1
```

---

## 📄 Lizenz

Dieses Projekt steht unter der [MIT Lizenz](LICENSE). Erstellt von [laxxx-lab](https://github.com/laxxx-lab).
