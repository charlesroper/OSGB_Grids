# OSGB Grids

Repository for the OSGB_Grids dataset: seven tile sizes, 100km to 1km,
in Shapefile and GeoParquet (OSGB 1936) and GeoJSON (WGS84). The data
includes `LETTER_REF` on the 25km layer and four corrected 25km labels,
so it can differ from older copies and forks. License: CC0; keep
`LICENSE.txt`.

Not an application codebase. There is no build or test step; validation
means checking the data, as described below.

## Layout

- `GeoJSON/` — EPSG:4326, one file per tile size.
- `Shapefile/` — EPSG:27700, one sidecar set per tile size.
- `GeoParquet/` — EPSG:27700, GeoParquet 1.0 with `geometry` column, ZSTD.
- `README.md` — canonical documentation: formats, counts, fields, and
  tile refs.
- `sql/` — DuckDB queries that rebuild derived fields.

## Environment

- Resolve tools with `command -v`. Also check `$XDG_BIN_HOME`,
  `~/.local/bin`, and `/usr/local/bin`; use the full path when found. Do not
  edit shell startup files.
- `terrio` 0.4+ is preferred for metadata, validation, and conversion. If
  missing and installation is possible, use the official installer
  (`curl -LsSf https://terrio.opengeos.org/install.sh | sh` on POSIX, or
  the PowerShell installer on Windows), `pip install terrio`, or
  `uv tool install terrio`.
- DuckDB v2+ is preferred for SQL. If missing and installation is possible,
  use `curl https://install.duckdb.org | bash`, a package manager, or
  `pip install duckdb`.
- GDAL is optional, not assumed. `ogrinfo`/`ogr2ogr` may be absent. Install
  `gdal-bin`/`brew install gdal` only if needed and permitted.
- Harness features (`ctx_*`, code indexes, ProjectMem) are optional. Use
  them when present; never depend on them.
- If a tool cannot be installed, do not block: use an available equivalent
  and say which one. If the environment cannot change at all (no network,
  no permissions), continue with what is installed and state the gap.
- Ask before system-wide installs or shell changes. Prefer user-local
  installs.

## Reading data

- Check size first: `ls -lhS` or `du -h`.
- Never load a data file whole into context. Sizes range from a few KB to
  93 MB; 5km GeoJSON alone is 5 MB. The worst are
  `GeoJSON/OSGB_Grid_1km.geojson` (~93 MB), `Shapefile/OSGB_Grid_1km.shp`
  (~38 MB), and the 1km `.dbf`/`.shx` (MB each).
- Peek with `head -c 2000`. For a structured sample, run
  `terrio convert IN "${TMPDIR:-/tmp}/sample.geojson" --limit 3`, then `jq`
  the small file. Do not run `jq` on a multi-megabyte file; it parses the
  whole document.
- For analysis, prefer DuckDB. Use `ctx_execute_file` when the harness
  provides it, or a short Python script otherwise. Return counts and
  summaries, not rows.
- Write samples and temporary outputs to `${TMPDIR:-/tmp}` or a
  harness-provided temp directory, never into the repo.

## Data layout

- Shapefile sidecars travel as a set: `.shp .shx .dbf .prj .cpg .qpj`.
  Never rename, delete, or replace one alone.
- Shapefile and GeoParquet CRS: OSGB 1936 / British National Grid
  (EPSG:27700). GeoJSON CRS: WGS84 (EPSG:4326). Do not mix them.
- Keep all three formats in sync after any data change.
- Fields differ by tile size; only 25km has `TILE_REF`/`LETTER_REF`.
  Run `terrio info FILE` before writing a query.

## 25km tile refs

- `TILE_REF` has letter and numeric forms. Both are valid. Keep numeric
  values as they are; do not normalize them to letters.
- `LETTER_REF` is derived from the south-west corner. For letter-form
  tiles it equals `TILE_REF`.
- Four source labels were duplicated or misplaced; they were corrected
  from geometry, giving `NN7525`, `NX7525`, `NY5000`, and `HU5050`. Fix
  label mismatches from geometry, never by editing text.
- Update `README.md` with any label change.

## Validation

- Prefer terrio. If it is unavailable, use `ogrinfo -so`/`ogr2ogr` or
  Python (`pyogrio`, `fiona`, `shapely`) for the same checks.
- After any change, check every format: `terrio info FILE` (add `--json` to
  compare programmatically). It reports driver, geometry, feature count,
  CRS, extent, and fields.
- Expected feature counts, identical in Shapefile, GeoJSON, and GeoParquet:
  100km 56 · 50km 163 · 25km 537 · 20km 824 · 10km 2886 ·
  5km 10719 · 1km 286300.
- Expected CRS: Shapefile and GeoParquet EPSG:27700, GeoJSON EPSG:4326.
- 25km baseline, all formats: 537 features, 537 unique `TILE_REF`,
  537 unique `LETTER_REF`, 0 invalid geometries.
- Compare feature counts, fields, and CRS across formats. Do not compare
  raw extents: Shapefile reports metres, GeoJSON degrees.
- The 1km layer has 286,300 features, so `terrio info` takes seconds and
  may take ~20 s on a small machine. Run it once per change, not in a loop.
- Sample with `terrio convert IN OUT --limit 3` (also `--where`, `--sql`,
  `--spat`). Write to a file, never stdout.
- DuckDB: `LOAD spatial;`, and run `SET geometry_always_xy = true` before
  any geometry `COPY` (GeoParquet or GDAL), otherwise axis-order errors.
  Regenerate GeoParquet from its Shapefile with the command in `README.md`.
- DuckDB agent mode is on by default when an agent environment variable is
  set and output is piped. Use `-csv`/`-json` with an explicit `LIMIT` for
  stable output.
- No application code here, only SQL scripts, so code-index tools have
  little to index. If code is added and an index tool is configured, build
  the index first.

## Formatting

- Present commands, SQL, and code in fenced blocks with a language tag
  (`bash`, `sql`, `python`), including one-line snippets.
- Break long commands over several lines. Keep the result copy-pasteable.
- One clause per line; no single-line command that scrolls sideways.
- Wrap file paths, field names, and inline commands in backticks.

## Git

- Working tree is ~145 MB, mostly data: GeoJSON ~100 MB of text, Shapefile
  ~44 MB of binary, GeoParquet 2.3 MB. `.git` adds ~40 MB. Never `git diff`
  `.shp`/`.dbf`; avoid diffing the large GeoJSON. Use `git status --short`
  and `git diff --stat`.
- Stage explicit paths. Do not use `git add -A`; a regenerated 93 MB file
  could slip in.
- Do not commit `.codegraph/` or `.projectmem/`.
- Prefer one tile size per commit; list regenerated files in the message.

## Memory

- If ProjectMem is configured, log data gotchas, coordinate fixes, and
  decisions there. Otherwise record them in `README.md` or the commit
  message.
