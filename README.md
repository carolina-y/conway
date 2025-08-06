# Conway's Game of Life

This is a sample application implementing a simple API controlling Conway's Game of Life boards.

As the specification was vague, we have to assume some things:

- the board coordinates are cartesian. This means that if you have an element such as element.x == 0, it might create a cell in x = -1. This creates a freedom and a problem as we do not specify height and width.
- next round saves the next state. The exercise's language can mislead as it tells to return next state. We'll assume the person will use the endpoint to calculate the progression of the board.
- the "gets x number of states away for board" endpoint returns the number of remaining rounds. I was not sure if I was to emulate a new state and return it (seems unlikely) or the number of states (x number of states away) remaining until the game of life stops.
- as the final state for the board, I did not save the state. From the understanding, as this was not specified, the only endpoint that really needs saving is the progression one (next round). Note: if doing progressions and having to save the result, of course, do not save for each iteration.

## Endpoints for this task

| Endpoint | Description |
| -------- | ----------- |
| POST /boards | Create a new board. Returns the ID of the board. Accepts the state as an array of an array of integers (e.g. [[1, 1], [1, 2], [2, 1], [2, 2]]). |
| POST /boards/:id/next_round | Advances a round. Returns the state in the same format as the array of integers provided in the creation process. As we are in a stateless environment, it does not check for the MAX_ROUNDS value, as we need to check whether MAX_ROUNDS refers to the maximum rounds for a board or for the current request. |
| POST /boards/:id/progress | Progresses the board for either 100 steps (Boards::MAX_ROUNDS) or returns the final state of the board. If erroring, returns a 422 error. |
| GET /boards/:id/remaining_rounds | Gets the number of remaining rounds to complete the current board status. If the current board is static (e.g. a square), returns 0. If the board is unprocessable, returns -1. |

If formal documentation for this endpoint is needed, we can use a gem such as Grape to automatically generate it. In order to keep the time constraints down, other possible additions such as dry-rb (typing the services and using it as a contract would be a nice to have) were not applied.

## Running this application

To run the application, you can execute `docker compose up` in this directory and connect to port 3000, which is exported.
