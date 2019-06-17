#compdef smart-sudo

function _smart-sudo() {
  service="sudo"
  _sudo
}

_smart-sudo $@
