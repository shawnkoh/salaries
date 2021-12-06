import { Elm } from "./Main.elm"

const $root = document.querySelector("#root")

Elm.Main.init({
  node: $root
});