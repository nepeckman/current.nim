import macros

when defined(js):
  import jsffi, asyncjs

  type wstring* = cstring
  type WObject* = JsObject

  proc fetch*(uri: cstring): Future[JsObject] {. importc .}
  proc fetch*(uri: cstring, data: JsObject): Future[JsObject] {. importc .}
  proc then*[T, R](promise: Future[T], next: proc (data: T): Future[R]): Future[R] {. importcpp: "#.then(@)" .}
  proc then*[T, R](promise: Future[T], next: proc (data: T): R): Future[R] {. importcpp: "#.then(@)" .}
  proc then*[T](promise: Future[T], next: proc(data: T)): Future[void] {. importcpp: "#.then(@)" .}
  proc catch*[T, R](promise: Future[T], next: proc (data: T): Future[R]): Future[R] {. importcpp: "#.catch(@)" .}
  proc catch*[T, R](promise: Future[T], next: proc (data: T): R): Future[R] {. importcpp: "#.catch(@)" .}
  proc catch*[T](promise: Future[T], next: proc(data: T)): Future[void] {. importcpp: "#.catch(@)" .}

  let hasKey = hasOwnProperty

  export jsffi

else:
  import json, asyncdispatch

  type wstring* = string
  type WObject* = JsonNode

  proc then*[T, R](future: Future[T], cb: proc (t: T): R {.gcsafe.}): Future[R] =
    let rv = newFuture[R]("then")
    future.callback = proc (data: Future[T])  =
      rv.complete(cb(data.read))
    result = rv

  proc then*[T, R](future: Future[T], cb: proc (t: T): Future[R] {.gcsafe.}): Future[R] =
    let rv = newFuture[R]("then")
    future.callback = proc (data: Future[T])  =
      let intermediate = cb(data.read)
      intermediate.callback = proc (otherData: Future[R]) =
        rv.complete(otherData.read)
    result = rv

  proc then*[T](future: Future[T], cb: proc (t: T) {.gcsafe.}): Future[void] =
    let rv = newFuture[void]("then")
    future.callback = proc (data: Future[T])  =
      cb(data.read)
      rv.complete()
    result = rv

  proc fwrap*[T](it: T): Future[T] =
    result = newFuture[T]()
    result.complete(it)

  export json
