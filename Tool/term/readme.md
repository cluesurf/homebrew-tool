<br/>
<br/>
<br/>

<h3 align='center'>cluesurf/tool/term</h3>
<p align='center'>
  The Term language: compiler, package manager and toolchain.
</p>

<br/>
<br/>

## Install

```bash
brew install cluesurf/tool/term
```

That taps `cluesurf/tool` and installs the cask. It downloads the
release for this machine straight from the Term registry,
`ghcr.io/cluesurf/term/code`, and checks it against the registry's
own digest. Term runs on Node, so Homebrew installs the `node` formula
alongside it.

Without Homebrew, the same release installs with:

```bash
curl -fsSL https://term.surf/load | sh
```

## Usage

```bash
term --help
term make        # build the project in this directory
term test        # run its tests
term load        # install its dependencies
term bind        # log in to term.surf, to publish
term host        # publish it
```

## Updating

```bash
brew upgrade cluesurf/tool/term
```

`term self update` is for installs made by `term.surf/load`; a Homebrew
copy says so and points here.

## Uninstall

```bash
brew uninstall --cask cluesurf/tool/term
```

## Releasing (maintainers)

1. `pnpm term:release` in the Term repository publishes every platform
   to `ghcr.io/cluesurf/term/code`.
2. `pnpm sync:term` here rewrites the cask's version and digests from
   that release.
3. Commit and push this tap.

## Related

- Cask: [`../../Casks/term.rb`](../../Casks/term.rb)
- Term: [term.surf](https://term.surf), [github.com/cluesurf/term](https://github.com/cluesurf/term)
