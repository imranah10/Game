# 🚀 AURA BLOCKS — The 20-Year Mobile Game Master Blueprint

> **Mission:** Ek bina-login ka addictive puzzle game jo duniya bhar mein viral ho, ad-based earning kare, aur 10-20 saal tak chale — taaki tum millionaire ban jao.
>
> **Status:** Production-ready Godot 4 project + GitHub Actions auto-build setup
>
> **Last Updated:** 2026-08-11

---

## 📑 Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Game Concept & Unique Selling Proposition](#2-game-concept--unique-selling-proposition)
3. [Core Game Mechanics](#3-core-game-mechanics)
4. [Psychology & 20-Year Level Design](#4-psychology--20-year-level-design)
5. [No-Login Architecture](#5-no-login-architecture)
6. [Ad Strategy (Non-Intrusive, Maximum Revenue)](#6-ad-strategy-non-intrusive-maximum-revenue)
7. [Earning Mathematics & Millionaire Roadmap](#7-earning-mathematics--millionaire-roadmap)
8. [Viral Marketing Blueprint](#8-viral-marketing-blueprint)
9. [Tech Stack & Architecture](#9-tech-stack--architecture)
10. [Project Structure](#10-project-structure)
11. [GitHub Actions Auto-Build Setup](#11-github-actions-auto-build-setup)
12. [LiveOps — 10-20 Saal Chalne Ka Raaz](#12-liveops-10-20-saal-chalne-ka-raaz)
13. [Publishing to Play Store & App Store](#13-publishing-to-play-store--app-store)
14. [5-Year Millionaire Roadmap](#14-5-year-millionaire-roadmap)
15. [Risk Analysis & Mitigation](#15-risk-analysis--mitigation)
16. [Action Checklist](#16-action-checklist)

---

## 1. Executive Summary

**Aura Blocks** ek one-tap physics puzzle game hai jisme player glowing blocks ko drop karta hai. Same-tier blocks aapas mein takrate hain to merge ho jate hain, aur tier-6 blocks explode hokar chain reactions create karte hain. Game ko ASMR-style visuals aur satisfying sounds ke saath design kiya gaya hai — jaise kinetic sand ya pop-it ka sound.

### Key Highlights

| Feature | Detail |
|---------|--------|
| **Game Engine** | Godot 4.3 (Free, Open Source, Industry Standard) |
| **Platform** | Android (priority), iOS (future) |
| **Login Required** | ❌ NO — instant play, frictionless entry |
| **Monetization** | Rewarded Ads (70%) + Interstitial (20%) + Banner (10%) |
| **Ad Network** | AdMob via AppLovin MAX mediation |
| **Build System** | GitHub Actions — auto-build APK on every push |
| **Levels at Launch** | 15 (extends to 1000+ via procedural generation) |
| **Retention Hook** | 3-star system + weekly events + season pass |
| **Target Revenue** | ₹1-5 Crore/month at scale (10M downloads) |

---

## 2. Game Concept & Unique Selling Proposition

### Game Name: **AURA BLOCKS**

### Concept

Screen ke top se alag-alag rang ke glowing blocks girti hain. Player tap karta hai jahan wo chahta hai block drop ho. Block physics ke neeche girti hai, aur agar same-tier block ko touch karti hai, to dono merge hokar ek bada block ban jate hain.

### Tier System

```
Tier 1 (Red)    → Tier 2 (Orange) → Tier 3 (Yellow)
Tier 3 (Yellow) → Tier 4 (Green)  → Tier 5 (Blue)
Tier 5 (Blue)   → Tier 6 (Purple) → EXPLOSION! 💥
```

### Unique Selling Points (USPs)

1. **Aura Particles** — Har block ke around glowing particles hote hain jo merge hone par intensify hote hain. Yeh ASMR-style visual satisfaction deta hai.
2. **Chain Reactions** — Tier-6 block explode karta hai aur aas-paas ke blocks ko push karta hai. Agar ye push kisi aur merge ko trigger karta hai, to chain multiplier milta hai (1x → 1.5x → 2x → 2.5x...).
3. **Procedural Physics** — Har drop ka result alag hota hai kyunki physics engine real-time mein blocks ko simulate karta hai. Player ko kabhi bore nahi hota.
4. **No Two Playthroughs Same** — Randomized block spawns + physics chaos = infinite replay value.

### Visual & Audio Design

- **Colors:** Soft pastel with neon glow (calming + exciting)
- **Animations:** Smooth easing, elastic transitions
- **Sound Effects:** Synthesized "pop" for merge, deep "boom" for explosion, ascending chime for stars
- **Haptics:** Vibration on merge (15ms), explosion (50ms), star earned (30ms)
- **Music:** Ambient lo-fi loop during gameplay, triumphant chord on level complete

### Why People Will Love It

> "Sirf ek aur try... sirf ek aur try..." — Yahi feeling Candy Crush aur Angry Birds ko 10 saal chali. Same loop yahan bhi hai: drop → merge → chain → score. Easy to play, hard to master.

---

## 3. Core Game Mechanics

### Input

- **One-tap mechanic:** Tap anywhere above the drop zone to drop a block at that X position
- **No swipes, no complex gestures** — frictionless

### Block Behavior

| Property | Value |
|----------|-------|
| Physics body | RigidBody2D (Godot) |
| Gravity | 1200 px/s² |
| Linear damping | 0.5 (so blocks settle quickly) |
| Collision layer | 1 (all blocks collide with each other) |
| Resting threshold | velocity < 5 px/s for 1 second = "at rest" |

### Merge Detection

```
For each pair of blocks (b1, b2):
    if b1.tier == b2.tier AND b1.tier < 6:
        if distance(b1, b2) < (b1.radius + b2.radius) * 0.95:
            MERGE: b1 absorbs b2, becomes tier+1
            SCORE += base_score * chain_multiplier
            if new_tier == 6: TRIGGER EXPLOSION
```

### Explosion Mechanics

- Tier-6 block explodes 0.3s after formation
- Applies radial impulse to all blocks within 300px
- Force = 400 * (1 - distance/300) — closer blocks pushed harder
- Creates potential for cascading merges (chain combo)

### Scoring Formula

```
base_score = TIER_SCORES[tier1] + TIER_SCORES[tier2]
chain_multiplier = 1.0 + (chain_count - 1) * 0.5
final_score = int(base_score * chain_multiplier)
```

**Example:**
- 2x chain at tier 3+3 merge: (50+50) * 1.0 = 100 points
- 3x chain at tier 4+4 merge: (100+100) * 1.5 = 300 points
- 4x chain at tier 5+5 merge → explosion: (200+200) * 2.0 = 800 points

### Star Rating System

| Stars | Requirement |
|-------|-------------|
| ⭐ | Reach `target_score` |
| ⭐⭐ | Reach `two_star_score` (1.5x target) |
| ⭐⭐⭐ | Reach `three_star_score` (2.25x target) |

### Difficulty Modifiers (per level)

- `block_types` — number of distinct tiers that spawn (3-5)
- `moves` — total drops allowed (16-25)
- `target_score` — score needed to clear (500-10000)
- `special_blocks` — wind (pushes blocks), magnet (pulls blocks), frozen (can't merge until thawed)

---

## 4. Psychology & 20-Year Level Design

### The Difficulty Curve — "Frustration + Triumph" Loop

```
Easy ────────────────► Choke Point ────────────────► Triumph
(Hook)                 (Rage)                         (Addiction)
```

| Phase | Levels | Player Feeling | Design Goal |
|-------|--------|----------------|-------------|
| **Hook** | 1-5 | "Main genius hu!" | Easy wins, dopamine release |
| **Flow** | 6-10 | "Thoda mushkil ho raha hai..." | New mechanics introduced |
| **Burn** | 11-13 | "Sirf 1 move aur chahiye tha!" | 15-20 attempts per level |
| **Choke** | 14-15 | "Bhosdiwal! Ye level impossible hai!" | Rage-quit tempting, but they retry |
| **Triumph** | After clear | "MAIN... HOON... LEGEND!" | Dopamine burst = addiction locked |

### Why This Loop Creates Addiction

1. **Dopamine spike on victory** — 20 failed attempts ke baad jeetne par jo dopamine release hota hai, wo heroin jaisi feeling deta hai
2. **Sunk cost fallacy** — "Maine 15 baar koshish ki, ab chod ke nahi jaunga"
3. **Near-miss effect** — "Sirf 1 point kam tha!" — brain ye as "almost win" process karta hai, na ki "loss"
4. **Variable reward** — Procedural physics ka matlab har game alag result. Brain ko pata nahi kab milega, isliye continuous khelta hai

### 3-Star System — Free Replay Value

Player ko level clear karne par sirf 1 star milta hai. Perfectionist log 3 stars laane ke liye level baar-baar khelte hain. **Aapko extra ad views milte hain, bina naya content banaye.**

### Infinite Content Pipeline (10-20 Years)

```
Launch:      100 levels (manual design)
Month 3:     200 levels (manual + procedural assist)
Month 6:     500 levels (procedural generation with human review)
Year 1:      1000+ levels (full procedural + weekly events)
Year 2+:     Endless levels + community-created content
```

**Procedural Generation Approach:**
1. Define level "templates" (e.g., "tight squeeze", "chain master")
2. Randomize parameters within each template's difficulty range
3. Run auto-playtester AI to verify level is solvable
4. Human review for top 10% of levels (quality control)

---

## 5. No-Login Architecture

### Why No Login?

```
With Login:     User installs → Sign-up form → 60% drop-off → Never plays
Without Login:  User installs → Instant play → 95% try game → Hooked
```

Industry data: **Bina login wale games ka D1 retention 40% higher hota hai** than games with mandatory signup.

### How Progress Is Saved (No Login, No Cloud)

#### 1. Local Save (Primary)
- **File:** `user://save_data.json` (Godot's persistent directory)
- **Format:** JSON (human-readable, easy to debug)
- **Contents:** Levels completed, stars earned, coins, settings, stats
- **Auto-save:** After every level complete, every setting change, every ad watch

#### 2. Backup Code System (Cross-Device)
- Player goes to Settings → "Show Backup Code"
- A 6-digit code is generated and stored both locally AND in backend (Supabase free tier)
- On new device: Settings → "Restore Progress" → Enter 6-digit code → Progress restored
- **No email, no phone number, no friction**

#### 3. Device ID Tracking (For Analytics & Ads)
- Ad networks (AdMob/AppLovin) automatically use Android Advertising ID
- Analytics (GameAnalytics, Firebase) use anonymous device IDs
- You get all the data you need WITHOUT asking user for anything

### Save Data Schema

```json
{
  "version": 1,
  "levels_completed": { "1": 3, "2": 2, "3": 1 },
  "total_stars": 6,
  "total_score": 12500,
  "highest_level_unlocked": 4,
  "coins": 60,
  "sound_enabled": true,
  "music_enabled": true,
  "haptics_enabled": true,
  "ads_watched": 12,
  "backup_code": "482917",
  "settings": { "quality": "auto", "reduced_motion": false },
  "stats": {
    "games_played": 15,
    "total_play_time_sec": 3600,
    "chain_reactions": 8,
    "blocks_merged": 247
  }
}
```

---

## 6. Ad Strategy (Non-Intrusive, Maximum Revenue)

### Revenue Breakdown

```
┌─────────────────────────────────────┐
│  Rewarded Video Ads ───── 70% ────► │  User CHOSE to watch
│  Interstitial Ads ────── 20% ────► │  Forced, but timed
│  Banner Ads ─────────── 10% ────► │  Always present, low revenue
└─────────────────────────────────────┘
```

### 1. Rewarded Video Ads (The Goldmine) — 70% Revenue

**User khud ad dekhna chahta hai.** Yahan ads pareshan nahi karte, balki user ke kaam aate hain.

| Trigger | Reward | Conversion Rate |
|---------|--------|-----------------|
| Game Over (out of moves) | +5 extra moves | 85-90% |
| Level failed 10+ times | Skip level | 40-60% |
| Daily login | 50 coins | 60-70% |
| Unlock new skin | 5 ad views | 30-50% |
| Double daily coins | 2x coins | 50-60% |

**Implementation:** See `scripts/AdManager.gd` → `show_rewarded_ad(reward_type)`

### 2. Interstitial Ads — 20% Revenue

**Rule: Har 3rd game over ke baad hi.** Agar player continuously jeet raha hai, to ad mat dikhao (frustration badhega, retention girega).

```gdscript
# Pseudocode from AdManager.gd
func show_interstitial() -> void:
    interstitial_counter += 1
    if interstitial_counter % 3 != 0:
        return  # Skip this time
    # Show full-screen ad
```

### 3. Banner Ads — 10% Revenue

- 320×50 banner at bottom of menu screens (NOT during gameplay)
- Native ads blend with UI
- Passive earning, low friction

### eCPM Benchmarks (2026)

| Region | Rewarded eCPM | Interstitial eCPM | Banner eCPM |
|--------|---------------|-------------------|-------------|
| 🇺🇸 USA | $25-35 | $15-22 | $0.50-1.20 |
| 🇬🇧 UK | $18-25 | $10-15 | $0.40-0.80 |
| 🇧🇷 Brazil | $3-6 | $2-4 | $0.10-0.25 |
| 🇮🇳 India | $0.80-2.50 | $0.50-1.50 | $0.05-0.15 |
| 🌍 Global Avg | $8-12 | $5-8 | $0.25-0.50 |

### Ad Network Strategy

1. **Start with AdMob** (Google's ad network, easiest to integrate, 100% fill rate in most countries)
2. **After 50K DAU:** Switch to **AppLovin MAX** (mediation layer that pulls ads from 10+ networks, automatically picks highest-paying ad)
3. **After 500K DAU:** Add direct deals with brands for premium ad placements

### Ad SDK Integration (Godot)

Use this plugin: **[godot-admob-android](https://github.com/Poing-Studios/godot-admob-android)** by Poing Studios

```bash
# Installation
# 1. Download plugin from GitHub releases
# 2. Copy to res://addons/admob/
# 3. Enable in Project Settings → Plugins
# 4. Add your AdMob App ID to AndroidManifest.xml
# 5. Replace stub methods in AdManager.gd with real calls
```

---

## 7. Earning Mathematics & Millionaire Roadmap

### Scenario 1: Conservative (Most Likely Outcome)

**Assumptions:**
- Downloads: 100K (achievable for any decent game)
- DAU: 10% = 10,000 daily users
- Sessions/user/day: 3
- Ads/session: 1 rewarded + 1 interstitial = 2
- Average eCPM (global): $2.50 (mixed Tier 1 + Tier 3 traffic)

**Calculation:**
```
Daily ad impressions = 10,000 users × 3 sessions × 2 ads = 60,000
Daily revenue = (60,000 / 1000) × $2.50 = $150/day
Monthly revenue = $150 × 30 = $4,500/month (~₹3.75 lakh)
```

### Scenario 2: Realistic Viral Hit

**Assumptions:**
- Downloads: 1 Million
- DAU: 15% = 150,000 daily users
- Sessions/user/day: 4
- Ads/session: 2
- Average eCPM: $3.00 (more Tier 1 traffic from viral spread)

**Calculation:**
```
Daily ad impressions = 150,000 × 4 × 2 = 1,200,000
Daily revenue = 1,200 × $3.00 = $3,600/day
Monthly revenue = $3,600 × 30 = $108,000/month (~₹90 lakh)
```

### Scenario 3: Massive Viral Success (Top 1%)

**Assumptions:**
- Downloads: 10 Million
- DAU: 10% = 1 Million daily users
- Sessions/user/day: 4
- Ads/session: 2
- Average eCPM: $3.50 (premium traffic mix)

**Calculation:**
```
Daily ad impressions = 1,000,000 × 4 × 2 = 8,000,000
Daily revenue = 8,000 × $3.50 = $28,000/day
Monthly revenue = $28,000 × 30 = $840,000/month (~₹7 Crore)
```

### Millionaire Math

| Scenario | Monthly Revenue | Time to $1M (₹8.3 Cr) |
|----------|----------------|----------------------|
| Conservative (100K downloads) | $4,500 | 18.5 years (too slow) |
| Viral Hit (1M downloads) | $108,000 | 9 months |
| Massive Viral (10M downloads) | $840,000 | 6 weeks |

**Reality Check:** 99% of mobile games never reach 1M downloads. Top 0.1% reach 10M+. To become a millionaire:
1. **Launch 3-5 games** (not just one) — each has ~5% chance of going viral
2. **Focus on retention** — D1 retention > 40%, D7 > 15%, D30 > 5%
3. **Iterate fast** — use data from Analytics to improve
4. **Scale what works** — if one mechanic goes viral, build more games around it

---

## 8. Viral Marketing Blueprint

### The "Impossible Level" Strategy

Level 14 ("Choke Point") ko aise design karein jo bohot mushkil lage. TikTok/Reels par uska screen record karein with caption:

> "I bet 99% of people can't beat Level 14. Can you? 🔥 #AuraBlocks #Impossible #PuzzleGame"

### Content Pillars (3 Types of Viral Content)

#### Type 1: Rage Content (40% of posts)
- Player gets SO close to winning, then loses
- Caption: "When you're ONE move away from 3 stars 😭"
- Why it works: Empathy + curiosity ("Can I do better?")

#### Type 2: Satisfying Content (40% of posts)
- Perfect chain reaction that clears the whole board
- Caption: "This 5x chain reaction gave me goosebumps 🤤"
- Why it works: ASMR satisfaction + "I want to feel that too"

#### Type 3: Challenge Content (20% of posts)
- "Speedrun Level 10 in under 30 seconds" challenges
- Caption: "Think you're faster? Prove it. Download Aura Blocks 👆"
- Why it works: Competitive instinct + clear CTA

### Posting Schedule

| Platform | Frequency | Best Time (IST) |
|----------|-----------|-----------------|
| TikTok | 2-3x/day | 12pm, 6pm, 10pm |
| Instagram Reels | 1-2x/day | 7pm, 9pm |
| YouTube Shorts | 1x/day | 5pm |
| Twitter/X | 3-5x/week | Variable |

### Influencer Outreach Playbook

1. **Find micro-influencers** (10K-100K followers in gaming/puzzle niche)
2. **DM them personally** with: free game link + $50-200 for a 30-second mention
3. **Track installs** with custom referral codes (each influencer gets unique code)
4. **Scale what works** — if an influencer drives 5K+ installs, pay them $500 for dedicated video

### ASO (App Store Optimization)

| Element | Strategy |
|---------|----------|
| **Title** | "Aura Blocks: Merge Puzzle" (keyword + brand) |
| **Short Description** | "Drop. Merge. Chain. The most satisfying puzzle of 2026!" |
| **Long Description** | Keyword-rich (merge, puzzle, blocks, satisfying, ASMR, free, offline) |
| **Icon** | Bright glowing block with bold "AB" text — must pop at 64x64px |
| **Screenshots** | 1) Hero shot of chain reaction 2) Level select grid 3) "Satisfying merge" moment 4) "Challenge your friends" |
| **Tags** | Puzzle, Casual, Offline, Single Player, Free |

### Keywords to Target

```
Primary:   merge game, puzzle game, block game, casual game
Secondary: satisfying game, asmr game, time killer, offline game
Long-tail: games like candy crush, games like 2048, no wifi puzzle game
```

---

## 9. Tech Stack & Architecture

### Game Engine: Godot 4.3

**Why Godot over Unity?**
- ✅ 100% Free, no revenue share (Unity charges after $100K revenue)
- ✅ Open source, no licensing issues for CI/CD
- ✅ Lightweight (50MB vs Unity's 200MB+)
- ✅ GDScript is Python-like, easy to learn
- ✅ Excellent 2D physics engine (perfect for merge games)
- ✅ GitHub Actions builds work without licensing headaches

### Architecture Diagram

```
┌─────────────────────────────────────────────┐
│              AURA BLOCKS GAME               │
├─────────────────────────────────────────────┤
│  Scenes (UI Layer)                          │
│  ├── Main.tscn (main menu)                  │
│  ├── LevelSelect.tscn (level grid)          │
│  ├── Game.tscn (gameplay)                   │
│  │   ├── Block.tscn (individual block)      │
│  │   ├── HUD (score, moves, next block)     │
│  │   ├── GameOverUI (rewarded ad option)    │
│  │   └── LevelCompleteUI (stars animation)  │
│  └── Settings.tscn (sound/backup/restore)   │
├─────────────────────────────────────────────┤
│  Singletons (Autoloads)                     │
│  ├── GameManager (scene transitions)        │
│  ├── SaveManager (JSON local save)          │
│  ├── AdManager (AdMob integration)          │
│  ├── AudioManager (SFX + music + haptics)   │
│  └── LevelManager (level data loader)       │
├─────────────────────────────────────────────┤
│  Data                                       │
│  ├── levels.json (15 levels → 1000+)        │
│  └── user://save_data.json (player save)    │
├─────────────────────────────────────────────┤
│  Backend (Optional)                         │
│  └── Supabase (backup code sync, analytics) │
├─────────────────────────────────────────────┤
│  External Services                          │
│  ├── AdMob (ads)                            │
│  ├── Firebase Analytics (events)            │
│  └── GameAnalytics (player behavior)        │
└─────────────────────────────────────────────┘
```

### Third-Party Tools & Services

| Tool | Purpose | Cost |
|------|---------|------|
| Godot 4.3 | Game engine | Free |
| Godot AdMob Plugin | Ad SDK | Free |
| GitHub Actions | Auto-build APK | Free (2000 min/month) |
| GitHub Pages | Marketing site | Free |
| Supabase | Backup code backend | Free (500MB DB) |
| Firebase Analytics | Player tracking | Free |
| GameAnalytics | Player behavior | Free |
| AdMob | Ad network | Free (Google takes 18% cut of ad revenue) |

**Total startup cost: $0** 🎉

---

## 10. Project Structure

```
aura_blocks/
├── .github/
│   └── workflows/
│       ├── build-android.yml     # Auto-build APK on push
│       └── release.yml           # Create GitHub Release on tag
├── assets/
│   ├── fonts/                    # Custom fonts (optional)
│   ├── sounds/                   # ASMR sound effects
│   └── sprites/                  # Block textures, icons
├── data/
│   └── levels.json               # All level definitions
├── scenes/
│   ├── Main.tscn                 # Main menu scene
│   ├── LevelSelect.tscn          # Level grid
│   ├── Game.tscn                 # Gameplay scene
│   ├── Block.tscn                # Block prefab
│   └── Settings.tscn             # Settings screen
├── scripts/
│   ├── GameManager.gd            # Scene transitions, global state
│   ├── SaveManager.gd            # JSON local save
│   ├── AdManager.gd              # AdMob integration
│   ├── AudioManager.gd           # SFX, music, haptics
│   ├── LevelManager.gd           # Level data loader
│   ├── MainMenu.gd               # Main menu logic
│   ├── LevelSelect.gd            # Level grid logic
│   ├── Game.gd                   # Main gameplay controller
│   ├── Block.gd                  # Block physics & merging
│   ├── HUD.gd                    # In-game HUD
│   ├── GameOverUI.gd             # Game over screen
│   ├── LevelCompleteUI.gd        # Level complete screen
│   └── Settings.gd               # Settings logic
├── export_presets.cfg            # Android export config
├── project.godot                 # Godot project config
├── README.md                     # Setup & build instructions
└── BLUEPRINT.md                  # This file (masterplan)
```

---

## 11. GitHub Actions Auto-Build Setup

### How It Works

1. **Push code** to your GitHub repo (any branch)
2. GitHub Actions workflow runs automatically
3. Downloads Godot 4.3 engine + Android export templates
4. Builds debug APK
5. APK uploaded as downloadable artifact (30-day retention)

### Setup Steps

#### Step 1: Create GitHub Repository

```bash
cd aura_blocks/
git init
git add .
git commit -m "Initial commit: Aura Blocks game"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/aura-blocks.git
git push -u origin main
```

#### Step 2: Trigger Build

- **Automatic:** Push any code change → build runs in ~5-8 minutes
- **Manual:** Go to GitHub → Actions → "Build Android APK" → Run workflow

#### Step 3: Download APK

1. Go to GitHub repo → **Actions** tab
2. Click the latest workflow run
3. Scroll down to **Artifacts** section
4. Download `AuraBlocks-debug-apk.zip`
5. Unzip → install `AuraBlocks.apk` on Android phone

### File: `.github/workflows/build-android.yml`

Key features:
- ✅ Caches Godot engine (saves 3 minutes per build after first run)
- ✅ Auto-imports Godot project resources
- ✅ Builds debug APK by default, release APK via manual trigger
- ✅ Uploads APK + build log as artifacts
- ✅ Build summary in workflow output

### File: `.github/workflows/release.yml`

For versioned releases:
```bash
git tag v1.0.0
git push origin v1.0.0
```
This auto-creates a GitHub Release with the signed APK attached.

### Production: Signing the Release APK

For Play Store upload, you need a **release keystore**:

```bash
# Generate keystore (one-time)
keytool -keyalg RSA -genkeypair -alias aura_blocks \
  -keyalg RSA -keysize 2048 -validity 9125 \
  -keystore release.keystore

# Convert to base64 for GitHub Secrets
base64 release.keystore > keystore_base64.txt
```

Add these as **GitHub Secrets** (Settings → Secrets and actions → New repository secret):
- `ANDROID_KEYSTORE_BASE64` — content of `keystore_base64.txt`
- `ANDROID_KEYSTORE_USER` — `aura_blocks`
- `ANDROID_KEYSTORE_PASSWORD` — your keystore password

Then uncomment the "Decode release keystore" step in `release.yml`.

---

## 12. LiveOps — 10-20 Saal Chalne Ka Raaz

### Why Candy Crush Has Lasted 13+ Years

Candy Crush launches **45 new levels every Wednesday**. Without this, players would have finished all levels and left. **Content pipeline is the moat.**

### Your LiveOps Schedule

#### Weekly (Every Sunday)
- Add 10 new levels (use procedural generation, human-review top 20%)
- Featured "Level of the Week" (older level with bonus rewards)

#### Monthly
- New theme (Diwali rangoli, Christmas snow, Holi colors, monsoon)
- Limited-time event: "Chain Master Tournament" — compete for highest chain combo
- New block skin unlockable via gameplay

#### Quarterly (Season Pass)
- 30-level season with exclusive skins
- Free track: skins unlock at levels 5, 15, 25
- Premium track (real money OR 50 ad views): exclusive skins, no ads, bonus coins

#### Yearly (Major Updates)
- New game mode (e.g., "Endless Mode", "Daily Challenge", "Versus Mode")
- New block types (e.g., rainbow blocks that match anything, bomb blocks that explode on tap)
- Major UI overhaul (keeps game feeling fresh)

### Community Building

1. **Discord server** for players (free, easy to moderate)
2. **Reddit** subreddit (`r/AuraBlocks`)
3. **Twitter/X** account posting daily chain reaction clips
4. **Player-created levels** (Year 2+ roadmap) — let community design and share levels

### Data-Driven Decisions

Track these KPIs weekly:

| Metric | Target | Action if Below |
|--------|--------|-----------------|
| D1 Retention | > 35% | Improve onboarding (first 5 levels) |
| D7 Retention | > 15% | Add more early-game content |
| D30 Retention | > 5% | Add social features (leaderboards, friends) |
| Session length | > 8 min | Tune difficulty curve |
| Ads/user/day | > 3 | Add more rewarded ad triggers |
| ARPU (Avg Revenue Per User) | > $0.05/month | Improve ad placement strategy |

---

## 13. Publishing to Play Store & App Store

### Google Play Store

1. **Create Developer Account** ($25 one-time fee)
   - Go to https://play.google.com/console
   - Pay $25 registration fee
   - Verify identity (24-48 hour review)

2. **Generate Signed Release APK**
   ```bash
   # Push a version tag
   git tag v1.0.0
   git push origin v1.0.0
   # GitHub Actions builds signed APK automatically
   ```

3. **Create Store Listing**
   - Title: "Aura Blocks: Merge Puzzle"
   - Description: ~4000 chars (use BLUEPRINT.md keywords section)
   - Screenshots: 2-8 screenshots (min 320px, max 3840px)
   - Feature graphic: 1024×500 PNG
   - App icon: 512×512 PNG

4. **Submit for Review**
   - Fill content rating questionnaire (IARC)
   - Set pricing (Free)
   - Select ad networks (AdMob, AppLovin)
   - Submit → review takes 1-3 days

### Apple App Store (Year 2 Roadmap)

1. **Apple Developer Account** ($99/year)
2. **Mac required** (for code signing — rent MacinCloud $20/month if needed)
3. **Godot iOS export** — works similar to Android
4. **App Store Review** — stricter than Play Store (3-7 days, ~30% rejection rate)

---

## 14. 5-Year Millionaire Roadmap

### Year 1: Launch & Validate

| Quarter | Goal | Success Metric |
|---------|------|----------------|
| Q1 | Build MVP, soft-launch in India | 100 installs/day |
| Q2 | Polish based on feedback, add 200 levels | 1K DAU, D1 retention 30%+ |
| Q3 | Integrate AdMob, ASO optimization | 10K DAU, $50/day revenue |
| Q4 | Viral marketing push, TikTok strategy | 100K DAU, $500/day |

**Year 1 Revenue Target:** $50,000-150,000

### Year 2: Scale

- Hit 1M downloads
- Implement AppLovin MAX mediation
- Launch 2nd game using same engine (build a portfolio)
- Sign first influencer deals ($5K-20K per campaign)
- Add iOS version

**Year 2 Revenue Target:** $500K-1.5M

### Year 3: Portfolio & Diversification

- 3-5 games in portfolio
- Hire 2-3 developers (full-time or freelance)
- Direct brand deals for sponsorships
- Merchandise launch (T-shirts, plushies of game characters)

**Year 3 Revenue Target:** $1.5M-3M

### Year 4: Build Studio

- 10+ employees
- Launch first paid game (premium $2.99)
- Expand to other platforms (web, PC via Steam)
- Begin publishing other developers' games (publishing label)

**Year 4 Revenue Target:** $3M-6M

### Year 5: Empire

- 10+ games live
- Multiple revenue streams (ads + IAP + premium + merch + licensing)
- Possibly acquire or merge with another studio
- Net worth target: **$5M-15M (₹40-125 Crore)**

### Reality Check

This roadmap assumes:
- ✅ You execute consistently for 5 years
- ✅ At least 1 of your 5 games goes viral
- ✅ You reinvest 50%+ of revenue into new games
- ✅ You adapt based on data (kill failed projects fast)

**Probability of becoming a millionaire from mobile games:** ~2-5% for solo developers who ship 3+ games. Sounds low, but it's higher than the probability of becoming a millionaire from a salaried job (~0.5%).

---

## 15. Risk Analysis & Mitigation

### Technical Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| AdMob account banned | Low | Critical | Always follow AdMob policy, never click own ads, have AppLovin backup |
| Game crashes on certain devices | Medium | High | Test on 10+ device configs via Firebase Test Lab |
| Save data corruption | Low | Medium | JSON schema versioning, automatic backups to backend |
| Godot engine deprecation | Very Low | Low | Open source, community maintained, can pin to 4.3 forever |

### Business Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Game doesn't go viral | High (95%) | High | Ship 3-5 games, not just one. Each has ~5% viral chance |
| Ad revenue drops (e.g., ad blockers grow) | Medium | Medium | Add IAP as secondary revenue stream |
| Play Store policy change | Medium | High | Stay compliant, diversify to iOS, web, PC |
| Competitor copies your game | High | Medium | Move fast, build brand, focus on community |
| Burnout (working alone) | High | Critical | Hire help by Year 2, take breaks, ship small updates |

### Legal Risks

- **Copyright:** Don't use existing game assets, music, or characters. Generate your own.
- **Privacy Policy:** Required by Play Store if you collect any data (you do — analytics). Use a free generator.
- **GDPR/CCPA:** If users from EU/California, show consent dialog for ads. The AdMob plugin handles this.
- **Children's COPPA:** Don't target under-13 audience. Mark app as "Everyone" or "Teen" in Play Store.

---

## 16. Action Checklist

### Week 1: Setup

- [ ] Install Godot 4.3 on your computer (https://godotengine.org/download)
- [ ] Open `project.godot` in Godot editor → verify project loads
- [ ] Press F5 to run game in editor → verify main menu appears
- [ ] Create GitHub repo, push code
- [ ] Verify GitHub Actions build succeeds (Actions tab → green checkmark)
- [ ] Download APK artifact, install on Android phone, play test

### Week 2: Polish & Test

- [ ] Add real sound effects to `assets/sounds/`
- [ ] Add real app icon to `assets/sprites/icon.png` (512x512)
- [ ] Test all 15 levels — verify difficulty curve feels right
- [ ] Adjust level data in `data/levels.json` based on playtest
- [ ] Add 35 more levels (target: 50 at soft launch)

### Week 3: Monetization

- [ ] Sign up for AdMob (https://admob.google.com)
- [ ] Create AdMob app, get App ID
- [ ] Install godot-admob-android plugin
- [ ] Replace stub methods in `AdManager.gd` with real AdMob calls
- [ ] Test rewarded ad on device (use Google's test ad unit IDs first!)
- [ ] Generate release keystore, add to GitHub Secrets

### Week 4: Soft Launch (India only)

- [ ] Create Play Store listing
- [ ] Upload signed release APK/AAB
- [ ] Set pricing: Free
- [ ] Submit for review (1-3 days)
- [ ] Once approved, run $50-100 in ads to drive initial installs
- [ ] Monitor retention metrics for 7 days

### Week 5-8: Iterate

- [ ] Based on data, improve first 5 levels (where most users drop)
- [ ] Add 50 more levels (target: 100 at global launch)
- [ ] Start TikTok account, post 2-3 videos/day
- [ ] Reach out to 10 micro-influencers for sponsored content

### Week 9+: Global Launch

- [ ] Push major update with marketing push
- [ ] Run $500-1000 in user acquisition ads
- [ ] Track virality (K-factor = organic installs / paid installs)
- [ ] If K > 1: viral! Scale marketing. If K < 0.5: iterate game mechanics.

### Ongoing (Forever)

- [ ] Add 10 new levels every week
- [ ] Post 2-3 TikToks daily
- [ ] Review analytics weekly, ship updates monthly
- [ ] Save 50% of revenue for next game development
- [ ] Start Game #2 once Game #1 hits $5K/month revenue

---

## 🎯 Final Word

Bhai, sabse bada raaz **"Code" nahi hai — sabse bada raaz "Psychology" hai.**

Agar tum us 1 minute ke frustration aur 1 second ki khushi ka loop banane mein successful ho gaye, toh tum aage sari zindagi paisa hi kamate rahoge.

Candy Crush 13 saal se chal raha hai kyunki usne ek **dopamine loop** banaya hai. Angry Birds 16 saal se chal raha hai kyunki usne ek **rage-quit-and-retry** loop banaya hai.

**Aura Blocks mein dono hain:**
- ASMR satisfaction (merge, chain, glow) → dopamine
- "Sirf 1 move aur chahiye tha!" → rage-quit-retry loop

Yeh blueprint tumhare paas hai. Ab baari hai **execution** ki.

> "Ideas are cheap. Execution is everything."
> — Every millionaire ever

**All the best bhai! Millionaire ban ke dikhao! 🚀💰**

---

*Document version: 1.0 | Last updated: 2026-08-11 | Project: Aura Blocks*
