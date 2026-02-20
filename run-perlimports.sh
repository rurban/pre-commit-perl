#!/usr/bin/env bash

# Run perlimports on perl scripts.
# Either with option --inplace-edit or --lint on some files.

set -eu

cmd=perlimports
if ! command -v "${cmd}" >/dev/null 2>&1; then
    echo "This check needs ${cmd} from https://github.com/oalders/App-perlimports."
    exit 1
fi

case $1 in
    -*) opts="$1"; shift ;;
esac

for file in "$@"; do
    cp -fp "${file}" "${file}.bak"
    if ! output=$("${cmd}" "${opts}" "${file}" 2>&1); then
        echo "${output}"
        exit 1
    fi
    if cmp "$file" "${file}.bak" >/dev/null 2>&1; then
        # nothing changed
        mv "${file}.bak" "${file}"
    else
        # we have it in git
        rm -f "${file}.bak"
    fi
done

