# Converts a Huffman coding to canonical form
#
# Reads a JSON Huffman encoding map from stdin and outputs the canonical encoding in JSON to stdout.
#
# In a canonical encoding, no code can be a prefix of any other code, and codes have the smallest numerical values
# possible without changing the length of the code.
#
# The conversion algorithm:
# Codes are sorted and grouped by length. For each group, if the length of the codes is m, then the previous group's
# next unused code is extended with 0's to m bits and each code is assigned sequentially.

fs = require 'fs'

# Increments a binary string
increment = (s) ->
  original = s
  i = s.length - 1
  while i >= 0 and s[i] is '1'
    s = s.substring(0, i) + '0' + s.substring(i + 1)
    --i
  s = s.substring(0, i) + '1' + s.substring(i + 1) if i >= 0
  return s

# Returns a canonical encoding
canonical = (encoding) ->
  # Move to an array for sorting by code length
  work = []
  work.push {symbol, code} for symbol, code of encoding

  # Sort by code length
  work.sort (a, b) -> a.code.length - b.code.length

  # Replace the codes
  code = ''
  for w in work
    # If the code length has changed, then reset for a new group
    if w.code.length > code.length
      code = code + '0'.repeat(w.code.length - code.length)
    w.code = code
#    console.error w
    code = increment(code)

  canonicalized = {}
  canonicalized[w.symbol] = w.code for w in work
  return canonicalized


json = ""

input = process.stdin
input.setEncoding('utf8')

output = process.stdout

input.on 'error', (e) ->
  console.error e.message
  process.exit 1
  return

input.on 'data', (chunk) ->
  json += chunk
  return

input.on 'end', () ->
  try
    code = JSON.parse(json)
  catch e
    console.error "Error parsing input: #{e.message}"
    return

  canonicalized = canonical(code)
  output.end JSON.stringify(canonicalized)
 return
