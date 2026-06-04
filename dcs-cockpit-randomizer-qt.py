# dcs-cockpit-randomizer-qt.py v1.0
# PyQt5 port of dcs-cockpit-randomizer
# Place this file next to the CockpitRandomizer\ folder.

import sys, os, shutil, json
from PyQt5.QtWidgets import (
    QApplication, QWidget, QVBoxLayout, QHBoxLayout,
    QLabel, QPushButton, QFrame, QSizePolicy,
    QFileDialog, QMessageBox, QProgressBar, QToolButton,
    QDialog, QCheckBox
)
from PyQt5.QtCore import Qt, QPoint, QPropertyAnimation, QEasingCurve, QTimer
from PyQt5.QtGui import QColor, QFont

# ── DPI awareness ─────────────────────────────────────────────────────────────
try:
    import ctypes
    ctypes.windll.shcore.SetProcessDpiAwareness(1)
except Exception:
    pass

# ── Constants ─────────────────────────────────────────────────────────────────
APP_TITLE            = "dcs-cockpit-randomizer"
APP_VERSION_FALLBACK = "1.0"

AIRCRAFT = [
    ("F-4E Phantom II", "f4e"),
    ("F/A-18C Hornet",  "fa18c"),
    ("F-14B Tomcat",    "f14b"),
    ("F-16C Viper",     "f16c"),
    ("F-5E Tiger II",   "f5e"),
]

DCS_FOLDER_NAMES = ["DCS", "DCS.openbeta"]

if getattr(sys, "frozen", False):
    THIS_DIR = os.path.dirname(sys.executable)
else:
    THIS_DIR = os.path.dirname(os.path.abspath(__file__))
LUA_SRC_DIR = os.path.join(THIS_DIR, "CockpitRandomizer")

# ── Palette ───────────────────────────────────────────────────────────────────
BG    = "#1a1d2e"
PANEL = "#16213e"
TB    = "#0d0f1e"
HL    = "#e05c7a"
ACC   = "#2d5fa0"
FG    = "#c0c8f0"
MUTED = "#5a6080"
GREEN = "#2e7d32"

# ── Version helpers ───────────────────────────────────────────────────────────
def read_version(path):
    try:
        with open(path, "r", encoding="utf-8") as f:
            return f.read().strip()
    except Exception:
        return None

def exe_version():
    v = read_version(os.path.join(THIS_DIR, "version.txt"))
    return v if v else APP_VERSION_FALLBACK

def installed_version(scripts_dir):
    return read_version(os.path.join(scripts_dir, "CockpitRandomizer", "version.txt"))

APP_VERSION = exe_version()

# ── Export.lua helpers ────────────────────────────────────────────────────────
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
    lines, out, inside = content.splitlines(keepends=True), [], False
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
    saved_games = os.path.join(
        os.environ.get("USERPROFILE", os.path.expanduser("~")), "Saved Games")
    found = []
    for name in DCS_FOLDER_NAMES:
        dcs_dir = os.path.join(saved_games, name)
        if os.path.isdir(dcs_dir):
            found.append(os.path.join(dcs_dir, "Scripts"))
    return found

def lua_files_in_src():
    if not os.path.isdir(LUA_SRC_DIR):
        return []
    return [f for f in os.listdir(LUA_SRC_DIR) if f.endswith(".lua")]

def copy_lua_files(dst_scripts):
    dst = os.path.join(dst_scripts, "CockpitRandomizer")
    os.makedirs(dst, exist_ok=True)
    for fname in lua_files_in_src():
        shutil.copy2(os.path.join(LUA_SRC_DIR, fname), os.path.join(dst, fname))
    src_ver = os.path.join(THIS_DIR, "version.txt")
    if os.path.isfile(src_ver):
        shutil.copy2(src_ver, os.path.join(dst, "version.txt"))

def is_installed(scripts_dir):
    return os.path.isfile(os.path.join(scripts_dir, "CockpitRandomizer", "core.lua"))

def config_path(scripts_dir):
    return os.path.join(scripts_dir, "CockpitRandomizer", "gui_config.json")

def backup_path(scripts_dir):
    return os.path.join(scripts_dir, "Export.lua.stock_backup")

def json_defaults_dir(scripts_dir):
    """Fabrika JSON ayarlarının saklandığı dizin."""
    return os.path.join(scripts_dir, "CockpitRandomizer", "json_defaults")

def save_json_defaults(scripts_dir):
    """LUA_SRC_DIR'deki orijinal JSON'ları json_defaults klasörüne kopyalar."""
    src_dir = LUA_SRC_DIR
    dst_dir = json_defaults_dir(scripts_dir)
    os.makedirs(dst_dir, exist_ok=True)
    json_files = [f for f in os.listdir(src_dir)
                  if f.endswith(".json") and f != "gui_config.json"]
    for fname in json_files:
        shutil.copy2(os.path.join(src_dir, fname), os.path.join(dst_dir, fname))
    return len(json_files)

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

