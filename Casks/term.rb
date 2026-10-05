cask "term" do
  name "Term"
  desc "The Term language: compiler, package manager and toolchain"
  homepage "https://term.surf"

  # `pnpm sync:term` rewrites `version` and the digests below from the
  # release on GHCR. Nothing else here changes between releases.
  version "2.6.12"

  # One release layer per platform, published by `pnpm term:release`
  # to ghcr.io/cluesurf/term/code. A layer's OCI digest IS the sha256 of
  # the tarball, so the same value is both the download address and the
  # checksum Homebrew verifies. Generated: keep the keys as they are.
  digests = {
    "darwin-arm64" => "f53550803d3557f305dd68ed0fd10148c0959dcc27395ee44eb55d5c48cdc62a",
    "darwin-x64"   => "c6882eb7a9a69ea6e0654f9fc60c3f933f776b3b1b9a5e5098847cb38b280d66",
    "linux-arm64"  => "59a60c6d18105af13869fa4de3a095692dfea00e225102f5179506026b45e79e",
    "linux-x64"    => "40669ce486a7f426b6c50460e9d8f90bfc94e19972d153df6d09793eff78de35",
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
