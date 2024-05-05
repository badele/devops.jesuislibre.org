#!/usr/bin/env just -f

# This help
# Help it showed if just is called without arguments
@help:
    just -lu | column -s '#' -t | sed 's/[ \t]*$//'

###############################################################################
# pre-commit
###############################################################################

# Setup pre-commit
precommit-install:
    #!/usr/bin/env bash
    test ! -f .git/hooks/pre-commit && pre-commit install || true

# Update pre-commit
@precommit-update:
    pre-commit autoupdate

# precommit check
@precommit-check:
    pre-commit run --all-files

###############################################################################
# Hugo
###############################################################################

[private]
hugo-download-theme:
    #!/usr/bin/env bash
    [ -e themes/hugo-geekdoc ] && rm -rf themes/hugo-geekdoc || true
    mkdir -p themes/hugo-geekdoc
    curl -L https://github.com/thegeeklab/hugo-geekdoc/releases/latest/download/hugo-geekdoc.tar.gz | tar -xz -C themes/hugo-geekdoc/ --strip-components=1

# Init hugo documentation site
@hugo-init: hugo-download-theme
    hugo new site . > /dev/null

# Hugo serve the locally content
@hugo-serve:
    GIT_COMMIT_SHA=`git rev-parse --verify HEAD` GIT_COMMIT_SHA_SHORT=`git rev-parse --short HEAD` hugo serve --debug --cleanDestinationDir -D

# Hugo build the content
hugo-build:
    GIT_COMMIT_SHA=`git rev-parse --verify HEAD` GIT_COMMIT_SHA_SHORT=`git rev-parse --short HEAD` hugo --cleanDestinationDir

# Hugo test publish the content
hugo-publishtest: hugo-build
    rsync -avrn --delete public/ w4a153382@ssh.web4all.fr:/datas/vol3/w4a153382/var/www/devops.jesuislibre.org/htdocs/

# Hugo publish the content
hugo-publish: hugo-build
    rsync -avr --delete public/ w4a153382@ssh.web4all.fr:/datas/vol3/w4a153382/var/www/devops.jesuislibre.org/htdocs/

###############################################################################
# Tools
###############################################################################

# Generate documentation samples
doc-generate-tex-sample:
    #!/usr/bin/env bash
    find . -type f -name '*.tex' | while read file; do
        # get file informations
        filename=$(basename -- "$file")
        filename="${filename%.*}"
        dirname=$(dirname -- "$file")
        # generate pdf
        pdflatex --output-dir "$dirname" "$file"
        # convert pdf to png
        convert -background white -alpha remove -alpha off -density 150 "$dirname/$filename.pdf" "$dirname/$filename.png"
    done

# Update documentation
@doc-update FAKEFILENAME:
    ./updatedoc.ts

# Lint the project
@lint:
    pre-commit run --all-files

# Repl the project
@repl:
    nix repl --extra-experimental-features repl-flake .#

# Show installed packages
@packages:
    echo $PATH | tr ":" "\n" | grep -E "/nix/store" | sed -e "s/\/nix\/store\/[a-z0-9]\+\-//g" | sed -e "s/\/.*//g"
