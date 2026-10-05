#!/usr/bin/env tsx
/**
 * Sync Casks/term.rb with the newest Term release on GHCR.
 *
 * Reads the tags of ghcr.io/cluesurf/term/code (anonymously, the
 * way the cask itself downloads), takes the newest version, reads
 * its image index and each platform's manifest, and rewrites the
 * `version` line and the `digests` table of Casks/term.rb. A
 * release layer's digest is its tarball's sha256, so that table is
 * both the download address and the checksum.
 *
 * Run from this repo root, after `pnpm term:release` in the Term
 * repository:
 *
 *     pnpm sync:term              the newest release
 *     pnpm sync:term 2.6.2        one version
 *     pnpm sync:term <release.json>   the file `pnpm term:release` wrote, for a
 *                                     release whose package is not public yet
 *
 * It does NOT commit or push. That's a separate step.
 */

import { readFile, writeFile } from 'node:fs/promises'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'

const HERE = dirname(fileURLToPath(import.meta.url))
const ROOT = join(HERE, '..')
const CASK = join(ROOT, 'Casks', 'term.rb')

const REGISTRY = 'https://ghcr.io'
const REPOSITORY = 'cluesurf/term/code'
const HEADERS = { authorization: 'Bearer QQ==' }
const RELEASE_ARTIFACT_TYPE = 'application/vnd.cluesurf.term.release.v1'

// the cask's keys, and the OCI platform each is in the index
const PLATFORMS: Record<string, { os: string; architecture: string }> = {
  'darwin-arm64': { os: 'darwin', architecture: 'arm64' },
  'darwin-x64': { os: 'darwin', architecture: 'amd64' },
  'linux-arm64': { os: 'linux', architecture: 'arm64' },
  'linux-x64': { os: 'linux', architecture: 'amd64' },
}

const VERSION = /^\d+\.\d+\.\d+$/

async function get<T>(path: string, accept?: string): Promise<T> {
  const response = await fetch(`${REGISTRY}/v2/${REPOSITORY}/${path}`, {
    headers: accept ? { ...HEADERS, accept } : HEADERS,
  })

  if (!response.ok) {
    throw new Error(
      `${response.status} for ${REPOSITORY}/${path}${response.status === 401 ? ': is the package public on GHCR?' : ''}`,
    )
  }

  return (await response.json()) as T
}

function compare(a: string, b: string): number {
  const x = a.split('.').map(Number)
  const y = b.split('.').map(Number)

  return x[0]! - y[0]! || x[1]! - y[1]! || x[2]! - y[2]!
}

async function newestVersion(): Promise<string> {
  const { tags } = await get<{ tags?: string[] }>('tags/list')
  const newest = (tags ?? []).filter(tag => VERSION.test(tag)).sort(compare).at(-1)

  if (!newest) {
    throw new Error(`${REPOSITORY} has no released version`)
  }

  return newest
}

async function digestsOf(version: string): Promise<Record<string, string>> {
  const index = await get<{ manifests?: { digest: string; platform?: { os?: string; architecture?: string } }[] }>(
    `manifests/${version}`,
    'application/vnd.oci.image.index.v1+json',
  )
  const out: Record<string, string> = {}

  for (const [name, platform] of Object.entries(PLATFORMS)) {
    const entry = index.manifests?.find(
      one => one.platform?.os === platform.os && one.platform?.architecture === platform.architecture,
    )

    if (!entry) {
      throw new Error(`${version} has no ${name} release`)
    }

    const manifest = await get<{ artifactType?: string; layers?: { digest: string }[] }>(
      `manifests/${entry.digest}`,
      'application/vnd.oci.image.manifest.v1+json',
    )
    const layer = manifest.layers?.[0]?.digest

    if (manifest.artifactType !== RELEASE_ARTIFACT_TYPE || !layer?.startsWith('sha256:')) {
      throw new Error(`the ${name} manifest of ${version} is not a Term release`)
    }

    out[name] = layer.slice('sha256:'.length)
  }

  return out
}

function rewrite(text: string, version: string, digests: Record<string, string>): string {
  let out = text.replace(/^(\s*version\s+).*$/m, (_match, lead: string) => `${lead}"${version}"`)

  for (const [name, hex] of Object.entries(digests)) {
    out = out.replace(new RegExp(`("${name}"\\s*=>\\s*)"[0-9a-f]{64}"`), (_match, lead: string) => `${lead}"${hex}"`)
  }

  return out
}

// The digests from the `release.json` `pnpm term:release` writes beside the payloads it published. For the first
// sync of a release, before its GHCR package is public and readable anonymously
async function fromReleaseFile(file: string): Promise<{ version: string; digests: Record<string, string> }> {
  const release = JSON.parse(await readFile(file, 'utf8')) as { version: string; built: { platform: string; digest: string }[] }
  const digests: Record<string, string> = {}

  for (const name of Object.keys(PLATFORMS)) {
    const built = release.built.find(one => one.platform === name)

    if (!built?.digest.startsWith('sha256:')) {
      throw new Error(`${file} has no ${name} payload`)
    }

    digests[name] = built.digest.slice('sha256:'.length)
  }

  return { version: release.version, digests }
}

async function main(): Promise<void> {
  const asked = process.argv[2]
  const local = asked?.endsWith('.json') ? await fromReleaseFile(asked) : undefined
  const version = local?.version ?? asked ?? (await newestVersion())

  if (!VERSION.test(version)) {
    throw new Error(`${version} is not a version`)
  }

  const digests = local?.digests ?? (await digestsOf(version))

  console.log(`term version: ${version}`)

  for (const [name, hex] of Object.entries(digests)) {
    console.log(`  ${name.padEnd(13)} sha256:${hex}`)
  }

  const cask = await readFile(CASK, 'utf8')
  const next = rewrite(cask, version, digests)

  for (const hex of Object.values(digests)) {
    if (!next.includes(hex)) {
      throw new Error('a digest did not land in Casks/term.rb; its `digests` table no longer has the shape this expects')
    }
  }

  if (next === cask) {
    console.log('\nCasks/term.rb already in sync.')

    return
  }

  await writeFile(CASK, next)
  console.log(`\nWrote ${CASK.replace(ROOT + '/', '')}.`)
  console.log('Review the diff, then commit + push when ready:')
  console.log('  git add Casks/term.rb')
  console.log(`  git commit -m "term: ${version}"`)
  console.log('  git push')
}

await main()
