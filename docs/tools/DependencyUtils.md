# DependencyUtils

## <span id="addJarToClasspath"> Adding Local Jars to ClassLoader

```scala
addJarToClasspath(
  localJar: String,
  loader: MutableURLClassLoader): Unit
```

`addJarToClasspath` adds `file` and `local` jars (as `localJar`) to the `loader` classloader.

`addJarToClasspath` resolves the URI of `localJar`. If the URI is `file` or `local` and the file denoted by `localJar` exists, `localJar` is added to `loader`. Otherwise, the following warning is printed out to the logs:

```text
Warning: Local jar /path/to/fake.jar does not exist, skipping.
```

For all other URIs, the following warning is printed out to the logs:

```text
Warning: Skip remote jar hdfs://fake.jar.
```

NOTE: `addJarToClasspath` assumes `file` URI when `localJar` has no URI specified, e.g. `/path/to/local.jar`.
