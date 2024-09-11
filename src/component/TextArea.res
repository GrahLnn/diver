open EditorModel

@react.component
let make = () => {
  let (state, dispatch) = useEditorState()
  let textAreaRef = React.useRef(Js.Nullable.null)

  React.useEffect(() => {
    textAreaRef.current
    ->Js.Nullable.toOption
    ->Belt.Option.flatMap(Webapi.Dom.Element.asHtmlElement)
    ->Belt.Option.forEach(Webapi.Dom.HtmlElement.focus)
    None
  }, [])

  let handleChange = event => {
    let newText = ReactEvent.Form.target(event)["value"]
    let newLines = Js.String.split("\n", newText)
    dispatch(UpdateLines(newLines))
  }

  let handleKeyDown = event => {
    if ReactEvent.Keyboard.key(event) == "Enter" {
      ReactEvent.Keyboard.preventDefault(event)
      let currentLineIndex = state.cursor.line
      let isLastLine = currentLineIndex == Belt.Array.length(state.lines) - 1
      let isAtEndOfLine =
        state.cursor.column == Js.String.length(Belt.Array.getExn(state.lines, currentLineIndex))

      if isLastLine && isAtEndOfLine {
        dispatch(AppendNewLine)
      } else {
        dispatch(InsertNewLine(currentLineIndex + 1))
      }

      // 更新光标位置
      let newCursor: EditorModel.cursor = {line: state.cursor.line + 1, column: 0}
      dispatch(UpdateCursor(newCursor))
    }
  }

  let handleCursorChange = event => {
    let target = ReactEvent.Selection.target(event)
    let selectionStart = target["selectionStart"]
    let textBeforeCursor = Js.String.substring(~from=0, ~to_=selectionStart, target["value"])
    let lines = Js.String.split("\n", textBeforeCursor)
    let currentLine = Belt.Array.length(lines) - 1
    let currentColumn = Js.String.length(Belt.Array.getExn(lines, currentLine))

    dispatch(UpdateCursor({line: currentLine, column: currentColumn}))
  }

  <div className="flex flex-col h-screen bg-gray-100">
    <textarea
      ref={ReactDOM.Ref.domRef(textAreaRef)}
      className="flex-grow p-4 font-mono text-sm resize-none bg-white focus:outline-none "
      value={state.lines->Belt.Array.joinWith("\n", x => x)}
      onChange={handleChange}
      onKeyDown={handleKeyDown}
      onSelect={handleCursorChange}
    />
    <div className="bg-gray-200 p-2 text-sm">
      {React.string(
        `行: ${Belt.Int.toString(state.cursor.line + 1)}, 列: ${Belt.Int.toString(
            state.cursor.column + 1,
          )}`,
      )}
    </div>
  </div>
}