# ── QSS ──────────────────────────────────────────────────────────────────────
STYLE = f"""
* {{ font-family: Consolas; }}
QWidget#main   {{ background-color: {BG}; }}
QWidget#tb     {{ background-color: {TB}; }}
QFrame#panel   {{ background-color: {PANEL}; border-radius: 6px; }}
QFrame#div     {{ background-color: #2e3250; }}
QFrame#content {{ background-color: {BG}; }}

QLabel          {{ background-color: transparent; color: {FG}; }}
QLabel#title    {{ color: {HL};    font-size: 19pt; font-weight: bold; }}
QLabel#ver      {{ color: {MUTED}; font-size: 10pt; }}
QLabel#sel      {{ color: {MUTED}; font-size: 14pt; }}
QLabel#appname  {{ color: #7b8cde; font-size: 10pt; }}
QLabel#status   {{ color: {MUTED}; font-size: 10pt; }}
QLabel#body     {{ color: {FG};    font-size: 13pt; }}
QLabel#head     {{ color: {FG};    font-size: 15pt; font-weight: bold; }}

QPushButton#apply   {{ background:#2e7d32; color:white; font-size:15pt; font-weight:bold; border:none; border-radius:8px; padding:10px; }}
QPushButton#apply:hover    {{ background:#43a047; }}
QPushButton#apply:pressed  {{ background:#1b5e20; }}

QPushButton#reset   {{ background:{ACC}; color:white; font-size:15pt; font-weight:bold; border:none; border-radius:8px; padding:10px; }}
QPushButton#reset:hover    {{ background:#1e5799; }}
QPushButton#reset:pressed  {{ background:#1a4a80; }}

QPushButton#update  {{ background:#f9a825; color:#1a1a00; font-size:15pt; font-weight:bold; border:none; border-radius:8px; padding:10px; }}
QPushButton#update:hover   {{ background:#ffe082; }}
QPushButton#update:pressed {{ background:#f57f17; }}

QPushButton#uninst  {{ background:#c0392b; color:white; font-size:15pt; font-weight:bold; border:none; border-radius:8px; padding:10px; }}
QPushButton#uninst:hover   {{ background:#e74c3c; }}
QPushButton#uninst:pressed {{ background:#922b21; }}

QPushButton#closebtn {{ background:#808080; color:white; font-size:10pt; border:none; border-radius:6px; padding:8px 24px; }}
QPushButton#closebtn:hover {{ background:#8f8b8b; }}

QPushButton#export {{ background:#1a3a4a; color:{FG}; font-size:15pt; font-weight:bold; border:none; border-radius:8px; padding:10px; }}
QPushButton#export:hover   {{ background:#1e4a5e; }}
QPushButton#export:pressed {{ background:#152e3a; }}

QPushButton#import {{ background:#1a3a4a; color:{FG}; font-size:15pt; font-weight:bold; border:none; border-radius:8px; padding:10px; }}
QPushButton#import:hover   {{ background:#1e4a5e; }}
QPushButton#import:pressed {{ background:#152e3a; }}

QPushButton#rdefault {{ background:#3a2a1a; color:{FG}; font-size:15pt; font-weight:bold; border:none; border-radius:8px; padding:10px; }}
QPushButton#rdefault:hover   {{ background:#4a3520; }}
QPushButton#rdefault:pressed {{ background:#2a1e10; }}

QPushButton#actbtn  {{ background:{ACC}; color:white; font-size:13pt; font-weight:bold; border:none; border-radius:8px; padding:10px; }}
QPushButton#actbtn:hover   {{ background:#1e5799; }}
QPushButton#actbtn:pressed {{ background:#1a4a80; }}

QPushButton#secbtn  {{ background:#1e2a3a; color:{FG}; font-size:13pt; border:none; border-radius:8px; padding:10px; }}
QPushButton#secbtn:hover   {{ background:#243040; }}
QPushButton#secbtn:pressed {{ background:#1a2030; }}

QPushButton#tb_min {{ background:transparent; color:#8890b8; font-size:13pt; border:none; padding:4px 14px; }}
QPushButton#tb_min:hover {{ background:#1e2238; color:{FG}; }}

QPushButton#tb_cls {{ background:transparent; color:#8890b8; font-size:13pt; border:none; padding:4px 14px; }}
QPushButton#tb_cls:hover {{ background:#3a0a0a; color:#e74c3c; }}

QProgressBar {{ background:#0d0f1e; border:none; border-radius:5px; height:10px; }}
QProgressBar::chunk {{ background:{GREEN}; border-radius:5px; }}

QMessageBox {{ background-color: #2a2d3e; }}
QMessageBox QLabel {{ color: {FG}; font-size: 11pt; font-family: Consolas; }}
QMessageBox QPushButton {{
    background: {ACC}; color: white;
    font-size: 11pt; font-family: Consolas;
    border: none; border-radius: 6px;
    padding: 6px 20px; min-width: 70px;
}}
QMessageBox QPushButton:hover {{ background: #1e5799; }}
QMessageBox QPushButton:default {{ background: {HL}; }}
QMessageBox QPushButton:default:hover {{ background: #c73652; }}

QToolTip {{
    background-color: #0d0f1e;
    color: {FG};
    border: 1px solid {ACC};
    border-radius: 4px;
    padding: 4px 8px;
    font-family: Consolas;
    font-size: 10pt;
}}
"""

