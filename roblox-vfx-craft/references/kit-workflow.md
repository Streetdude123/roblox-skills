# Work with supplied VFX packs

Use only the pack actually supplied to the current project. Keep original assets
intact while selecting and editing working copies. Prior project names and IDs
are examples in project-history.md, not an inventory of the current place.

## Inspect before adopting

Identify the exact pack root and list its models, parts, meshes, attachments,
emitters, beams, trails, textures, and sounds. Preview selected candidates alone.
Record the source path and the role each piece could serve.

Inspect executable content before integrating an imported art pack. The bundled
ScanPack.lua is a search aid, not proof that a model is safe. Review flagged source
and dependency behavior; keep unneeded executable content out of working copies.
Do not run a pack's installer merely to see an emitter.

Archive only the identified pack when requested or needed for the agreed workflow.
Do not move every unfamiliar Workspace child: it could be the user's map, rig, or
another system. ServerStorage removes client replication, not Studio/server memory.
A very large pack may need a separate saved model/project; verify that archive
before removing anything from the working place.

## Catalogue the useful subset

| Record | Why it matters |
|---|---|
| Original path and asset reference | Find the source and verify access later |
| Class and hierarchy | Know whether a helper accepts it |
| Local axes, pivot, bounds | Place and scale it correctly |
| Texture/flipbook layout | Avoid playing a sheet as one static image |
| Default emission and tail | Prevent auto-playing clones and premature destruction |
| Visual role | Select by design rather than by an attractive name |
| Verified status | Distinguish an inspected property from a rendered result |

View a small gallery of shortlisted meshes at their intended proportions and
textures on useful backgrounds. Inspect the actual asset, not a wall of tiny tiles.
A failed preload alone does not establish why something is invisible; check
permissions, content status, hierarchy, dimensions, and rendering together.

## Create editable working templates

Clone the chosen subset into the project's VFX template folder, usually under
ReplicatedStorage when clients must clone it. Keep only needed art Instances and
owned configuration. Disable automatic emission and trails until the preview fires.
Set carrier collision/query/touch/shadow behavior explicitly.

Preserve attachment references inside each template. Name layers by role. Keep
source provenance with the project. Use construction.md for a new Model template;
use modules.md for the BasePart-based bundled Kit contract.

Asset IDs from scripts/Emitters.lua are historical picks, not guaranteed public
assets. Check the real target experience. Report missing assets or request the
required source instead of substituting a different look silently.

## Preload and diagnose first use

Preload the selected effect's essential content, not the entire kit. Compare a
fresh-session first cast with later casts and inspect the profiler. If first-draw
work remains, try a bounded warm-up of the actual render path during an appropriate
loading phase and measure the result on the target device.

Invisible/offscreen draws may be culled or unloaded. A world-space draw does not
prove a ViewportFrame path is warm. Do not promise that two nearly invisible frames
fix every device or transfer a first-use hitch to an uncontrolled join-time spike.

## Audio and asset failures

Retain original IDs. Confirm an access failure in the target experience before
editing a working copy. Do not blank every sound in an unrelated pack. The bundled
BlankDeadSounds.lua mutates IDs and belongs only in a deliberate scoped repair.

Check both Studio and the intended runtime context when asset ownership differs.
Deliver the missing-asset list as a concrete limitation, not a silent success.
