AtomLedger = require '../lib/atom-ledger'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "AtomLedger", ->
  it "finds dates at the beginning of a line", ->
    matches = AtomLedger.getMatches("2015/10/12 ! (100) Exxon")
    expect(matches[1]).toEqual("2015/10/12")

    matches = AtomLedger.getMatches("    Exxon")
    expect(matches).toEqual(null)

  it "finds transaction status", ->
    matches = AtomLedger.getMatches("2015/10/12 ! (100) Exxon")
    expect(matches[2]).toEqual("!")

    matches = AtomLedger.getMatches("2015/10/12 * (100) Exxon")
    expect(matches[2]).toEqual("*")

    matches = AtomLedger.getMatches("2015/10/12 (100) Exxon")
    expect(matches[2]).toEqual(undefined)

  it "toggles transaction status", ->
    expect(AtomLedger.getNewRowText("2015/10/12", "!", "Exxon")).toEqual("2015/10/12 * Exxon")
    expect(AtomLedger.getNewRowText("2015/10/12", "*", "Exxon")).toEqual("2015/10/12 Exxon")
    expect(AtomLedger.getNewRowText("2015/10/12", "", "Exxon")).toEqual("2015/10/12 ! Exxon")
