# dcs-cockpit-randomizer-qt.py v3.0.0
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
APP_VERSION_FALLBACK = "3.0.0"  # [6] v3.0.0

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
BG    = "#000000"
PANEL = "#111111"
TB    = "#0a0a0a"
HL    = "#9ae69b"
ACC   = "#9ae69b"
FG    = "#ffffff"
MUTED = "#666666"
GREEN = "#9ae69b"

# [10] Hover rengi — neon yeşil vurgu
HOVER_ROW = "#1a1a1a"

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
QFrame#div     {{ background-color: #222222; }}
QFrame#div     {{ background-color: #222222; }}
QFrame#content {{ background-color: {BG}; }}

QLabel          {{ background-color: transparent; color: {FG}; }}
QLabel#title    {{ color: {HL};    font-size: 19pt; font-weight: bold; }}
QLabel#ver      {{ color: {MUTED}; font-size: 10pt; }}
QLabel#sel      {{ color: {MUTED}; font-size: 14pt; }}
QLabel#appname  {{ color: {MUTED}; font-size: 10pt; }}
QLabel#status   {{ color: {MUTED}; font-size: 10pt; }}
QLabel#body     {{ color: {FG};    font-size: 13pt; }}
QLabel#head     {{ color: {FG};    font-size: 15pt; font-weight: bold; }}

QPushButton#apply   {{ background:{ACC}; color:#000000; font-size:15pt; font-weight:bold; border:none; border-radius:8px; padding:10px; }}
QPushButton#apply:hover    {{ background:#55ff2a; }}
QPushButton#apply:pressed  {{ background:#22cc00; }}

QPushButton#reset   {{ background:#1a1a1a; color:{FG}; font-size:15pt; font-weight:bold; border:1px solid #333333; border-radius:8px; padding:10px; }}
QPushButton#reset:hover    {{ background:#222222; border:1px solid {ACC}; }}
QPushButton#reset:pressed  {{ background:#0a0a0a; }}

QPushButton#update  {{ background:#1a1a1a; color:{FG}; font-size:15pt; font-weight:bold; border:1px solid #333333; border-radius:8px; padding:10px; }}
QPushButton#update:hover   {{ background:#222222; border:1px solid {ACC}; }}
QPushButton#update:pressed {{ background:#0a0a0a; }}

QPushButton#uninst  {{ background:#824f4a; color:white; font-size:15pt; font-weight:bold; border:none; border-radius:8px; padding:10px; }}
QPushButton#uninst:hover   {{ background:#e74c3c; }}
QPushButton#uninst:pressed {{ background:#922b21; }}

QPushButton#closebtn {{ background:#1a1a1a; color:{MUTED}; font-size:10pt; border:1px solid #333333; border-radius:6px; padding:8px 24px; }}
QPushButton#closebtn:hover {{ background:#222222; color:{FG}; }}

QPushButton#iconbtn_update,
QPushButton#iconbtn_deactivate,
QPushButton#iconbtn_import,
QPushButton#iconbtn_export,
QPushButton#iconbtn_defaults {{ background:{PANEL}; color:{ACC}; border:1px solid #222222; border-radius:8px; font-family:'Segoe MDL2 Assets'; font-size:18pt; }}
QPushButton#iconbtn_update:hover,
QPushButton#iconbtn_deactivate:hover,
QPushButton#iconbtn_import:hover,
QPushButton#iconbtn_export:hover,
QPushButton#iconbtn_defaults:hover {{ background:#1a1a1a; border:1px solid {ACC}; }}
QPushButton#iconbtn_update:pressed,
QPushButton#iconbtn_deactivate:pressed,
QPushButton#iconbtn_import:pressed,
QPushButton#iconbtn_export:pressed,
QPushButton#iconbtn_defaults:pressed {{ background:#0a0a0a; }}

QPushButton#iconbtn_uninst  {{ background:#824f4a; color:white; border:none; border-radius:8px; font-family:'Segoe MDL2 Assets'; font-size:18pt; }}
QPushButton#iconbtn_uninst:hover   {{ background:#e74c3c; }}
QPushButton#iconbtn_uninst:pressed {{ background:#922b21; }}

