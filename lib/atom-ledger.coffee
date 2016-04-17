module.exports = AtomLedger =

  activate: ->
    atom.commands.add 'atom-text-editor',
      'atom-ledger:next-entry': => @nextEntry()
      'atom-ledger:toggle-status': => @toggleStatus()
      'atom-ledger:toggle-status-all': => @toggleStatusAll()

  toggleStatus: ->
    if editor = atom.workspace.getActiveTextEditor()
      currentRow = @getCurrentRow(editor)
      currentRowText = @getRowText(editor, currentRow)
      matches = @getMatches(currentRowText)

      if matches
        [transDate, transStatus, restOfLine] = matches[1..3]
        restOfLine = restOfLine.trim()
        newRowText = @getNewRowText(transDate, transStatus, restOfLine)
        @setRowText(editor, currentRow, currentRowText, newRowText)

  toggleStatusAll: ->
    if editor = atom.workspace.getActiveTextEditor()
      numLines = editor.getLineCount()
      for currentRow in [0..numLines-1]
        currentRowText = @getRowText(editor, currentRow)
        matches = @getMatches(currentRowText)

        if matches
          [transDate, transStatus, restOfLine] = matches[1..3]
          restOfLine = restOfLine.trim()
          newRowText = @getNewRowText(transDate, transStatus, restOfLine)
          @setRowText(editor, currentRow, currentRowText, newRowText)

  nextEntry: ->
    if editor = atom.workspace.getActiveTextEditor()
      currentRow = @getCurrentRow(editor)
      scanLength = editor.getLineCount()

      scanRange = [[currentRow+1, 0], [scanLength, 0]]
      editor.scanInBufferRange(/\d{4}\/\d+\/\d+/, scanRange, (obj) ->
        startOfMatch = obj.range.start
        editor.setCursorBufferPosition(startOfMatch)
        obj.stop())

  getNewRowText: (transDate, transStatus, restOfLine) ->
    newStatus = ''
    if transStatus == '*'
      newStatus = ' '
    else if transStatus == '!'
      newStatus = ' * '
    else
      newStatus = ' ! '

    return transDate + newStatus + restOfLine

  getCurrentRow: (editor) ->
    return editor.getCursorBufferPosition().row

  getRowText: (editor, row) ->
    currentRowText = editor.lineTextForBufferRow(row)
    return currentRowText

  setRowText: (editor, row, currentRowText, newRowText) ->
    setTextRange = [[row, 0], [row, currentRowText.length]]
    editor.setTextInBufferRange(setTextRange, newRowText)

  getMatches: (line) ->
    pattern = ///
      ^(\d{4}\/\d+\/\d+) # transaction date
      \x20               # a space
      ([\*\!])?          # optional transaction status: either * or !
      (.*)$              # rest of line
    ///
    matches = line.match(pattern)
    return matches