# ── Title bar ─────────────────────────────────────────────────────────────────
class TitleBar(QWidget):
    def __init__(self, parent):
        super().__init__(parent)
        self.parent = parent
        self.setObjectName("tb")
        self.setFixedHeight(36)
        self._drag_pos = QPoint()

        lay = QHBoxLayout(self)
        lay.setContentsMargins(12, 0, 0, 0)
        lay.setSpacing(0)

        lbl = QLabel(APP_TITLE)
        lbl.setObjectName("appname")
        lay.addWidget(lbl)
        lay.addStretch()

        for text, obj, slot, tip in [("─", "tb_min", parent.showMinimized, "Minimize"),
                                 ("✕", "tb_cls", parent.close, "Close")]:
            btn = QPushButton(text)
            btn.setObjectName(obj)
            btn.setFixedHeight(36)
            btn.setCursor(Qt.PointingHandCursor)
            btn.setToolTip(tip)
            btn.clicked.connect(slot)
            lay.addWidget(btn)

    def mousePressEvent(self, e):
        if e.button() == Qt.LeftButton:
            self._drag_pos = e.globalPos() - self.parent.frameGeometry().topLeft()

    def mouseMoveEvent(self, e):
        if e.buttons() == Qt.LeftButton:
            self.parent.move(e.globalPos() - self._drag_pos)

# ── Aircraft row ──────────────────────────────────────────────────────────────
class AircraftRow(QWidget):
    def __init__(self, label, key, checked=True, scripts_dir=None, parent_win=None):
        super().__init__()
        self.key         = key
        self.label       = label
        self._checked    = checked
        self._scripts_dir = scripts_dir
        self._parent_win  = parent_win
        self.setFixedHeight(52)

        lay = QHBoxLayout(self)
        lay.setContentsMargins(16, 0, 8, 0)
        lay.setSpacing(0)

        # Tik + isim — tıklanabilir alan
        self.lbl = QLabel(self._text())
        font = QFont("Consolas", 15)
        font.setBold(True)
        self.lbl.setFont(font)
        self.lbl.setStyleSheet(f"color: {FG}; background: transparent;")
        self.lbl.setCursor(Qt.PointingHandCursor)
        self.lbl.mousePressEvent = lambda e: self._toggle()
        lay.addWidget(self.lbl)

        lay.addStretch()

        # Çark (settings) butonu
        self._gear_btn = QToolButton()
        self._gear_btn.setText("⚙")
        self._gear_btn.setFixedSize(36, 36)
        self._gear_btn.setCursor(Qt.PointingHandCursor)
        self._gear_btn.setToolTip(f"Configure {label} switches")
        self._gear_btn.setStyleSheet(f"""
            QToolButton {{
                background: transparent;
                color: {MUTED};
                font-size: 16pt;
                border: none;
                border-radius: 6px;
            }}
            QToolButton:hover {{
                background: #1e2a4a;
                color: {FG};
            }}
            QToolButton:pressed {{
                background: {ACC};
                color: white;
            }}
        """)
        self._gear_btn.clicked.connect(self._open_settings)
        lay.addWidget(self._gear_btn)

        self._refresh_bg(False)

    def _text(self):
        return f"{'☑' if self._checked else '☐'}  {self.label}"

    def _refresh_bg(self, hover):
        p = self.palette()
        p.setColor(self.backgroundRole(), QColor("#1e2a4a" if hover else PANEL))
        self.setAutoFillBackground(True)
        self.setPalette(p)

    def enterEvent(self, e): self._refresh_bg(True)
    def leaveEvent(self, e): self._refresh_bg(False)

    def mousePressEvent(self, e):
        # Row'a tıklanınca toggle — ama çark butonuna tıklanınca buraya düşmez
        self._toggle()

    def _toggle(self):
        self._checked = not self._checked
        self.lbl.setText(self._text())

    def _open_settings(self):
        # aircraft_settings.py'deki AircraftSettingsDialog'u aç
        try:
            from aircraft_settings import AircraftSettingsDialog
        except ImportError:
            QMessageBox.warning(
                self, "Settings unavailable",
                "aircraft_settings.py not found next to this executable.\n"
                "Place aircraft_settings.py and the metadata JSON files\n"
                "in the same folder as this application."
            )
            return

        dlg = AircraftSettingsDialog(
            aircraft_key=self.key,
            scripts_dir=self._scripts_dir,
            parent=self._parent_win,
        )
        dlg.setWindowModality(Qt.ApplicationModal)
        # Ekran merkezine göre ortala (DPI-safe)
        screen = QApplication.desktop().availableGeometry()
        dlg_w, dlg_h = 800, dlg.height()
        dlg.move(
            screen.x() + (screen.width()  - dlg_w) // 2,
            screen.y() + (screen.height() - dlg_h) // 2,
        )
        dlg.exec_()

    def set_checked(self, val):
        self._checked = val
        self.lbl.setText(self._text())

    def is_checked(self):
        return self._checked