QPushButton#export {{ background:#1a1a1a; color:{FG}; font-size:15pt; font-weight:bold; border:1px solid #333333; border-radius:8px; padding:10px; }}
QPushButton#export:hover   {{ background:#222222; border:1px solid {ACC}; }}
QPushButton#export:pressed {{ background:#0a0a0a; }}

QPushButton#import {{ background:#1a1a1a; color:{FG}; font-size:15pt; font-weight:bold; border:1px solid #333333; border-radius:8px; padding:10px; }}
QPushButton#import:hover   {{ background:#222222; border:1px solid {ACC}; }}
QPushButton#import:pressed {{ background:#0a0a0a; }}

QPushButton#rdefault {{ background:#1a1a1a; color:{FG}; font-size:15pt; font-weight:bold; border:1px solid #333333; border-radius:8px; padding:10px; }}
QPushButton#rdefault:hover   {{ background:#222222; border:1px solid {ACC}; }}
QPushButton#rdefault:pressed {{ background:#0a0a0a; }}

QPushButton#actbtn  {{ background:{ACC}; color:#000000; font-size:13pt; font-weight:bold; border:none; border-radius:8px; padding:10px; }}
QPushButton#actbtn:hover   {{ background:#55ff2a; }}
QPushButton#actbtn:pressed {{ background:#22cc00; }}

QPushButton#secbtn  {{ background:#1a1a1a; color:{FG}; font-size:13pt; border:1px solid #333333; border-radius:8px; padding:10px; }}
QPushButton#secbtn:hover   {{ background:#222222; border:1px solid {ACC}; }}
QPushButton#secbtn:pressed {{ background:#0a0a0a; }}

QPushButton#tb_cls {{ background: transparent; color: {MUTED}; font-size: 13pt; border: none; }}
QPushButton#tb_cls:hover {{ background:#1a0000; color:#e74c3c; }}

