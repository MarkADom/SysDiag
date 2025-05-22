# 🧪 SysDiag v1.2.0 – Linux System Diagnostic

**SysDiag** is a diagnostic tool for Linux systems, developed by **Marco Domingues / SynchLabs**. It offers a rich and modern terminal experience, automatic reporting, and no need for root — making it ideal for developers, sysadmins, and power users who want **clear, actionable insights** into system health.

---

## 🚀 Features

- ✅ **Dependency check** with optional auto-install
- 🌡️ **Sensor readings**: CPU, GPU temperatures via `sensors`, `nvidia-smi`
- 🧠 **Comprehensive diagnostics**: hardware, CPU, RAM, disk, network, GPU, drivers
- 🔥 **Real stress tests**: CPU and RAM (`stress`, `stress-ng`)
- 🧩 **Log analysis**: detects BIOS issues, GNOME errors, Bluetooth and kernel driver problems
- 🧾 **Detailed summary per test**: status, duration and notes
- 📊 **Auto-exported reports**:
  - `HTML`: visually rich with collapsible logs and issue summary
  - `JSON`: structured data for automation
  - `CSV`: spreadsheet compatible
  - `Markdown`: GitHub-ready test summary
  - `SVG`: graphical status overview
- 🧭 End-of-run **terminal summary** with icons and timings
- ❌ **No root required** for diagnostics (except optional sensor-level adjustments)

---

## 📦 Dependencies

SysDiag relies on several reliable tools for real diagnostics:

| Command      | Purpose                          |
|--------------|----------------------------------|
| `sensors`    | Temperature sensors              |
| `stress`     | CPU & RAM stress testing         |
| `glmark2`    | GPU benchmarking                 |
| `lshw`       | Hardware inventory               |
| `lscpu`      | CPU information                  |
| `lsblk`      | Disk and partition info          |
| `dmidecode`  | BIOS, memory, manufacturer info  |

### 📥 Install Manually (Debian/Ubuntu)

```bash
sudo apt update
sudo apt install lm-sensors stress glmark2 lshw lscpu lsblk dmidecode -y
```

---

## 📁 Output Files

Default output location:

```bash
~/.local/share/sysdiag/
```

| File Name                          | Description                            |
|------------------------------------|----------------------------------------|
| `sysdiag_report.html`              | Full HTML report with collapsible logs |
| `sysdiag_summary.json`             | Test results in JSON                   |
| `sysdiag_summary.csv`              | Tabular export for Excel/Sheets        |
| `sysdiag_summary.md`               | Markdown-formatted test table          |
| `sysdiag_status.svg`               | SVG visual summary                     |
| `sysdiag_YYYY-MM-DD_HH-MM-SS.log`  | Full raw logs per test                 |

---

## 🧠 Issue Detection (v1.2.0+)

SysDiag intelligently flags potential issues like:

- ⚠️ BIOS misconfiguration (`SGX` or `VMX` disabled)
- ⚠️ GNOME keyring and session problems
- ⚠️ Bluetooth driver/service failures
- ⚠️ Kernel `dmesg` restrictions or warnings

---

## 🧪 Example Output

```text
🧾 SYS DIAG TEST SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
▶ CPU Info           ✅ OK       (0.2s)
▶ RAM Info           ✅ OK       (0.1s)
▶ Disk Info          ✅ OK       (0.3s)
▶ Temp Sensors       ⚠️ Warning  (0.6s)  CPU 88°C
▶ GPU Benchmark      ⏭️ Skipped  (0.0s)  glmark2 not installed
▶ System Logs        ⚠️ Warning  (0.4s)  3 critical messages
▶ Driver Errors      ⚠️ Warning  (0.1s)  Permission denied
```

---

## ▶️ How to Run

```bash
chmod +x sysdiag.sh
./sysdiag.sh
```

> ⚠️ SysDiag runs fully without root. Only `dmesg` access may require permission tuning:
> ```bash
> sudo sysctl -w kernel.dmesg_restrict=0
> ```

---

## 📸 Screenshot

![Report Preview](docs/screenshot-report.png)

---

## 👨‍💻 Developed by

🛰️ **Marco Domingues**  
🔧 [SynchLabs](https://github.com/SynchLabs)  
🐙 GitHub: [@MarkADom](https://github.com/MarkADom)

---

## 📜 License

**MIT License** — Free to use, modify, and distribute.