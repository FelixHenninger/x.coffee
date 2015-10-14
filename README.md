# x.coffee

__An implementation of [Knuth's Algorithm X](https://en.wikipedia.org/wiki/Knuth's_Algorithm_X) in [CoffeeScript](http://coffeescript.org/).__

This package provides a basic implementation of Knuth's algorithm for finding solutions to an exact cover problem.

The implementation is based on [Ali Assaf's Python implementation](http://www.cs.mcgill.ca/~aassaf9/python/algorithm_x.html), translated, commented and extended slightly.

## Usage example

The following problem is taken from the algorithm's [Wikipedia page](https://en.wikipedia.org/wiki/Knuth's_Algorithm_X#Example), where it is explained in greater detail.

```javascript
x = require('./x.js')

constraints = {
  1: ['A', 'B'],
  2: ['E', 'F'],
  3: ['D', 'E'],
  4: ['A', 'B', 'C'],
  5: ['C', 'D'],
  6: ['D', 'E'],
  7: ['A', 'C', 'E', 'F']
}

x.solve(constraints).next().value
// -> ['B', 'D', 'F']
```
