# WebUITab

`WebUITab` is an abstraction of [UI tabs](#implementations) with a [name](#name) and [pages](#pages).

## Implementations

* [SparkUITab](SparkUITab.md)

## Creating Instance

`WebUITab` takes the following to be created:

* <span id="parent"> [WebUI](WebUI.md)
* <span id="prefix"> Prefix

??? note "Abstract Class"
    `WebUITab` is an abstract class and cannot be created directly. It is created indirectly for the [concrete WebUITabs](#implementations).

## <span id="name"> Name

```scala
name: String
```

`WebUITab` has a name that is the [prefix](#prefix) capitalized by default.

## <span id="pages"> Pages

```scala
pages: ArrayBuffer[WebUIPage]
```

`WebUITab` has [WebUIPage](WebUIPage.md)s.

## <span id="attachPage"> Attaching Page

```scala
attachPage(
  page: WebUIPage): Unit
```

`attachPage` registers the [WebUIPage](WebUIPage.md) (in the [pages](#pages) registry).

`attachPage` adds the [prefix](#prefix) of this `WebUITab` before the [prefix](WebUIPage.md#prefix) of the given [WebUIPage](WebUIPage.md):

```text
[prefix]/[page.prefix]
```
