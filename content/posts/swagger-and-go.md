---
title: "OpenAPI and Go"
date: 2018-07-14T11:00:00+02:00
tags: ["blog"]
categories: ["go"]
---

In this blog post we will first discuss OpenAPI (formerly know as Swagger), before
we will explore a code generation tool called go-swagger.

### OpenAPI vs Swagger

The OpenAPI Specification formerly know as Swagger Specification is a DSL (domain specific
language) for describing REST APIs.
 
 > _OpenAPI Specification is an API description 
format for REST APIs. An OpenAPI file allows you to describe your entire API_
([Source](https://swagger.io/docs/specification/about/))

The specification was currently published in his 3rd version and is developed by 
_Open API Initiative_, an open source collaborative project of the Linux Foundation.

An OpenAPI file can be written in YAML or JSON.

There are many tools that can help you to create, edit, design and generate code of these
files. These tools are defined as Swagger.

- [Swagger Editor](http://editor.swagger.io/?_ga=2.67802775.727341211.1531501053-1913297280.1531501053) 
– browser-based editor where you can write OpenAPI specs.
- [Swagger UI](https://swagger.io/tools/swagger-ui/) 
– renders OpenAPI specs as interactive API documentation.
- [Swagger Codegen](https://github.com/swagger-api/swagger-codegen) 
– generates server stubs and client libraries from an OpenAPI spec.

### Why use OpenAPI

Usually when creating and designing REST APIs three parties are involved: The architect(s), the service 
owner(s) and the service consumer(s). OpenAPI can help you to satisfy all involved parties in a 
high scale manner.

- Collaboration - all parties fully understand what is being developed. How it will integrate, 
what it is being expected to do, and how it will behave.

- Consistency - a client generated from a OpenAPO file will know how to talk to a server 
generated from the same file.

- Concurrency - Using OpenAPI files, the owner and the consumer can work independently, 
and even test independently and meet only in integration stage for final tests of their 
implementations. 

- Adaptability - APIs can be easily changed using re-generation of the code.

- Reflectivity - the server has a defined endpoint which can be documented to the service customers.

- Language Agnostic - even though the server is implemented in a specific language, 
consumers can be in any language, and clients  can be automatically generated 
from the service defined specification.

### Alternatives

Like OpenAPI you can use [RAML](https://raml.org/) as a DSL for describing REST APIs.

### Example

Let's take the example [Swagger Editor](http://editor.swagger.io/?_ga=2.67802775.727341211.1531501053-1913297280.1531501053)
and strip it down to a miminal configuration.

It incluces three endpoints: list-pet, create-pet and get-pet operations, with a defintion of a 
pet object.

It is pretty descriptive, so I won’t explain how to write an OpenAPI file.
 
The example is here just to get a feeling what you are going into.

```yaml
swagger: '2.0'
info:
  version: '1.0.0'
  title: Minimal Pet Store Example
schemes: [http]
host: example.org
basePath: /api
consumes: [application/json]
produces: [application/json]
paths:
  /pets:
    post:
      tags: [pet]
      operationId: Create
      parameters:
      - in: body
        name: pet
        required: true
        schema:
          $ref: '#/definitions/Pet'
      responses:
        201:
          description: Pet Created
          schema:
            $ref: '#/definitions/Pet'
        400:
          description: Bad Request
    get:
      tags: [pet]
      operationId: List
      parameters:
      - in: query
        name: kind
        type: string
      responses:
        200:
          description: 'Pet list'
          schema:
            type: array
            items:
                $ref: '#/definitions/Pet'
  /pets/{petId}:
    get:
      tags: [pet]
      operationId: Get
      parameters:
      - name: petId
        in: path
        required: true
        type: integer
        format: int64
      responses:
        200:
          description: Pet get
          schema:
            $ref: '#/definitions/Pet'
        400:
          description: Bad Request
        404:
          description: Pet Not Found

definitions:
  Pet:
    type: object
    required:
    - name
    properties:
      id:
        type: integer
        format: int64
        readOnly: true
      kind:
        type: string
        example: dog
      name:
        type: string
        example: Bobby
```

### go-swagger

[go-swagger](https://github.com/go-swagger/go-swagger/blob/master/docs/install.md) is a tool for 
go developers to generate go code from swagger files.

#### Example

First have a look at the [docs](https://github.com/go-swagger/go-swagger/blob/master/docs/install.md)
to install the `swagger` command.

##### Generating a Server

The only requirements for this to work is to have a swagger.yaml in the current working directory, 
and that this directory will be somewhere inside the `GOPATH`.

```bash
$ # working directory
$ pwd
/home/chris/go/src/example.org
$ # swagger.yaml
$ ls
swagger.yaml
$ # Validate the swagger file
$ swagger validate ./swagger.yamlThe swagger spec at "swagger.yaml" is valid against swagger specification 2.0
$ # Generate server code
$ swagger generate server
$ # go get dependencies, alternatively you can use `dep init` or `dep ensure` to fix the dependencies.
$ go get -u ./...
$ # The structure of the generated code
$ ls                                                                                                               18.7s  Sa 14 Jul 2018 12:28:28 CEST
cmd/  models/  restapi/  swagger.yaml
$ # Run the server in a background process
$ go run cmd/minimal-pet-store-example-server/main.go --port 8080 &
2018/07/14 12:30:07 Serving minimal pet store example at http://127.0.0.1:8080
$ # go-swagger serves the swagger scheme on /swagger.json path:
$ curl -s http://127.0.0.1:8080/swagger.json | head
  {
    "consumes": [
      "application/json"
    ],
    "produces": [
      "application/json"
    ],
    "schemes": [
      "http"
    ],
 # Test list pets
$ curl -i http://127.0.0.1:8080/api/pets
HTTP/1.1 501 Not Implemented
Content-Type: application/json
Date: Sat, 14 Jul 2018 10:32:16 GMT
Content-Length: 50

"operation pet.List has not yet been implemented"
$ # Test enforcement of scheme - create a pet without a required property name.
$ curl -i http://127.0.0.1:8080/api/pets \
    -H 'content-type: application/json' \
    -d '{"kind":"cat"}'
HTTP/1.1 422 Unprocessable Entity
Content-Type: application/json
Content-Length: 49

{"code":602,"message":"name in body is required"}    
```