# The Internals of Apache Spark Online Book

[![CI](https://github.com/japila-books/apache-spark-internals/workflows/CI/badge.svg)](https://github.com/japila-books/apache-spark-internals/actions)

The project contains the sources of [The Internals of Apache Spark](https://books.japila.pl/apache-spark-internals) online book.

## Tools

The project is based on or uses the following tools:

* [Apache Spark](https://spark.apache.org/)

* [MkDocs](https://www.mkdocs.org/) which strives for being _a fast, simple and downright gorgeous static site generator that's geared towards building project documentation_

* [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/) theme (with [Insiders](https://squidfunk.github.io/mkdocs-material/insiders/) features)

* [Markdown](https://commonmark.org/help/)

* [Visual Studio Code](https://code.visualstudio.com/) as a Markdown editor

* [Docker](https://www.docker.com/) to [run the Material for MkDocs](https://squidfunk.github.io/mkdocs-material/getting-started/#with-docker-recommended) (with extra plugins and extensions)

## Previewing Book

### Custom Docker Image

This project uses a custom Docker image (based on the [Insiders](https://squidfunk.github.io/mkdocs-material/insiders/) image) since the [official Docker image](https://squidfunk.github.io/mkdocs-material/getting-started/#with-docker-recommended) includes just a few plugins only.

Build the custom Docker image using the following command:

```text
docker build \
  -t jaceklaskowski/mkdocs-material-insiders \
  -t jaceklaskowski/mkdocs-material-insiders:6.2.3-insiders-1.15.0 \
  .
```

### Building Book

Run the following command to build the book.

```text
docker run \
  -it \
  -p 8000:8000 \
  -v ${PWD}:/docs \
  jaceklaskowski/mkdocs-material-insiders \
  build --clean
```

**TIP:** Consult the [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/creating-your-site/) documentation to get started.

### Live Editing

Start `mkdocs serve` (with `--dirtyreload` for faster reloads) as follows:

```shell
docker run \
  -it \
  -p 8000:8000 \
  -v ${PWD}:/docs \
  jaceklaskowski/mkdocs-material-insiders \
  serve --dirtyreload --verbose --dev-addr 0.0.0.0:8000
```

You should start the above command in the project root (the folder with [mkdocs.yml](mkdocs.yml)).

## No Sphinx?! Why?

Read [Giving up on Read the Docs, reStructuredText and Sphinx](https://medium.com/@jaceklaskowski/giving-up-on-read-the-docs-restructuredtext-and-sphinx-674961804641).
