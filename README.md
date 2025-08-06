# Conway's Game of Life

This is a sample application implementing a simple API controlling Conway's Game of Life boards.

As the specification was vague, we have to assume some things:

- the board coordinates are cartesian. This means that if you have an element such as element.x == 0, it might create a cell in x = -1.
- next round saves the next state. The exercise's language can mislead as it tells to return next state. We'll assume the person will use the endpoint to calculate the progression of the board.



