# Script Guide

This folder contains data generation and maintenance scripts for question banks and mocks.

## Folder Layout

- `topics/`: Topic-specific question bank generators (`generate_*_250.ps1`)
- `mocks/`: Mock test assembly scripts
- `legacy/`: Older maintenance scripts retained for reference

## Conventions

- Scripts run from project root by resolving `..\..\..` from script location.
- Output files are written under `data/topics/` and `data/mocks/`.
- Topic scripts should generate strict MCQ schema:
  - exactly 4 string options
  - answer index in range `0..3`

## Typical Usage

Run from project root:

```powershell
.\scripts\generators\topics\generate_os_250.ps1
.\scripts\generators\mocks\generate_mocks_from_topics.ps1
```

## Validation

After generation, run integrity checks before commit to ensure metadata and question counts remain aligned.
