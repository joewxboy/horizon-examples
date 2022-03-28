# Colors and icons, thanks Sanjay!
green = \x1B[0;32m
red = \x1B[0;31m
yellow = \x1B[0;33m
cyan = \x1B[0;36m
no_color = \x1B[0m
beer = \xF0\x9f\x8d\xba
delivery = \xF0\x9F\x9A\x9A
beers = \xF0\x9F\x8D\xBB
eyes = \xF0\x9F\x91\x80
cloud = \xE2\x98\x81
crossbones = \xE2\x98\xA0
litter = \xF0\x9F\x9A\xAE
fail = \xE2\x9B\x94
harpoons = \xE2\x87\x8C
tools = \xE2\x9A\x92
present = \xF0\x9F\x8E\x81

# Transform the machine arch into some standard values: "arm", "arm64", or "amd64"
SYSTEM_ARCH := $(shell uname -m | sed -e 's/aarch64.*/arm64/' -e 's/x86_64.*/amd64/' -e 's/armv.*/arm/')
OS := $(shell uname -s)
PUBLIC_IP := $(shell curl --silent ifconfig.me) # Thanks, Sanjay!
USER := $(shell whoami)
HZN := $(shell which hzn)
HORIZON := $(shell which horizon-container)
HORIZON_RUNNING := $(shell sudo docker ps -f name=horizon | grep -w openhorizon)

# To build for an arch different from the current system, set this env var to "arm", "arm64", or "amd64"
ARCH ?= $(SYSTEM_ARCH)

# Set the filepath, since different for OSX and Linux
HZN_FILEPATH = /etc/horizon
ifeq ($(OS),Darwin)
	HZN_FILEPATH = /usr/local/etc/horizon
endif

# These variables can be overridden from the environment
PATTERN_NAME ?= pattern.edgex.amd64
PATTERN_VERSION ?= 1.0.0
HZN_ORG_ID ?= organization-name
HZN_EXCHANGE_USER_AUTH ?= username:password
HZN_DEVICE_ID ?= my-device-id
HZN_DEVICE_TOKEN ?= i-am-not-a-pw
HZN_EXCHANGE_NODE_AUTH ?= $(HZN_DEVICE_ID):$(HZN_DEVICE_TOKEN)
HZN_EXCHANGE_URL ?= http://127.0.0.1:8080/v1/
HZN_FSS_CSSURL ?= http://127.0.0.1:8080/css/

default: show-args

check: validate-anax-exist

show-args:
	@echo "${cyan}SYSTEM SETTINGS, NOT FROM VARIABLES${no_color}"
	@echo "${cyan}===================================${no_color}"
	@echo "${green}                  USER: ${yellow}$(USER)${no_color}"
	@echo "${green}                   HZN: ${yellow}$(HZN)${no_color}"
	@echo "${green}               HORIZON: ${yellow}$(HORIZON)${no_color}"
	@echo "${green}                    OS: ${yellow}$(OS)${no_color}"
	@echo "${green}           SYSTEM_ARCH: ${yellow}$(SYSTEM_ARCH)${no_color}"
	@echo "${green}             PUBLIC_IP: ${yellow}$(PUBLIC_IP)${no_color}"
	@echo "${green}          HZN_FILEPATH: ${yellow}$(HZN_FILEPATH)${no_color}"
	@echo ""
	@echo "${cyan}USER SETTINGS, FROM ENVIRONMENT${no_color}"
	@echo "${cyan}===============================${no_color}"
	@echo "${green}            HZN_ORG_ID: ${yellow}$(HZN_ORG_ID)${no_color}"
	@echo "${green}HZN_EXCHANGE_USER_AUTH: ${yellow}$(HZN_EXCHANGE_USER_AUTH)${no_color}"
	@echo "${green}         HZN_DEVICE_ID: ${yellow}$(HZN_DEVICE_ID)${no_color}"
	@echo "${green}      HZN_DEVICE_TOKEN: ${yellow}$(HZN_DEVICE_TOKEN)${no_color}"
	@echo "${green}HZN_EXCHANGE_NODE_AUTH: ${yellow}$(HZN_EXCHANGE_NODE_AUTH)${no_color}"
	@echo "${green}      HZN_EXCHANGE_URL: ${yellow}$(HZN_EXCHANGE_URL)${no_color}"
	@echo "${green}        HZN_FSS_CSSURL: ${yellow}$(HZN_FSS_CSSURL)${no_color}"

publish-all: populate-configs validate-keys validate-exchange-exist validate-file-exist validate-file-schema

populate-configs:
	@echo "${cyan}POPULATING CONFIGURATION FILES${no_color}"
	@echo "${cyan}==============================${no_color}"

	@echo "${cyan}Stopping Horizon Anax agent${no_color}."
	@hzn unregister -r -f
ifeq ($(OS),Darwin)
	@sudo horizon-container stop
else
	@sudo systemctl stop horizon
endif

	@echo "${cyan}Populating agent variable data properties files${no_color}."
ifeq (,$(wildcard /etc/default/horizon))
	@echo "${crossbones}   ${red}FILE NOT FOUND: ${yellow}/etc/default/horizon${no_color}, cannot continue."
	@echo "Is the Horizon Anax agent installed?"
	@exit 1
else
	@echo "${eyes}   ${green}FILE FOUND: ${yellow}/etc/default/horizon${no_color}, replacing contents."
	@sudo chmod -R a+rw /etc/default
	@sed -i.bak "s~HZN_EXCHANGE_URL=.*~HZN_EXCHANGE_URL=${HZN_EXCHANGE_URL}~" /etc/default/horizon
	@sed -i.bak "s~HZN_FSS_CSSURL=.*~HZN_FSS_CSSURL=${HZN_FSS_CSSURL}~" /etc/default/horizon
	@echo "${eyes}   Replacing contents of: ${yellow}${HZN_FILEPATH}/hzn.json${no_color}."
	@sudo chmod a+rw ${HZN_FILEPATH}
	@sudo chmod a+rw ${HZN_FILEPATH}/hzn.json
	@echo "{" > ${HZN_FILEPATH}/hzn.json
	@echo "	\"HZN_EXCHANGE_URL\": \"${HZN_EXCHANGE_URL}\"," >> ${HZN_FILEPATH}/hzn.json
	@echo "	\"HZN_FSS_CSSURL\": \"${HZN_FSS_CSSURL}\"" >> ${HZN_FILEPATH}/hzn.json
	@echo "}" >> ${HZN_FILEPATH}/hzn.json
endif

	@echo "${cyan}Starting Horizon Anax agent${no_color}."
ifeq ($(OS),Darwin)
	@sudo horizon-container start
else
	@sudo systemctl start horizon
endif

	@echo "${cyan}Task complete${no_color}."

validate-keys:

validate-file-exist:

validate-file-schema:

validate-exchange-exist:

validate-anax-exist:
	@echo "${cyan}CHECKING FOR HORIZON ANAX AGENT${no_color}"
	@echo "${cyan}===============================${no_color}"

ifeq (/usr/local/bin/hzn,$(HZN))
	@echo "${present}   ${green}SUCCESS: ${yellow}Anax agent found${no_color}."
ifeq ($(OS),Darwin)
ifeq (/usr/local/bin/horizon-container,$(HORIZON))
	@echo "${present}   ${green}SUCCESS: ${yellow}Horizon container found${no_color}."
ifeq (anax,$(findstring anax,$(HORIZON_RUNNING)))
	@echo "${present}   ${green}SUCCESS: ${yellow}Horizon container is running${no_color}."
else
	@echo "${eyes}   ${yellow}WARNING: ${no_color}Horizon container is not running.  Try 'horizon-container start'."
	@exit 1
endif
else
	@echo "${crossbones}   ${red}ERROR: ${yellow}Horizon container not found.  Try (re)installing it${no_color}."
	@exit 1
endif
endif
else
	@echo "${crossbones}   ${red}ERROR: ${yellow}Anax agent not found.  Try (re)installing it${no_color}."
	@exit 1
endif

server-init:
	@echo "${cyan}INITIALIZING UBUNTU SERVER FOR HORIZON SERVICES${no_color}"
	@echo "${cyan}===============================================${no_color}"

ifeq ($(OS),Darwin)
	@echo "${crossbones}   ${red}WRONG OS: ${yellow}You appear to be running MacOS${no_color}."
	@exit 1
else
	@echo "${cyan}Installing pre-requisites${no_color}."
	@sudo apt-get -y update
	@sudo apt-get -y install curl jq make gcc net-tools

	@echo "${cyan}Installing Golang${no_color}."
	@sudo curl https://dl.google.com/go/go1.11.4.linux-amd64.tar.gz | sudo tar -xzf- -C /usr/local/
	PATH=$PATH:/usr/local/go/bin

	@echo "${cyan}Installing Docker and docker-compose${no_color}."
	@sudo curl -fsSL get.docker.com | sudo sh
	@sudo usermod -aG docker ${USER}
	@sudo apt-get -y install docker-compose

	@echo "${cyan}Installing Go utilities${no_color}."
	@sudo mkdir -p /go/src
	@sudo chmod -R a+rwx /go
	GOPATH=/go

	@echo "${cyan}Retrieving Anax source code${no_color}."
	go get -u github.com/open-horizon/anax
	ANAX_SOURCE=/go/src/github.com/open-horizon/anax
endif

.PHONY: default show-args publish-all validate-keys validate-file-exist validate-file-schema validate-exchange-exist populate-configs server-init validate-anax-exist check
