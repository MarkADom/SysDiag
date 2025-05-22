# 🧪 SysDiag v1.2.0 – Linux System Diagnostic

**SysDiag** is a diagnostic tool for Linux systems, developed by **Marco Domingues / SynchLabs**. It provides a modern CLI experience, auto-reporting, issue detection, and export functionality — all without requiring root access.

---

## 🚀 Features

- ✅ **Dependency check** with optional install prompt
- 🌡️ **Temperature readings**: CPU, GPU sensors (`sensors`, `nvidia-smi`)
- 🧠 **Diagnostics**: CPU, RAM, disk, GPU, network, drivers, logs
- 🔥 **Real stress tests** for CPU/RAM (`stress`, `stress-ng`)
- 🧩 **Log analysis** with issue detection for:
  - BIOS misconfigurations (`SGX`, `VMX`)
  - GNOME session/keyring failures
  - Bluetooth and driver problems
- 📋 **Detailed test summary** with icons, duration, and notes
- 📊 **Export formats**:
  - `HTML`: full visual report with collapsible logs
  - `JSON`: includes date, error count, and test list
  - `CSV`: spreadsheet-friendly
  - `Markdown`: GitHub-friendly table
  - `SVG`: graphical summary
- ⚠️ **Issues section shown in terminal summary**
- ❌ **No root required** — fully functional without `sudo`

---

## 📦 Dependencies

| Tool         | Purpose                           |
|--------------|-----------------------------------|
| `sensors`    | CPU/GPU temperature sensors       |
| `stress`     | Stress test for CPU and RAM       |
| `glmark2`    | GPU benchmarking                  |
| `lshw`       | Hardware overview                 |
| `lscpu`      | CPU info                          |
| `lsblk`      | Disk and partition details        |
| `dmidecode`  | BIOS, memory, vendor info         |

### Install manually (Debian/Ubuntu)

```bash
sudo apt update
sudo apt install lm-sensors stress glmark2 lshw lscpu lsblk dmidecode -y
```

### Remove manually (Debian/Ubuntu)
```bash
sudo apt remove --purge lm-sensors stress glmark2 lshw dmidecode -y
```

---

## 📁 Output Location

All reports are saved in:

```bash
~/.local/share/sysdiag/
```

| File Name                          | Description                            |
|------------------------------------|----------------------------------------|
| `sysdiag_report.html`              | HTML report (collapsible logs)         |
| `sysdiag_summary.json`             | JSON with date, error count, summary   |
| `sysdiag_summary.csv`              | Spreadsheet-friendly CSV               |
| `sysdiag_summary.md`               | Markdown-formatted table               |
| `sysdiag_status.svg`               | Color-coded SVG overview               |
| `sysdiag_YYYY-MM-DD_HH-MM-SS.log`  | Full plain text logs                   |

---

## ⚠️ JSON Example (v1.2.0)

```json
{
  "date": "Wed May 21 12:00:00 2025",
  "errors": 2,
  "summary": [
    {
      "test": "GPU Benchmark",
      "status": "SKIP",
      "duration": "0.00",
      "note": "Skipped"
    },
    {
      "test": "Driver Errors",
      "status": "WARN",
      "duration": "0.01",
      "note": "Permission denied"
    }
  ]
}
```

---

## ▶️ How to Run

```bash
chmod +x sysdiag.sh
./sysdiag.sh
```

> ⚠️ If `dmesg` access fails:
> ```bash
> sudo sysctl -w kernel.dmesg_restrict=0
> ```

---

## 👨‍💻 Developed by

🛰️ **Marco Domingues**  
🔧 [SynchLabs](https://github.com/SynchLabs)  
🐙 GitHub: [@MarkADom](https://github.com/MarkADom)

---

## 📜 License

**MIT License** — Free to use, modify, and distribute.