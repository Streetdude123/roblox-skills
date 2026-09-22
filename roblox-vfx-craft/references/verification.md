# Verifying an effect from Studio MCP

Claude cannot watch the effect play. Everything below is how to see it anyway.

## Before judging any look

- `settings().Rendering.QualityLevel = Enum.QualityLevel.Level21` (and `EditQualityLevel`) from the
  Client VM. Play mode ran at Level01 for an hour once: no bloom, no Neon glow, flat lighting, every
  capture dull and dark.
- Check `Lighting.BloomEffect.Threshold`: at 2 nothing ever glows. The reel place uses 0.55 / 32 / 1.
- Studio must be in front. A covered Studio stops rendering (viewport 1 x 1, RenderStepped never fires,
  captures time out); an unfocused Studio throttles to about 15 fps or freezes for whole seconds, so
  short-lived particles never appear and frame time reads are garbage. Measure two seconds of idle
  first and trust a run only when idle frames are 16 to 18 ms. Ask him to bring Studio to the front.

## Captures

- `screen_capture` with the same camera arguments as the previous call returns the previous image.
  Move the camera 0.1 stud on every call. Calls without camera arguments use the game camera and can
  also return stale frames in play.
- Tool round trips cost 10 to 30 s, so "capture two seconds later" never happens. Slow the sequence with
  the `TimeScale` attribute (8 to 10x), write the current phase to an attribute on the effect model,
  and poll for it inside one `execute_luau` (under 24 s per call) right before the capture.
- Sampling the state every second inside one call (positions, transparencies, emitter rates, light
  brightness) reads a timeline more reliably than captures.
- Billboards with AlwaysOnTop and other CoreGui layers never composite into a capture.
- Texture galleries and CoreGui pose sheets are unreadable in a capture; read properties instead.
- Two captures of a strip or a scene: three quarter from behind for anything the player sees from the
  default camera (stands, auras on the back), front three quarter for what an enemy sees.

## Profiling a cast

- Connect `RunService.RenderStepped` and keep the worst `dt` per 0.05 s slot from the cast; print once.
  Wrap suspicious calls with `os.clock` marks printed on one line and read them with the console tool.
- Lua time is rarely the cause. The summon's pop cost 3 ms of Lua and 57 ms of frame: the first draw of
  the stand meshes, the Neon ghost and the kit sprites. A second cast in the same session never hitches,
  so profile the FIRST cast of a fresh play session, and fix with a join-time warm-up (draw once at
  0.98 transparency for two frames, emit one invisible particle per emitter).
- `Kit.burst` clones and Debris are cheap; `materialize` tweening 60 parts is cheap. Do not cut pieces
  before measuring; he wants "no change in quality".

## Testing without input

- The server test hook: `player:SetAttribute("CastUlt", true)` or `CastStand` fires the request from
  a probe, since synthetic keys from the MCP never reach `UserInputService` reliably.
- Remotes cannot be fired from an `execute_luau` probe on the Edit VM; use the Client VM in play and
  `FireServer` from there, then poll attributes.
- `execute_luau` runs in its own VM: `require` of a live module returns a fresh copy, so live module
  state reads nil and hooks on the module table never reach the running effect. Add prints to the
  module source, push it, and read the console instead.
- Pushing a module while play runs is impossible (the Edit datamodel is unavailable); stop, push through
  the local HTTP source server, start, test.
- Watch the console for "not authorized" audio, `no vfx template <name>` warnings from `Kit.spawn`,
  and `summon failed` / `ultimate failed` from the `pcall` wrappers.
