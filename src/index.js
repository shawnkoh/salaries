import { Elm } from "./Main.elm"
import data from "./data.csv"

const $root = document.querySelector("#root")
console.log(data)
console.log(typeof data)

Elm.Main.init({
  node: $root,
  flags: data
});