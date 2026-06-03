# CockpitRandomizer.pyw
# Place this file next to the CockpitRandomizer\ folder (the one containing core.lua, f4e.lua, etc.)
# Double-click to run. No console window will appear (.pyw extension).

import tkinter as tk
from tkinter import messagebox, filedialog
import os
import shutil
import json

# ── Constants ────────────────────────────────────────────────────────────────

APP_TITLE        = "CockpitRandomizer"
APP_VERSION_FALLBACK = "1.0"

# Aircraft list: (display name, lua file key)
AIRCRAFT = [
    ("F-4E Phantom II", "f4e"),
    ("F/A-18C Hornet",  "fa18c"),
    ("F-14B Tomcat",    "f14b"),
    ("F-16C Viper",     "f16c"),
    ("F-5E Tiger II",   "f5e"),
]

# Known DCS Saved Games folder names to auto-detect
DCS_FOLDER_NAMES = ["DCS", "DCS.openbeta"]

# Paths relative to the exe / .pyw file
# sys.executable gives the correct path when frozen by PyInstaller
import sys
if getattr(sys, "frozen", False):
    THIS_DIR = os.path.dirname(sys.executable)
else:
    THIS_DIR = os.path.dirname(os.path.abspath(__file__))
LUA_SRC_DIR  = os.path.join(THIS_DIR, "CockpitRandomizer")  # folder next to exe

# ── Version helpers ─────────────────────────────────────────────────────────

def read_version(path):
    """Read version string from a version.txt file."""
    try:
        with open(path, "r", encoding="utf-8") as f:
            return f.read().strip()
    except Exception:
        return None

def exe_version():
    """Version bundled with this exe (next to the exe)."""
    v = read_version(os.path.join(THIS_DIR, "version.txt"))
    return v if v else APP_VERSION_FALLBACK

def installed_version(scripts_dir):
    """Version currently installed in Scripts/CockpitRandomizer/."""
    return read_version(os.path.join(scripts_dir, "CockpitRandomizer", "version.txt"))

APP_VERSION = exe_version()

# ── Colour / font palette ────────────────────────────────────────────────────

BG      = "#1a1a2e"
PANEL   = "#16213e"
ACCENT  = "#0f3460"
HL      = "#e94560"
FG      = "#eaeaea"
MUTED   = "#8892a4"
GREEN   = "#4caf50"

F_TITLE = ("Consolas", 14, "bold")
F_HEAD  = ("Consolas", 11, "bold")
F_BODY  = ("Consolas", 10)
F_SMALL = ("Consolas", 8)

BTN_BASE = dict(bd=0, relief="flat", cursor="hand2", pady=6, padx=8)

# ── Export.lua template ──────────────────────────────────────────────────────

CR_BLOCK_START = "-- [CockpitRandomizer:begin]"
CR_BLOCK_END   = "-- [CockpitRandomizer:end]"

def build_cr_block(selected_keys):
    dofiles = "\n".join(
        f'    dofile(base .. "{key}.lua")'
        for _, key in AIRCRAFT if key in selected_keys
    )
    return f"""{CR_BLOCK_START}
local cr_status, cr_err = pcall(function()
    local lfs = require('lfs')
    local base = lfs.writedir() .. "Scripts\\\\CockpitRandomizer\\\\"
    dofile(base .. "core.lua")
{dofiles}
end)
if not cr_status then
    log.write("COCKPIT_RANDOMIZER", log.ERROR, "Load failed: " .. tostring(cr_err))
end
{CR_BLOCK_END}"""

def build_fresh_export_lua(selected_keys):
    return build_cr_block(selected_keys) + "\n"

def remove_cr_block(content):
    """Remove the CR block from an existing Export.lua content string."""
    lines   = content.splitlines(keepends=True)
    out     = []
    inside  = False
    for line in lines:
        if CR_BLOCK_START in line:
            inside = True
        if not inside:
            out.append(line)
        if CR_BLOCK_END in line:
            inside = False
    return "".join(out).strip() + "\n"

def has_cr_block(content):
    return CR_BLOCK_START in content

# ── Installation helpers ──────────────────────────────────────────────────────

def find_dcs_scripts_dirs():
    """Return list of existing candidate Scripts directories."""
    saved_games = os.path.join(os.environ.get("USERPROFILE", os.path.expanduser("~")), "Saved Games")
    found = []
    for name in DCS_FOLDER_NAMES:
        scripts = os.path.join(saved_games, name, "Scripts")
        dcs_dir = os.path.join(saved_games, name)
        if os.path.isdir(dcs_dir):
            found.append(scripts)  # may not exist yet — that's fine
    return found

