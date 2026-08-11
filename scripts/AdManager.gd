# AdManager.gd
# Auto-loaded singleton for ad management
# 
# PRODUCTION: Replace stub methods with actual AdMob/AppLovin MAX SDK calls
# via Android plugin (https://github.com/Poing-Studios/godot-admob-android)
# 
# For now, this simulates ad behavior so the game flow works end-to-end.

extends Node

signal rewarded_ad_completed(reward_type: String, amount: int)
signal rewarded_ad_failed(reason: String)
signal interstitial_closed
signal banner_loaded

# Revenue tracking
var total_revenue := 0.0
var interstitial_counter := 0  # shows interstitial every 3rd game over

# AdMob IDs (replace with your real ones from AdMob dashboard)
const AD_UNIT_REWARDED := "ca-app-pub-3940256099942544/5224354917"  # Google's test ID
const AD_UNIT_INTERSTITIAL := "ca-app-pub-3940256099942544/1033173712"  # Google's test ID
const AD_UNIT_BANNER := "ca-app-pub-3940256099942544/6300978111"  # Google's test ID

# Test mode - keep TRUE during development, FALSE in production
var test_mode := true

func _ready() -> void:
	# In production: initialize AdMob SDK here
	print("[AdManager] Initialized (test_mode=", test_mode, ")")

# ---------- Rewarded Video Ads (70% of revenue) ----------

func show_rewarded_ad(reward_type: String) -> void:
	print("[AdManager] Showing rewarded ad for: ", reward_type)
	
	if test_mode:
		# Simulate ad playback (3 seconds)
		await get_tree().create_timer(3.0).timeout
		var amount := _get_reward_amount(reward_type)
		SaveManager.record_ad_watched()
		total_revenue += 0.025  # avg rewarded ad eCPM = $25 -> $0.025 per view
		rewarded_ad_completed.emit(reward_type, amount)
		print("[AdManager] Rewarded ad completed. Revenue: $", total_revenue)
	else:
		# PRODUCTION CODE (pseudocode):
		# AdMob.show_rewarded(AD_UNIT_REWARDED)
		# await AdMob.rewarded_earned
		# rewarded_ad_completed.emit(reward_type, amount)
		pass

func _get_reward_amount(reward_type: String) -> int:
	match reward_type:
		"extra_moves": return 5
		"level_skip": return 1
		"daily_bonus": return 50
		"double_coins": return 2
		_: return 1

# ---------- Interstitial Ads (20% of revenue) ----------

func show_interstitial() -> void:
	interstitial_counter += 1
	# Rule: show interstitial only every 3rd game over
	if interstitial_counter % 3 != 0:
		interstitial_closed.emit()
		return
	
	print("[AdManager] Showing interstitial ad (count=", interstitial_counter, ")")
	
	if test_mode:
		await get_tree().create_timer(2.0).timeout
		total_revenue += 0.012  # avg interstitial eCPM = $12 -> $0.012 per view
		interstitial_closed.emit()
		print("[AdManager] Interstitial closed. Revenue: $", total_revenue)
	else:
		# PRODUCTION:
		# AdMob.show_interstitial(AD_UNIT_INTERSTITIAL)
		# await AdMob.interstitial_closed
		# interstitial_closed.emit()
		pass

# ---------- Banner Ads (10% of revenue) ----------

func load_banner() -> void:
	print("[AdManager] Loading banner ad...")
	if test_mode:
		await get_tree().create_timer(1.0).timeout
		banner_loaded.emit()
	else:
		# AdMob.load_banner(AD_UNIT_BANNER, BannerPosition.BOTTOM)
		pass

func show_banner() -> void:
	print("[AdManager] Banner shown")
	# AdMob.show_banner()

func hide_banner() -> void:
	print("[AdManager] Banner hidden")
	# AdMob.hide_banner()

# ---------- Revenue / Stats ----------

func get_total_revenue() -> float:
	return total_revenue

func reset_revenue() -> void:
	total_revenue = 0.0
