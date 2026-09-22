# Moon Animator and the Roblox Animation Editor

## What is installed

Moon Animator 2 (asset 4725618216) is installed for Lepy's account at
`%LOCALAPPDATA%\Roblox\<userId>\InstalledPlugins\4725618216\` (two `Plugin.rbxm` versions of about 440 KB plus `settings.json`). Studio MCP cannot click a plugin's widgets, so Claude never operates Moon Animator directly. Claude works through the instances the plugin reads and writes.

## What the two tools read and write

- The Roblox Animation Editor loads a `KeyframeSequence` placed under a rig's `AnimSaves` (an ObjectValue named AnimSaves under the rig, KeyframeSequences as its children) and publishes it to an asset id. Lepy's community rigs (`BestWalkAnimR6.R6.AnimSaves`, the sword rig) use exactly this layout, and `Bake.lua` writes into it.
- Moon Animator saves its own files under `ServerStorage.MoonAnimator2Saves` when the user saves a project. The internal format has not been decoded yet; the first time Lepy saves a project, read that folder with `execute_luau` and record the layout here (folder per file, string values with encoded tracks is the expectation).
- Moon Animator exports through its File menu into `ServerStorage.MoonAnimatorExport` (KeyframeSequences per rig, or a published id when he chooses publish). Those exports are plain KeyframeSequences, so `ReadClips.lua` decodes them and a Clips entry can be generated from them.
- Moon Animator imports a published animation by asset id (its Import item), and the Animation Editor imports from AnimSaves, so the round trip is: Claude bakes to AnimSaves, Lepy publishes from the Animation Editor or loads it in Moon by id, polishes, exports, Claude reads the export back.

## The loop to use

1. Claude authors a clip in code, verifies it with a motion strip, and bakes it to the rig's AnimSaves.
2. Lepy opens the rig in Moon Animator or the Animation Editor, tweaks timing or poses, and exports a KeyframeSequence.
3. Claude runs ReadClips on the export, compares the curves with the code version, and either converts the export into the game's Clips module (`e = "linear"` keys at the export rate) or updates the code numbers to match what he changed.
4. Record what he changed in memory; it is the fastest way to learn his taste.

## To do when a Moon save exists

Read `ServerStorage.MoonAnimator2Saves` with execute_luau, dump every descendant class and string value length, and try `HttpService:JSONDecode` on the strings. If the format is readable, write a `MoonToClip.lua` and a `ClipToMoon.lua` so Claude can hand him editable Moon files instead of baked keyframes.
