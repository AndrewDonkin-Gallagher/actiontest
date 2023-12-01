#! /bin/sh -l

# Bail on error.
set -e
# Hush ownership complaints
git config --global --add safe.directory /github/workspace

echo Fetch:
git fetch --all

echo Deleting gh-pages branch
git branch --quiet -D gh-pages 2>/dev/null || true
echo Starting new gh-pages branch
git checkout --orphan gh-pages "${GITHUB_SHA}"
# git checkout "${GITHUB_SHA}" -B gh-pages

echo Plain
asciidoctor -o index.html --verbose test.adoc || true

echo Diagram
asciidoctor -r asciidoctor-diagram -o index2.html --verbose test.adoc || true

echo Book
asciidoctor-pdf -r asciidoctor-diagram -o book.pdf --verbose test.adoc || true

# Git insists on these
git config --global user.email "action@github.com"
git config --global user.name "GitHub Action"

# echo '!index.html' >> .gitignore
echo "Adding *.html to gh-pages branch"
git add -f *.html book.pdf
git rm -rf .github action || true
git status
git commit -m "Asciidoctored $GITHUB_SHA"

echo Pushing
git push -f --set-upstream origin gh-pages
