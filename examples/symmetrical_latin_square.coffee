x = require '../x.js'
_ = require 'lodash'

triangular = (i) ->
  # Calculate the ith triangular number
  i * (i + 1) / 2

inverse_triangular = (i) ->
  # For a given integer i, find its
  # position on the (virtual) continuum
  # of triangular numbers
  Math.sqrt(8 * i + 1) / 2 - 0.5;

triangular_coordinates = (i) ->
  # Find a pair of [row, column] coordinates
  # for a cell i where i numbers cells
  # under the main diagonal horizontally
  # from the top left
  row = Math.ceil(inverse_triangular i)
  column = i - triangular(row - 1) - 1

  [row, column]

linear_coordinates = (row, column, n, skip_diagonal=true) ->
  # Map a matrix cell coordinate onto
  # a simple linear mapping where cells
  # are counted from left to right,
  # top to bottom, ommitting the diagonal
  # by default.
  if skip_diagonal
    diagonals_seen = row
    # If we go beyond the diagonal,
    # there is one more cell to skip
    if column > row
       diagonals_seen += 1;
  else
    diagonals_seen = 0

  row * n + column - diagonals_seen

decode_suggestion = (id, n) ->
  # Suggestions have predictable ids that
  # map onto coordinates and values at
  # these coordinates.
  # This function maps an id onto the
  # corresponding information.
  value = id % (n - 1) + 1
  [row, column] = triangular_coordinates(
    (id - value + 1) / (n - 1) + 1
    )

  return [row, column, value]

generate_suggestions = (n) ->
  # Generate a set of constraints that
  # correspond to all possible entries
  # in a symmetrical latin square.


  # Create an empty constraint dictionary
  suggestions = {}

  # Populate the array with suggestions,
  # and the constraints they fulfill.
  # The number of possible entries that
  # need to be computed is n-1 (for the
  # set of numbers used) times (n - 1) *
  # n / 2 (for the cells they can occupy)
  for i in _.range(Math.pow(n - 1, 2) * n / 2)
    # Compute the value, row and column
    # for any instance i
    [row, column, value] = decode_suggestion i, n

    #console.log "Suggestion #{ i }: Value #{ value } at #{ [row, column] }"

    # Create an empty constraint array
    c = []

    # Define constraints ---------------
    # 1: Each suggestion populates two cells
    #    of the matrix (because of symmetry)
    c.push(linear_coordinates row, column, n)
    c.push(linear_coordinates column, row, n)

    # 2: Each suggestion places a value in
    #    two rows and columns
    #    (again, symmetry doubles entries)
    c.push n * (n - 1) + n * row + (value - 1)
    c.push n * (n - 1) + n * column + (value - 1)

    suggestions[i] = c

  return suggestions

suggestions_to_matrix = (suggestions, n) ->
  # The solver returns a set of suggestions
  # which together cover all requirements.
  # This function turns the constraints back
  # into a latin square
  m = (new Array(n) for i in [1..n])

  for s in suggestions
    [row, column, value] = decode_suggestion s, n
    m[row][column] = value
    m[column][row] = value

  # Return matrix
  m

symmetrical_latin_square = (n) ->
  # Put together the steps defined above
  # to compute a symmetrical latin square
  # in a single step.
  # Acts as an iterator in case additional
  # matrices are needed.
  # (Though we recommend that these be
  # perturbed additionaly since they will
  # not be independent of previous matrices)
  suggestions = generate_suggestions n
  constraints = x.invert suggestions

  # CoffeeScript does not support for..of,
  # and I could find no other way.
  `for (s of x.solve(constraints)) {`
  yield suggestions_to_matrix(s, n)
  `}`

  return null

if module.parent
  module.exports =
    symmetrical_latin_square: symmetrical_latin_square
    generate_suggestions: generate_suggestions
else
  console.log 'Generating a symmetrical latin square ...'
  console.log symmetrical_latin_square(10).next().value
