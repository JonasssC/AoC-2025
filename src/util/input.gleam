import gleam/string
import gleam/result
import gleam/http/request
import gleam/httpc
import simplifile

pub fn get_input(year: String, day: String) -> Result(String, Nil) {
  case simplifile.read("./.hidden/input/y" <> year <> "d" <> day) {
    Ok(content) -> Ok(string.trim(content))
    Error(_) -> {
      let assert Ok(req) = request.to("https://adventofcode.com/" <> year <> "/day/" <> day <> "/input")
      let assert Ok(session_cookie) = simplifile.read("./.hidden/session_cookie")
      use resp <- result.try(
        req
          |> request.set_header("cookie", "session=" <> session_cookie)
          |> httpc.send
          |> result.map_error(fn(_) { Nil })
      )

      assert resp.status == 200 as "Failed request"

      let input = string.trim(resp.body)

      let _ = simplifile.write("./.hidden/input/y" <> year <> "d" <> day, input)

      Ok(input)
    }
  }
}
