cask "rock" do
  name "Rock"
  desc "A Hackable Terminal ⊡"
  homepage "https://github.com/cluesurf/rock"
  version "0.1.2"

  # URL uses #{version} interpolation so ship.sh only has
  # to rewrite the `version` and `sha256` lines on each
  # release — the URL self-updates from there. The published
  # artifact is a zipped Rock.app from `electron-builder
  # --mac` uploaded to GitHub Releases.
  url "https://github.com/cluesurf/rock/releases/download/v#{version}/Rock-#{version}-arm64-mac.zip"

  # ship.sh rewrites this hash on every release. :no_check
  # is the initial value before the script has run.
  sha256 "230b894f17a59ee5e680ac5108b08c832d70b7da232e415df26b7c4a5baf0469"

  # livecheck tells brew (and `brew upgrade --cask`) where
  # to look for new versions. Uses the GitHub Releases tag
  # list as the source of truth.
  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on macos: ">= :catalina"

  app "Rock.app"

  # CLI companion — symlinks Rock.app's bundled bash launcher
  # to /usr/local/bin/rock so users can `rock` from any
  # terminal. The script execs Rock.app's bundled Electron
  # with ELECTRON_RUN_AS_NODE=1 (no Node runtime needed).
  # Subcommands: rock, rock open, rock bind, rock list,
  # rock send, rock focus, rock spawn, rock kill, rock doctor,
  # rock install theme claude.
  binary "#{appdir}/Rock.app/Contents/Resources/rock"

  # Rock.app is currently signed with an ad-hoc signature
  # (no Apple Developer ID). Gatekeeper would otherwise
  # block first launch with "Apple could not verify…".
  # Strip the quarantine attribute on install so the cask
  # works without the user manually right-click → Open.
  # Once we have a Developer ID signature + notarization,
  # this block can come out.
  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/Rock.app"]
  end

  zap trash: [
    "~/Library/Application Support/Rock",
    # New (surf.clue.rock) — current app bundle ID.
    "~/Library/Preferences/surf.clue.rock.plist",
    "~/Library/Saved Application State/surf.clue.rock.savedState",
    # Legacy (com.cluesurf.rock) — pre-0.0.5 installs.
    # Kept here so brew zap cleans up upgraders' old files
    # too. Safe to remove once nobody's running <= 0.0.4.
    "~/Library/Preferences/com.cluesurf.rock.plist",
    "~/Library/Saved Application State/com.cluesurf.rock.savedState",
    "~/Library/Logs/Rock",
    "~/.rock",
  ]

  caveats <<~EOS
    Rock is a hackable terminal.

    For project-specific workspaces, bind rock to a project:
      cd ~/code/your-project
      rock bind

    Or open the default workspace:
      rock

    Match Claude Code's theme to Rock:
      rock install theme claude
  EOS
end
