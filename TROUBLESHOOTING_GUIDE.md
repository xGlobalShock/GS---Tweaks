# Gaming Tweaks - Troubleshooting Guide

## Quick Diagnostics

### Issue: Tweaks Don't Apply
**Symptoms:** Click "Apply Tweaks" but nothing happens or get error messages

**Solutions:**
1. **Run as Administrator**
   - Right-click Launch.ps1 → Run as Administrator
   - Or right-click UI.exe → Run as Administrator

2. **Check UAC Prompt**
   - After clicking "Apply Tweaks", a blue UAC dialog should appear
   - Click "Yes" to confirm
   - If no dialog appears, check if UAC is disabled

3. **Check Antivirus**
   - Temporarily disable antivirus/Windows Defender
   - Some antivirus blocks registry modifications
   - Re-enable after testing

4. **Check Event Viewer for Errors**
   - Press Windows+R, type "eventvwr"
   - Check Application and System logs
   - Look for PowerShell errors

---

### Issue: Reset All Doesn't Work
**Symptoms:** Click "Reset All" but tweaks remain in registry

**Solutions:**
1. **Verify Reset Process Completed**
   - Check if green checkmarks appeared for each reset
   - If not, the script may have failed
   - Try again and watch for error messages

2. **Manual Registry Check**
   - Press Windows+R, type "regedit"
   - Navigate to registry paths listed below
   - Verify values are removed or reverted

3. **Restart Required**
   - Some tweaks require restart to fully revert
   - Restart PC and check again
   - Some values persist in memory until reboot

---

### Issue: Some Tweaks Show "Already Exists"
**Symptoms:** Apply tweaks, then apply again - some show "already exists"

**Expected Behavior:** ✅ This is NORMAL and safe
- Means the tweak is already applied
- Value will be overwritten (safe operation)
- System continues to work normally
- No action needed

---

### Issue: Error Message: "Registry Path Not Found"
**Symptoms:** Error when applying a specific tweak

**Causes & Solutions:**
1. **Windows Build Too Old**
   - Some tweaks require Windows 10 2004+
   - Update Windows and try again

2. **Registry Path Doesn't Exist**
   - Path may be removed/missing in your Windows version
   - Safe to skip, other tweaks will still apply
   - Not a system problem, just compatibility

3. **Insufficient Permissions**
   - Some tweaks require admin privileges
   - Run as Administrator and try again
   - Confirm UAC prompt

---

### Issue: PC Behaves Strangely After Tweaks
**Symptoms:** Game performance worse, input lag, or other issues

**Solutions:**
1. **Use Reset All Button (Recommended)**
   - Click "Reset All" to revert all tweaks
   - Wait for confirmation message
   - Restart PC
   - Problem should be resolved

2. **Manual Registry Reset**
   - Press Windows+R, type "regedit"
   - Locate values listed in REGISTRY REFERENCE section
   - Right-click and delete the value
   - Restart PC

3. **System Restore (Last Resort)**
   - Press Windows+R, type "rstrui"
   - Select restore point before tweaks
   - Follow prompts to restore

---

### Issue: Specific Game Performance Worse
**Symptoms:** A particular game runs slower or has lag

**Analysis:**
- Not all tweaks help all games
- Different games respond differently to tweaks
- This is expected and depends on game/hardware

**Solutions:**
1. **Reset Individual Tweaks**
   - Use Reset All button
   - Then apply tweaks selectively
   - Test each tweak to see which helps/hurts

2. **Test Without All Tweaks**
   - If performance is bad with all tweaks
   - Reset and apply one tweak at a time
   - Find which one(s) cause the problem

3. **Revert That Specific Tweak**
   - See REGISTRY REFERENCE section
   - Manual delete that specific registry value
   - Keep other tweaks for other games

---

### Issue: Mouse Feels Strange
**Symptoms:** Mouse movement feels sluggish or too fast

**Cause:** Mouse Acceleration disable tweak

**Solutions:**
1. **Temporary Disable**
   - Go to Settings > Devices > Mouse
   - Advanced mouse options > Pointer Options
   - Enable "Enhance pointer precision"
   - Or click Reset All

2. **Manual Disable in Mouse Settings**
   - Same location as above
   - Click box to enable/disable as needed

3. **Game Setting Override**
   - Most games have raw mouse input option
   - Enable in game settings for direct control

---

### Issue: USB Devices Not Working
**Symptoms:** USB mouse, keyboard, or peripherals stop responding

**Cause:** USB Suspend disable may be too aggressive

**Solutions:**
1. **Reset USB Suspend Only**
   - Registry: `HKLM:\SYSTEM\CurrentControlSet\Services\USB`
   - Delete `DisableSelectiveSuspend` value
   - Restart PC