def lua_files_in_src():
    """Return list of .lua filenames available next to the exe."""
    if not os.path.isdir(LUA_SRC_DIR):
        return []
    return [f for f in os.listdir(LUA_SRC_DIR) if f.endswith(".lua")]

def copy_lua_files(dst_scripts):
    """Copy all Lua files and version.txt from source folder to destination Scripts/CockpitRandomizer/."""
    dst = os.path.join(dst_scripts, "CockpitRandomizer")
    os.makedirs(dst, exist_ok=True)
    for fname in lua_files_in_src():
        shutil.copy2(os.path.join(LUA_SRC_DIR, fname), os.path.join(dst, fname))
    # Also copy version.txt if present
    src_ver = os.path.join(THIS_DIR, "version.txt")
    if os.path.isfile(src_ver):
        shutil.copy2(src_ver, os.path.join(dst, "version.txt"))

def is_installed(scripts_dir):
    return os.path.isfile(os.path.join(scripts_dir, "CockpitRandomizer", "core.lua"))

def config_path(scripts_dir):
    return os.path.join(scripts_dir, "CockpitRandomizer", "gui_config.json")

def backup_path(scripts_dir):
    return os.path.join(scripts_dir, "Export.lua.stock_backup")

def export_lua_path(scripts_dir):
    return os.path.join(scripts_dir, "Export.lua")

