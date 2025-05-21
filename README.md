# 🧪 SysDiag v1.1 – Linux System Diagnostic

**SysDiag** is a diagnostic tool for Linux systems, developed by **SynchLabs**. It offers a modern terminal experience, clear test output, and rich export options, making it ideal for developers, sysadmins, and advanced users who want reliable insight into their system's health — **without requiring sudo**.

---

## 🚀 Features

- ✅ **Auto-check of dependencies** with optional install prompt
- 🧠 Full tests for **CPU, RAM, Disk, GPU, Kernel logs, and Temperature sensors**
- 🔥 Stress testing for CPU and memory with controlled duration
- 🌐 Detection of **driver issues** and **kernel errors**
- 📋 Final test summary including **duration, status and notes**
- 📊 Auto-generated exports:
  - `HTML`: visually structured full report
  - `JSON`: structured data for automation
  - `CSV`: spreadsheet-friendly
  - *(coming soon)* `Markdown` report
- 🧭 Interactive end-of-script menu with report shortcuts
- ❌ **No root required** – works fully without `sudo`

---

## 📦 Dependencies

SysDiag relies on trusted external tools to provide **real, system-level diagnostics**:

| Command      | Purpose                          |
|--------------|----------------------------------|
| `sensors`    | Reads temperature sensors        |
| `stress`     | CPU and RAM stress tests         |
| `glmark2`    | GPU benchmarking                 |
| `lshw`       | Hardware inventory               |
| `lscpu`      | CPU information                  |
| `lsblk`      | Disk and partition listing       |
| `dmidecode`  | BIOS, memory and vendor details  |

### 📥 Manual Installation (Ubuntu/Debian)

```bash
sudo apt update
sudo apt install lm-sensors htop stress glmark2 lshw lscpu lsblk dmidecode -y
```

### 🧹 Manual Removal

```bash
sudo apt remove --purge lm-sensors htop stress glmark2 lshw lscpu lsblk dmidecode -y
```

---

## 📁 Output Files

All reports and logs are saved under:

```bash
~/.local/share/sysdiag/
```

| File Name                        | Description                         |
|----------------------------------|-------------------------------------|
| `sysdiag_report.html`            | Full HTML visual report             |
| `sysdiag_summary.json`           | Structured JSON summary             |
| `sysdiag_summary.csv`            | Spreadsheet-compatible export       |
| `sysdiag_YYYY-MM-DD_HH-MM-SS.log`| Detailed plain text test log        |

---

## 🧪 Example Summary (Terminal)

```text
🧾 SYS DIAG TEST SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
▶ CPU Info           ✅ OK       (0.2s)
▶ Memory Overview    ✅ OK       (0.1s)
▶ Disk Info          ✅ OK       (0.3s)
▶ Temp Sensors       ⚠️ Warning  (0.6s)  CPU 88°C
▶ GPU Benchmark      ⏭️ Skipped  (0.0s)  glmark2 not installed
▶ Kernel Logs        ❌ Fail     (0.4s)  2 errors, 3 warnings
```

---

## 👨‍💻 Developed by

🛰️ Marco Domingues
**SynchLabs** — [SynchLabs](https://github.com/SynchLabs)  

---

## 📜 License

**MIT License** – Free to use, modify and distribute.
=======
- ✅ **Dependency Check & Auto Install**
- 🌡️ **Live Sensor Reading** (CPU/GPU temp via `sensors`, `nvidia-smi`)
- 🔥 **CPU/RAM Stress Testing** (via `stress`)
- 🎮 **GPU Benchmarking** (via `glmark2`)
- 📊 **System Summary** (CPU, Memory, Disk, Uptime, Kernel)
- 📄 **Report Export**
  - HTML: `/tmp/sysdiag_report.html`
  - JSON: `/tmp/sysdiag_report.json`
  - SVG: `/tmp/sysdiag_graph.svg`
  - TXT Log: `/var/log/sysdiag/sysdiag_*.log`
- 🎛️ **Interactive Terminal Menu**
- 🧼 **Optional Clean-up of Installed Dependencies**

---

## 📦 Requirements

SysDiag uses the following tools (installed on first run if missing):

```bash
sudo apt install lshw sensors htop stress glmark2 lscpu lsblk dmidecode
```

---

## 🛠️ Installation & Usage

```bash
git clone https://github.com/MarkADOm/sysdiag.git
cd sysdiag
chmod +x sysdiag.sh
sudo ./sysdiag.sh
```

> ⚠️ The script **prompts before installing any packages**. It does **not** run as root without your permission.
> ⚠️ Must be run with `sudo` for full hardware access.

---

## 📁 Output Samples

| Format       | Path                                               |
| ------------ | -------------------------------------------------- |
| HTML Report  | `/tmp/sysdiag_report.html`                         |
| JSON Summary | `/tmp/sysdiag_report.json`                         |
| SVG Overview | `/tmp/sysdiag_graph.svg`                           |
| Full Log     | `/var/log/sysdiag/sysdiag_YYYY-MM-DD_HH:MM:SS.log` |

---

## 📸 Screenshot


---![Screenshot from 2025-05-21 22-47-06](https://github.com/user-attachments/assets/49cd6cfd-6875-4abc-8928-352b6efded2d)


## 📄 License

MIT License — free to use, modify and distribute.

---

## 🧠 Developed by

🛰️ **Marco Domingues**  
GitHub: [@MarkADom](https://github.com/MarkADom)
