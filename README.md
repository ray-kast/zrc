# `~/.zrc`
My shell (and select config) files as a recovered oh-my-zsh addict.  Pared down
to just what I need for better startup times and interoperability.

# Installation

Make sure this Git repository has been cloned into `~/.zrc` — otherwise, the
install script (and possibly other utilities) will not work correctly.

The script `install.zsh` will install the proper files to change `$ZDOTDIR` to
a new folder which will contain files to run this script.  For more info, run
`./install.zsh -h`.

# Configuration

## Additional Scripts

Installing this script will write startup scripts to `$ZDOTDIR/.zshenv`,
`$ZDOTDIR/.zprofile`, and `$ZDOTDIR/.zshrc` corresponding to the environment,
profile, and RC scripts respectively.  These files can be edited as long as the
line sourcing the appropriate file in `.zrc` is left alone.

## Environment Variables

Currently, this script accepts the following environment variables:

| Name | Usage |
|------|-------|
| `CARGO_CLEANUP_ROOT` | Used by `cargo-cleanup` as the default root directory |
| `NODE_CLEANUP_ROOT` | Used by `node-cleanup` as the default root directory |
| `ZRC_NO_GIT_PROMPT` | Set to a nonempty value to disable Git information in the prompt |
| `ZRC_NO_GPG` | Set to a nonempty value to disable searching for GPG as an SSH agent |
