---
title: VHS
resources:
  - name: demo-vhs
    src: demo-vhs.gif
    title: "VHS demo"
    params:
      credits: "generated with `vhs demo-vhs.tape`"
---

{{< hint type=note title=Intro >}} Sometimes, **A picture is worth a thousand
words**. [VHS](https://github.com/charmbracelet/vhs) is the perfect tool to
explain in animated image how to use command line tools {{< /hint >}}

## VHS in pictures

[VHS](https://github.com/charmbracelet/vhs) is a substantially identical tool at
[asciinema](https://asciinema.org/). Nevertheless **VHS** uses an approach
declarative (via the creation of a `.tape` file). It allows you to automate the
execution of a scenario composed of a series of commands to be executed, to then
record the results of the actions in the form of videos in different formats
(webm, mp4, gif), which can be particularly useful for documentation or
knowledge sharing.

Starting from this `demo-vhs.tape` file

```text
Output demo-vhs.gif

Require nix

Set TypingSpeed 75ms
Set FontSize 18
Set Width 800
Set Height 680

Type "# Install the needed packages" Sleep 500ms Enter Enter Sleep 2s

Type "nix-shell -p dotacat neofetch"

Type "neofetch" Sleep 500ms Enter Sleep 2s

Type "dotacat --help | dotacat" Sleep 500ms Enter

Sleep 5s
```

We obtain the result below with the following command `vhs demo-vhs.tape`

{{< img name="demo-vhs" size=origin lazy=false >}}
