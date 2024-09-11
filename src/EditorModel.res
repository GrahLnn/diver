type line = string
type t = array<line>
type cursor = {
  line: int,
  column: int,
}

type state = {
  lines: t,
  cursor: cursor,
}

type action =
  | UpdateLines(t)
  | UpdateCursor(cursor)
  | InsertNewLine(int)
  | AppendNewLine // 新增的动作

let reducer = (state, action) => {
  switch action {
  | UpdateLines(newLines) => {...state, lines: newLines}
  | UpdateCursor(newCursor) => {...state, cursor: newCursor}
  | InsertNewLine(position) => {
      let before = Belt.Array.slice(state.lines, ~offset=0, ~len=position)
      let after = Belt.Array.sliceToEnd(state.lines, position)
      let newLines = Belt.Array.concat(Belt.Array.concat(before, [""]), after)
      {...state, lines: newLines}
    }
  | AppendNewLine => {
      let newLines = Belt.Array.concat(state.lines, [""])
      {...state, lines: newLines}
    }
  }
}

let initialState = {
  lines: [""],
  cursor: {line: 0, column: 0},
}

let useEditorState = () => React.useReducer(reducer, initialState)

let getLineContent = (state, lineNumber) =>
  Belt.Array.get(state.lines, lineNumber)->Belt.Option.getWithDefault("")

let getLineCount = state => Belt.Array.length(state.lines)