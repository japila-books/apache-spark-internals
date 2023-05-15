---
title: pyspark
---

# pyspark Shell Script

`pyspark` shell script runs [spark-submit](spark-submit/index.md) with [pyspark-shell-main](#pyspark-shell-main) application resource as the first argument followed by `--name "PySparkShell"` option (with other command-line arguments, if specified).

## pyspark/shell.py { #pyspark-shell }

!!! note "pyspark/shell.py"
    Learn more about `pyspark/shell.py` in [The Internals of PySpark]({{ book.pyspark }}/pyspark/shell/).

`pyspark/shell.py` module is launched as a [PYTHONSTARTUP](#PYTHONSTARTUP) script.

## Environment Variables

`pyspark` script exports the following environment variables:

* [OLD_PYTHONSTARTUP](#OLD_PYTHONSTARTUP)
* `PYSPARK_DRIVER_PYTHON`
* `PYSPARK_DRIVER_PYTHON_OPTS`
* [PYSPARK_PYTHON](#PYSPARK_PYTHON)
* `PYTHONPATH`
* [PYTHONSTARTUP](#PYTHONSTARTUP)

### OLD_PYTHONSTARTUP { #OLD_PYTHONSTARTUP }

`pyspark` defines `OLD_PYTHONSTARTUP` environment variable to be the initial value of [PYTHONSTARTUP](#PYTHONSTARTUP) (before it gets redefined).

The idea of `OLD_PYTHONSTARTUP` is to delay execution of the Python startup script until [pyspark/shell.py](#PYTHONSTARTUP) finishes.

### PYSPARK_PYTHON { #PYSPARK_PYTHON }

`PYSPARK_PYTHON` environment variable can be used to specify a Python executable to run PySpark scripts.

??? note "The Internals of PySpark"
    Learn more about PySpark in [The Internals of PySpark]({{ book.pyspark }}).

`PYSPARK_PYTHON` can be overriden by [PYSPARK_DRIVER_PYTHON](#PYSPARK_DRIVER_PYTHON) and configuration properties when `SparkSubmitCommandBuilder` is requested to [buildPySparkShellCommand](SparkSubmitCommandBuilder.md#buildPySparkShellCommand).

`PYSPARK_PYTHON` is overriden by `spark.pyspark.python` configuration property, if defined, when `SparkSubmitCommandBuilder` is requested to [buildPySparkShellCommand](SparkSubmitCommandBuilder.md#buildPySparkShellCommand).

### PYTHONSTARTUP { #PYTHONSTARTUP }

From [Python Documentation](https://docs.python.org/3/using/cmdline.html):

> **PYTHONSTARTUP**
>
> If this is the name of a readable file, the Python commands in that file are executed before the first prompt is displayed in interactive mode.
> The file is executed in the same namespace where interactive commands are executed so that objects defined or imported in it can be used without qualification in the interactive session.
> You can also change the prompts `sys.ps1` and `sys.ps2` and the hook `sys.__interactivehook__` in this file.

`pyspark` (re)defines `PYTHONSTARTUP` environment variable to be [pyspark/shell.py](#pyspark-shell) module:

```text
${SPARK_HOME}/python/pyspark/shell.py
```

!!! note "OLD_PYTHONSTARTUP"
    The initial value of `PYTHONSTARTUP` environment variable is available as [OLD_PYTHONSTARTUP](#OLD_PYTHONSTARTUP).
