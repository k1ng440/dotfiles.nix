; extends

((short_var_declaration
   left: (_) ; variable name
   (comment) @comment
   right: (expression_list
            (interpreted_string_literal
              (interpreted_string_literal_content) @injection.content))
 )
 (#match? @comment "^/\\*\\s*sql\\s*\\*/$")
 (#set! @injection.content @comment 0))