def load_config(scripts_dir):
    p = config_path(scripts_dir)
    if os.path.isfile(p):
        try:
            with open(p, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            pass
    return {"selected": [key for _, key in AIRCRAFT]}

def save_config(scripts_dir, selected_keys):
    with open(config_path(scripts_dir), "w", encoding="utf-8") as f:
        json.dump({"selected": list(selected_keys)}, f, indent=2)

# ── Shared widget helpers ─────────────────────────────────────────────────────

def make_button(parent, text, command, primary=True, width=14):
    bg_col = HL if primary else ACCENT
    ab_col = "#c73652" if primary else "#1a4a80"
    return tk.Button(
        parent, text=text, command=command,
        font=F_HEAD, fg="#ffffff", bg=bg_col,
        activebackground=ab_col, activeforeground="#ffffff",
        width=width, **BTN_BASE
    )

def clear_frame(frame):
    for w in frame.winfo_children():
        w.destroy()

# ── Main application ──────────────────────────────────────────────────────────

class App(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title(APP_TITLE)
        self.resizable(False, False)
        self.configure(bg=BG)

        self.scripts_dir = None   # resolved after detection / selection

        # Header (always visible)
        tk.Label(self, text="COCKPIT RANDOMIZER", font=F_TITLE, fg=HL, bg=BG).pack(pady=(20, 2))
        tk.Label(self, text=f"v{APP_VERSION}", font=F_SMALL, fg=MUTED, bg=BG).pack()

        # Content area — swapped between screens
        self.content = tk.Frame(self, bg=BG)
        self.content.pack(fill="both", expand=True, padx=20, pady=10)

        # Status bar
        self.status_var = tk.StringVar(value="")
        self.status_lbl = tk.Label(self, textvariable=self.status_var,
                                   font=F_SMALL, fg=MUTED, bg=BG, wraplength=340, justify="center")
        self.status_lbl.pack(pady=(0, 14))

        self._detect_and_route()

    # ── Status bar ────────────────────────────────────────────────────────────

    def set_status(self, msg, color=MUTED):
        self.status_var.set(msg)
        self.status_lbl.configure(fg=color)

    # ── Routing ───────────────────────────────────────────────────────────────

    def _detect_and_route(self):
        """Detect DCS installation(s) and route to the appropriate screen."""
        if not os.path.isdir(LUA_SRC_DIR) or not lua_files_in_src():
            self._show_no_source_screen()
            return

        candidates = find_dcs_scripts_dirs()

        if len(candidates) == 1:
            self.scripts_dir = candidates[0]
            self._route()
        elif len(candidates) > 1:
            self._show_pick_install_screen(candidates)
        else:
            # No known DCS folder found — ask user
            self._show_browse_screen()

    def _route(self):
        """Given self.scripts_dir is set, decide which screen to show."""
        if is_installed(self.scripts_dir):
            self._show_main_screen()
        else:
            self._show_install_screen()

    # ── Screen: no source Lua files ───────────────────────────────────────────

    def _show_no_source_screen(self):
        clear_frame(self.content)
        tk.Label(self.content,
                 text="CockpitRandomizer folder not found.\n\n"
                      "Make sure CockpitRandomizer.exe is placed\n"
                      "next to the CockpitRandomizer\\ folder\n"
                      "containing the Lua scripts.",
                 font=F_BODY, fg=FG, bg=BG, justify="center").pack(pady=20)
        self.set_status("Lua source folder missing.", color=HL)

    # ── Screen: multiple DCS installs ─────────────────────────────────────────

    def _show_pick_install_screen(self, candidates):
        clear_frame(self.content)
        tk.Label(self.content, text="Multiple DCS installations found.\nSelect one:",
                 font=F_BODY, fg=FG, bg=BG, justify="center").pack(pady=(10, 12))

        for path in candidates:
            display = path.replace(os.environ.get("USERPROFILE", ""), "%USERPROFILE%")
            make_button(self.content, display,
                        command=lambda p=path: self._select_and_route(p),
                        primary=False, width=40).pack(pady=4, fill="x")

        tk.Label(self.content, text="— or —", font=F_SMALL, fg=MUTED, bg=BG).pack(pady=6)
        make_button(self.content, "Browse manually...",
                    command=self._browse_scripts_dir,
                    primary=False, width=40).pack(pady=4, fill="x")

    # ── Screen: browse for DCS Scripts folder ────────────────────────────────

    def _show_browse_screen(self):
        clear_frame(self.content)
        tk.Label(self.content,
                 text="DCS installation not found automatically.\n\n"
                      "Please locate your DCS Saved Games folder\n"
                      "(e.g. Saved Games\\DCS\\Scripts).",
                 font=F_BODY, fg=FG, bg=BG, justify="center").pack(pady=(10, 16))
        make_button(self.content, "Browse...", command=self._browse_scripts_dir).pack()

    def _browse_scripts_dir(self):
        chosen = filedialog.askdirectory(title="Select your DCS Scripts folder (Saved Games\\DCS\\Scripts)")
        if chosen:
            self._select_and_route(chosen)

    def _select_and_route(self, path):
        self.scripts_dir = path
        self._route()

    # ── Screen: install ───────────────────────────────────────────────────────

    def _show_install_screen(self):
        clear_frame(self.content)
        scripts_display = self.scripts_dir.replace(
            os.environ.get("USERPROFILE", ""), "%USERPROFILE%")

        tk.Label(self.content, text="Installation", font=F_HEAD, fg=FG, bg=BG).pack(pady=(6, 10))

        info = (f"CockpitRandomizer will be installed to:\n\n"
                f"{scripts_display}\\CockpitRandomizer\\")
        tk.Label(self.content, text=info, font=F_BODY, fg=FG, bg=BG,
                 justify="center", wraplength=340).pack(pady=(0, 16))

        make_button(self.content, "Install", command=self._do_install).pack(pady=4, fill="x")
        make_button(self.content, "Change location...",
                    command=self._browse_scripts_dir, primary=False).pack(pady=4, fill="x")

    def _do_install(self):
        scripts = self.scripts_dir
        export  = export_lua_path(scripts)

        try:
            # Check for existing Export.lua — if it already has our block, treat as update
            if os.path.isfile(export):
                with open(export, "r", encoding="utf-8") as f:
                    content = f.read()
                if has_cr_block(content):
                    self._do_update()
                    return

            # Create directories and copy Lua files only
            # Export.lua is NOT touched here — Apply will handle it
            os.makedirs(scripts, exist_ok=True)
            copy_lua_files(scripts)

            all_keys = {key for _, key in AIRCRAFT}
            save_config(scripts, all_keys)
            self.set_status("Installation complete. Press Apply to activate.", color=GREEN)
            self._show_main_screen()

        except Exception as e:
            messagebox.showerror("Installation failed", str(e))
            self.set_status(f"Error: {e}", color=HL)

    # ── Screen: update ────────────────────────────────────────────────────────

    def _show_update_screen(self):
        clear_frame(self.content)
        tk.Label(self.content, text="Update available", font=F_HEAD, fg=FG, bg=BG).pack(pady=(6, 10))
        tk.Label(self.content,
                 text="An existing CockpitRandomizer installation\nwas found.\n\n"
                      "Updating will overwrite the Lua scripts.\n"
                      "Your aircraft selection and Export.lua\nwill not be changed.",
                 font=F_BODY, fg=FG, bg=BG, justify="center", wraplength=340).pack(pady=(0, 16))

        make_button(self.content, "Update", command=self._do_update).pack(pady=4, fill="x")
        make_button(self.content, "Skip", command=self._show_main_screen, primary=False).pack(pady=4, fill="x")

    def _do_update(self):
        try:
            copy_lua_files(self.scripts_dir)
            self.set_status("Lua scripts updated. Press Apply to refresh Export.lua.", color=GREEN)
            self._show_main_screen()
        except Exception as e:
            messagebox.showerror("Update failed", str(e))
            self.set_status(f"Error: {e}", color=HL)

    # ── Screen: main (aircraft selection) ────────────────────────────────────

    def _show_main_screen(self):
        # Check if this is a fresh arrival from install, or direct open
        # If installed but coming from _detect_and_route with existing install → offer update
        # (only if source Lua files are newer — we skip version comparison for now
        #  and just show "Check for update" button)
        clear_frame(self.content)

        cfg = load_config(self.scripts_dir)
        saved_selected = set(cfg.get("selected", [key for _, key in AIRCRAFT]))

        tk.Label(self.content,
                 text="Select aircraft to randomize:",
                 font=F_BODY, fg=MUTED, bg=BG).pack(pady=(4, 10))

        # Aircraft checkboxes
        self.vars = {}
        panel = tk.Frame(self.content, bg=PANEL)
        panel.pack(fill="x")

        for _, key in AIRCRAFT:
            label = next(l for l, k in AIRCRAFT if k == key)
            var = tk.BooleanVar(value=(key in saved_selected))
            self.vars[key] = var
            row = tk.Frame(panel, bg=PANEL)
            row.pack(fill="x", padx=16, pady=5)
            tk.Checkbutton(
                row, text=label, variable=var,
                font=F_BODY, fg=FG, bg=PANEL,
                selectcolor=ACCENT,
                activebackground=PANEL, activeforeground=FG,
                bd=0, highlightthickness=0, cursor="hand2"
            ).pack(side="left")

        # Buttons
        btn_row = tk.Frame(self.content, bg=BG)
        btn_row.pack(pady=14, fill="x")
        make_button(btn_row, "Apply", command=self._do_apply, width=12).pack(
            side="left", expand=True, fill="x", padx=(0, 4))
        make_button(btn_row, "Reset", command=self._do_reset, primary=False, width=12).pack(
            side="left", expand=True, fill="x")

        # Update banner — shown only when installed version differs from exe version
        inst_ver = installed_version(self.scripts_dir)
        exe_ver  = exe_version()
        if inst_ver and inst_ver != exe_ver:
            banner = tk.Frame(self.content, bg="#2a1a0e")
            banner.pack(fill="x", pady=(8, 0))
            tk.Label(banner,
                     text=f"New version available: v{exe_ver}  (installed: v{inst_ver})",
                     font=F_SMALL, fg="#f0a030", bg="#2a1a0e").pack(side="left", padx=8, pady=4)
            tk.Button(banner, text="Update now",
                      command=self._do_update,
                      font=F_SMALL, fg="#f0a030", bg="#2a1a0e",
                      activebackground="#3a2a1e", activeforeground="#f0a030",
                      bd=0, relief="flat", cursor="hand2").pack(side="right", padx=8)

        # Secondary actions
        sec_row = tk.Frame(self.content, bg=BG)
        sec_row.pack(fill="x", pady=(6, 0))
        tk.Button(sec_row, text="Update Lua scripts",
                  command=self._show_update_screen,
                  font=F_SMALL, fg=MUTED, bg=BG,
                  activebackground=BG, activeforeground=FG,
                  bd=0, relief="flat", cursor="hand2").pack(side="left")
        tk.Button(sec_row, text="Uninstall",
                  command=self._confirm_uninstall,
                  font=F_SMALL, fg=MUTED, bg=BG,
                  activebackground=BG, activeforeground=HL,
                  bd=0, relief="flat", cursor="hand2").pack(side="right")

    def _selected_keys(self):
        return {key for key, var in self.vars.items() if var.get()}

    def _do_apply(self):
        try:
            selected = self._selected_keys()
            save_config(self.scripts_dir, selected)
            export = export_lua_path(self.scripts_dir)

            if not selected:
                # No aircraft selected — restore stock backup
                bak = backup_path(self.scripts_dir)
                if os.path.isfile(bak):
                    shutil.copy2(bak, export)
                    self.set_status("No aircraft selected — stock Export.lua restored.", color=MUTED)
                elif os.path.isfile(export):
                    os.remove(export)
                    self.set_status("No aircraft selected — Export.lua removed.", color=MUTED)
                return

            if os.path.isfile(export):
                with open(export, "r", encoding="utf-8", errors="ignore") as f:
                    content = f.read()
                if has_cr_block(content):
                    # Our block already present — just replace it, preserve the rest
                    cleaned = remove_cr_block(content).strip()
                    if cleaned:
                        new_content = build_cr_block(selected) + "\n\n" + cleaned + "\n"
                    else:
                        new_content = build_fresh_export_lua(selected)
                else:
                    # Foreign Export.lua — warn before overwriting
                    bak = backup_path(self.scripts_dir)
                    if not os.path.isfile(bak):
                        answer = messagebox.askyesno(
                            "Existing Export.lua detected",
                            "An Export.lua already exists (possibly from DCS-BIOS, SRS, or Tacview).\n\n"
                            "The CockpitRandomizer block will be added to the top.\n"
                            "Your existing content will be preserved below it.\n\n"
                            "A backup will be saved as Export.lua.stock_backup.\n\n"
                            "Continue?",
                            icon="warning"
                        )
                        if not answer:
                            self.set_status("Cancelled — Export.lua not modified.", color=MUTED)
                            return
                        shutil.copy2(export, bak)
                    # Strip leading path comment if present
                    lines = content.splitlines(keepends=True)
                    if lines and lines[0].strip().startswith("-- Saved Games"):
                        content = "".join(lines[1:]).lstrip("\n")
                    new_content = build_cr_block(selected) + "\n\n" + content
            else:
                new_content = build_fresh_export_lua(selected)

            with open(export, "w", encoding="utf-8") as f:
                f.write(new_content)

            n = len(selected)
            self.set_status(f"Applied — {n} aircraft active.", color=GREEN)

        except Exception as e:
            messagebox.showerror("Error", str(e))
            self.set_status(f"Error: {e}", color=HL)

    def _do_reset(self):
        if not messagebox.askyesno(
            "Reset",
            "All selections will be cleared and the stock Export.lua will be restored.\n\nContinue?"
        ):
            return
        try:
            bak = backup_path(self.scripts_dir)
            export = export_lua_path(self.scripts_dir)
            if os.path.isfile(bak):
                shutil.copy2(bak, export)
                for var in self.vars.values():
                    var.set(False)
                save_config(self.scripts_dir, set())
                self.set_status("Stock Export.lua restored.", color=GREEN)
            else:
                messagebox.showwarning(
                    "No backup found",
                    "No stock backup exists.\n\n"
                    "This means CockpitRandomizer was applied without a pre-existing Export.lua, "
                    "or the backup was deleted manually.\n\n"
                    "Export.lua will be removed instead."
                )
                if os.path.isfile(export):
                    os.remove(export)
                for var in self.vars.values():
                    var.set(False)
                save_config(self.scripts_dir, set())
                self.set_status("No backup found — Export.lua removed.", color=MUTED)
        except Exception as e:
            messagebox.showerror("Error", str(e))
            self.set_status(f"Error: {e}", color=HL)

    # ── Uninstall ─────────────────────────────────────────────────────────────

    def _confirm_uninstall(self):
        bak = backup_path(self.scripts_dir)
        if os.path.isfile(bak):
            extra = "Your original Export.lua will be restored from backup."
        else:
            extra = "No backup found — Export.lua will be deleted."

        if not messagebox.askyesno(
            "Uninstall",
            f"This will remove CockpitRandomizer completely.\n\n{extra}\n\nContinue?"
        ):
            return
        self._do_uninstall()

    def _do_uninstall(self):
        try:
            scripts  = self.scripts_dir
            cr_dir   = os.path.join(scripts, "CockpitRandomizer")
            export   = export_lua_path(scripts)
            bak      = backup_path(scripts)

            # Restore or clean Export.lua
            if os.path.isfile(bak):
                shutil.copy2(bak, export)
                os.remove(bak)
            else:
                if os.path.isfile(export):
                    with open(export, "r", encoding="utf-8", errors="ignore") as f:
                        content = f.read()
                    cleaned = remove_cr_block(content).strip()
                    if cleaned:
                        with open(export, "w", encoding="utf-8") as f:
                            f.write(cleaned + "\n")
                    else:
                        os.remove(export)

            # Remove CockpitRandomizer folder
            if os.path.isdir(cr_dir):
                shutil.rmtree(cr_dir)

            messagebox.showinfo("Uninstall complete", "CockpitRandomizer has been removed.")
            self.destroy()

        except Exception as e:
            messagebox.showerror("Uninstall failed", str(e))
            self.set_status(f"Error: {e}", color=HL)


# ── Entry point ───────────────────────────────────────────────────────────────

if __name__ == "__main__":
    app = App()
    app.mainloop()
