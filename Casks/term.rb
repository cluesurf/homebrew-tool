cask "term" do
  name "Term"
  desc "The Term language: compiler, package manager and toolchain"
  homepage "https://term.surf"

  # `pnpm sync:term` rewrites `version` and the digests below from the
  # release on GHCR. Nothing else here changes between releases.
  version "2.8.2"

  # One release layer per platform, published by `pnpm term:release`
  # to ghcr.io/cluesurf/term/code. A layer's OCI digest IS the sha256 of
  # the tarball, so the same value is both the download address and the
  # checksum Homebrew verifies. Generated: keep the keys as they are.
  digests = {
    "darwin-arm64" => "d7db7a8c4feac70e253ef23b566db117fe68f865b5a3d0d45de3e7b8fca7ec61",
    "darwin-x64"   => "56e06a84023de25496b2a9f7c425e85fe1d8e0a133a9cb88f7922fd485af49f1",
    "linux-arm64"  => "14a708520e0f75a620391fcfa92c25be518bb23a0b3a0621bb2a18104a6a0113",
    "linux-x64"    => "ea8b8850ed88f6bdd3909c1232b21db09b01c606e27b49348ed216e6011faf60",
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
