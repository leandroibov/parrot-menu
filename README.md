
## 📄 README.md


# 🦜 Parrot Tools List Guide — Navigator



**Made especially for use on Qubes OS with a Parrot OS template based on the default Debian template!**
Since Qubes uses XFCE, navigating and browsing categories through the GUI mode isn't possible — but this command-line navigator and categorizer allows great usability even on Qubes OS!

An interactive **Bash** navigator that lists and organizes all the tools from
**Parrot Security OS** directly in your command line. It replicates the Parrot
menu tree inside the terminal, letting you browse by **categories**,
**subcategories**, and view the **exact execution command** for every tool.

---

## ✨ Features

- 🗂️ Hierarchical navigation: **Categories → Subcategories → Tools**
- 🛠️ Automatically extracts commands (`Exec=`) from the system's `.desktop` files
- 🏷️ Maps each tool to its correct Parrot menu category
- 🔍 Numeric prefix matching (e.g., `02-` shows only subcategories of category 02)
- 💾 Local plain-text database — no external dependencies
- ♻️ Automatically generates the database on first run

---

## 📋 Requirements

- Parrot Security OS (or any system with `parrot-*.desktop` applications)
- Bash 4+
- Read permission on `/usr/share/applications/`

---

## 🚀 How to use


### 1. Make the script executable

```bash
chmod +x parrot-menu.sh
```

### 2. Run it

```bash
./parrot-menu.sh
```

> On first run, the script automatically creates the database at
> `~/parrot-tools--list-commands.txt` by scanning the
> `/usr/share/applications/parrot-*.desktop` files on your system.

---

## 🕹️ Navigation

| Key | Action |
|-----|--------|
| `[1-9]` | Select a category or subcategory |
| `[b]` | Go back to the previous menu |
| `[q]` | Exit the navigator |

**Flow:**

```
MAIN MENU (e.g.: 05-password-attacks)
   └──> SUBCATEGORIES (e.g.: 05-01-online-attacks)
           └──> TOOL LIST
                   ├── App:  filename.desktop
                   ├── Cmd:  command to execute
                   └── Cat:  category
```

To run a listed tool, simply copy the **Cmd** field and paste it into another
terminal.

---

## 🔄 Updating the database

Installed or removed tools? Regenerate the database:

```bash
rm ~/parrot-tools--list-commands.txt
./parrot-tools-guide.sh
```

---

## 📁 Database structure

The generated file contains three sections:

1. **Main Categories** — primary Parrot menu categories
2. **Subcategories** — subcategories derived from numeric prefixes
3. **Tool list** — blocks with `file`, `command`, and `category`

---
