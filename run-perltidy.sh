#!/usr/bin/env bash

# Run perltidy on perl scripts. Scripts are modified in place. A copy will be
# saved with .bak extension.
# By default, perltidy will look for .perltidyrc current directory (repository
# root) and in the home directory. If no config file is found then perltidy will
# run with --perl-best-practices.

set -eu

cmd=perltidy
if ! command -v "${cmd}" >/dev/null 2>&1; then
    echo "This check needs ${cmd} from http://perltidy.sourceforge.net/."
    exit 1
fi

cfg=.perltidyrc
# --nostandard-output --warning-output --backup-and-modify-in-place --backup-method=move
opts=(-nst -w -b -bm=move)
if [[ ! -r "${cfg}" ]] && [[ ! -r "$HOME/${cfg}" ]]; then
    # --noprofile" "--perl-best-practices
    opts=("-npro" "-pbp" "${opts[@]}")
fi

if ! output=$("${cmd}" "${opts[@]}" "$@" 2>&1) ||
    [[ "${output}" == *"## Please see file "*.ERR* ]]; then
    echo "${output}"
    exit 1
fi

for file in "$@"
do
    if cmp "$file" "${file}.bak" >/dev/null 2>&1; then
        # nothing changed
        mv "${file}.bak" "${file}"
    else
        # we have it in git
        rm -f "${file}.bak"
    fi
done
