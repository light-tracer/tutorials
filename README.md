# Light Tracer tutorials

Published tutorial scripts, previews and self-contained resources for LT.
Authoring sources and publishing tools live in the Light Tracer repository.

- `catalogs/lt-3.5-v1.json`: active signed catalog; clients filter compatibility.
- `releases/lt-3.5-v1/`: retained signed publications, including rollback targets.
- `data/tutorials/*.lua`: ordinary lesson source files, ready to read/edit.
- `data/tutorials/assets/` and `previews/`: helpers and preview images.
- `data/models/`, `data/hdri/`: shared scene and environment resources.
- `tutorials-1.pem`: public verification key. The private key stays outside Git.
- `data/tutorials/revisions.json`: immutable fingerprints of explicit lesson revisions.

Resources in catalogs point to full Git commit IDs. Keep their Git history.
Before release, bump the changed lesson's `--@ revision: N`. Freeze revisions
with LT's `scripts/tutorial_versions.py --root <this-checkout> --record` and
commit the registry with the source edits. Never rewrite old fingerprints.
Then prepare/sign a catalog using this checkout as
`--source`. Editing a file alone does not activate it: the signed catalog pins
its commit and SHA-256. Old versions remain in Git history, without hash folders.
