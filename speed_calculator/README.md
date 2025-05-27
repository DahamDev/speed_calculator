# Final Speed calculation API
This API takes the initial speed and incline values and calculate the final speed

## Installation

```bash
pip install -r requirements.txt
```

## Configuration

Configure the application by editing the `.env` file:

```
API_PORT=8000
```

## Running the Application

```bash
python run.py
```

## To run unit tests
```bash
python -m pytest tests/unit -v
```


## To run the API as a container

- build the docker container
```bash
docker build -t speedapi:1.0.0 .
```

- run the container
```
docker run -d -p <hostport>:<apiport> speedapi:1.0.0
```

## API Documentation

- Swagger UI: http://localhost:8000/docs

