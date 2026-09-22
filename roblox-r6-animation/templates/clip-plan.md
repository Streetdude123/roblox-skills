# Clip plan

Fill this in task notes. Keep only fields relevant to the request. Record unknowns that affect the result and ask about them before choosing values.

## Brief

- Action and intent:
- Style and supplied reference:
- Rig and inspected joint/prop setup:
- Duration and authoring FPS:
- Loop or one-shot:
- Player camera:
- Allowed world movement and planted contacts:
- Required impact, cancel, or transition times:
- Runtime and requested delivery:

## Reference evidence

| Source URL or asset path | Timestamp or frame range | FPS if known | Observed poses, spacing, and support | How inspected |
| --- | --- | --- | --- | --- |

## Beat table

Count at 60 fps.

| Frame / seconds | Intent and silhouette | Support or grip | Lead and secondary response | Endpoint path | Event |
| --- | --- | --- | --- | --- | --- |

## Motion layers

- Curve: `curve = "spline"`; keys marked `flat` and why:
- Moving holds (which hold, how far it drifts, 5 to 15%):
- Keyed follow-through of the leading parts (the key past the contact, the drift):
- `lag` per carried joint (frames):
- `springs` per carried joint (preset):
- Head: counters the torso on its frames, or trails as a carried part:
- `life` (degrees) and, for idles, the breath period:
- `post`: foot targets `{x, z, yaw}`, steps and pivots as functions of time; torso drop planned with each turn:
- Recovery: over-extended hold frames, pop-back frames, which part returns first:

## Contacts and transitions

| Part or prop contact | Coordinate space and target | Start and release time | Allowed slip or pivot | Check |
| --- | --- | --- | --- | --- |

- Incoming state and pose:
- Outgoing state and pose:
- Loop boundary pose and velocity:
- Joint ownership or overlay composition:
- Source observations versus new authoring choices:

## Measurements

| Revision | frozen% | still% / longest | rest% | stops/s | unison/s | contrast | spread | feet (corner, slide, hip gap) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |

Targets for a one-shot: frozen 0, still 5% or less and 0.1 s or less, rest 45% or less, contrast 2 to 10, stops 3/s or less, unison 5/s or less, planted corners within 0.03, slide 0.05 or less, hip gap 0.12 or less. A loop or a held pose: frozen 0.

## Review

| Revision | Time and view | Observed fault | Change and reason | Recheck result |
| --- | --- | --- | --- | --- |

- Source / instance path:
- Export path and settings:
- Authored:
- Measured (Poser.check, feet):
- Structurally checked:
- Visually reviewed:
- Runtime tested:
- User accepted:
- Remaining unverified items:
