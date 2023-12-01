#! /bin/sh -l

# Bail on error.
set -e

echo "Hello $1"
time=$(date)
echo "time=$time" >> $GITHUB_OUTPUT

# Hush ownership complaints
git config --global --add safe.directory /github/workspace
git fetch --all

echo Deleting gh-pages branch
git branch -D gh-pages || true
echo Starting new gh-pages branch
#git checkout --orphan gh-pages "${GITHUB_SHA}"
git checkout "${GITHUB_SHA}" -B gh-pages

echo plain
asciidoctor -o index.html --verbose test.adoc || true

echo diagram
asciidoctor -r asciidoctor-diagram -o index2.html --verbose test.adoc || true

echo book
asciidoctor-pdf -r asciidoctor-diagram -o book.pdf --verbose test.adoc || true

echo "Adding *.html to gh-pages branch"

# Git insists on these
git config --global user.email "action@github.com"
git config --global user.name "GitHub Action"

# echo '!index.html' >> .gitignore
git add -f *.html book.pdf
git rm -rf .github || true
git status
git commit -m "Asciidoctored $GITHUB_SHA"

echo Pushing
git push -f --set-upstream origin gh-pages
