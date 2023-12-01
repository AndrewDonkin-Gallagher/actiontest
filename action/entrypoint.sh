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
#git checkout --orphan gh-pages "${GITHUB_SHA}"
git checkout "${GITHUB_SHA}" -B gh-pages

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

# If the action is being run into the GitHub Servers,
# the checkout action (which is being used)
# automatically authenticates the container using ssh.
# If the action is running locally, for instance using https://github.com/nektos/act,
# we need to push via https with a Personal Access Token
# which should be provided by an env variable.
# We can run the action locally using act with:
#    act -s GITHUB_TOKEN=my_github_personal_access_token
#if ! ssh -T git@github.com > /dev/null 2>/dev/null; then
#    echo SSH failed.
#    URL="https://$GITHUB_TOKEN@github.com/$GITHUB_REPOSITORY.git"
#    git remote remove origin
#    git remote add origin "$URL"
#fi

echo Pushing
git push -f --set-upstream origin gh-pages
