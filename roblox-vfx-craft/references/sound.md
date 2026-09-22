# Sound supporting VFX

Use when audio is requested or an existing audiovisual effect is being refined.
Keep the current audio architecture. Sound is a supporting design pass, not a
substitute for a readable world effect.

## Design and align

Choose roles: anticipation, motion, contact, body, and tail. Use only the roles the
brief needs. Align the audible onset with the actual action; a file's start may
contain silence. Leave space around important transients rather than stacking
several full-volume impacts.

Use positional audio for a world source when appropriate. Test from the caster,
target, and spectator distances. A loop needs a clean entry, seam, and exit. A
pitch-shifted impact may leave an unwanted long low-frequency tail; listen and
trim/fade the working copy intentionally.

Record normal-speed output. Review the visual action muted, then together with
audio. Inspect relative levels, unwanted masking, distortion, silent starts, and
abrupt tails. Do not impose the historical example's gain, rolloff, compression,
or EQ settings on unrelated assets.

## Asset and measurement evidence

Check permissions and loading in the target experience. Preserve source IDs when
repairing a working copy. A PlaybackLoudness trace can help locate an onset in
Studio; it is not a calibrated loudness meter or proof that a final mix is clean.

Measure peaks from the actual capture when needed. Sample peaks are not true-peak
measurements unless the analysis accounts for intersample peaks. Compressor settings
do not guarantee that a stack cannot clip. Listen as well as inspect measurements.

Connect sound completion and cancellation to the effect lifecycle. Restore only
owned mix state; overlapping casts must not reset each other's shared groups.

## Historical example

The original sword effect used separate bed and hit SoundGroups, short ducking,
and faded low-frequency hits. The summon used fewer layers. Their reported mix
settings and recordings belong to those projects; see project-history.md.

The original Mirelo and generated-sound notes described one plugin version. Check
current tools and supported duration before using them. Do not add or subscribe to
a service just because the old example used it.
