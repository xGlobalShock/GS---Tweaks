# GlobalShock Tweaker - AI Coding Guide

## Project Overview

A Windows gaming optimization tool built with PowerShell + WPF UI for applying performance tweaks, managing Apex Legends configs, and handling OBS/NVIDIA utilities. The application uses VBScript launcher for elevation, a XAML-based modern UI, and modular PowerShell scripts.

## Architecture

### Entry Point & Elevation Pattern
- **[Launch.vbs](../Launch.vbs)**: VBScript launcher that elevates and executes [Settings/Launch.ps1](../Settings/Launch.ps1) with admin rights using `ShellExecute` with `"runas"`
- All scripts require elevation for registry/system modifications

### UI Architecture (WPF + PowerShell)
- **[UI/UI.xaml](../UI/UI.xaml)**: Main UserControl defining the entire interface (1326 lines)
  - Sidebar navigation with 4 sections: Gaming, Apex, OBS, NVIDIA
  - Multiple tabs per section (e.g., Gaming has PerfTweaks, PerfCleanup, ServicesOpt)
  - Custom styles: `SidebarButton`, `PrimaryActionBtn`, `PopupOKButtonStyle`
  - Dark theme with cyan accents (`#00A3FF`)
  
- **[Settings/Launch.ps1](../Settings/Launch.ps1)**: Main application logic (1786 lines)
  - Loads XAML using `XmlReader` and wraps UserControl in Window
  - Uses `FindName()` to access XAML elements: `$UserControl.FindName("ElementName")`
  - Event handlers attached via `Add_Click()` delegates
  - Contains two popup systems: `Show-InfoPopup` (info/config ready) and `Show-CacheResultPopup` (cleanup results)

### Script Organization

