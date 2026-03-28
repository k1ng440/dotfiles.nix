; extends

((nixComment) @_lang
  .
  (nixString
    (nixStringContent) @injection.content)
  (#lua-match? @_lang "^/%* lang: (%a+) %*/$")
  (#gsub! @_lang "^/%* lang: (%a+) %*/$" "%1")
  (#set! injection.language @_lang))
