Output demo-ghq.gif

Require nix-shell

Set TypingSpeed 75ms
Set FontSize 12
Set Width 800
Set Height 680

Hide
Type "nix-shell -p ghq tree --run zsh" Sleep 500ms Enter Sleep 2s
Type "reset" Sleep 500ms Enter Sleep 2s
Show

Type "tree -d -L 6 ~/ghq" Sleep 500ms Enter Sleep 2s

Type "ghq get https://github.com/mathiasbynens/dotfiles.git" Sleep 500ms Enter Sleep 2s

Type "tree -d -L 6 ~/ghq" Sleep 500ms Enter Sleep 2s

Type "ghq get https://github.com/badele/dotfiles.git" Sleep 500ms Enter Sleep 2s

Type "tree -d -L 6 ~/ghq" Sleep 500ms Enter Sleep 2s

Sleep 5s
