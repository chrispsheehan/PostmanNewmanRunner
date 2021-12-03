# PostmanNewmanRunner

Docker image to run postman tests in CI.

## Run Locally

- Run locally inside of `src`

``` bash
cd src
```

- Prefixing commands with `make`
- Full Example;

``` bash
make get-environment envname="[EnvironmentName]"
```

## Run with Docker

- Build image locally.

``` bash
docker build . -t postman-newman:[YourNewTag]
```

- Append commands to the below.

``` bash
docker run --rm postman-newman:[YourNewTag]
```

- Full Example;

``` bash
docker run --rm postman-newman:[YourNewTag] get-environment envname="[EnvironmentName]"
```

### Pull enviroment from postman API

``` bash
get-environment envname="[EnvironmentName]"
get-environment envid=40cdb6c1-41e5-4d1d-8046-054dba6375d
```

### Pull collection from postman API

``` bash
get-collection collname="[CollectionName]" forkname="master"
get-collection collname="[CollectionName]"
```

### Run single folder

``` bash
run-tests envname="[EnvironmentName]" collname="[CollectionName]" folder="[FolderName]" slackwebhook=""
```

### Run from file defined list of folders

- File content

``` json
[
    "[FolderName1]",
    "[FolderName2]",
    "[FolderName1]",
    "[FolderName3]"
]
```

``` bash
run-test-list envname="[EnvironmentName]" collname="[CollectionName]" folderlist=[PathToJsonFile] slackwebhook=""
```

- note a volume mount is required for docker. As per below.

``` bash
docker run --rm -v /Users/Shared/Docker/:/etc/newman/lists
```

### Override postman params

- Append the below

``` bash
additonalparams="--env-var baseUrl=foo"
```
