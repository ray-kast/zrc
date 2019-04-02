# `~/.zrc`
My response to `oh-my-zsh`.  Considerably smaller, considerably more
lightweight, and considerably more tuned to what I want from my shell.

# Installation

Make sure this Git repository has been cloned into `~/.zrc` — otherwise, the
install script (and possibly other utilities) will not work correctly.

The script `install.zsh` will install the proper files to change `$ZDOTDIR` to
a new folder which will contain files to run this script.  For more info, run
`./install.zsh -h`.

# Configuring

## Additional Scripts

This script will look for the file `~/.zrc-local.zsh`, and source it at the end
of the `.zshrc` phase.

## Environment Variables

Currently, this script accepts the following environment variables:

| Name | Usage |
|------|-------|
| `CARGO_CLEANUP_ROOT` | Used by `cargo-cleanup` as the default root directory |
| `ZRC_NO_GIT_PROMPT` | Disables Git information in the prompt |