# Main

`Main` is the [standalone application](#main) of [spark-class](spark-class.md) shell script.

## main

```java
void main(
  String[] argsArray)
```

!!! note
    `main` requires that at least the class name (`className`) is given as the first argument in the given `argsArray`.

For `org.apache.spark.deploy.SparkSubmit` class name, `main` creates a [SparkSubmitCommandBuilder](SparkSubmitCommandBuilder.md) and [builds a command](AbstractCommandBuilder.md#buildCommand) (with the `SparkSubmitCommandBuilder`).

Otherwise, `main` creates a [SparkClassCommandBuilder](SparkClassCommandBuilder.md) and [builds a command](#buildCommand) (with the `SparkClassCommandBuilder`).

Class Name | AbstractCommandBuilder
-----------|-----------------------
 `org.apache.spark.deploy.SparkSubmit` | [SparkSubmitCommandBuilder](SparkSubmitCommandBuilder.md)
 _anything else_ | [SparkClassCommandBuilder](SparkClassCommandBuilder.md)

In the end, `main` `prepareWindowsCommand` or [prepareBashCommand](#prepareBashCommand) based on the operating system it runs on, MS Windows or non-Windows, respectively.

### buildCommand { #buildCommand }

```java
List<String> buildCommand(
  AbstractCommandBuilder builder,
  Map<String, String> env,
  boolean printLaunchCommand)
```

`buildCommand` requests the given [AbstractCommandBuilder](AbstractCommandBuilder.md) to [build a command](AbstractCommandBuilder.md#buildCommand).

With `printLaunchCommand` enabled, `buildCommand` prints out the command to standard error:

```text
Spark Command: [cmd]
========================================
```

!!! note "SPARK_PRINT_LAUNCH_COMMAND"
    `printLaunchCommand` is controlled by `SPARK_PRINT_LAUNCH_COMMAND` environment variable.
