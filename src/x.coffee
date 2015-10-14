_ = require 'lodash'

invert_constraints = (c) ->
  # CoffeeScript (sadly) does not
  # support "for of", and I'm lazy
  output = {}
  `for (row of Object.keys(c)) {
    for (entry of c[row]) {
      output[entry] = output[entry] || []
      output[entry].push(row)
    }
  }`
  output

# Solve an exact cover problem, given a dictionary
# of constraints, each containing an array of of
# the exemplars which satisfy them, and a (redundant)
# dictionary of exemplars with values indicating the
# constraints covered by the respective exemplar.
#
# Together, both data structures represent a sparse
# matrix with (typically) exemplars represented by
# rows and constraints by columns.
#
# Please note that I personally prefer a literal
# notation, but feel free to replace constraints by X
# and exemplars by Y to get closer to the original
# notation.
solve = (constraints, exemplars, solution=[]) ->
  if _.isEmpty(constraints)
    # If there are no contraints left to solve,
    # we have found a valid solution.
    yield solution
  else
    # Otherwise, keep searching ...

    # Find the constraint that is satisfied by the
    # smallest number of exemplars
    min_length = _.min _.map(constraints, (c) -> c.length)
    constraint = _.findKey constraints, (c) -> c.length is min_length

    # For each of the exemplars that would satisfy
    # this constraint, ...
    for r in constraints[constraint]
      # ... tentatively add the candidate exemplar to the
      # solution (this would be a row in the constraint
      # matrix, which is why it is labeled r)
      solution.push(r)

      # Given this candidate, remove from further
      # consideration all candidates that satisfy
      # any of the constraints now covered,
      # but save them temporarily
      exemplars_removed = filter_constraints constraints, exemplars, r

      # Recurse by solving the problem with the
      # new subset of remaining constraints
      `for (s of solve(constraints, exemplars, solution)) {
        yield s
      }`
      # Again, this should really be
      #for s of solve(constraints, exemplars, solution)
      #  yield s

      # After considering this candidate,
      # undo the changes made above: restore the
      # constraints previously discarded, and remove
      # the most recent candidate from the proposal
      restore_constraints constraints, exemplars, r, exemplars_removed
      solution.pop()

    return

filter_constraints = (constraints, exemplars, candidate) ->
  # Filter the constraints so that any constraint
  # satisfied by the candidate is removed,
  # and any other exemplar that would double-cover
  # any of the constraints is removed likewise.
  #
  # Note how the exemplar object, which contains
  # the same information as does the constraints object,
  # is never changed.
  exemplars_removed = []

  # For every constraint solved by a candidate ...
  for j in exemplars[candidate]
    # For every exemplar that solves this constraint ...
    for i in constraints[j]
      # ... and every constraint solved by each of
      # these exemplars
      for k in exemplars[i]
        if k != j
          # ... remove the exemplar from further
          # consideration, as it would double-
          # cover the constraint.
          _.remove(constraints[k], (x) -> x is i)

    # ... remember this constraint, and then
    # remove it from further consideration
    # (because it has been satisfied by the interim
    # proposal)
    exemplars_removed.push(constraints[j])
    delete constraints[j]

  # Return an array of the exemplars thus
  # deleted in this step.
  exemplars_removed

restore_constraints = (constraints, exemplars, r, exemplars_removed) ->
  # This function is the inverse of the one above:
  # Given a reduced set of constraints, the
  # candidate which has been used to filter it,
  # and an array of the exemplars removed,
  # restore the constraints to their previous state.

  # For each of the constraints satisfied by our
  # candidate exemplar ...
  for j in exemplars[r].reverse()
    # Add a previously removed constraint
    constraints[j] = exemplars_removed.pop()
    for i in constraints[j]
      for k in exemplars[i]
        if k != j
          constraints[k].push(i)

module.exports =
  solve: (c) ->
    solve(
      c, invert_constraints c
    )
  invert: invert_constraints
