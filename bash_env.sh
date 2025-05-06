# set -x

f.e() { [[ $(type -t ${1:?'expecting a function name'}) = function ]]; }
f.x() { for f in "$@"; do f.e ${f} && export -f ${f}; done; }
f.x f.e f.x

f.const() { eval $(printf '%s() ( echo '%q'; )' ${1:?'expecting a function name'} ${2:?'expecting a value'}); f.x $1; }
f.x f.const
f.const build.root "$(dirname $(realpath -Lq ${BASH_SOURCE}))"

jq() ( command ${FUNCNAME} --color-output "$@"; )
f.x jq
# set +x

