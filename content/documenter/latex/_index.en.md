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

{{< hint type=note title=Intro >}} **LaTeX** is a programming language layout
used to create scientific and academic documents with precision. Its
command-based syntax is reminiscent of the approach of the automation of the IT
infrastructure (**IAC**) used by **DevOps**. As the IAC makes it possible to
describe and manage the infrastructure of reproducible way via code, LaTeX
offers similar control over the presentation of documents, allowing coherent and
efficient management of complex elements such as mathematical equations and
references bibliographic.

{{< /hint >}}

## Why LaTeX?

As **DevOps** we like to master code generation, deployment generation, document
generation. This is why that **[LaTeX](https://www.latex-project.org/)** can be
a good tool in replacement for Office or LibreOffice.

Without a special editor, coding a LaTeX document is much easier to read an
Office/LibreOffice document that is saved in format
**[Office Open XML](https://fr.wikipedia.org/wiki/Office_Open_XML)** LaTeX is
mainly

Personally, although you can write LaTeX documents with a editor like
[TeXstudio](https://www.texstudio.org/), it is also possible to use simpler
editors such as Nano or Vim. For my part, I use
[my own IDE**](https://github.com/badele/vide), based on Vim, which not only
allows you to edit, reformat, linter and view files LaTeX documents, but also,
thanks to Nix, to download LaTeX packages.

{{< img name="vim_latex" size=origin lazy=false >}}

## The basics

### The preamble

The preamble allows you to configure the form of your document and to indicate
the additional packages to download as well as their configuration.

the preamble is inserted between the start of the document and the command
`\begin{document}`, it allows you to define the global configurations of the
document, such as the document class, the packages to use, and the metadata.

Here is a simple example

{{< include file="content/documenter/latex/01-simple_example.tex"
language="latex">}}

{{< img name="simple_example" size=origin lazy=false >}}

### The sections

Sections and subsections in LaTeX are used to organize a document into parts and
sub-parts, similar to the structuring by titles in Office. In Additionally, it
is possible to generate a table of contents using the command
`\tableofcontents`. Additionally, it is possible to include sections not
numbered in the table of contents by adding an asterisk as a suffix
(`section*{Title}`).

{{< include file="content/documenter/latex/02-section_example.tex"
language="latex">}}

{{< img name="section_example" size=origin lazy=false >}}

### Text style

Here is a range of text styles.

{{< include file="content/documenter/latex/03-textsize_example.tex"
language="latex">}}

{{< img name="textsize_example" size=origin lazy=false >}}

## Some tips

### Debug

#### In the Preamble

##### draf, showframe

LaTeX is a tool that aims to produce optimal formatting for documents, but when
it encounters rules that it cannot apply, it generates warnings or errors.
However, these error messages can sometimes be difficult to understand. To
resolve these problems, it is possible enable a debug mode that provides
additional information for understand and correct errors.

By adding the `draft` and `showframe` options to the `\documentclass` command,
you can display the borders of the boxes as well as turn the boxes black problem
parts.

{{< include file="content/documenter/latex/04-debug_example.tex"
language="latex">}}

{{< img name="debug_example" size=origin lazy=false >}}

##### listfiles

To list the installed packages, simply add the command `\listfiles` in the
preamble, during the next compilation via `pdflatex` you will have command
output the list of files.

```text
 *File List*
 article.cls 2023/05/17 v1.4n Standard LaTeX document class
  size12.clo 2023/05/17 v1.4n Standard LaTeX file (size option)
  french.sty 2019/09/06 The e-french package /V6,11/
     msg.sty 2019/01/01 loading localization extension (V0.51).
latexsym.sty 1998/08/17 v2.2e Standard LaTeX package (lasy symbols)
fenglish.sty 2004/06/23 english interface for the french(le/pro) package
  lipsum.sty 2021-09-20 v2.7 150 paragraphs of Lorem Ipsum dummy text
l3keys2e.sty 2024-02-18 LaTeX2e option processing using LaTeX3 keys
   expl3.sty 2024-02-20 L3 programming layer (loader)
l3backend-pdftex.def 2024-02-20 L3 backend support: PDF output (pdfTeX)
  lipsum.ltd
   t1lmr.fd 2015/05/01 v1.6.1 Font defs for Latin Modern
  french.cfg
   ulasy.fd 1998/08/17 v2.2e LaTeX symbol font definitions
 *****
```

### Fonts

- List of fonts https://tug.org/FontCatalogue/allfonts.html
- Comprehensive LaTeX Symbol List
  http://mirrors.ctan.org/info/symbols/comprehensive/symbols-a4.pdf
