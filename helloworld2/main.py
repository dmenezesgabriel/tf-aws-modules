from fastapi import APIRouter, FastAPI

app = FastAPI()
router = APIRouter()


@router.get("/")
def read_root():
    return {"message": "Hello World 2"}


app.include_router(router, prefix="/app2")
