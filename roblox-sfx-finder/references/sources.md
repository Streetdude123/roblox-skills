# Sound sources

Rule: CC0, or a site license that allows free use in a commercial game with no attribution. No
non-commercial (NC) licenses. No attribution-required licenses (CC-BY, credit-required sites).
Every file keeps its source, author, license and page in `candidates.json` and in the build's
`_credits.json`. Checked 2026-09-26.

## Web sources used by `find.py web`

| Key | Site | License | Quality | Access |
|---|---|---|---|---|
| `bigsoundbank` | BigSoundBank (La Sonothèque), Joseph Sardin | "Free and Royalty Free", CC0 equivalent | original FLAC, 24 bit 48 kHz | search page per word, `/UPLOAD/flac/<id>.flac` |
| `freesound` | freesound.org, search filtered to Creative Commons 0 | CC0 | hq preview MP3, 128 kbps; originals need a freesound login (OAuth) | search page, `data-mp3` preview |
| `mixkit` | Mixkit (Envato) | Mixkit Sound Effects Free License | full WAV 44.1 kHz | tag pages `/free-sound-effects/<tag>/` (no free text search), `/active_storage/sfx/<id>/<id>.wav` |
| `lab` | 効果音ラボ soundeffect-lab.info | site terms | MP3 192 kbps | `search.php?s=<Japanese>`; downloads need a Referer header |
| `kenney` | Kenney audio packs | CC0 | OGG, game-style | pack zips cached in `~/.cache/roblox-sfx/kenney`, matched on file names |

License evidence:
- BigSoundBank: "All files whose download pages mention 'Free and Royalty Free' ... are made available free of charge and freely for all your projects, whether commercial or not". Their license page says attribution is "Rien n'est obligatoire, mais fortement apprécié" (nothing is required) and compares it to CC0, WTFPL and public domain. Each sound page carries "CC0 (public domain): Free and royalty-free". https://lasonotheque.org/licenses.html
- 効果音ラボ: 「個人、法人、公的機関問わず無料で使用可能（商用利用無料）」 (free for commercial use); 「使用にあたっての報告、リンク、クレジット表記不要」 (no report, link or credit needed). Its listed uses include RPG Maker and WOLF RPG Editor games. Forbidden: redistribution (including content where the sound is the main point), use as AI training data, SFX showcase videos, sound trademark registration. https://soundeffect-lab.info/agreement/
- Mixkit: commercial and personal use, no attribution; files may not be redistributed or claimed as your own (license text loads by script on https://mixkit.co/license/; wording confirmed through search summaries and https://mixkit.co/llm-info/).
- Kenney: every pack page says "CC0 licensed". https://kenney.nl/assets/impact-sounds
- freesound: the search is filtered to `license:"Creative Commons 0"`, and each result shows "License: Creative Commons 0".

Upload rule for Mixkit and 効果音ラボ files: redistribution is forbidden, so the Roblox upload stays private (the default for uploaded audio) and is never shared on the Creator Store.

## Roblox Creator Store (`find.py roblox`)

- Search: `https://apis.roblox.com/toolbox-service/v1/marketplace/3?keyword=...&creatorTargetId=<id>&creatorType=1`. Details: `https://apis.roblox.com/toolbox-service/v1/items/details?assetIds=...`. No login is needed for either.
- Roblox docs: the store has "free-to-use audio assets made by Roblox and the Roblox community", including "more than 100,000 professionally-produced sound effects and music tracks". https://create.roblox.com/docs/audio/assets
- Licensed partner accounts, searched first:
  - `ProSoundEffects` (user 7462895450). Real recorded SFX with descriptive names. Results for single words: magic 829, sword 728, glass 1000+, explosion 328, punch 541, whoosh 1000+, cloth 840, bell 608, energy 789.
  - `APMOfficial` (user 7462718749). Mostly music and stings, plus some designed SFX such as "Whoosh Magic Spell" and "Whoosh Hit Thick Grit".
- The `Roblox` account (user 1) has only a few old sounds, such as swordslash.wav and glassbreak.wav.
- Community uploads are only shown with `--community` and are marked "ownership unverified". Many are ripped from games and commercial libraries (titles like "hl2 metal impact", "TF2 ...").
- Store audio cannot be downloaded without a login (`assetdelivery` returns 401). So a store sound cannot be measured or layered offline. It is used by ID as it is. It can be measured in Studio with `scripts/Audition.lua`.

## Checked and excluded

| Site | Reason |
|---|---|
| ポケットサウンド pocket-se.info | credit or link required unless paid ("作品でのクレジット表記、またはポケットサウンドへのリンクをお願いします") |
| 無料効果音で遊ぼう taira-komori.net | the terms page mentions a link requirement and forbids AI training; attribution terms are unclear |
| Pixabay, Zapsplat, Sonniss, OtoLogic | blocked by Cloudflare from the container (403) |
| YouTube, myinstants, voicy | blocked (bot check, Cloudflare) |
| OpenGameArt | mixed licenses per item, mostly CC-BY; not wired in |
| SoundBible | mixed licenses, including personal-use-only |
