# The Internals of Apache Spark Online Book

[![CI](https://github.com/japila-books/apache-spark-internals/workflows/CI/badge.svg)](https://github.com/japila-books/apache-spark-internals/actions)

The project contains the sources of [The Internals of Apache Spark](https://books.japila.pl/apache-spark-internals) online book.

## Tools

The project is based on or uses the following tools:

* [Apache Spark](https://spark.apache.org/)

* [MkDocs](https://www.mkdocs.org/) which strives for being _a fast, simple and downright gorgeous static site generator that's geared towards building project documentation_

* [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/) theme

* [Markdown](https://commonmark.org/help/)

* [Visual Studio Code](https://code.visualstudio.com/) as a Markdown editor

* [Docker](https://www.docker.com/) to [run the Material for MkDocs](https://squidfunk.github.io/mkdocs-material/getting-started/#with-docker-recommended) (with plugins and extensions)

## Previewing Book

### Custom Docker Image

This project uses a custom Docker image (based on [Dockerfile](Dockerfile)) since the [official Docker image](https://squidfunk.github.io/mkdocs-material/getting-started/#with-docker-recommended) includes just a few plugins only.

Build the custom Docker image using the following command:

```text
docker build -t macros-material .
```

### Building Book

Run the following command to build the book.

```text
docker run \
  -it \
  -p 8000:8000 \
  -v ${PWD}:/docs macros-material \
  build --clean
```

Consult the [MkDocs documentation](https://www.mkdocs.org/#getting-started) to get started and learn how to [build the project](https://www.mkdocs.org/#building-the-site).

```shell
$ docker run --rm -it -p 8000:8000 -v ${PWD}:/docs squidfunk/mkdocs-material --help
Usage: mkdocs [OPTIONS] COMMAND [ARGS]...

  MkDocs - Project documentation with Markdown.

Options:
  -V, --version  Show the version and exit.
  -q, --quiet    Silence warnings
  -v, --verbose  Enable verbose output
  -h, --help     Show this message and exit.

Commands:
  build      Build the MkDocs documentation
  gh-deploy  Deploy your documentation to GitHub Pages
  new        Create a new MkDocs project
  serve      Run the builtin development server
```

### Online Editing

Start `mkdocs serve` (with `--dirtyreload` for faster reloads) as follows:

```shell
docker run \
  -it \
  -p 8000:8000 \
  -v ${PWD}:/docs macros-material \
  serve --dirtyreload --verbose --dev-addr 0.0.0.0:8000
```

You should start the above command in the project root (the folder with [mkdocs.yml](mkdocs.yml)).

Use `mkdocs build --clean` to remove any stale files.

## No Sphinx?! Why?

Read [Giving up on Read the Docs, reStructuredText and Sphinx](https://medium.com/@jaceklaskowski/giving-up-on-read-the-docs-restructuredtext-and-sphinx-674961804641).