# ── Main window ───────────────────────────────────────────────────────────────
class MainWindow(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle(APP_TITLE)
        self.setFixedSize(560, 856)
        self.setObjectName("main")
        self.setWindowFlags(Qt.FramelessWindowHint | Qt.Window)

        scr = QApplication.desktop().screenGeometry()
        self.move((scr.width() - 560) // 2, (scr.height() - 856) // 2)

        self.scripts_dir = None
        self._rows = []       # AircraftRow list (populated in main screen)

        # Persistent layout skeleton
        root = QVBoxLayout(self)
        root.setContentsMargins(0, 0, 0, 0)
        root.setSpacing(0)

        root.addWidget(TitleBar(self))

        div = QFrame(); div.setObjectName("div"); div.setFixedHeight(1)
        root.addWidget(div)

        # Fixed header
        hdr = QWidget(); hdr.setObjectName("main")
        hdr_lay = QVBoxLayout(hdr)
        hdr_lay.setContentsMargins(20, 28, 20, 0)
        hdr_lay.setSpacing(0)
        self.lbl_title = QLabel("DCS-COCKPIT-RANDOMIZER")
        self.lbl_title.setObjectName("title")
        self.lbl_title.setAlignment(Qt.AlignCenter)
        hdr_lay.addWidget(self.lbl_title)
        lbl_ver = QLabel(f"v{APP_VERSION}")
        lbl_ver.setObjectName("ver")
        lbl_ver.setAlignment(Qt.AlignCenter)
        hdr_lay.addWidget(lbl_ver)
        hdr_lay.addSpacing(12)
        root.addWidget(hdr)

        # Swappable content area
        self.content = QVBoxLayout()
        self.content.setContentsMargins(20, 0, 20, 0)
        self.content.setSpacing(0)
        root.addLayout(self.content)

        # Persistent bottom bar
        bottom = QWidget(); bottom.setObjectName("main")
        bot_lay = QVBoxLayout(bottom)
        bot_lay.setContentsMargins(20, 8, 20, 16)
        bot_lay.setSpacing(6)

        # status ve progress main screen'de enjekte edilir
        self.status_lbl = QLabel("")
        self.status_lbl.setObjectName("status")
        self.status_lbl.setAlignment(Qt.AlignCenter)
        self.status_lbl.setWordWrap(True)
        self.status_lbl.setFixedHeight(20)

        self.progress = QProgressBar()
        self.progress.setFixedHeight(10)
        self.progress.setRange(0, 100)
        self.progress.setTextVisible(False)
        self.progress.hide()

        btn_close = QPushButton("Close")
        btn_close.setObjectName("closebtn")
        btn_close.setCursor(Qt.PointingHandCursor)
        btn_close.setToolTip("Close the application")
        btn_close.clicked.connect(self.close)
        btn_close.setFixedWidth(130)
        crow = QHBoxLayout()
        crow.addStretch(); crow.addWidget(btn_close); crow.addStretch()
        bot_lay.addLayout(crow)
        root.addWidget(bottom)

        # Fade-in
        self.setWindowOpacity(0.0)
        anim = QPropertyAnimation(self, b"windowOpacity", self)
        anim.setDuration(300)
        anim.setStartValue(0.0)
        anim.setEndValue(1.0)
        anim.setEasingCurve(QEasingCurve.InOutQuad)
        anim.start()
        self._anim = anim

        self._detect_and_route()

    # ── Helpers ───────────────────────────────────────────────────────────────

    def _clear_content(self):
        protected = {self.status_lbl, self.progress}
        while self.content.count():
            item = self.content.takeAt(0)
            if item.widget():
                if item.widget() not in protected:
                    item.widget().deleteLater()
            elif item.layout():
                self._clear_layout(item.layout())

    def _clear_layout(self, layout):
        while layout.count():
            item = layout.takeAt(0)
            if item.widget():
                item.widget().deleteLater()
            elif item.layout():
                self._clear_layout(item.layout())

    def set_status(self, msg, color=MUTED):
        self.status_lbl.setStyleSheet(
            f"color: {color}; font-family: Consolas; font-size: 10pt;")
        self.status_lbl.setText(msg)

    def _make_btn(self, text, obj, slot):
        btn = QPushButton(text)
        btn.setObjectName(obj)
        btn.setCursor(Qt.PointingHandCursor)
        btn.setFixedHeight(52)
        btn.clicked.connect(slot)
        return btn

    def _ask(self, title, msg, icon=QMessageBox.Warning):
        dlg = QMessageBox(self)
        dlg.setWindowTitle(title)
        dlg.setText(msg)
        dlg.setIcon(icon)
        dlg.setStandardButtons(QMessageBox.Yes | QMessageBox.No)
        dlg.setDefaultButton(QMessageBox.No)
        dlg.show()
        dlg.adjustSize()
        geo = self.frameGeometry()
        dlg.move(geo.right() + 16, geo.top() + (geo.height() - dlg.height()) // 2)
        return dlg.exec_() == QMessageBox.Yes

    def _err(self, title, msg):
        dlg = QMessageBox(QMessageBox.Critical, title, msg, QMessageBox.Ok, self)
        dlg.show(); dlg.adjustSize()
        geo = self.frameGeometry()
        dlg.move(geo.right() + 16, geo.top() + (geo.height() - dlg.height()) // 2)
        dlg.exec_()

    def _info(self, title, msg):
        dlg = QMessageBox(QMessageBox.Information, title, msg, QMessageBox.Ok, self)
        dlg.show(); dlg.adjustSize()
        geo = self.frameGeometry()
        dlg.move(geo.right() + 16, geo.top() + (geo.height() - dlg.height()) // 2)
        dlg.exec_()

    # ── Routing ───────────────────────────────────────────────────────────────

    def _detect_and_route(self):
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
            self._show_browse_screen()

    def _route(self):
        if is_installed(self.scripts_dir):
            self._show_main_screen()
        else:
            self._show_install_screen()

    # ── Screen: no source ─────────────────────────────────────────────────────

    def _show_no_source_screen(self):
        self._clear_content()
        lbl = QLabel(
            "CockpitRandomizer folder not found.\n\n"
            "Make sure the exe is placed next to\n"
            "the CockpitRandomizer\\ folder\n"
            "containing the Lua scripts.")
        lbl.setObjectName("body")
        lbl.setAlignment(Qt.AlignCenter)
        lbl.setWordWrap(True)
        self.content.addStretch()
        self.content.addWidget(lbl)
        self.content.addStretch()
        self.set_status("Lua source folder missing.", color=HL)

    # ── Screen: pick install ──────────────────────────────────────────────────

    def _show_pick_install_screen(self, candidates):
        self._clear_content()
        lbl = QLabel("Multiple DCS installations found.\nSelect one:")
        lbl.setObjectName("body"); lbl.setAlignment(Qt.AlignCenter)
        self.content.addSpacing(10)
        self.content.addWidget(lbl)
        self.content.addSpacing(12)
        for path in candidates:
            display = path.replace(os.environ.get("USERPROFILE", ""), "%USERPROFILE%")
            btn = QPushButton(display)
            btn.setObjectName("secbtn")
            btn.setCursor(Qt.PointingHandCursor)
            btn.clicked.connect(lambda _, p=path: self._select_and_route(p))
            self.content.addWidget(btn)
            self.content.addSpacing(4)
        sep = QLabel("— or —"); sep.setObjectName("ver"); sep.setAlignment(Qt.AlignCenter)
        self.content.addWidget(sep)
        browse = QPushButton("Browse manually...")
        browse.setObjectName("secbtn"); browse.setCursor(Qt.PointingHandCursor)
        browse.clicked.connect(self._browse_scripts_dir)
        self.content.addWidget(browse)
        self.content.addStretch()

    # ── Screen: browse ────────────────────────────────────────────────────────

    def _show_browse_screen(self):
        self._clear_content()
        lbl = QLabel(
            "DCS installation not found automatically.\n\n"
            "Please locate your DCS Saved Games folder\n"
            "(e.g. Saved Games\\DCS\\Scripts).")
        lbl.setObjectName("body"); lbl.setAlignment(Qt.AlignCenter)
        lbl.setWordWrap(True)
        self.content.addStretch()
        self.content.addWidget(lbl, alignment=Qt.AlignHCenter)
        self.content.addSpacing(16)
        btn = QPushButton("Browse...")
        btn.setObjectName("actbtn"); btn.setCursor(Qt.PointingHandCursor)
        btn.setFixedHeight(52); btn.clicked.connect(self._browse_scripts_dir)
        self.content.addWidget(btn)
        self.content.addStretch()

    def _browse_scripts_dir(self):
        chosen = QFileDialog.getExistingDirectory(
            self, "Select your DCS Scripts folder (Saved Games\\DCS\\Scripts)")
        if chosen:
            self._select_and_route(chosen)

    def _select_and_route(self, path):
        self.scripts_dir = path
        self._route()

    # ── Screen: install ───────────────────────────────────────────────────────

    def _show_install_screen(self):
        self._clear_content()
        scripts_display = self.scripts_dir.replace(
            os.environ.get("USERPROFILE", ""), "%USERPROFILE%")
        head = QLabel("Installation"); head.setObjectName("head"); head.setAlignment(Qt.AlignCenter)
        info = QLabel(f"CockpitRandomizer will be installed to:\n\n"
                      f"{scripts_display}\\CockpitRandomizer\\")
        info.setObjectName("body"); info.setAlignment(Qt.AlignCenter); info.setWordWrap(True)
        self.content.addSpacing(6)
        self.content.addWidget(head)
        self.content.addSpacing(10)
        self.content.addWidget(info)
        self.content.addSpacing(16)
        for text, obj, slot in [("Install", "actbtn", self._do_install),
                                 ("Change location...", "secbtn", self._browse_scripts_dir)]:
            btn = QPushButton(text); btn.setObjectName(obj)
            btn.setCursor(Qt.PointingHandCursor); btn.setFixedHeight(52)
            btn.clicked.connect(slot)
            self.content.addWidget(btn)
            self.content.addSpacing(4)
        self.content.addStretch()

    def _do_install(self):
        scripts = self.scripts_dir
        export  = export_lua_path(scripts)
        try:
            if os.path.isfile(export):
                with open(export, "r", encoding="utf-8") as f:
                    c = f.read()
                if has_cr_block(c):
                    self._do_update(); return
            os.makedirs(scripts, exist_ok=True)
            copy_lua_files(scripts)
            save_json_defaults(scripts)
            save_config(scripts, {key for _, key in AIRCRAFT})
            self.set_status("Installation complete. Press Apply to activate.", color=GREEN)
            self._show_main_screen()
        except Exception as e:
            self._err("Installation failed", str(e))
            self.set_status(f"Error: {e}", color=HL)

    # ── Screen: update ────────────────────────────────────────────────────────

    def _show_update_screen(self):
        self._clear_content()
        head = QLabel("Update"); head.setObjectName("head"); head.setAlignment(Qt.AlignCenter)
        info = QLabel("An existing CockpitRandomizer installation\nwas found.\n\n"
                      "Updating will overwrite the Lua scripts.\n"
                      "Your aircraft selection and Export.lua\nwill not be changed.")
        info.setObjectName("body"); info.setAlignment(Qt.AlignCenter)
        self.content.addSpacing(6)
        self.content.addWidget(head)
        self.content.addSpacing(10)
        self.content.addWidget(info)
        self.content.addSpacing(16)
        for text, obj, slot in [("Update", "actbtn", self._do_update),
                                 ("Skip", "secbtn", self._show_main_screen)]:
            btn = QPushButton(text); btn.setObjectName(obj)
            btn.setCursor(Qt.PointingHandCursor); btn.setFixedHeight(52)
            btn.clicked.connect(slot)
            self.content.addWidget(btn)
            self.content.addSpacing(4)
        self.content.addStretch()

    def _do_update(self):
        try:
            copy_lua_files(self.scripts_dir)
            save_json_defaults(self.scripts_dir)
            self.set_status("Lua scripts updated. Press Apply to refresh Export.lua.", color=GREEN)
            self._show_main_screen()
        except Exception as e:
            self._err("Update failed", str(e))
            self.set_status(f"Error: {e}", color=HL)

    # ── Screen: main ──────────────────────────────────────────────────────────

    def _show_main_screen(self):
        self._clear_content()
        self._rows = []

        cfg = load_config(self.scripts_dir)
        saved = set(cfg.get("selected", [key for _, key in AIRCRAFT]))

        # Aircraft panel
        panel = QFrame(); panel.setObjectName("panel")
        pl = QVBoxLayout(panel)
        pl.setContentsMargins(0, 4, 0, 4)
        pl.setSpacing(2)
        for label, key in AIRCRAFT:
            row = AircraftRow(label, key, checked=(key in saved),
                              scripts_dir=self.scripts_dir, parent_win=self)
            self._rows.append(row)
            pl.addWidget(row)
        self.content.addWidget(panel)

        # Update banner
        inst_ver = installed_version(self.scripts_dir)
        exe_ver  = exe_version()
        if inst_ver and inst_ver != exe_ver:
            banner = QFrame(); banner.setStyleSheet("background:#2a1a0e; border-radius:6px;")
            bl = QHBoxLayout(banner); bl.setContentsMargins(10, 6, 10, 6)
            bl.addWidget(QLabel(
                f"New version available: v{exe_ver}  (installed: v{inst_ver})",
            ))
            upd = QPushButton("Update now")
            upd.setObjectName("secbtn"); upd.setCursor(Qt.PointingHandCursor)
            upd.clicked.connect(self._do_update)
            bl.addWidget(upd)
            self.content.addSpacing(8)
            self.content.addWidget(banner)

        # Status + progress — liste ile butonlar arasında
        self.content.addSpacing(8)
        self.content.addWidget(self.status_lbl)
        self.content.addSpacing(4)
        self.content.addWidget(self.progress)

        # Spacer
        self.content.addStretch()

        # Tooltip metinleri
        _TIPS = {
            "Apply":           "Write selected aircraft to Export.lua and activate the randomizer.",
            "Update":          "Copy updated Lua scripts to your DCS Scripts folder.",
            "Reset":           "Deselect all aircraft and restore the original Export.lua.",
            "Import Settings": "Import aircraft switch settings from a backup folder.",
            "Export Settings": "Export current aircraft switch settings to a backup folder.",
            "Defaults":        "Reset switch settings to factory defaults for selected aircraft.",
            "Uninstall":       "Remove CockpitRandomizer completely from your DCS installation.",
        }

        # Apply — tam genişlik
        btn_apply = self._make_btn("Apply", "apply", self._do_apply)
        btn_apply.setToolTip(_TIPS["Apply"])
        self.content.addWidget(btn_apply)
        self.content.addSpacing(4)

        # Satır: Update | Reset
        for pairs in [
            [("Update", "update", self._show_update_screen), ("Reset", "reset", self._do_reset)],
            [("Import Settings", "import", self._do_import_settings), ("Export Settings", "export", self._do_export_settings)],
            [("Defaults", "rdefault", self._do_reset_settings), ("Uninstall", "uninst", self._confirm_uninstall)],
        ]:
            row_lay = QHBoxLayout(); row_lay.setSpacing(4)
            for text, obj, slot in pairs:
                btn = self._make_btn(text, obj, slot)
                btn.setToolTip(_TIPS.get(text, ""))
                row_lay.addWidget(btn)
            self.content.addLayout(row_lay)
            self.content.addSpacing(4)

    def _selected_keys(self):
        return {row.key for row in self._rows if row.is_checked()}

    # ── Apply ─────────────────────────────────────────────────────────────────

    def _do_apply(self):
        try:
            selected = self._selected_keys()
            save_config(self.scripts_dir, selected)
            export = export_lua_path(self.scripts_dir)

            if not selected:
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
                    c = f.read()
                if has_cr_block(c):
                    cleaned = remove_cr_block(c).strip()
                    new_content = (build_cr_block(selected) + "\n\n" + cleaned + "\n"
                                   if cleaned else build_fresh_export_lua(selected))
                else:
                    bak = backup_path(self.scripts_dir)
                    if not os.path.isfile(bak):
                        if not self._ask(
                            "Existing Export.lua detected",
                            "An Export.lua already exists (possibly from DCS-BIOS, SRS, or Tacview).\n\n"
                            "The CockpitRandomizer block will be added to the top.\n"
                            "Your existing content will be preserved below it.\n\n"
                            "A backup will be saved as Export.lua.stock_backup.\n\nContinue?"
                        ):
                            self.set_status("Cancelled — Export.lua not modified.", color=MUTED)
                            return
                        shutil.copy2(export, bak)
                    lines = c.splitlines(keepends=True)
                    if lines and lines[0].strip().startswith("-- Saved Games"):
                        c = "".join(lines[1:]).lstrip("\n")
                    new_content = build_cr_block(selected) + "\n\n" + c
            else:
                new_content = build_fresh_export_lua(selected)

            with open(export, "w", encoding="utf-8") as f:
                f.write(new_content)

            n = len(selected)
            # Animate progress then show status
            self.progress.show()
            self.progress.setValue(0)
            self._progress_step(0, done_msg=f"Applied — {n} aircraft active.", done_color=GREEN)

        except Exception as e:
            self._err("Error", str(e))
            self.set_status(f"Error: {e}", color=HL)

    def _progress_step(self, val, done_msg="Done.", done_color=GREEN):
        val += 10
        self.progress.setValue(min(val, 100))
        if val < 100:
            QTimer.singleShot(30, lambda: self._progress_step(val, done_msg, done_color))
        else:
            self.set_status(done_msg, color=done_color)
            QTimer.singleShot(1500, self.progress.hide)

    # ── Reset ─────────────────────────────────────────────────────────────────

    def _do_reset(self):
        if not self._ask("Reset",
                         "All selections will be cleared and your original Export.lua will be restored.\n\nContinue?"):
            return
        try:
            bak    = backup_path(self.scripts_dir)
            export = export_lua_path(self.scripts_dir)
            if os.path.isfile(bak):
                shutil.copy2(bak, export)
                for row in self._rows:
                    row.set_checked(False)
                save_config(self.scripts_dir, set())
                self.set_status("Stock Export.lua restored.", color=GREEN)
            else:
                QMessageBox.warning(self, "No backup found",
                    "No stock backup exists.\nExport.lua will be removed instead.")
                if os.path.isfile(export):
                    os.remove(export)
                for row in self._rows:
                    row.set_checked(False)
                save_config(self.scripts_dir, set())
                self.set_status("No backup found — Export.lua removed.", color=MUTED)
        except Exception as e:
            self._err("Error", str(e))
            self.set_status(f"Error: {e}", color=HL)

    # ── Uninstall ─────────────────────────────────────────────────────────────

    def _confirm_uninstall(self):
        bak = backup_path(self.scripts_dir)
        extra = ("Your original Export.lua will be restored from backup."
                 if os.path.isfile(bak) else
                 "No backup found — Export.lua will be deleted.")
        if self._ask("Uninstall",
                     f"This will remove CockpitRandomizer completely.\n\n{extra}\n\nContinue?"):
            self._do_uninstall()

    def _do_uninstall(self):
        try:
            scripts = self.scripts_dir
            cr_dir  = os.path.join(scripts, "CockpitRandomizer")
            export  = export_lua_path(scripts)
            bak     = backup_path(scripts)
            if os.path.isfile(bak):
                shutil.copy2(bak, export)
                os.remove(bak)
            else:
                if os.path.isfile(export):
                    with open(export, "r", encoding="utf-8", errors="ignore") as f:
                        c = f.read()
                    cleaned = remove_cr_block(c).strip()
                    if cleaned:
                        with open(export, "w", encoding="utf-8") as f:
                            f.write(cleaned + "\n")
                    else:
                        os.remove(export)
            if os.path.isdir(cr_dir):
                shutil.rmtree(cr_dir)
            self._info("Uninstall complete", "CockpitRandomizer has been removed.")
            self.close()
        except Exception as e:
            self._err("Uninstall failed", str(e))
            self.set_status(f"Error: {e}", color=HL)


    # ── Export / Import Settings ─────────────────────────────────────────────────

    def _do_reset_settings(self):
        ddir = json_defaults_dir(self.scripts_dir)
        if not os.path.isdir(ddir):
            self._err("Reset to Defaults",
                      "No factory defaults found.\n\n"
                      "Defaults are saved during installation or update.\n"
                      "Re-run the installer to restore them.")
            return
        available = {f[:-5]: f for f in os.listdir(ddir)
                     if f.endswith(".json") and f != "gui_config.json"}
        if not available:
            self._err("Reset to Defaults", "Defaults folder is empty.")
            return

        # Aircraft seçim dialogu
        dlg = QDialog(self)
        dlg.setWindowTitle("Reset to Defaults")
        dlg.setWindowFlags(Qt.Dialog)
        dlg.setFixedWidth(340)
        dlg.setStyleSheet(f"QDialog {{ background: #2a2d3e; }} "
                          f"QLabel {{ color: {FG}; font-family: Consolas; }} "
                          f"QCheckBox {{ color: {FG}; font-family: Consolas; font-size: 11pt; }}")
        lay = QVBoxLayout(dlg)
        lay.setContentsMargins(20, 16, 20, 16)
        lay.setSpacing(8)

        lbl = QLabel("Select aircraft to reset to factory defaults:")
        lbl.setWordWrap(True)
        lay.addWidget(lbl)
        lay.addSpacing(6)

        # Aircraft adı → json dosya adı eşleşmesi
        aircraft_map = {label: key for label, key in AIRCRAFT if key in available}
        checkboxes = {}
        for label, key in AIRCRAFT:
            if key in available:
                cb = QCheckBox(label)
                cb.setChecked(True)
                lay.addWidget(cb)
                checkboxes[key] = cb

        lay.addSpacing(10)
        btn_row = QHBoxLayout()
        btn_cancel = QPushButton("Cancel")
        btn_ok     = QPushButton("Reset Selected")
        for btn, style in [(btn_cancel, f"background:#1e2a3a; color:{FG}; border:none; border-radius:6px; padding:6px 16px; font-family:Consolas;"),
                           (btn_ok,     f"background:{HL}; color:white; border:none; border-radius:6px; padding:6px 16px; font-family:Consolas; font-weight:bold;")]:
            btn.setStyleSheet(style)
            btn.setCursor(Qt.PointingHandCursor)
        btn_cancel.clicked.connect(dlg.reject)
        btn_ok.clicked.connect(dlg.accept)
        btn_row.addWidget(btn_cancel)
        btn_row.addWidget(btn_ok)
        lay.addLayout(btn_row)

        if dlg.exec_() != QDialog.Accepted:
            return

        selected_keys = [key for key, cb in checkboxes.items() if cb.isChecked()]
        if not selected_keys:
            return

        try:
            count = 0
            for key in selected_keys:
                fname = available[key]
                for dest_dir in self._json_search_dirs():
                    if os.path.isdir(dest_dir):
                        shutil.copy2(os.path.join(ddir, fname),
                                     os.path.join(dest_dir, fname))
                count += 1
            self.set_status(f"Reset to defaults — {count} aircraft restored.", color=GREEN)
            self._info("Reset complete",
                       f"{count} aircraft settings restored to factory defaults.")
        except Exception as e:
            self._err("Reset failed", str(e))
            self.set_status(f"Reset error: {e}", color=HL)

    def _json_search_dirs(self):
        """JSON ayar dosyalarının bulunabileceği dizinleri döndür (öncelik sırasıyla)."""
        dirs = [THIS_DIR]
        if self.scripts_dir:
            dirs.append(os.path.join(self.scripts_dir, "CockpitRandomizer"))
        return dirs

    def _do_export_settings(self):
        chosen = QFileDialog.getExistingDirectory(
            self, "Select folder to export settings into")
        if not chosen:
            return
        try:
            from datetime import date
            backup_name = f"CockpitRandomizer_Backup_{date.today().isoformat()}"
            backup_dir  = os.path.join(chosen, backup_name)
            os.makedirs(backup_dir, exist_ok=True)

            # Her iki dizinden de JSON topla; aynı isimli dosyada THIS_DIR öncelikli
            collected = {}
            for search_dir in reversed(self._json_search_dirs()):
                if os.path.isdir(search_dir):
                    for fname in os.listdir(search_dir):
                        if fname.endswith(".json") and fname != "gui_config.json":
                            collected[fname] = os.path.join(search_dir, fname)

            if not collected:
                self._info("Export", "No JSON settings files found to export.")
                return
            for fname, fpath in collected.items():
                shutil.copy2(fpath, os.path.join(backup_dir, fname))

            self.set_status(f"Exported {len(collected)} file(s) to {backup_name}.", color=GREEN)
            self._info("Export complete",
                       "Settings exported to:\n" + backup_dir)
        except Exception as e:
            self._err("Export failed", str(e))
            self.set_status(f"Export error: {e}", color=HL)

    def _do_import_settings(self):
        chosen = QFileDialog.getExistingDirectory(
            self, "Select backup folder to import settings from")
        if not chosen:
            return
        try:
            json_files = [f for f in os.listdir(chosen)
                          if f.endswith(".json") and f != "gui_config.json"]
            if not json_files:
                self._info("Import", "No JSON settings files found in selected folder.")
                return
            if not self._ask(
                "Import Settings",
                f"This will overwrite {len(json_files)} settings file(s) "
                "in your CockpitRandomizer installation.\n\nContinue?"
            ):
                return
            # Her iki dizine de kopyala
            for dest_dir in self._json_search_dirs():
                if os.path.isdir(dest_dir):
                    for fname in json_files:
                        shutil.copy2(os.path.join(chosen, fname),
                                     os.path.join(dest_dir, fname))
            self.set_status(f"Imported {len(json_files)} file(s).", color=GREEN)
            self._info("Import complete",
                       f"{len(json_files)} settings file(s) imported successfully.")
        except Exception as e:
            self._err("Import failed", str(e))
            self.set_status(f"Import error: {e}", color=HL)


# ── Entry point ───────────────────────────────────────────────────────────────
if __name__ == "__main__":
    app = QApplication(sys.argv)
    app.setStyleSheet(STYLE)
    win = MainWindow()
    win.show()
    sys.exit(app.exec_())
