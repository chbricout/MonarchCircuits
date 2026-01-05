FROM rapidsai/base:25.12-cuda12-py3.10

# Set the working directory
WORKDIR /app

RUN python -m pip install --upgrade pip

COPY requirements.txt ./

RUN pip install --no-cache-dir -r requirements.txt

