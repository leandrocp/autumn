defmodule Autumn.CssGeneratorTest do
  use ExUnit.Case, async: true
  alias Autumn.CssGenerator

  @theme ~S"""
  "attribute" = { fg = "yellow" }
  "comment" = { fg = "light-gray", modifiers = ["italic", "bold"], underline = {  style = "line" } }
  "comment.block" = {}
  "constant" = { fg = "cyan", modifiers = ["bold"] }
  "constant.numeric" = "gold"
  "string" = "green"

  [palette]
  yellow     = "#E5C07B"
  light-gray = "#5C6370"
  gold       = "#D19A66"
  green      = "#98C379"
  """

  @tag :tmp_dir
  test "run", %{tmp_dir: tmp_dir} do
    theme_path = Path.join(tmp_dir, "theme.toml")
    File.write!(theme_path, @theme)
    dest_dir = Path.join(tmp_dir, "css")
    dest_path = Path.join(dest_dir, "theme.css")
    CssGenerator.run(tmp_dir, dest_dir)
    output = File.read!(dest_path)

    assert output == """
           /* theme */
           :root {
             /* palette */
             --athl-gold: #D19A66;
             --athl-green: #98C379;
             --athl-light-gray: #5C6370;
             --athl-yellow: #E5C07B;
             /* shared */
             --athl-shared-bg-color: #ffffff;
             --athl-shared-fg-color: #000000;
           }
           pre.athl {
             background-color: var(--athl-shared-bg-color);
             color: var(--athl-shared-fg-color);
           }
           .athl-markup {
             color: var(--athl-shared-fg-color);
           }
           .athl-operator {
             color: var(--athl-shared-fg-color);
           }
           .athl-markup-heading-3 {
             color: var(--athl-shared-fg-color);
           }
           .athl-attribute {
             color: var(--athl-yellow, yellow);
           }
           .athl-function-special {
             color: var(--athl-shared-fg-color);
           }
           .athl-comment-block-documentation {
             color: var(--athl-shared-fg-color);
           }
           .athl-constant {
             color: var(--athl-shared-fg-color);
           }
           .athl-markup-raw-block {
             color: var(--athl-shared-fg-color);
           }
           .athl-markup-raw {
             color: var(--athl-shared-fg-color);
           }
           .athl-keyword-storage-modifier {
             color: var(--athl-shared-fg-color);
           }
           .athl-markup-italic {
             color: var(--athl-shared-fg-color);
           }
           .athl-diff {
             color: var(--athl-shared-fg-color);
           }
           .athl-keyword-storage-type {
             color: var(--athl-shared-fg-color);
           }
           .athl-markup-heading-1 {
             color: var(--athl-shared-fg-color);
           }
           .athl-markup-list {
             color: var(--athl-shared-fg-color);
           }
           .athl-type-enum {
             color: var(--athl-shared-fg-color);
           }
           .athl-keyword-control-import {
             color: var(--athl-shared-fg-color);
           }
           .athl-markup-heading-4 {
             color: var(--athl-shared-fg-color);
           }
           .athl-tag {
             color: var(--athl-shared-fg-color);
           }
           .athl-markup-link-text {
             color: var(--athl-shared-fg-color);
           }
           .athl-markup-link {
             color: var(--athl-shared-fg-color);
           }
           .athl-keyword-control-return {
             color: var(--athl-shared-fg-color);
           }
           .athl-markup-heading-marker {
             color: var(--athl-shared-fg-color);
           }
           .athl-escape {
             color: var(--athl-shared-fg-color);
           }
           .athl-punctuation {
             color: var(--athl-shared-fg-color);
           }
           .athl-diff-minus {
             color: var(--athl-shared-fg-color);
           }
           .athl-diff-delta {
             color: var(--athl-shared-fg-color);
           }
           .athl-string-regexp {
             color: var(--athl-shared-fg-color);
           }
           .athl-function-builtin {
             color: var(--athl-shared-fg-color);
           }
           .athl-comment-line {
             color: var(--athl-light-gray, light-gray);
             font-style: italic;
             font-weight: bold;
             text-decoration: underline;
           }
           .athl-constant-numeric-float {
             color: var(--athl-shared-fg-color);
           }
           .athl-constant-builtin {
             color: var(--athl-shared-fg-color);
           }
           .athl-punctuation-special {
             color: var(--athl-shared-fg-color);
           }
           .athl-markup-raw-inline {
             color: var(--athl-shared-fg-color);
           }
           .athl-markup-quote {
             color: var(--athl-shared-fg-color);
           }
           .athl-constructor {
             color: var(--athl-shared-fg-color);
           }
           .athl-special {
             color: var(--athl-shared-fg-color);
           }
           .athl-constant-numeric {
             color: var(--athl-shared-fg-color);
           }
           .athl-constant-character-escape {
             color: var(--athl-shared-fg-color);
           }
           .athl-label {
             color: var(--athl-shared-fg-color);
           }
           .athl-punctuation-bracket {
             color: var(--athl-shared-fg-color);
           }
           .athl-tag-builtin {
             color: var(--athl-shared-fg-color);
           }
           .athl-markup-heading-5 {
             color: var(--athl-shared-fg-color);
           }
           .athl-keyword-function {
             color: var(--athl-shared-fg-color);
           }
           .athl-constant-numeric-integer {
             color: var(--athl-shared-fg-color);
           }
           .athl-punctuation-delimiter {
             color: var(--athl-shared-fg-color);
           }
           .athl-type-enum-variant {
             color: var(--athl-shared-fg-color);
           }
           .athl-keyword-directive {
             color: var(--athl-shared-fg-color);
           }
           .athl-keyword-control {
             color: var(--athl-shared-fg-color);
           }
           .athl-markup-list-numbered {
             color: var(--athl-shared-fg-color);
           }
           .athl-keyword-operator {
             color: var(--athl-shared-fg-color);
           }
           .athl-type-builtin {
             color: var(--athl-shared-fg-color);
           }
           .athl-markup-strikethrough {
             color: var(--athl-shared-fg-color);
           }
           .athl-string-special-path {
             color: var(--athl-shared-fg-color);
           }
           .athl-function-method {
             color: var(--athl-shared-fg-color);
           }
           .athl-diff-plus {
             color: var(--athl-shared-fg-color);
           }
           .athl-markup-heading-6 {
             color: var(--athl-shared-fg-color);
           }
           .athl-variable {
             color: var(--athl-shared-fg-color);
           }
           .athl-markup-heading-2 {
             color: var(--athl-shared-fg-color);
           }
           .athl-markup-heading {
             color: var(--athl-shared-fg-color);
           }
           .athl-keyword-storage {
             color: var(--athl-shared-fg-color);
           }
           .athl-keyword-control-repeat {
             color: var(--athl-shared-fg-color);
           }
           .athl-string-special {
             color: var(--athl-shared-fg-color);
           }
           .athl-function {
             color: var(--athl-shared-fg-color);
           }
           .athl-string-special-url {
             color: var(--athl-shared-fg-color);
           }
           .athl-variable-parameter {
             color: var(--athl-shared-fg-color);
           }
           .athl-namespace {
             color: var(--athl-shared-fg-color);
           }
           .athl-comment {
             color: var(--athl-light-gray, light-gray);
             font-style: italic;
             font-weight: bold;
             text-decoration: underline;
           }
           .athl-markup-list-unnumbered {
             color: var(--athl-shared-fg-color);
           }
           .athl-markup-link-url {
             color: var(--athl-shared-fg-color);
           }
           .athl-string {
             color: var(--athl-shared-fg-color);
           }
           .athl-comment-block {
             color: var(--athl-shared-fg-color);
           }
           .athl-diff-delta-moved {
             color: var(--athl-shared-fg-color);
           }
           .athl-type {
             color: var(--athl-shared-fg-color);
           }
           .athl-variable-other {
             color: var(--athl-shared-fg-color);
           }
           .athl-constant-character {
             color: var(--athl-shared-fg-color);
           }
           .athl-markup-link-label {
             color: var(--athl-shared-fg-color);
           }
           .athl-keyword {
             color: var(--athl-shared-fg-color);
           }
           .athl-keyword-control-exception {
             color: var(--athl-shared-fg-color);
           }
           .athl-variable-other-member {
             color: var(--athl-shared-fg-color);
           }
           .athl-constant-builtin-boolean {
             color: var(--athl-shared-fg-color);
           }
           .athl-keyword-control-conditional {
             color: var(--athl-shared-fg-color);
           }
           .athl-markup-list-unchecked {
             color: var(--athl-shared-fg-color);
           }
           .athl-string-special-symbol {
             color: var(--athl-shared-fg-color);
           }
           .athl-markup-list-checked {
             color: var(--athl-shared-fg-color);
           }
           .athl-variable-builtin {
             color: var(--athl-shared-fg-color);
           }
           .athl-function-macro {
             color: var(--athl-shared-fg-color);
           }
           .athl-markup-bold {
             color: var(--athl-shared-fg-color);
           }
           """
  end
end
