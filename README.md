# Conway's Game of Life

This is a sample application implementing a simple API controlling Conway's Game of Life boards.

As the specification was vague, we assumed:

- the board coordinates are cartesian. This means that if you have an element such as element.x == 0, it might create a cell in x = -1. This creates a freedom and a problem as we do not specify height and width.
- The next round endpoint (`POST /boards/:id/next_round`) saves the next state. The exercise's language can mislead as it tells to return next state. We'll assume the person will use the endpoint to calculate the progression of the board.
- the "gets x number of states away for board" endpoint returns the number of remaining rounds. I was not sure if I was to emulate a new state and return it (seems unlikely) or the number of states (x number of states away) remaining until the game of life stops.
- as the final state for the board, I did not save the state. From the understanding, as this was not specified, the only endpoint that really needs saving is the progression one (next round). Note: if doing progressions and having to save the result, of course, do not save for each iteration.

## Endpoints for this task

| Endpoint | Description |
| -------- | ----------- |
| POST /boards | Create a new board. Returns the ID of the board. Accepts the state as an array of an array of integers and a board of up to 100x100 (x and y 0-99) (e.g. `{ "state": [[1, 1], [1, 2], [2, 1], [2, 2]], width: 50, height: 50 }`). This endpoint supports providing an idempotency key. Returns a JSON with the board ID in an `{ id: 1 }` format. |
| POST /boards/:id/next_round | Advances a round. Returns the state in the same format as the array of integers provided in the creation process. As we are in a stateless environment, it does not check for the MAX_ROUNDS value, as we need to check whether MAX_ROUNDS refers to the maximum rounds for a board or for the current request. This endpoint supports providing an idempotency key. Returns the state in the same format as the `state` hash above (e.g. `{ "state": [[1, 1], [1, 2], [2, 1], [2, 2]], width: 50, height: 50 }`). |
| POST /boards/:id/progress | Progresses the board for either 100 steps (Boards::MAX_ROUNDS) or returns the final state of the board. If erroring, returns a 422 error. Returns the board in the same format (e.g. `{ "state": [[1, 1], [1, 2], [2, 1], [2, 2]], width: 50, height: 50 }`). |
| GET /boards/:id/remaining_rounds | Gets the number of remaining rounds to complete the current board status. If the current board is static (e.g. a square), returns 0. If the board is unprocessable, returns -1. |

To provide an idempotency key, meaning that we will in this case make an effort to return the endpoint result instead of processing the request twice, please include an `Idempotency-Key` header for the request. The header is a string with at most 100 characters.

If formal documentation for this endpoint is needed, we can use a gem such as Grape to automatically generate it. In order to keep the time constraints down, other possible additions such as dry-rb (typing the services and using it as a contract would be a nice to have) were not applied.

## Running this application

Before running the application locally, please run these commands to build the application and do the first database migration (we can use db:migrate here):

```
$ docker compose build
$ docker compose run conway rails db:migrate
```

And, to run the application locally:

```
$ docker compose up
```


### "Production"

To run this application in a production environment, please do the steps necessary to reproduce this sequence. Please replace the `DB_` prefixed variables. Here we use the variables that would work if mysql and redis are running from `docker-compose.yml`.

```
$ docker build -t conway .
$ docker run -p 3000:3000 \
    -e SECRET_KEY_BASE=(random key) \
    -e DB_HOST=172.17.0.1 \
    -e DB_PORT=3306 \
    -e DB_USER=conway \
    -e DB_PASSWORD=conway \
    -e DB_NAME=conway_development \
    -e REDIS_URL=redis://172.17.0.1:6379 \
    conway
```

To avoid random Rails shutdowns, we use supervisor to restart the server if necessary.

## Rails choices

This application uses PORO services to avoid adding new dependencies. This also can be a challenge because either we can show compliance to using a framework (e.g. dry-rb contracts) or doing checks for the input. However, not using a standardized library also made remembered the limitation of Rails strong parameters where it is still problematic to specify clearly that we need an array of integers. Even if the input could be changed to an array of hashes (e.g. `[{ "x": 1, "y": 1 }]`), I made the decision of keeping the previously intended state definition to remember we do not always control the input a third party will send to your server (e.g. a webhook server).
