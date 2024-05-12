---
title: ghq
resources:
  - name: demo-ghq
    src: demo-ghq.gif
    title: "ghq demo"
    params:
      credits: "generated with `vhs demo-ghq.tape`"
---

{{< hint type=note title=Intro >}} **[ghq](https://github.com/x-motemen/ghq)**
permet de cloner un projet sans se soucier où sera cloné le projet, il permet
également de cloner en respectant l'arborescence du repo distant. {{< /hint >}}

## git clone, c'est pourtant simple !

Le processus de clonage avec la commande `git clone` peut sembler simple au
premier abord, mais lorsqu'on gère plusieurs dépôts **Git**, cela peut
rapidement devenir complexe. C'est encore plus vrai lorsque l'on travaille avec
des forks de dépôts. L'outil **ghq** vient simplifier cette gestion en
centralisant les dépôts dans un emplacement spécifique sur votre machine.

Imaginons que vous désiriez travailler avec des **dotfiles** et que vous
récupériez un **dotfiles** avec la commande
`ghq get https://github.com/mathiasbynens/dotfiles.git`. Et que maintenant vous
voulez également travailler sur votre **dotfiles**, pas besoin de se poser la
question où vous alliez cloner votre projet, il vous suffit d'exécuter
`ghq get https://github.com/badele/dotfiles.git`. Après l'exécution de ces
commandes, la structure des projets sera organisée de manière claire dans votre
répertoire **ghq**.

De plus, lors de collaborations en équipe impliquant le partage de scripts
utilisant des projets clonés, il n'est pas nécessaire de spécifier des chemins
spécifiques tels que `/usr/local/nosprojets/xxx`. Il suffit par exemple
d'exporter une variable, comme `TEAM_PROJECT=~/ghq`, pour toute l'équipe et
d'utiliser cette référence dans vos scripts. Ainsi, vous pouvez utiliser
`$TEAM_PROJECT/mateam/monprojet/bin/monexecutable` dans vos scripts, assurant
une cohérence dans l'accès aux ressources partagées.

```text
└─ ~/ghq
   └─ github.com
      ├─ mathiasbynens
      │  └─ dotfiles
      └─ badele
         └─ dotfiles
```

Voici un exemple d'utilisation de **ghq**

{{< img name="demo-ghq" size=origin lazy=false >}}