2. **Device Manager Reset**
   - Right-click device in Device Manager
   - Select "Uninstall device"
   - Unplug USB device
   - Plug back in (Windows reinstalls)
   - Device should work normally

3. **Full Reset**
   - Click Reset All button
   - Restart PC
   - All USB devices should work

---

### Issue: Network Speed Slow
**Symptoms:** Internet speed reduced after tweaks

**Cause:** Network Interrupt tweak may need adjustment

**Solutions:**
1. **Reset Network Tweak Only**
   - Registry: `HKLM:\SYSTEM\CurrentControlSet\Services\NDIS\Parameters`
   - Delete `ProcessorThrottleMode` value
   - Restart PC

2. **Test Without Tweak**
   - Click Reset All
   - Run speed test
   - Compare with speed from before
   - Reapply other tweaks but not this one

---

## Registry Reference (For Manual Fixes)

### Tweak Locations & Values

#### IRQ8 Priority
- **Path:** `HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl`
- **Value:** `IRQ8Priority`
- **Applied:** = 1 (DWORD)
- **Default:** (not present)
- **Delete to Revert:** Yes

#### Network Interrupts
- **Path:** `HKLM:\SYSTEM\CurrentControlSet\Services\NDIS\Parameters`
- **Value:** `ProcessorThrottleMode`
- **Applied:** = 1 (DWORD)
- **Default:** (not present)
- **Delete to Revert:** Yes

#### GPU Scheduling
- **Path:** `HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers`
- **Value:** `HwSchMode`
- **Applied:** = 2 (DWORD)
- **Default:** (not present)
- **Delete to Revert:** Yes

#### Game DVR Disable
- **Path:** `HKCU:\System\GameConfigStore`
- **Value:** `GameDVR_Enabled`
- **Applied:** = 0 (DWORD)
- **Default:** = 1
- **Revert to:** 1

#### Fullscreen Optimizations
- **Path:** `HKCU:\System\GameConfigStore`
- **Value:** `GameDVR_FSEBehaviorMonitorEnabled`
- **Applied:** = 0 (DWORD)
- **Default:** = 1
- **Revert to:** 1

#### USB Suspend Disable
- **Path:** `HKLM:\SYSTEM\CurrentControlSet\Services\USB`
- **Value:** `DisableSelectiveSuspend`
- **Applied:** = 1 (DWORD)
- **Default:** (not present)
- **Delete to Revert:** Yes

#### Mouse Acceleration
- **Path:** `HKCU:\Control Panel\Mouse`
- **Values:**
  - `MouseSpeed = "0"` (Default: "1")
  - `MouseThreshold1 = "0"` (Default: "6")
  - `MouseThreshold2 = "0"` (Default: "10")
- **Revert to:** Set to default values

---

## How to Access Registry Editor

1. **Open Registry Editor:**
   - Press Windows+R
   - Type "regedit"
   - Press Enter

2. **Navigate to Path:**
   - Click in address bar at top
   - Paste path from above
   - Press Enter

3. **Find Value:**
   - Look for value name in right panel
   - Right-click to delete or edit

4. **Edit Value:**
   - Right-click → Modify
   - Change value as needed
   - Click OK

5. **Restart PC:**
   - Some changes require restart
   - Recommended after any registry changes

---

## Safety During Troubleshooting

### ✅ Safe Actions
- ✅ Use Reset All button
- ✅ Delete values you added
- ✅ Restart PC
- ✅ Disable tweaks in Settings

### ❌ Unsafe Actions
- ❌ Randomly deleting registry values
- ❌ Modifying system-critical values
- ❌ Using registry cleanup tools
- ❌ Disabling Windows services

---

## When to Seek Help

### Contact Needed If:
- ❌ Reset All doesn't work even after restart
- ❌ PC won't boot after tweaks
- ❌ Multiple system errors in Event Viewer
- ❌ Antivirus blocks all tweaks

### Information to Provide:
1. Windows version (Settings > System > About)
2. Error messages (exact text)
3. Which tweaks were applied
4. When problem started
5. What you've already tried

---

## Prevention & Best Practices

### Before Applying Tweaks
- ✅ Create System Restore point
- ✅ Close gaming applications
- ✅ Disable antivirus temporarily
- ✅ Run as Administrator

### After Applying Tweaks
- ✅ Restart PC for full effect
- ✅ Test in your primary game
- ✅ Monitor for issues 24+ hours
- ✅ Keep Reset All available

### Regular Maintenance
- ✅ Keep Windows updated
- ✅ Don't modify registry manually
- ✅ Use Reset All if testing tweaks
- ✅ Restart PC monthly

---

**Last Updated:** 2024
**Support:** See SAFETY_DOCUMENTATION.md for more info
