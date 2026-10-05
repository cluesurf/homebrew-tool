cask "term" do
  name "Term"
  desc "The Term language: compiler, package manager and toolchain"
  homepage "https://term.surf"

  # `pnpm sync:term` rewrites `version` and the digests below from the
  # release on GHCR. Nothing else here changes between releases.
  version "2.6.4"

  # One release layer per platform, published by `pnpm term:release`
  # to ghcr.io/cluesurf/term/code. A layer's OCI digest IS the sha256 of
  # the tarball, so the same value is both the download address and the
  # checksum Homebrew verifies. Generated: keep the keys as they are.
  digests = {
    "darwin-arm64" => "3aedfe0ade3440a399bc95fe2449b9b608af49e2d178bbfb3ae68e2cf468b315",
    "darwin-x64"   => "c3862fd626d0e0f1564483ad429ab9f37d6cf482800294e2a199fd3ee5e06d7e",
    "linux-arm64"  => "57ca98cd434aac19ce9936dbe8f9eb10589c6237d57cde3dcc03102b942599c2",
    "linux-x64"    => "f2c49308a2b580cb5490aaa7a6067f63efab2c5ab92254eb3a91ebd6ad7fca26",
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
