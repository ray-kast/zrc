function autoxelatex() {
  if (( # != 1 )); then
    echo "Usage: autoxelatex <file>"
    return 1
  fi

  { jobs | grep -Gqsm 1 -e autoxelatex } && { echo "Job already running."; return -1 }

  typeset -a args
  args=(-pdf -pdflatex="timeout --signal=9 5s xelatex -interaction=nonstopmode -synctex=1 %O %S")
  echo "\x1b[1mRunning latexmk once...\x1b[0m"
  latexmk -f $args "$1" || return $?
  [[ -f "$(dirname "$1")/${$(basename "$1")%.*}.pdf" ]] || return 1
  echo "\x1b[1mOpening $(dirname "$1")/${$(basename "$1")%.*}.pdf...\x1b[0m"
  evince "$(dirname "$1")/${$(basename "$1")%.*}.pdf" &
  echo "\x1b[1mStarting latexmk in continuous mode...\x1b[0m"
  latexmk -f -pvc $args "$1"
}
