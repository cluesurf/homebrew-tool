cask "term" do
  name "Term"
  desc "The Term language: compiler, package manager and toolchain"
  homepage "https://term.surf"

  # `pnpm sync:term` rewrites `version` and the digests below from the
  # release on GHCR. Nothing else here changes between releases.
  version "2.10.0"

  # One release layer per platform, published by `pnpm term:release`
  # to ghcr.io/cluesurf/term/code. A layer's OCI digest IS the sha256 of
  # the tarball, so the same value is both the download address and the
  # checksum Homebrew verifies. Generated: keep the keys as they are.
  digests = {
    "darwin-arm64" => "d12c773462546364b50ebb70abf70709ec71503ed9897b226c3180e39179b3d9",
    "darwin-x64"   => "0ac6a9cd9b82950118cc4a1b057b16db0b02bb6797478bd1091ba40c2813b184",
    "linux-arm64"  => "fe6a9813617931645844a03f55b0c0d726fc33c717d6b1c4314336fb817e2311",
    "linux-x64"    => "7ffbf95ef5472f590382054a661af2502a3a0e98c0685f1652c81cd0294e7f07",
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
