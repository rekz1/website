#!/usr/bin/env bash

set -x
set -euo pipefail
shopt -s globstar

if [[ $# -lt 1 ]]; then
    echo "Usage: convert_adoc.sh <file.adoc> [<target.md>]"
    exit 1
fi

TMPDIR="$(mktemp -d)"
trap "rm -rf ${TMPDIR}" EXIT

INPUT_ADOC="${1}"
[[ ${INPUT_ADOC} =~ ^.*/([^/.]+)(\..*)?$ ]] && INPUT_BASE="${BASH_REMATCH[1]}"
OUTPUT_MD="${2:-${INPUT_BASE}.md}"
INPUT_DOCBOOK="${TMPDIR}/$INPUT_BASE.xml"

echo "Converting ${INPUT_ADOC}"
asciidoc -b docbook -o "$INPUT_DOCBOOK" "$INPUT_ADOC"
pandoc -f docbook -t markdown_strict "$INPUT_DOCBOOK" -o "$OUTPUT_MD"
read -r -d '' FRONTEND_MATTER <<EOF
---
title: "${INPUT_BASE}"
date: $(date -Iseconds)
tags: []
categories: ["howto"]
---
EOF
echo -e "${FRONTEND_MATTER}\n$(cat "$OUTPUT_MD")" > "$OUTPUT_MD"