QProgressBar {{ background:#111111; border:none; border-radius:5px; height:10px; }}
QProgressBar::chunk {{ background:{GREEN}; border-radius:5px; }}

QMessageBox {{ background-color: #111111; }}
QMessageBox QLabel {{ color: {FG}; font-size: 11pt; font-family: Consolas; }}
QMessageBox QPushButton {{
    background: #1a1a1a; color: {FG};
    font-size: 11pt; font-family: Consolas;
    border: 1px solid #333333; border-radius: 6px;
    padding: 6px 20px; min-width: 70px;
}}
QMessageBox QPushButton:hover {{ background: #222222; border: 1px solid {ACC}; }}
QMessageBox QPushButton:default {{ background: {ACC}; color: #000000; border: none; }}
QMessageBox QPushButton:default:hover {{ background: #55ff2a; }}

QToolTip {{
    background-color: #111111;
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
        self.setFixedHeight(40)
        self._drag_pos = QPoint()

        lay = QHBoxLayout(self)
        lay.setContentsMargins(16, 0, 8, 0)
        lay.setSpacing(0)

        lbl = QLabel(APP_TITLE)
        lbl.setObjectName("appname")
        lay.addWidget(lbl)
        lay.addStretch()

        cls_btn = QPushButton("✕")
        cls_btn.setObjectName("tb_cls")
        cls_btn.setFixedSize(32, 32)
        cls_btn.setCursor(Qt.PointingHandCursor)
        cls_btn.setToolTip("Close")
        cls_btn.clicked.connect(parent.close)
        lay.addWidget(cls_btn)

    def mousePressEvent(self, e):
        if e.button() == Qt.LeftButton:
            self._drag_pos = e.globalPos() - self.parent.frameGeometry().topLeft()

    def mouseMoveEvent(self, e):
        if e.buttons() == Qt.LeftButton:
            self.parent.move(e.globalPos() - self._drag_pos)
            self.parent._reposition_settings_dialog()

# ── Aircraft row ──────────────────────────────────────────────────────────────
class AircraftRow(QWidget):
    def __init__(self, label, key, checked=True, scripts_dir=None, parent_win=None):
        super().__init__()
        self.key          = key
        self.label        = label
        self._checked     = checked
        self._scripts_dir = scripts_dir
        self._parent_win  = parent_win
        self.setFixedHeight(52)

        lay = QHBoxLayout(self)
        lay.setContentsMargins(16, 0, 8, 0)
        lay.setSpacing(0)

        # [12] Modern tik: ✔ / boş daire ○ — seçili daha koyu, pasif daha silik
        self.lbl = QLabel(self._text())
        font = QFont("Consolas", 15)
        font.setBold(True)
        self.lbl.setFont(font)
        self.lbl.setStyleSheet(self._label_style())
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
                outline: none;
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
        self._gear_btn.setFocusPolicy(Qt.NoFocus)
        self._gear_btn.clicked.connect(self._open_settings)
        lay.addWidget(self._gear_btn)

        self._refresh_bg(False)

    def _text(self):
        # [12] Modern tik stili: ✔ seçili, ○ seçisiz
        return f"{'✔' if self._checked else '○'}  {self.label}"

    def _label_style(self):
        # [11] Seçili: tam parlak renk; pasif: soluk
        if self._checked:
            return f"color: {FG}; background: transparent;"
        else:
            return f"color: {MUTED}; background: transparent;"

    def _refresh_bg(self, hover):
        p = self.palette()
        # [10] hover rengi = ACC (Reset butonuyla aynı mavi)
        p.setColor(self.backgroundRole(), QColor(HOVER_ROW if hover else PANEL))
        self.setAutoFillBackground(True)
        self.setPalette(p)

    def enterEvent(self, e): self._refresh_bg(True)
    def leaveEvent(self, e): self._refresh_bg(False)

    def mousePressEvent(self, e):
        self._toggle()

    def _toggle(self):
        self._checked = not self._checked
        self.lbl.setText(self._text())
        # [11] Font rengini güncelle
        self.lbl.setStyleSheet(self._label_style())

    def _open_settings(self):
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

        # Mevcut kalıcı dialog varsa içini yenile, yoksa modal aç
        pw = self._parent_win
        if hasattr(pw, "_persistent_settings_dlg") and pw._persistent_settings_dlg is not None:
            dlg = pw._persistent_settings_dlg
            dlg.load_aircraft(self.key, self._scripts_dir)
            dlg.raise_()
            dlg.activateWindow()
        else:
            dlg = AircraftSettingsDialog(
                aircraft_key=self.key,
                scripts_dir=self._scripts_dir,
                parent=pw,
            )
            dlg.setWindowModality(Qt.ApplicationModal)
            parent_geo = pw.frameGeometry()
            dlg.show()
            dlg_w = dlg.width()
            dlg_h = dlg.height()
            screen = QApplication.desktop().availableGeometry()
            x = parent_geo.right() + 10
            y = parent_geo.top() + (parent_geo.height() - dlg_h) // 2
            if x + dlg_w > screen.right():
                x = parent_geo.left() - dlg_w - 10
            y = max(screen.top(), min(y, screen.bottom() - dlg_h))
            dlg.move(x, y)
            dlg.exec_()

    def set_checked(self, val):
        self._checked = val
        self.lbl.setText(self._text())
        self.lbl.setStyleSheet(self._label_style())

    def is_checked(self):
        return self._checked

# ── Main window ───────────────────────────────────────────────────────────────
class MainWindow(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle(APP_TITLE)
        # [7] Ana arayüz yüksekliği aircraft_settings.py ile uyumlu (856→1080)
        self.setFixedSize(560, 1280)
        self.setObjectName("main")
        self.setWindowFlags(Qt.FramelessWindowHint | Qt.Window)

        scr = QApplication.desktop().screenGeometry()
        self.move((scr.width() - 560) // 2, (scr.height() - 1080) // 2)

        self.scripts_dir = None
        self._rows = []

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
        btn.setFixedHeight(104)
        btn.clicked.connect(slot)
        return btn

    # [1] _ask, _err, _info — style_msgbox ile tutarlı stil, "Defaults" QDialog gibi görünür
    def _style_msgbox(self, dlg: QMessageBox):
        dlg.setStyleSheet(f"""
            QMessageBox {{
                background-color: #111111;
            }}
            QMessageBox QLabel {{
                color: {FG};
                font-size: 11pt;
                font-family: Consolas;
            }}
            QMessageBox QPushButton {{
                background: #1a1a1a; color: {FG};
                font-size: 11pt; font-family: Consolas;
                border: 1px solid #333333; border-radius: 6px;
                padding: 6px 20px; min-width: 70px;
            }}
            QMessageBox QPushButton:hover {{ background: #222222; border: 1px solid {ACC}; }}
            QMessageBox QPushButton:default {{ background: {ACC}; color: #000000; border: none; }}
            QMessageBox QPushButton:default:hover {{ background: #55ff2a; }}
        """)

    def _ask(self, title, msg, icon=QMessageBox.Warning):
        dlg = QMessageBox(self)
        dlg.setWindowTitle(title)
        dlg.setText(msg)
        dlg.setIcon(icon)
        dlg.setStandardButtons(QMessageBox.Yes | QMessageBox.No)
        dlg.setDefaultButton(QMessageBox.No)
        self._style_msgbox(dlg)  # [1] tutarlı stil
        dlg.show()
        dlg.adjustSize()
        geo = self.frameGeometry()
        dlg.move(geo.right() + 16, geo.top() + (geo.height() - dlg.height()) // 2)
        return dlg.exec_() == QMessageBox.Yes

    def _err(self, title, msg):
        dlg = QMessageBox(QMessageBox.Critical, title, msg, QMessageBox.Ok, self)
        self._style_msgbox(dlg)  # [1] tutarlı stil
        dlg.show(); dlg.adjustSize()
        geo = self.frameGeometry()
        dlg.move(geo.right() + 16, geo.top() + (geo.height() - dlg.height()) // 2)
        dlg.exec_()

    def _info(self, title, msg):
        dlg = QMessageBox(QMessageBox.Information, title, msg, QMessageBox.Ok, self)
        self._style_msgbox(dlg)  # [1] tutarlı stil
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

    # ── Screen: browse ────────────────────────────────────────────────────────

    def _show_browse_screen(self):
        self._clear_content()
        lbl = QLabel(
            "DCS Scripts folder not found automatically.\n\n"
            "Please browse to your DCS Scripts folder\n"
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

    # ── Screen: pick install ──────────────────────────────────────────────────

    def _show_pick_install_screen(self, candidates):
        self._clear_content()
        lbl = QLabel("Multiple DCS installations found.\nChoose one:")
        lbl.setObjectName("body"); lbl.setAlignment(Qt.AlignCenter)
        self.content.addStretch()
        self.content.addWidget(lbl)
        self.content.addSpacing(12)
        for path in candidates:
            display = path.replace(os.environ.get("USERPROFILE", ""), "%USERPROFILE%")
            btn = QPushButton(display)
            btn.setObjectName("actbtn"); btn.setCursor(Qt.PointingHandCursor)
            btn.setFixedHeight(52)
            btn.clicked.connect(lambda _, p=path: self._select_and_route(p))
            self.content.addWidget(btn)
            self.content.addSpacing(4)
        self.content.addSpacing(8)
        btn_browse = QPushButton("Browse other location...")
        btn_browse.setObjectName("secbtn"); btn_browse.setCursor(Qt.PointingHandCursor)
        btn_browse.setFixedHeight(52); btn_browse.clicked.connect(self._browse_scripts_dir)
        self.content.addWidget(btn_browse)
        self.content.addStretch()

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
            self._err("Install failed", str(e))
            self.set_status(f"Error: {e}", color=HL)

    # ── Screen: update ────────────────────────────────────────────────────────

    def _show_update_screen(self):
        self._clear_content()
        head = QLabel("Update"); head.setObjectName("head"); head.setAlignment(Qt.AlignCenter)
        info = QLabel("Update Lua scripts in your DCS installation.\n\n"
                      "Your switch settings will be preserved.")
        info.setObjectName("body"); info.setAlignment(Qt.AlignCenter); info.setWordWrap(True)
        self.content.addSpacing(6)
        self.content.addWidget(head)
        self.content.addSpacing(10)
        self.content.addWidget(info)
        self.content.addSpacing(16)
        for text, obj, slot in [("Update now", "actbtn", self._do_update),
                                 ("Back", "secbtn", self._show_main_screen)]:
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
            self.set_status("Update complete. Press Apply to refresh Export.lua.", color=GREEN)
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

        # [8] Başlık ile uçak listesi arasına boşluk
        self.content.addSpacing(12)

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

        # Status + progress
        self.content.addSpacing(8)
        self.content.addWidget(self.status_lbl)
        self.content.addSpacing(4)
        self.content.addWidget(self.progress)

        # Spacer
        self.content.addStretch()

        # Apply — tam genişlik, büyük
        btn_apply = self._make_btn("Apply", "apply", self._do_apply)
        btn_apply.setFixedHeight(72)
        btn_apply.setToolTip("Write selected aircraft to Export.lua and activate the randomizer.")
        self.content.addWidget(btn_apply)
        self.content.addSpacing(6)

        # 6 ikon butonu — tek satır
        _ICON_BTNS = [
            ("\uE72C", "iconbtn_update",   self._show_update_screen, "Update: copy updated Lua scripts to DCS."),
            ("\uE7A7", "iconbtn_deactivate", self._do_reset, "Deactivate Randomizer: Deactivates the randomizer and restores your own Export.lua."),
            ("\uE896", "iconbtn_import",   self._do_import_settings, "Import Settings from a backup folder."),
            ("\uE898", "iconbtn_export",   self._do_export_settings, "Export Settings to a backup folder."),
            ("\uE734", "iconbtn_defaults", self._do_reset_settings,  "Defaults: reset switches to factory defaults."),
            ("\uE107", "iconbtn_uninst",   self._confirm_uninstall,  "Uninstall: remove CockpitRandomizer completely."),
        ]
        mdl2_font = QFont("Segoe MDL2 Assets", 18)
        icon_row = QHBoxLayout()
        icon_row.setSpacing(4)
        for icon, obj, slot, tip in _ICON_BTNS:
            btn = QPushButton(icon)
            btn.setFont(mdl2_font)
            btn.setObjectName(obj)
            btn.setCursor(Qt.PointingHandCursor)
            btn.setToolTip(tip)
            btn.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Fixed)
            btn.setFixedHeight(56)
            btn.clicked.connect(slot)
            icon_row.addWidget(btn)
        self.content.addLayout(icon_row)
        self.content.addSpacing(8)

        # Kalıcı settings dialog — ilk açılışta placeholder, çark'a tıklanınca dolar
        self._open_persistent_settings_dialog()

    def _open_persistent_settings_dialog(self):
        """Ana pencereyle birlikte sağında duran, kalıcı settings dialog'unu aç."""
        try:
            from aircraft_settings import AircraftSettingsDialog
        except ImportError:
            return

        # Zaten açıksa tekrar açma
        if hasattr(self, "_persistent_settings_dlg") and self._persistent_settings_dlg is not None:
            return

        dlg = AircraftSettingsDialog(aircraft_key=None, scripts_dir=self.scripts_dir, parent=self)
        dlg.setWindowModality(Qt.NonModal)
        self._persistent_settings_dlg = dlg

        dlg.show()
        self._reposition_settings_dialog()

    def _reposition_settings_dialog(self):
        dlg = getattr(self, "_persistent_settings_dlg", None)
        if dlg is None:
            return
        geo = self.frameGeometry()
        screen = QApplication.desktop().availableGeometry()
        x = geo.right() + 10
        y = geo.top() + (geo.height() - dlg.height()) // 2
        if x + dlg.width() > screen.right():
            x = geo.left() - dlg.width() - 10
        y = max(screen.top(), min(y, screen.bottom() - dlg.height()))
        dlg.move(x, y)

    def closeEvent(self, e):
        dlg = getattr(self, "_persistent_settings_dlg", None)
        if dlg is not None:
            dlg.close()
        super().closeEvent(e)

    def moveEvent(self, e):
        self._reposition_settings_dialog()
        super().moveEvent(e)

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
                else:
                    self.set_status("No aircraft selected.", color=MUTED)
                return

            bak = backup_path(self.scripts_dir)
            if not os.path.isfile(bak) and os.path.isfile(export):
                with open(export, "r", encoding="utf-8", errors="ignore") as f:
                    c = f.read()
                if not has_cr_block(c):
                    shutil.copy2(export, bak)

            if os.path.isfile(export):
                with open(export, "r", encoding="utf-8", errors="ignore") as f:
                    c = f.read()
                cleaned = remove_cr_block(c).strip()
                new_block = build_cr_block(selected)
                content = (cleaned + "\n\n" + new_block + "\n") if cleaned else (new_block + "\n")
            else:
                content = build_fresh_export_lua(selected)

            with open(export, "w", encoding="utf-8") as f:
                f.write(content)

            self.progress.show()
            self.progress.setValue(0)
            self._progress_step(0, f"Export.lua updated — {len(selected)} aircraft active.", GREEN)

        except Exception as e:
            self._err("Apply failed", str(e))
            self.set_status(f"Error: {e}", color=HL)

    def _progress_step(self, val, done_msg, done_color=GREEN):
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

    # ── Export / Import / Defaults ────────────────────────────────────────────

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

        # [1] Aircraft seçim dialogu — Uninstall (_ask) penceresi ile aynı stil
        dlg = QDialog(self)
        dlg.setWindowTitle("Reset to Defaults")
        dlg.setFixedWidth(340)
        dlg.setStyleSheet(f"""
            QDialog {{
                background-color: #111111;
            }}
            QLabel {{
                color: {FG};
                font-family: Consolas;
                font-size: 11pt;
                background: transparent;
            }}
            QCheckBox {{
                color: {FG};
                font-family: Consolas;
                font-size: 11pt;
                spacing: 8px;
            }}
            QCheckBox::indicator {{
                width: 16px; height: 16px;
                border: 2px solid {MUTED};
                border-radius: 3px;
                background: #000000;
            }}
            QCheckBox::indicator:checked {{
                background: {ACC};
                border: 2px solid {ACC};
            }}
        """)
        lay = QVBoxLayout(dlg)
        lay.setContentsMargins(20, 16, 20, 16)
        lay.setSpacing(8)

        lbl = QLabel("Select aircraft to reset to factory defaults:")
        lbl.setWordWrap(True)
        lay.addWidget(lbl)
        lay.addSpacing(6)

        aircraft_map = {label: key for label, key in AIRCRAFT if key in available}
        checkboxes = {}
        for label, key in AIRCRAFT:
            if key in available:
                cb = QCheckBox(label)
                cb.setChecked(False)
                lay.addWidget(cb)
                checkboxes[key] = cb

        lay.addSpacing(10)
        btn_row = QHBoxLayout()
        btn_cancel = QPushButton("Cancel")
        btn_ok     = QPushButton("Reset Selected")
        for btn, style in [
            (btn_cancel, f"background:#1e2a3a; color:{FG}; border:none; border-radius:6px; padding:6px 10px; font-family:Consolas; font-size:11pt;"),
            (btn_ok,     f"background:{HL}; color:white; border:none; border-radius:6px; padding:6px 10px; font-family:Consolas; font-size:11pt; font-weight:bold;"),
        ]:
            btn.setStyleSheet(style)
            btn.setCursor(Qt.PointingHandCursor)
        btn_cancel.clicked.connect(dlg.reject)
        btn_ok.clicked.connect(dlg.accept)
        btn_row.addWidget(btn_cancel)
        btn_row.addWidget(btn_ok)
        lay.addLayout(btn_row)

        # [1] Uninstall (_ask) ile aynı açılma konumu: ana pencerenin sağında
        dlg.show()
        dlg.adjustSize()
        geo = self.frameGeometry()
        dlg.move(geo.right() + 16, geo.top() + (geo.height() - dlg.height()) // 2)

        if dlg.exec_() != QDialog.Accepted:
            return

        selected_keys = [key for key, cb in checkboxes.items() if cb.isChecked()]
        if not selected_keys:
            return

        try:
            count = 0
            cr_dir = os.path.join(self.scripts_dir, "CockpitRandomizer")
            for key in selected_keys:
                fname = available[key]
                shutil.copy2(os.path.join(ddir, fname), os.path.join(cr_dir, fname))
                count += 1
            self.set_status(f"Reset to defaults — {count} aircraft restored.", color=GREEN)
            self._info("Reset complete",
                       f"{count} aircraft settings restored to factory defaults.")
        except Exception as e:
            self._err("Reset failed", str(e))
            self.set_status(f"Reset error: {e}", color=HL)

    def _json_search_dirs(self):
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
