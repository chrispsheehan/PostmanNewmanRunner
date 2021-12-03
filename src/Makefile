uri = https://api.getpostman.com
apikey ?= [DefaulValue]

slackuri = https://hooks.slack.com/services
slackwebhook ?= [DefaulValue]

globalvariables ?= globals.json
collectionsfile = collections.json
environmentsfile = environments.json
defaultfork = master
basefolder = /etc/newman

additonalparams ?=
envid ?=
envname ?=
collid ?=
collname ?=
forkname ?=
folder ?=
folderlist ?=

################## Logic to get env file ######################

ifeq ($(strip $(nodownload)),)
get-environment: | pull-environment 
	$(info environment downloaded)
else
get-environment:
	$(info no download as in no download mode)
endif	

pull-environment:
    envfile = env_$(envid).json
pull-environment: | get-environment-id 
	curl -s GET $(uri)/environments/$(envid)?apikey=$(apikey) | jq -r '.' > "$(envfile)"

download-enviroments-file:
	curl -s GET $(uri)/environments?apikey=$(apikey) | jq -r '.' > "$(environmentsfile)"

ifeq ($(strip $(envid)),)
get-environment-id: download-enviroments-file
	$(if $(envname), $(info finding id for enviroment $(envname)) ,$(error envname or envid must be specified))
	$(eval override envid := $(shell cat $(environmentsfile) | jq -r '[.environments[] | select(.name == "$(envname)")][0].uid'))
	$(if $(findstring $(envid),null), $(error environment with name $(envname) not found in postman API.), $(info environment id is $(envid)))
else
get-environment-id: download-enviroments-file
	$(info using environment id $(envid))
	$(eval override envname := $(shell cat $(environmentsfile) | jq -r '[.environments[] | select(.uid == "$(envid)")][0].name'))
	$(if $(findstring $(envname),null), $(error environment with id $(envid) not found in postman API.), $(info environment name is $(envname)))
endif


################## Logic to get collection file ######################

ifeq ($(strip $(nodownload)),)
get-collection: | pull-collection
	$(info collection downloaded)
else
get-collection:
	$(info no download as in no download mode)
endif

pull-collection:
    collfile = coll_$(collid).json
pull-collection: | get-collection-id
	curl -s GET $(uri)/collections/$(collid)?apikey=$(apikey) | jq -r '.' > "$(collfile)"

download-collections-file:
	curl -s GET $(uri)/collections?apikey=$(apikey) | jq -r '.' > "$(collectionsfile)"

ifeq ($(strip $(collid)),)
get-collection-id: download-collections-file
	$(if $(collname), $(info finding id for collection $(collname) and fork $(forkname)), $(error collname or collid must be specified))
	$(if $(forkname), $(info fork $(forkname) specified), $(eval forkname := $(defaultfork)) $(info ******* default fork $(defaultfork) will be used as forkname not specified*******))
	$(eval override collid := $(shell cat $(collectionsfile) | jq -r '[.collections[] | select(.name == "$(collname)") | select(.fork.label == "$(forkname)")][0].uid'))
	$(if $(findstring $(collid),null), $(info collection with name $(collname) and fork $(forkname) not found in postman API.) $(info *******default fork $(defaultfork) will be used*******) $(eval override forkname := $(defaultfork)) $(eval override collid := $(shell cat $(collectionsfile) | jq -r '[.collections[] | select(.name == "$(collname)") | select(.fork.label == "$(forkname)")][0].uid')),)
	$(if $(findstring $(collid),null), $(error collection with name $(collname) and fork $(forkname) not found in postman API.), $(info discovered id $(collid)))
else
get-collection-id: download-collections-file
	$(info using collection id $(collid))
	$(eval override collname := $(shell cat $(collectionsfile) | jq -r '[.collections[] | select(.uid == "$(collid)")][0].name'))
	$(if $(findstring $(collname),null), $(error collection with id $(collid) not found in postman API.), $(info collection name is $(collname)))
	$(eval override forkname := $(shell cat $(collectionsfile) | jq -r '[.collections[] | select(.uid == "$(collid)")][0].fork.label'))
	$(if $(findstring $(forkname),null), $(error collection fork not found in postman API.), $(info collection fork is $(forkname)))
endif


################## Run the tests via newman  ######################

################## for entire collection - all folders  ######################
run-all-tests: get-environment get-collection
	newman run $(collfile) --environment $(envfile) -g $(globalvariables) --export-environment $(envfile) \
    -r 'cli,junit,slackreporter' --reporter-junit-export "$(collname).xml" --reporter-slackreporter-webhookurl "$(slackuri)/$(slackwebhook)" --reporter-slackreporter-chanel \
    --reporter-slackreporter-collection "$(collname) \r\n Branch: $(forkname) \r\n Folder: All" --reporter-slackreporter-environment "$(envname)" $(additonalparams)

################## for single sub folder  ######################
run-tests: get-environment get-collection
	newman run $(collfile) --folder "$(folder)" --environment $(envfile) -g $(globalvariables) --export-environment $(envfile) \
    -r 'cli,junit,slackreporter' --reporter-junit-export "$(folder).xml" --reporter-slackreporter-webhookurl "$(slackuri)/$(slackwebhook)" --reporter-slackreporter-chanel \
    --reporter-slackreporter-collection "$(collname) \r\n Branch: $(forkname) \r\n Folder: $(folder)" --reporter-slackreporter-environment "$(envname)" $(additonalparams)

################## for ordered list of sub folders via defined file  ###############
ifneq ($(strip $(folderlistfile)),)
create-test-list-file:
	$(info reading tests folders from $(folderlistfile))
	$(eval override folderlistfile := $(basefolder)/lists/$(folderlistfile))
	$(info folderlist file is $(folderlistfile))
else
create-test-list-file:
	$(if $(findstring $(folderlist),null), $(error must specify either folderlistfile i.e. folderlistfile=filename.json or folderlist i.e. folderlist="['a test folder1', 'some other test folder']"))
	$(eval override folderlistfile := $(basefolder)/targetFolders.json)
	$(info reading tests folders from $(folderlist) folderlist file is $(folderlistfile))
	$(shell echo "$(folderlist)" | tr "'" '""' >> $(folderlistfile))
endif

run-test-list: create-test-list-file get-environment get-collection
	cat $(folderlistfile) | jq .[] | tr -d '"' | xargs -I {folder} newman run $(collfile) --folder "{folder}" --environment $(envfile) -g $(globalvariables) --export-environment $(envfile) \
    -r 'cli,junit,slackreporter' --reporter-junit-export "{folder}.xml" --reporter-slackreporter-webhookurl "$(slackuri)/$(slackwebhook)" --reporter-slackreporter-chanel \
    --reporter-slackreporter-collection "$(collname) \r\n Branch: $(forkname) \r\n Folder: {folder}" --reporter-slackreporter-environment "$(envname)" $(additonalparams)