**Settings/** - Core application scripts
- `Launch.ps1`: Main UI logic, event handlers, popup systems
- `ButtonsFunction.ps1`: Deprecated dispatcher (functionality moved to Launch.ps1)
- `RegistryStatusChecker.ps1`: Reads registry to determine tweak status (Applied/Default)

**Tools/Tweaks/** - Gaming optimization scripts
- `GamingTweaks.ps1`: Main registry tweak handler with `-Type` parameter (IRQ, NET, GPU, CPU, USB, HPET, GameDVR, FullscreenOpt, USBSuspend)
- `ApexTweaks.ps1`: Apex Legends videoconfig modifications
- `ApexShaders.ps1`: Clears Apex shader cache
- `Clear*.ps1`: System cache cleanup utilities (Temp, Prefetch, MemDumps, UpdateCache)
- `DownloadNvidiaDriver.ps1`, `DownloadNvidiaApp.ps1`: NVIDIA utilities with progress reporting
- `NvidiaCache.ps1`: NVIDIA cache management

**Tools/OBS/** - OBS Studio presets
- `ImportScenes.ps1`: Copies preset scenes to `$env:APPDATA\obs-studio\basic\scenes`
- `Presets/`: OBS preset directories (OBS_Fully_Setup, OBS_Only, OBS_Streamelements, OBS_Streamelements_Multistream)

**Config/** - Application configuration
- `videoconfig.txt`: Optimized Apex Legends video settings template

## AI Agent Best Practices

### MCP Tool: Context7 (Library Documentation)

**Always retrieve fresh documentation before writing code** using the Context7 MCP tools:

#### Required Workflow for Any Code Implementation
1. **Identify Libraries**: Before writing any code, identify what libraries/frameworks you need to use
2. **Resolve Library ID**: Use `mcp_io_github_ups_resolve-library-id` to find the correct Context7-compatible library ID
3. **Fetch Documentation**: Use `mcp_io_github_ups_get-library-docs` with the resolved ID to get up-to-date docs
4. **Apply Best Practices**: Implement code using the retrieved documentation and best practices

#### When to Use Context7
- **Before implementing WPF/XAML features**: Get latest WPF documentation
- **Before PowerShell scripting**: Retrieve PowerShell module docs and cmdlet references
- **Before registry operations**: Check current registry manipulation best practices
- **Before working with .NET assemblies**: Get up-to-date .NET API documentation
- **Before file operations**: Review current file system best practices
- **When implementing new features**: Always check for modern approaches and APIs

#### Context7 Usage Pattern
```
1. Determine what you need to implement (e.g., "WPF DataGrid", "PowerShell async", "Registry monitoring")
2. Call resolve-library-id with library name (e.g., "dotnet/wpf", "PowerShell/PowerShell")
3. Call get-library-docs with the resolved ID and specific topic
4. Use mode='code' for API references and examples
5. Use mode='info' for conceptual guides and architecture
6. Implement code using the retrieved documentation
```

#### Example Scenarios
- **Adding XAML control**: Resolve `/microsoft/wpf` → Get docs on specific control → Implement with best practices
- **PowerShell async operations**: Resolve `/PowerShell/PowerShell` → Get docs on Jobs/Runspaces → Use modern patterns
- **Registry APIs**: Resolve `/dotnet/runtime` → Get docs on Microsoft.Win32.Registry → Safe implementation

### MCP Tool: Clear Thoughts (Structured Reasoning)

**Use Clear Thoughts tools for complex problem-solving and structured analysis**. These tools enhance code quality and decision-making through systematic reasoning.

#### Available Clear Thought Tools

**1. Sequential Thinking** (`mcp_clear_thought_sequentialthinking`)
- **Use for**: Breaking down complex implementations into logical steps
- **When**: Planning multi-file changes, architecting new features, debugging complex issues
- **Benefits**: Maintains context, allows revision, tracks progress
- **Example**: Planning the addition of a new game optimization section

**2. Mental Models** (`mcp_clear_thought_mentalmodel`)
- **First Principles Thinking**: Break down complex systems to fundamental truths (use when redesigning architecture)
- **Opportunity Cost Analysis**: Evaluate trade-offs between implementation approaches
- **Error Propagation Understanding**: Trace how errors flow through the system
- **Rubber Duck Debugging**: Systematically explain code logic to find issues
- **Pareto Principle**: Identify 20% of changes that deliver 80% of value
- **Occam's Razor**: Choose simpler solutions when multiple approaches exist

**3. Design Patterns** (`mcp_clear_thought_designpattern`)
- **Modular Architecture**: When separating concerns (UI/Logic/Data)
- **API Integration Patterns**: For NVIDIA API, OBS websocket, game config APIs
- **State Management**: Managing tweak status, UI state, registry states
- **Asynchronous Processing**: Background downloads, cache cleanup operations
- **Scalability Considerations**: Adding more games, more tweaks
- **Security Best Practices**: Handling elevation, registry modifications
- **Agentic Design Patterns**: Autonomous optimization agents

**4. Programming Paradigms** (`mcp_clear_thought_programmingparadigm`)
- **Procedural Programming**: Script-based tweaks (current pattern)
- **Object-Oriented Programming**: Refactoring to classes
- **Functional Programming**: Pipeline-based cache cleanup
- **Event-Driven Programming**: UI event handlers, file watchers
- **Reactive Programming**: Real-time status monitoring

**5. Debugging Approaches** (`mcp_clear_thought_debuggingapproach`)
- **Binary Search**: Finding which tweak causes issues
- **Reverse Engineering**: Understanding existing registry modifications
- **Divide and Conquer**: Isolating UI vs logic vs registry problems
- **Backtracking**: Reverting changes to find breaking point
- **Cause Elimination**: Systematically ruling out causes
- **Program Slicing**: Extracting relevant code paths for analysis

**6. Collaborative Reasoning** (`mcp_clear_thought_collaborativereasoning`)
- **Use for**: Complex architectural decisions requiring multiple viewpoints
- **Personas**: Security expert, Performance specialist, UX designer, PowerShell veteran
- **Benefits**: Catches edge cases, reveals trade-offs, builds consensus
- **Example**: Deciding on new popup system architecture

**7. Decision Framework** (`mcp_clear_thought_decisionframework`)
- **Use for**: Choosing between implementation approaches
- **Frameworks**: Pros-cons, weighted criteria, decision tree, expected value
- **Example**: Selecting UI framework (WPF vs WinUI vs Avalonia)

**8. Metacognitive Monitoring** (`mcp_clear_thought_metacognitivemonitoring`)
- **Use for**: Assessing knowledge boundaries and confidence levels
- **Prevents**: Implementing based on outdated knowledge
- **Action**: If confidence is low, use Context7 to get fresh documentation
- **Example**: Before implementing new registry tweak, assess knowledge of current Windows registry APIs

**9. Scientific Method** (`mcp_clear_thought_scientificmethod`)
- **Use for**: Performance optimization and testing
- **Process**: Hypothesis → Experiment → Measure → Analyze → Conclude
- **Example**: Testing if tweak X improves FPS by Y%

**10. Structured Argumentation** (`mcp_clear_thought_structuredargumentation`)
- **Use for**: Defending design decisions, evaluating alternatives
- **Pattern**: Thesis → Antithesis → Synthesis
- **Example**: Arguing for/against moving to HKCU vs HKLM registry locations

**11. Visual Reasoning** (`mcp_clear_thought_visualreasoning`)
- **Use for**: Understanding system architecture, data flows
- **Diagrams**: Component diagrams, sequence diagrams, state machines
- **Example**: Mapping the tweak application flow from UI → Script → Registry

#### Clear Thoughts Workflow Integration

**Before Starting Any Implementation:**
1. **Assess Knowledge** (Metacognitive Monitoring): Do I have up-to-date knowledge?
   - If NO → Use Context7 to get fresh documentation
   - If YES → Proceed with confidence level check
2. **Plan Approach** (Sequential Thinking): Break down the task into steps
3. **Consider Design** (Design Patterns): What pattern best fits this problem?
4. **Evaluate Options** (Decision Framework): If multiple approaches exist, analyze systematically

**During Implementation:**
1. **Apply Mental Models**: Use First Principles or Occam's Razor to simplify
2. **Check Paradigm Fit**: Am I using the right programming paradigm?
3. **Debug Systematically**: If stuck, use Debugging Approaches (Binary Search, Divide and Conquer)

**For Complex Decisions:**
1. **Collaborative Reasoning**: Simulate multiple expert perspectives
2. **Structured Argumentation**: Build thesis, challenge with antithesis, synthesize solution

**For Performance/Optimization:**
1. **Scientific Method**: Form hypothesis, design experiment, measure results

#### Example: Adding New Game Optimization

```
1. Metacognitive Monitoring: Assess knowledge of game config formats
2. Context7: Get documentation on game-specific APIs/config structures
3. Sequential Thinking: Plan steps (UI addition → Config parser → Registry tweaks → Testing)
4. Design Patterns: Apply Modular Architecture pattern
5. Decision Framework: Choose between JSON/INI/XML config storage
6. Implementation: Write code using Context7 documentation
7. Debugging Approach: Use Binary Search to isolate issues
8. Scientific Method: Test FPS improvement hypothesis
```

#### Critical Rule
**Never implement code without first using Context7 to verify current best practices and API documentation.** Technology evolves rapidly; outdated patterns lead to technical debt and bugs.

## Critical Patterns

### Registry Tweak Pattern
All tweaks use safe registry modification with verification:
```powershell
function Set-SafeRegistryValue {
    param([string]$Path, [string]$Name, [object]$Value, [string]$PropertyType = "DWORD")
    # 1. Verify path exists
    # 2. Set value with error handling
    # 3. Write status to console
}
```

Status checking pattern in `RegistryStatusChecker.ps1`:
```powershell
$irqValue = Get-ItemProperty -Path $regPath -Name "IRQ8Priority" -ErrorAction SilentlyContinue
if ($irqValue -and $irqValue.IRQ8Priority -eq 1) {
    $tweakStatus.IRQ = "Applied"
}
```

### Apply Tweaks Workflow (Launch.ps1, lines ~995-1170)
1. Check selected checkboxes (`$ChkIRQ.IsChecked`, etc.)
2. Query registry to detect already-applied tweaks
3. Show pre-apply popup with registry changes
4. Generate temp script with multiple tweak calls
5. Execute elevated: `Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File $tempScript" -Wait`
6. Sleep 2000ms for registry propagation
7. Refresh status badges via `Get-RegistryTweakStatus`

### Popup System
Two distinct popup implementations:

**Info Popup** (`Show-InfoPopup`):
- Parameters: `$title`, `$gridItems` (array of hashtables with 'name'/'value'), `$statusMessage`, `$pathToCopy`
- Special case: `$title -eq "Config Ready"` displays installation guide using RichTextBox
- Element names: `InfoPopupOverlay`, `InfoPopupContainer`, `InfoPopupTitle`, `InfoPopupMessage`, `InfoPopupDataGrid`

**Cache Result Popup** (`Show-CacheResultPopup`):
- Parameters: `$title`, `$description`, `$filesDeleted`, `$filesRemaining`
- Element names: `PopupOverlay`, `CacheResultPopupContainer`, `FilesDeletedCount`, `FilesRemainingCount`

### Script Output Protocol
Cleanup scripts use pipe-delimited output for structured data:
```powershell
Write-Output "NVIDIA_CACHE|$totalDeleted|$totalRemaining"
Write-Output "TEMP_CACHE|$totalDeleted|$totalRemaining"
```

Launch.ps1 parses: `if ($output -match "NVIDIA_CACHE\|(\d+)\|(\d+)") { ... }`

## Developer Workflows

### Testing Tweaks
1. Run [Launch.vbs](../Launch.vbs) with admin rights
2. Navigate to Gaming section → Performance Tweaks tab
3. Check desired tweaks and click Apply
4. Monitor console output in PowerShell window (use `-WindowStyle Normal` for debugging)
5. Use "Refresh Status" button to verify registry changes

### Adding New Tweak
1. Add registry logic to [Tools/Tweaks/GamingTweaks.ps1](../Tools/Tweaks/GamingTweaks.ps1) with new `-Type` value
2. Add status check to [Settings/RegistryStatusChecker.ps1](../Settings/RegistryStatusChecker.ps1)
3. Add checkbox to [UI/UI.xaml](../UI/UI.xaml) in appropriate section
4. Add UI binding in [Settings/Launch.ps1](../Settings/Launch.ps1):
   - FindName for checkbox
   - Add to Apply button handler logic (lines ~995-1170)
   - Add to status badge updates

### Debugging UI Issues
- XAML elements must have `x:Name` attribute to be accessible via `FindName()`
- Check element names are unique across entire XAML
- For button styling issues, inspect `SidebarButton`, `PrimaryActionBtn` styles
- Tab switching: Check Tag property (`Tag="Active"`) and Visibility toggling
- Popup not showing: Verify both Overlay and Container visibility set to "Visible"

## Project-Specific Conventions

### Naming
- PowerShell parameters: PascalCase (`-Type`, `-DownloadPath`)
- XAML element names: PascalCase with prefix (`BtnApply`, `ChkIRQ`, `SectionGaming`)
- Status badges: "Badge" + TweakName format (`BadgeIRQ`, `BadgeIRQText`)
- Script output protocols: UPPERCASE_SNAKE_CASE (`NVIDIA_CACHE`, `OPERATION_COMPLETE`)

### File Paths
- Relative navigation from script location: `Split-Path $PSScriptRoot`
- Config paths: `Join-Path $env:USERPROFILE "Saved Games\Respawn\Apex\Local\videoconfig.txt"`
- Temp scripts: `$env:TEMP\ApexTweaks_Temp_$(Get-Random).ps1`

### Error Handling
- Registry operations: Always use `-ErrorAction SilentlyContinue` with null checks
- Test paths before operations: `Test-Path $path`
- Safe registry pattern: Verify path exists, then modify with try/catch
- Clean up temp files: `Remove-Item -Force -ErrorAction SilentlyContinue`

### UI State Management
- Section navigation: Hide all sections, show target section, update button Tags
- Status badges: Update via `Update-StatusBadge` function with element names
- Checkbox state: Always check for null before accessing `.IsChecked`
- Popup closure: Remove event handlers or use fire-once pattern

## External Dependencies
- **Windows PowerShell 5.1+**: Required for WPF assemblies
- **Admin Rights**: All tweaks require elevation
- **NVIDIA Tools** (optional): nvidia-smi for GPU detection
- **OBS Studio** (optional): Scenes copied to `%APPDATA%\obs-studio\basic\scenes`

## Common Gotchas
- Registry changes require 2+ second delay before refresh (`Start-Sleep -Milliseconds 2000`)
- XAML must use `xmlns:x` namespace for `x:Name` attributes
- PowerShell UI event handlers don't automatically capture outer scope - pass via closure or script block parameters
- VBScript launcher doesn't return exit codes - use temp file for status communication if needed
- Popup RichTextBox requires Document.Blocks manipulation, not Text property
