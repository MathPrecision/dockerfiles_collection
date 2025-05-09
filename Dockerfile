#A premade docker image with python on Ubuntu is fetched from .../library and is set as parent image. If no premade parent image shall be set, FROM scratch is used.
FROM .../library/python:3-ubuntu24.04

#/app is being set as working directory. If /app did not exist, /app would be created. WORKDIR creates a new image layer.
WORKDIR /app

#RUN is a key-expression which executes a command within the container shell. "RUN" creates a new image layer.
#"apt-get" is a tool, which is used on Linux systems like Ubuntu to manage packages.
#"apt-get update" updates the list of avaiable packages and their versions.
RUN apt-get update 
#"RUN apt-get update" is not really required in our case beacause there is no apt-get command that follows. Anyways "RUN apt-get update" is best practice.

#The environment variable VIRTUAL_ENV is defined as opt/venv, which is the commonly used path for optional software packages on Unix systems
ENV VIRTUAL_ENV=/opt/venv

#creates a python venv at $VIRTUAL_ENV (opt/venv). Like every RUN expression, this expression creates another layer.
RUN python3 -m venv $VIRTUAL_ENV

#append opt/venv/bin to the left side of the "PATH" variable. $PATH contains a collection of directories.
#As a file is trying to be executed, it is looked up in the directories located in "PATH". "PATH" is looked through from left to right. 
#By appending "VIRTUAL_ENV" to the existing "PATH" to the left side ("$VIRTUAL_ENV:$PATH"), we assure to prioritize files in "VIRTUAL_ENV" on execution. 
#If we try to run a python file, the "python file/version for execution" is looked up in "PATH" from left to right, so the venv is used. 
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
#Unlike .venv\scripts\activate in powershell, the venv is not being activated in docker. By assigning our "VIRTUAL_ENV" to "PATH", we assure that the files are launched from our venv (if avaiable) first.

#needed during build -> COPY necessary (Rest will be mounted into the container @runtime - see docker compose)
COPY . /app/
#To pick up on our previous ENV commands: If we run pip, pip is looked for along our PATH, leading to the pip in $VIRTUAL_ENV being executed.
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

#Shows that Port 8501 going to be used and is listening. Mainly documentation purpose
EXPOSE 8501

# Run Streamlit when the container starts
# server.adress = 0.0.0.0 ensures, that the service can be accsesed from outside the container
#otherwise it would only listen to localhost inside the container
#By default the first command that is executed when the container is started.
CMD ["streamlit", "run", "dashboard/Home.py", "--server.port=8501", "--server.address=0.0.0.0"]

#this needs a mapping when running. this:
# docker run -p 8502:8501 your_image_name
#maps the exposed port of the container to 8502 on localhost, so localhost:8502 is where the app is running
#or use docker compose up and specify this in the docker-compose.yml
