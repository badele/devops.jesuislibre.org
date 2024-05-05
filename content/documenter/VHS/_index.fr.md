---
title: VHS
resources:
  - name: demo-vhs
    src: demo-vhs.gif
    title: "VHS demo"
    params:
      credits: "generated with `vhs demo-vhs.tape`"
---

{{< hint type=note title=Intro >}} Parfois, **Une image vaut mille mots**.
[VHS](https://github.com/charmbracelet/vhs) est l'outil parfait expliquer en
image animée comment utiliser des outils en ligne de commande {{< /hint >}}

## VHS en image

[VHS](https://github.com/charmbracelet/vhs) est un outil sensiblement identique
à [asciinema](https://asciinema.org/). Néamoins **VHS** utilise une approche
déclarative (via la création de fichier `.tape`). Il permet d'automatiser
l'éxecution d'un scénario composé d'une suite de commandes à executer, pour
ensuite enregrister le résultat des actions sous forme de videos dans différents
formats (webm, mp4, gif), ce qui peut être particulièrement utile pour la
documentation ou le partage de connaissances.

En partant de ce fichier `demo-vhs.tape`

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

Nous obtenos le résultat ci-dessous avec commande suivante `vhs demo-vhs.tape`

{{< img name="demo-vhs" size=origin lazy=false >}}
