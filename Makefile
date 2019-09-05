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

# To build for an arch different from the current system, set this env var to "arm", "arm64", or "amd64"
ARCH ?= $(SYSTEM_ARCH)

# Set the filepath, since different for OSX and Linux
HZN_FILEPATH = /etc/horizon
ifeq ($(OS),Darwin)
	HZN_FILEPATH = /usr/local/etc/horizon
endif

# These variables can be overridden from the environment
PATTERN_NAME ?= IBM.helloworld
PATTERN_VERSION ?= 1.0.0
HZN_ORG_ID ?= mycluster
HZN_EXCHANGE_USER_AUTH ?= joe:cool
HZN_DEVICE_ID ?= [device-name-here]
HZN_DEVICE_TOKEN ?= [unique-string-here]
HZN_EXCHANGE_NODE_AUTH ?= $HZN_DEVICE_ID:$HZN_DEVICE_TOKEN
HZN_EXCHANGE_URL ?= https://52.116.21.112:8443/ec-exchange/v1/
HZN_FSS_CSSURL ?= https://52.116.21.112:8443/ec-css/

default: show-args

show-args:
	@echo "${cyan}              OS: ${yellow}$(OS)${no_color}"
	@echo "${cyan}     SYSTEM_ARCH: ${yellow}$(SYSTEM_ARCH)${no_color}"
	@echo "${cyan}       PUBLIC_IP: ${yellow}$(PUBLIC_IP)${no_color}"
	@echo "${cyan}    PATTERN_NAME: ${yellow}$(PATTERN_NAME)${no_color}"
	@echo "${cyan}      HZN_ORG_ID: ${yellow}$(HZN_ORG_ID)${no_color}"
	@echo "${cyan}HZN_EXCHANGE_URL: ${yellow}$(HZN_EXCHANGE_URL)${no_color}"
	@echo "${cyan}    HZN_FILEPATH: ${yellow}$(HZN_FILEPATH)${no_color}"

publish-all: populate-configs validate-keys validate-exchange-exist validate-file-exist validate-file-schema

populate-configs:
	@echo "${cyan}POPULATING CONFIGURATION FILES${no_color}"
	@echo "${cyan}==============================${no_color}"

	@echo "${cyan}Populating agent variable data properties files.${no_color}"
ifeq (,$(wildcard /etc/default/horizon))
	@echo "${crossbones}   ${red}FILE NOT FOUND: ${yellow}/etc/default/horizon${no_color}, cannot continue."
	@echo "Is the Horizon Anax agent installed?"
else
	@echo "${eyes}   ${green}FILE FOUND: ${yellow}/etc/default/horizon${no_color}, replacing contents."
	@sudo chmod a+rw /etc/default
	@sudo chmod a+rw /etc/default/horizon
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

	@echo "${cyan}Restarting Horizon Anax agent.${no_color}"
ifeq ($(OS),Darwin)
	@sudo horizon-container stop
	@sudo horizon-container start
else
	@sudo systemctl restart horizon
endif

	@echo "${cyan}Task complete.${no_color}"

validate-keys:

validate-file-exist:

validate-file-schema:

validate-exchange-exist:

.PHONY: default show-args publish-all validate-keys validate-file-exist validate-file-schema validate-exchange-exist populate-configs