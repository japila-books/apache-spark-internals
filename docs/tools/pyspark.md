---
title: pyspark
---

# pyspark Shell Script

`pyspark` shell script runs [spark-submit](spark-submit.md) with [pyspark-shell-main](#pyspark-shell-main) application resource as the first argument followed by `--name "PySparkShell"` option (with other command-line arguments, if specified).

## PYTHONSTARTUP { #PYTHONSTARTUP }

`pyspark` defines `PYTHONSTARTUP` environment variable to the following value:

```text
${SPARK_HOME}/python/pyspark/shell.py
```

!!! note "pyspark/shell.py"
    Learn more about `pyspark/shell.py` in [The Internals of PySpark]({{ book.pyspark }}/pyspark/shell/).

## Exports

`pyspark` script exports the following environment variables:

* `PYSPARK_PYTHON`
* `PYSPARK_DRIVER_PYTHON`
* `PYSPARK_DRIVER_PYTHON_OPTS`
* `PYTHONPATH`
* [PYTHONSTARTUP](#PYTHONSTARTUP)
