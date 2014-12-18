require 'redsnow'

result = RedSnow.parse('# My API', exportSourcemap: true)
puts result.ast.name
puts result.sourcemap.name
