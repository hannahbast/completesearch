# CompleteSearch Docker Setup

CompleteSearch is a fast and interactive search engine for what we call *context-sensitive prefix search* on a given collection of documents.
The techniques and features behind CompleteSearch are described in full detail in [this paper](https://pdfs.semanticscholar.org/ba12/7643fadeed05eed91b0714a5f85444e8df71.pdf).
A fully-functional demo using [DBLP](https://dblp.uni-trier.de/) as document collection can be found [here](http://dblp.informatik.uni-freiburg.de).

This repository provides a very easy to use installation setup for CompleteSearch using Docker, including information how to build an index, how to start a backend server and how to setup a simple frontend.

## Quickstart

We now show how this Docker setup can be used to install an instance of CompleteSearch using DBLP as the document collection.
The information given are not specific to DBLP and can be also used, in principle, to install other CompleteSearch instances based on other document collections (e.g., Wikipedia or the [Vorlesungsverzeichnis of the University of Freiburg](http://vvz.tf.uni-freiburg.de/)).  

### 1. Checkout
Checkout the repository

    git clone https://ad-git.informatik.uni-freiburg.de/ad/completesearch-docker
    cd completesearch-docker                                                      

### 2. Build an index

Building an index requires the following two arguments:
* *<DB\>* :
The name of the database to build the index from.
This name must correspond to the name of a folder in the `./databases` directory that provides all source code files (e.g., the source code files of the parser to use for parsing the database files in *<DATA_DIR>*) specific to this database.
* *<DATA_DIR\>* :
The path to the directory that provides the database file(s) to parse.
The basename of the database file(s) must be *<DB\>*, and the file type must match the type expected by the used parser.
For example, if the value of *<DB\>* is "dblp", and the expected type is xml, the directory must contain a file `dblp.xml`.
Also, all index- and intermediate files will be stored in this directory, so make sure that the container has write access to this directory.

#### docker-compose

To build an index by using **docker-compose**, open docker-compose.yml and change the values of *<DB\>* and *<DATA_DIR\>* in the *index-builder* service:
```yml
index-builder:
  build:
    context: .
    dockerfile: ./Dockerfile.index-builder
  image: completesearch:index-builder
  environment:
    - DB=<DB>
  volumes:
    - <DATA_DIR>:/data:rw
```
Afterwards, type

    docker-compose up -d index-builder

#### docker

To build an index by using **docker**, type:

    # Build a container.
    docker build -f Dockerfile.index-builder -t completesearch:index-builder .
    # Run the container.
    docker run -e DB=<DB> -v <DATA_DIR>:/data -it completesearch:index-builder

### 3. Start the backend

Starting the backend requires the following two arguments:
* *<DB\>* :
The name of the database to start a backend for.
This name must correspond to the database name used in the previous step.
* *<DATA_DIR\>* :
The path to the directory that provides the index files created in the previous step.

#### docker-compose
To start the backend by using **docker-compose**, open `docker-compose.yml` and change the values of *<DB\>* and *<DATA_DIR\>* in the *backend* service:

```yml
backend:
  build:
    context: .
    dockerfile: ./Dockerfile.backend
  image: completesearch:backend
  environment:
    - DB=<DB>
  volumes:
    - <DATA_DIR>:/data:rw
```
Afterwards, type:

    docker-compose up -d backend

#### docker
To start the backend by using **docker**, type:

    # Build a container.
    docker build -f Dockerfile.backend -t completesearch:backend .
    # Run the container.
    docker run -e DB=<DB> -v <DATA_DIR>:/data -it completesearch:backend

### 4. Set up the frontend

TODO: Apache config on the host.

Setting up the frontend for searching DBLP requires the following four arguments:
* *<BACKEND_HOST\>* :
The host name of the backend. When you use *docker-compose*, this is equal to the name of the backend service ("*backend*").
* *<BACKEND_PORT\>* :
The port of the backend server **inside** the backend container (which is *8181* per default).
* *<FRONTEND_PORT\>* :
The port under which the frontend should be available **outside** the container.
* *<SERVER_NAME\>* :
TODO

#### docker-compose
To start the frontend by using **docker-compose**, open `docker-compose.yml` and change the values of *<BACKEND_HOST\>*, *<BACKEND_PORT\>*, *<FRONTEND_PORT\>* and *<SERVER_NAME\>* in the *frontend-dblp* service:

```yml
frontend-dblp:
  build:
    context: .
    dockerfile: ./Dockerfile.frontend-dblp
    args:
      - BACKEND_HOST=<BACKEND_HOST>
      - BACKEND_PORT=<BACKEND_PORT>
      - SERVER_NAME=<SERVER_NAME>
  image: completesearch:frontend-dblp
  ports:
    - 0.0.0.0:<FRONTEND_PORT>:80
```
Afterwards, type:

    docker-compose up -d frontend-dblp

#### docker
To start the frontend by using **docker**, type:

    # Build a container.
    docker build -f Dockerfile.frontend-dblp --build-arg BACKEND_HOST=<BACKEND_HOST> --build-arg BACKEND_PORT=<BACKEND_PORT> --build-arg SERVER_NAME=<SERVER_NAME> -t completesearch:frontend-dblp .
    # Run the container.
    docker run -p 0.0.0.0:<FRONTEND_PORT>:80 -it completesearch:frontend-dblp