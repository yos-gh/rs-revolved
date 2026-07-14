# Rev Sweeper Revolved

Rev Sweeper Revolved is a Godot 4 port and reinterpretation of soy's Tonyu
System shooter "REV SWEEPER".

The game is a fixed-screen, all-range shooter built around mouse aiming,
an orbital weapon, dense enemy waves, and bullet-time pressure effects.

## Download

The latest Windows build is available from
[GitHub Releases](https://github.com/ysykiskw-gh/rs-revolved/releases/latest).

## Controls

The most recently used input device selects the control mode automatically.
Gamepad input hides the mouse cursor; keyboard or mouse input restores it.

### Keyboard and mouse

- Move: `WASD` or arrow keys
- Aim: mouse cursor
- Fire: hold the left mouse button
- Orbital Weapon: right mouse button
- Confirm: left mouse button or `Enter`
- Back/quit: `Esc`

### Gamepad

- Move: left stick or D-pad
- Aim direction: right stick
- Fire: `LB` or `LT`
- Orbital Weapon: `RB` or `RT`
- Confirm: `LB`, `LT`, A/Cross, or Start
- Back/quit: B/Circle or Back/Select

### Orbital Weapon

Press the Orbital Weapon control once to deploy it around the ship. Press it
again to launch it, and press it once more to recall it. While it is away from
the ship, you can alternate between launching and recalling it.

With a mouse, the weapon travels toward the cursor and returns after reaching
it. With a gamepad, use the right stick to steer the weapon's direction; it
returns after reaching the edge of the playfield. It also returns automatically
when its energy runs out.

### Common

- Fullscreen: `F11` or the title-screen fullscreen icon
- Debug collision display in development builds: `F2`

## Game Modes

- **Arcade:** Fight through increasingly intense enemy waves and boss battles
  in a finite run. Defeat the final boss to clear the game.
- **Endless:** Survive an unending stream of enemies at the selected difficulty.
  The run continues until all lives are lost.

## Scoring

Destroying enemies increases both your score and Tension. Higher Tension raises
the value of subsequent kills, but it gradually falls over time. Keep defeating
enemies to maintain your momentum and earn larger scores. Reaching score
milestones awards extra lives.

## Development

Required for normal development:

- Godot 4.7

Run the project from Godot using `scenes/main.tscn`.

Release exports can be generated with:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\export_release.ps1
```

The export script writes local build outputs under `export/`, which is ignored
by Git.

## License

The Godot port code and newly created project assets are released under the MIT
License. See `LICENSE`.

Original REV SWEEPER-derived runtime assets are redistributed under the
original REV SWEEPER license. See `REV_SWEEPER_ORIGINAL_LICENSE.txt` and
`THIRD_PARTY_NOTICES.md`.
