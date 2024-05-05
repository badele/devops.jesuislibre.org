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
allows you to clone a project without worrying where the project will be cloned,
it allows also to clone while respecting the aborescende of the remote repo. {{<
/hint >}}

## git clone, it's simple!

The cloning process with the `git clone` command may seem simple at first
glance. at first glance, but when managing several **Git** repositories, this
can quickly become complex. This is even more true when working with repository
forks. The **ghq** tool simplifies this management by centralizing repositories
in a specific location on your machine.

Let's say you use work with **dotfiles** and you get a **dotfiles** with the
command `ghq get https://github.com/mathiasbynens/dotfiles.git`. And now you
also want to work on your **dotfiles**, no need to worry question where you were
going to clone your project, you just need to run
`ghq get https://github.com/badele/dotfiles.git`. After executing these orders,
the structure of the projects will be clearly organized in your **ghq**
directory.

```text
└─ ~/ghq
   └─ github.com
      ├─ mathiasbynens
      │  └─ dotfiles
      └─ badele
         └─ dotfiles
```

Here is an example of using **ghq**

{{< img name="demo-ghq" size=origin lazy=false >}}
