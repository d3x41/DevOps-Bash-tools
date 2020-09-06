#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-04-01 18:59:00 +0100 (Wed, 01 Apr 2020)
#
#  https://github.com/harisekhon/bash-tools
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/harisekhon
#

set -euo pipefail

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_description="
Run a command for each Buildkite pipeline

All arguments become the command template

The command template replaces the following for convenience in each iteration:

{username}, {user}    => \$BUILDKITE_ORGANIZATION / \$BUILDKITE_USER
{name}                => the repo name without the user prefix
{repo}                => the repo name with the user prefix

eg.
    ${0##*/} echo user={user} name={name} repo={repo}
"

# shellcheck disable=SC2034
usage_args="[<curl_options>]"

[ -n "${DEBUG:-}" ] && set -x
srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1090
. "$srcdir/lib/utils.sh"

help_usage "$@"

min_args 1 "$@"

cmd_template="$*"

# remember to set this eg. BUILDKITE_ORGANIZATION="hari-sekhon"
prefix="${BUILDKITE_ORGANIZATION:-${BUILDKITE_USER:-}}"

while read -r name; do
    repo="$prefix/$name"
    echo "# ============================================================================ #" >&2
    echo "# $repo" >&2
    echo "# ============================================================================ #" >&2
    cmd="$cmd_template"
    cmd="${cmd//\{username\}/$prefix}"
    cmd="${cmd//\{user\}/$prefix}"
    cmd="${cmd//\{repo\}/$repo}"
    cmd="${cmd//\{name\}/$name}"
    eval "$cmd"
done < <("$srcdir/buildkite_pipelines.sh")
