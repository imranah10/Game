# 🎮 Aura Blocks

> A no-login, ad-based, hyper-addictive mobile puzzle game built with Godot 4.
> Drop blocks. Merge same colors. Trigger chain reactions. Repeat.

![Status](https://img.shields.io/badge/status-ready_to_build-green)
![Engine](https://img.shields.io/badge/engine-Godot_4.3-blue)
![License](https://img.shields.io/badge/license-MIT-brightgreen)

## 📱 What Is This?

**Aura Blocks** is a Candy Crush + Angry Birds inspired puzzle game designed to be:
- ✅ **Frictionless** — no signup, no login, instant play
- ✅ **Addictive** — one-tap mechanic with chain reactions
- ✅ **Profitable** — non-intrusive ad-based monetization
- ✅ **Long-lasting** — 20-year content pipeline via procedural generation
- ✅ **Auto-buildable** — push code → GitHub Actions builds APK

## 🚀 Quick Start

### Option A: Build APK via GitHub Actions (Recommended)

You don't even need to install Godot locally!

```bash
# 1. Create a new GitHub repo and push this code
git init
git add .
git commit -m "Initial commit: Aura Blocks"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/aura-blocks.git
git push -u origin main

# 2. GitHub Actions auto-builds APK on push!
#    Go to: GitHub repo → Actions tab → latest run → Artifacts → download APK
```

**Build time:** ~5-8 minutes (cached after first run: ~3 minutes)

### Option B: Run Locally in Godot Editor

1. **Install Godot 4.3** from https://godotengine.org/download
2. **Open project:** Launch Godot → Open → select `project.godot`
3. **Run:** Press `F5` (or click Play button)
4. **Test gameplay:** Tap to drop blocks, watch them merge!

### Option C: Build APK Locally

1. Install Godot 4.3 + Android export templates
2. Install Android SDK (Android Studio)
3. Configure keystore in Editor Settings
4. Project → Export → Android → Export Project

## 🎯 How to Play

1. **Tap anywhere** on the screen above the danger line to drop a block
2. **Same-color blocks merge** when they touch (tier 1 → 2 → 3 → 4 → 5 → 6)
3. **Tier 6 blocks explode!** Creates chain reactions for massive score multipliers
4. **Reach the target score** before running out of moves to clear the level
5. **Earn 3 stars** by scoring way above the target

### Tips for High Scores

- Aim for **chain reactions** — they multiply your score (1x → 1.5x → 2x → 2.5x...)
- Build **higher tier blocks** before triggering explosions
- Use **explosions** to push blocks into merge positions
- **Watch rewarded ads** for extra moves when stuck (also supports the developer! 😄)

## 📁 Project Structure

```
aura_blocks/
├── .github/workflows/
│   ├── build-android.yml     # Auto-build APK on push
│   └── release.yml           # Release APK on tag
├── assets/                   # Sounds, sprites, fonts
├── data/
│   └── levels.json           # 15 levels with difficulty curve
├── scenes/                   # Godot scene files (.tscn)
│   ├── Main.tscn             # Main menu
│   ├── LevelSelect.tscn      # Level grid
│   ├── Game.tscn             # Gameplay
│   ├── Block.tscn            # Block prefab
│   └── Settings.tscn         # Settings screen
├── scripts/                  # GDScript files
│   ├── GameManager.gd        # Global state, scene transitions
│   ├── SaveManager.gd        # Local JSON save system
│   ├── AdManager.gd          # AdMob integration (with stub for testing)
│   ├── AudioManager.gd       # SFX, music, haptics
│   ├── LevelManager.gd       # Level data loader
│   ├── Game.gd               # Main gameplay controller
│   ├── Block.gd              # Block physics & merging
│   └── ...                   # UI scripts
├── export_presets.cfg        # Android export config
├── project.godot             # Godot project config
├── BLUEPRINT.md              # 20-year masterplan (MUST READ!)
└── README.md                 # This file
```

## 🔧 Configuration

### Change App Name / Package ID

Edit `export_presets.cfg`:
```
package/unique_name="com.aurablocks.game"
package/name="Aura Blocks"
```

### Add More Levels

Edit `data/levels.json` — add new level objects following the schema:
```json
{
  "id": 16,
  "name": "New Level",
  "description": "...",
  "target_score": 12000,
  "two_star_score": 18000,
  "three_star_score": 27000,
  "moves": 16,
  "block_types": 5,
  "grid_rows": 8,
  "grid_cols": 6,
  "special_blocks": ["wind", "magnet", "frozen"],
  "difficulty": "hard"
}
```

### Enable Real Ads (Production)

1. Sign up at https://admob.google.com
2. Create an app, get your App ID
3. Install the [godot-admob-android](https://github.com/Poing-Studios/godot-admob-android) plugin
4. Replace the test ad unit IDs in `scripts/AdManager.gd` with your real IDs
5. Set `test_mode = false` in `AdManager.gd`
6. ⚠️ **Never click your own ads in production** — Google will ban your account

## 📊 Revenue Model

| Ad Type | Revenue Share | Trigger |
|---------|---------------|---------|
| Rewarded Video | 70% | "Watch ad for +5 moves" / "Skip level" |
| Interstitial | 20% | Every 3rd game over |
| Banner | 10% | Bottom of menu screens |

See `BLUEPRINT.md` → Section 7 for full earning math and 5-year millionaire roadmap.

## 🎨 Customization

### Colors

Edit `scripts/Block.gd` → `TIER_COLORS`:
```gdscript
const TIER_COLORS := {
    1: Color(0.95, 0.35, 0.35),   # red
    2: Color(0.95, 0.65, 0.30),   # orange
    # ... change these
}
```

### Sounds

Drop `.wav` or `.ogg` files in `assets/sounds/` and update `AudioManager.gd` to load them.

### Difficulty

Edit `data/levels.json` — adjust `moves`, `target_score`, `block_types` per level.

## 🚢 Publishing to Play Store

See `BLUEPRINT.md` → Section 13 for full publishing guide.

Quick version:
1. Generate release keystore
2. Add keystore to GitHub Secrets
3. Push a tag: `git tag v1.0.0 && git push origin v1.0.0`
4. GitHub Actions builds signed APK + creates GitHub Release
5. Download signed APK, upload to Play Console

## 📚 Documentation

- **[BLUEPRINT.md](BLUEPRINT.md)** — Full 20-year masterplan with earning math, marketing strategy, LiveOps schedule, and 5-year millionaire roadmap. **READ THIS FIRST!**

## 📄 License

MIT License — do whatever you want with this code. Attribution appreciated but not required.

## 🙏 Credits

Built with:
- [Godot Engine](https://godotengine.org) — Free and open source game engine
- [godot-ci](https://github.com/barichello/godot-ci) — Inspiration for GitHub Actions setup
- [godot-admob-android](https://github.com/Poing-Studios/godot-admob-android) — AdMob plugin

---

**Made with ❤️ for indie game developers who want to build something viral.**
