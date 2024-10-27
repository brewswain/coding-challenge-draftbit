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
external fetch: (
  string,
  'options,
) => // ~headers: Js.Dict.t<string>,
// ~method: string,
// ~body: Js.Dict.t<string>,
Js.Promise.t<Response.t> = "fetch"

let fetchJson = (~headers=Js.Dict.empty(), url: string): // ~headers=Js.Dict.empty(),
// ~method="GET",
// ~body=Js.Dict.empty(),
// url: string,
Js.Promise.t<Js.Json.t> => {
  let options = {
    "headers": headers,
  }

  fetch(url, options) |> Js.Promise.then_(res =>
    // fetch(url, ~headers, ~method, ~body) |> Js.Promise.then_(res =>
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
  ~method="POST",
  ~headers=Js.Dict.empty(),
  ~body=Js.Dict.empty(),
  url: string,
): Js.Promise.t<Js.Json.t> => {
  let options = {
    "headers": headers,
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
