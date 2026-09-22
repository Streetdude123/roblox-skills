# Editor handoff

Use an editable source plus a verified KeyframeSequence or published asset according to the requested handoff. Keep source keys for later changes. A dense bake is a playback representation, not a native Moon Animator project.

## Inspect the installed workflow

Confirm the editor and version available in the current Studio session. Discover whether the connected tool can interact with plugin UI; do not assume it can or cannot. Inspect an existing save or a small test export before relying on a folder name or container class.

Earlier project sessions recorded `AnimSaves` under rigs, `ServerStorage.MoonAnimator2Saves`, and `ServerStorage.MoonAnimatorExport`. Treat these as locations to investigate, not a documented universal Moon Animator file format. The old notes and `Bake.lua` disagree about the AnimSaves container class. Confirm what the current editor can load.

The official Animation Editor supports animation editing and publication. Use its current documented workflow and actual UI. Verify asset ownership/access for the target experience when publishing. Do not invent an asset ID or report an upload from the presence of a local sequence alone.

## Round trip

1. Save the authored source and its timing/contact plan.
2. Export a separate sequence with the inspected rig hierarchy. Apply the baker checks in [pipeline.md](pipeline.md).
3. Load it using the installed editor's supported import workflow. If direct local import is unavailable, use a published asset only when that handoff is authorized.
4. Compare source and imported motion at contact, extreme poses, loop boundaries, and transitions. Check duration, priority, easing, keyed body coverage, and events.
5. After manual edits, preserve the editor's original project and inspect the actual export.
6. Use native playback when sparse easing, weights, or markers must be preserved. The bundled Poser importer is not a lossless conversion.
7. Recheck the final delivery in the intended runtime and record which checks were executed.

Do not overwrite an existing editor save with a guessed internal schema. Decode a real save only when the requested task needs that format and its structure can be established from actual files.
