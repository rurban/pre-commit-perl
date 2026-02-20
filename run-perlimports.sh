#!/usr/bin/env bash

# Run perlimports on perl scripts.
# Either with option --inplace-edit or --lint on some files.

set -eu

cmd=perlimports
if ! command -v "${cmd}" >/dev/null 2>&1; then
    echo "This check needs ${cmd} from https://github.com/oalders/App-perlimports."
    exit 1
fi

opts=
need_cp=
case $1 in
    --inplace-edit) opts="$1"; need_cp=1; shift ;;
    -*) opts="$1"; shift ;;
esac

for file in "$@"; do
    if [ -n "${need_cp}" ]; then
        cp -fp "${file}" "${file}.bak"
    fi
    if ! output=$("${cmd}" ${opts} "${file}" 2>&1); then
        echo "${output}"
        exit 1
    fi
    if [ -n "${need_cp}" ]; then
        if cmp "$file" "${file}.bak" >/dev/null 2>&1; then
            # nothing changed
            mv "${file}.bak" "${file}"
        else
            # we have it in git
            rm -f "${file}.bak"
        fi
    fi
done

