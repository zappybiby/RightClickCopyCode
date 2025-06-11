# 📋 Copy Code – Explorer Context-Menu Tool

“Copy Code” adds a right-click option to Windows Explorer that places any file’s  
contents on your clipboard wrapped in a Markdown-ready fenced code block—perfect  
for chats, issues, docs, or pull requests with syntax highlighting.

---

## 🔍 How It Works

1. After installation, you can right click a file, e.g. `hello.py` and select "Copy Code". This will copy it in this format:

    ~~~text
    hello.py (C:\Projects\hello.py)
    ```python
    print("Hello, world!")
    ```
    ~~~

2. **`Install.ps1`** compiles that script to a **silent `CopyCode.exe`** and registers
   the context-menu entry.

---

## 🤔 Why Compile with PS2EXE?

If Explorer launches a **raw PowerShell script** from a context menu, Windows
always flashes a console window—even with `-WindowStyle Hidden`.  
Compiling the script with **PS2EXE** turns it into a tiny Win32 executable that
runs in the *“windows”* subsystem (no console), so **Copy Code** pops up nothing
at all—just instant clipboard magic.

---

## 🛡️ Recommended Install Location

**Inside `C:\Program Files` (or any sub-folder)**

That protected path prevents non-admin users or malware from swapping out the
executable that Explorer will run.

---

# Quick Start

1. **Open Windows Terminal / Powershell as Administrator**  

2. **Clone the repo into the protected path**  
   ```powershell
   git clone https://github.com/zappybiby/RightClickCopyCode.git "C:\Program Files\CopyCode"
   ```

3. **Change into the install directory**  
   ```powershell
   cd "C:\Program Files\CopyCode"
   ```

4. **Bypass the execution policy (if needed)**  
   *This lets you run the unsigned installer script for this session only:*  
   ```powershell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   ```

5. **Run the installer**  
   ```powershell
   .\Install.ps1 -Install
   ```
   - Compiles `CopyCode.ps1` → `CopyCode.exe`  
   - Registers the **Copy code** context-menu entry  
   - Prompts to install **PS2EXE** if it’s not already available

## ✂️ Using “Copy Code”

1. Right-click any file in Explorer.  
2. Choose **Copy code**.  
3. Paste anywhere—your clipboard now holds a labelled, fenced block.

---

## 🧹 Uninstalling

Use the built-in switch:

~~~powershell
.\Install.ps1 -Uninstall
~~~

---
