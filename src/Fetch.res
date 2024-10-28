module Response = {
  type t

  @send
  external json: t => Js.Promise.t<Js.Json.t> = "json"

  @send
  external text: t => Js.Promise.t<string> = "text"

  @get
  external ok: t => bool = "ok"

  @get
  external status: t => int = "status"

  @get
  external statusText: t => string = "statusText"
}

type options = {
  headers: Js.Dict.t<string>,
  // method: string, // we're using rescript 9.1.4 which doesn't allow optional params. Let's sidestep this options record in our fetch but leave it here for reference.
}

@val
external fetch: (string, 'options) => Js.Promise.t<Response.t> = "fetch"

let fetchJson = (~headers=Js.Dict.empty(), url: string): Js.Promise.t<Js.Json.t> => {
  let options = {
    "headers": headers,
  }

  fetch(url, options) |> Js.Promise.then_(res =>
    if !Response.ok(res) {
      res->Response.text->Js.Promise.then_(text => {
        let msg = `${res->Response.status->Js.Int.toString} ${res->Response.statusText}: ${text}`
        Js.Exn.raiseError(msg)
      }, _)
    } else {
      res->Response.json
    }
  )
}
let mutate = (
  ~new_value: string,
  ~dimension_key: string,
  ~method="POST",
  url: string,
): Js.Promise.t<Js.Json.t> => {
  let body = {
    // "some_int": some_int,
    // "some_text": some_text,
    "updated_column": new_value,
    "target_column": dimension_key,
  }

  let options = {
    "headers": {"Content-Type": "application/json"},
    "method": method,
    "body": Js.Json.stringifyAny(body),
  }
  fetch(url, options) |> Js.Promise.then_(res =>
    if !Response.ok(res) {
      res->Response.text->Js.Promise.then_(text => {
        let msg = `${res->Response.status->Js.Int.toString} ${res->Response.statusText}: ${text}`
        Js.Exn.raiseError(msg)
      }, _)
    } else {
      res->Response.json
    }
  )
}
