from fastapi import FastAPI

app = FastAPI()

@app.get("/visits")
def get_visits():
    return {"count": 123}