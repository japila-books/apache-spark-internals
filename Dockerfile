FROM squidfunk/mkdocs-material:6.0.2
RUN pip install \
  mkdocs-git-revision-date-plugin \
  mkdocs-awesome-pages-plugin \
  mkdocs-macros-plugin
