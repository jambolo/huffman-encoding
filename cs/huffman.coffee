# Huffman Encoding
#
# Reads a JSON frequency map from stdin and outputs a basic Huffman encoding map in JSON format to stdout.

fs = require 'fs'

# Nodes are assembled into a binary tree based on frequency
class Node
  constructor: (@symbol, @frequency, @left, @right) ->
    @code = ""
    if @left?
      @left.prefix '0'
    if @right?
      @right.prefix '1'
    return

  # Recursively prefixes my code and my childrens' codes
  prefix: (p) ->
    @code = p + @code
    if @left?
      @left.prefix p
    if @right?
      @right.prefix p
    return

huffman = (frequencies) ->
  # Move to an array of nodes
  work = []
  for s, f of frequencies
    work.push new Node s, f

  # Save the original nodes for later extraction
  leafNodes = work[..]

  # Create a tree by iteratively replacing the two lowest nodes with a parent node until there is only one node
  while work.length > 1
    # Note: popping the first two elements then sorting is basically emulating a priority queue
    work.sort (a, b) -> a.frequency - b.frequency
#    console.error ([w.symbol, w.frequency] for w in work)
    left = work[0]
    right = work[1]
    work = work[2..]  # Remove the nodes
    parent = new Node "(#{left.symbol},#{right.symbol})", left.frequency + right.frequency, left, right
    work.push parent  # Add the parent to the list

  # Get the codes of the leaf nodes
  encoded = {}
  for n in leafNodes
    encoded[n.symbol] = n.code
  return encoded

analyze = (frequencies, encoding) ->
  originalSize = 0
  originalSize += f for s, f of frequencies
  originalSize *= Math.log2(originalSize)
  encodedSize = 0
  encodedSize += code.length * frequencies[s] for s, code of encoding

  ratio = encodedSize / originalSize
  entropy = 1 - ratio

  console.error "\n\nOriginal size = #{originalSize}"
  console.error "Encoded size = #{encodedSize}"
  console.error "Compression ratio = #{Math.round(ratio * 100)}%"
  console.error "Entropy = #{Math.round(entropy * 100)}%"

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
    frequencies = JSON.parse(json)
  catch e
    console.error "Error parsing input: #{e.message}"
    return

  encoding = huffman(frequencies)
  output.end JSON.stringify(encoding)

  # Analyze results
  analyze frequencies, encoding
  return
