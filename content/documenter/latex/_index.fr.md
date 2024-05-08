---
title: LaTeX
resources:
  - name: vim_latex
    src: vim_latex.png
    title: "Vim latex editor"
  - name: simple_example
    src: 01-simple_example.png
    title: "simple example"
    params:
      credits: "auto-generated with `just doc-generate-tex-sample` command"
  - name: section_example
    src: 02-section_example.png
    title: "section example"
    params:
      credits: "auto-generated with `just doc-generate-tex-sample` command"
  - name: textsize_example
    src: 03-textsize_example.png
    title: "textsize example"
    params:
      credits: "auto-generated with `just doc-generate-tex-sample` command"
  - name: debug_example
    src: 04-debug_example.png
    title: "debug example"
    params:
      credits: "auto-generated with `just doc-generate-tex-sample` command"
---

{{< hint type=note title=Intro >}} **LaTeX** est un langage de programmation de
mise en page utilisé pour créer des documents scientifiques et académiques avec
précision. Sa syntaxe basée sur des commandes rappelle l'approche de
l'automatisation de l'infrastructure informatique (**IAC**) utilisée par les
**DevOps**. Comme l'IAC permet de décrire et de gérer l'infrastructure de
manière reproductible via du code, LaTeX offre un contrôle similaire sur la
présentation des documents, permettant une gestion cohérente et efficace des
éléments complexes tels que les équations mathématiques et les références
bibliographiques.

{{< /hint >}}

{{< toc >}}

## Pourquoi LaTeX ?

En tant que **DevOps** on aime bien maitriser la génération de code, la
génération de déploiement, la génération de documents. C'est pour cette raison
que **[LaTeX](https://www.latex-project.org/)** peu être un bon outil en
remplacement de Office ou LibreOffice.

Sans éditeur particulier, le code d'un documents LaTeX est beaucoup plus facile
à lire qu'un document Office/LibreOffice qui sont enregistrés au format
**[Office Open XML](https://fr.wikipedia.org/wiki/Office_Open_XML)** LaTeX est
principalement

Personnellement, bien que l'on puisse rédiger des documents LaTeX avec un
éditeur comme [TeXstudio](https://www.texstudio.org/), il est également possible
d'utiliser des éditeurs plus simples tels que Nano ou Vim. Pour ma part,
j'utilise [mon propre IDE**](https://github.com/badele/vide), basé sur Vim, qui
permet non seulement d'éditer, de reformater, linter et de visualiser des
documents LaTeX, mais également, grâce à Nix, de télécharger des packages LaTeX.

{{< img name="vim_latex" size=origin lazy=false >}}

## Les bases

### Le préambule

Le préambule permet de configurer la forme de son document ainsi d'indiquer les
packages supplémentaires à télécharger ainsi que de leur configuration.

le préambule s'insère entre le début du document et la commande
`\begin{document}`, il permet de définir les configurations globales du
document, tel que la classe du document, les packages à utiliser et les
métadonnées.

Voici un exemple simple

{{< include file="content/documenter/latex/01-simple_example.tex"
language="latex">}}

{{< img name="simple_example" size=origin lazy=false >}}

### Les sections

Les sections et sous-sections en LaTeX servent à organiser un document en
parties et sous-parties, similaire à la structuration par titres sous Office. En
outre, il est possible de générer une table des matières à l'aide de la commande
`\tableofcontents`. De plus, il est possible d'inclure des sections non
numérotées dans la table des matières en ajoutant un astérisque en suffixe
(`section*{Titre}`).

{{< include file="content/documenter/latex/02-section_example.tex"
language="latex">}}

{{< img name="section_example" size=origin lazy=false >}}

### Style de textes

Voici un éventail des styles de texte.

{{< include file="content/documenter/latex/03-textsize_example.tex"
language="latex">}}

{{< img name="textsize_example" size=origin lazy=false >}}

## Quelques astuces

### Debug

#### Dans le Préambule

##### draf, showframe

LaTeX est un outil qui vise à produire un formatage optimal pour les documents,
mais lorsqu'il rencontre des règles qu'il ne peut pas appliquer, il génère des
avertissements ou des erreurs. Cependant, ces messages d'erreur peuvent parfois
être difficiles à comprendre. Pour résoudre ces problèmes, il est possible
d'activer un mode de débogage qui fournit des informations supplémentaires pour
comprendre et corriger les erreurs.

En ajoutant les options `draft` et `showframe` à la commande `\documentclass`,
vous pouvez afficher les bordures des boîtes ainsi que mettre en noir les
parties posant problème.

{{< include file="content/documenter/latex/04-debug_example.tex"
language="latex">}}

{{< img name="debug_example" size=origin lazy=false >}}

##### listfiles

Pour lister les packages installés, il sufft d'ajouter la commande `\listfiles`
dans le préambule, lors de la prochaine compilation via `pdflatex` vous aurez en
sortie de commande la liste des fichiers.

```text
 *File List*
 article.cls    2023/05/17 v1.4n Standard LaTeX document class
  size12.clo    2023/05/17 v1.4n Standard LaTeX file (size option)
  french.sty    2019/09/06 The e-french package /V6,11/
     msg.sty    2019/01/01 chargement de l'extension de localisation (V0.51).
latexsym.sty    1998/08/17 v2.2e Standard LaTeX package (lasy symbols)
fenglish.sty    2004/06/23 english interface for the french(le/pro) package
  lipsum.sty    2021-09-20 v2.7 150 paragraphs of Lorem Ipsum dummy text
l3keys2e.sty    2024-02-18 LaTeX2e option processing using LaTeX3 keys
   expl3.sty    2024-02-20 L3 programming layer (loader)
l3backend-pdftex.def    2024-02-20 L3 backend support: PDF output (pdfTeX)
  lipsum.ltd
   t1lmr.fd    2015/05/01 v1.6.1 Font defs for Latin Modern
  french.cfg
   ulasy.fd    1998/08/17 v2.2e LaTeX symbol font definitions
 ***********
```

### Divers

- Liste des fontes https://tug.org/FontCatalogue/allfonts.html
- Comprehensive LaTeX Symbol List
  http://mirrors.ctan.org/info/symbols/comprehensive/symbols-a4.pdf
