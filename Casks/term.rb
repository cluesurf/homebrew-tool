cask "term" do
  name "Term"
  desc "The Term language: compiler, package manager and toolchain"
  homepage "https://term.surf"

  # `pnpm sync:term` rewrites `version` and the digests below from the
  # release on GHCR. Nothing else here changes between releases.
  version "2.10.2"

  # One release layer per platform, published by `pnpm term:release`
  # to ghcr.io/cluesurf/term/code. A layer's OCI digest IS the sha256 of
  # the tarball, so the same value is both the download address and the
  # checksum Homebrew verifies. Generated: keep the keys as they are.
  digests = {
    "darwin-arm64" => "0325590353ab446cf9ca29633d2ef729caeac21482f4a3025284a1ca5ed28e79",
    "darwin-x64"   => "27a33da278da30975b5d1aa9ab742c51d8cc96717c1a482fb74109cb51aacc53",
    "linux-arm64"  => "e9116bca46a50fa94bf33b7f487d887eef8ec62896c10d0f2c678da2169fd590",
    "linux-x64"    => "1389dba5ea86367dbf7e83bb515e7e34c738fdf30f4c4b60f81cb8cc085830b0",
  }

  arch arm: "arm64", intel: "x64"
  os macos: "darwin", linux: "linux"

  sha256 arm:          digests["darwin-arm64"],
         intel:        digests["darwin-x64"],
         arm64_linux:  digests["linux-arm64"],
         x86_64_linux: digests["linux-x64"]

  # Straight from the registry. GHCR serves a public package to this
  # fixed anonymous token, which is what Homebrew sends for its own
  # bottles on GHCR.
  url "https://ghcr.io/v2/cluesurf/term/code/blobs/sha256:#{digests["#{os}-#{arch}"]}",
      header: "Authorization: Bearer QQ=="

  livecheck do
    skip "Released through GHCR; `pnpm sync:term` in this tap keeps the version current"
  end

  # The payload is the Node build of term until the native binary ships
  # (note/term/self-host/09-distribution.md in the Term repository).
  depends_on formula: "node"

  # The launcher follows its own link back into the Caskroom, so it
  # finds the stdlib and node_modules unpacked beside it.
  binary "term/bin/term"

  caveats <<~EOS
    Homebrew updates this copy:
      brew upgrade cluesurf/tool/term

    `term self update` is for installs made with
      curl -fsSL https://term.surf/load | sh
  EOS
end
