# sourced indirectly via environment variable BASH_ENV
# set -x

# f.e $1 returns 0 iff $1 is a bash function
# f.e f.e => 0, f.e quux => 1
# usage: f.e quux || return $(err "quux not defined")
f.e() { [[ $(type -t ${1:?'expecting a function name'}) = function ]]; }

# f.x ${name}... exports all bash functions enumerated that are defined (and skips those that aren't).
f.x() { for f in "$@"; do f.e ${f} && export -f ${f}; done; }
f.x f.e f.x

# err "${message}" [${status}] prints ${message} to stderr and returns the status of that last command (ostensibly an error).
# usage: false || return $(err "false is an error")
err() ( local -i status=${2:-$?}; >&2 echo "${1:-${FUNCNAME}}"; return ${_status}; )
f.x err

# f.const ${name} ${value} creates and exports ${name}() that returns ${value} when called. An alternative to exported values.
f.const() { eval $(printf '%s() ( echo '%q'; )' ${1:?'expecting a function name'} ${2:?'expecting a value'}); f.x $1; }
f.x f.const
f.const build.root "$(dirname $(realpath -Lq ${BASH_SOURCE}))"

# wrap some commands to add default switches
# colorize json output
jq() ( command ${FUNCNAME} --color-output "$@"; )
f.x jq

context() (
    local label=${1:?'expecting a label like gitub'}
    local payload=${2:?'expecting a json payload'}
    echo ${label}
    jq <<< ${payload}
)
f.x context

# Don't descend into the .git subtree
tree() ( command ${FUNCNAME} -aF -I .git "$@"; )
f.x tree
# set +x

