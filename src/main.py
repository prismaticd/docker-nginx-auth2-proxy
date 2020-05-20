from fastapi import FastAPI,  Request

app = FastAPI()


@app.get("/")
async def home(request: Request):
    return {"status": "ok", "user": request.headers.get('X-User'), "email": request.headers.get('X-Email')}


@app.get("/")
async def headers(request: Request):
    return {"headers": request.headers}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="127.0.0.1", port=8000, reload=True)
else:
    # We are runnign in a Docker container
    import logging
    logging.info("Visit http://localhost:8282/ for testing")