#!/bin/bash

OS=`uname -s`
if [ $OS = Darwin ]
    then
        echo "OSX Not Supported.  Please run this script on Linux."
        echo ""
	    exit 1
fi
WHOAMI=`whoami`
if [ $WHOAMI = root ]
    then
        _PREFIX=''
    else
        _PREFIX='sudo'
fi
if [ $OS = Darwin ]
    then
        echo "Storing settings in zshrc."
        echo ""
        BASHRC=~/.zshrc
    else
        echo "Storing settings in bashrc."
        echo ""
        BASHRC=~/.bashrc
fi

HZN_JSON_FILEPATH=/etc/horizon/hzn.json
HZN_FILEPATH=/etc/default/horizon

echo ""
echo "====="
echo "Current Settings"
echo "====="
echo ""
echo "NOTE: Type Control-C if all settings are correct."
echo ""
sleep 2

echo "-----"
echo "Exchange Service Env Var: ${HZN_EXCHANGE_URL}"
echo ""
echo "Sync Service Env Var: ${HZN_FSS_CSSURL}"
echo ""
echo "JSON config file:"
cat ${HZN_JSON_FILEPATH}
echo ""
echo "Var config file:"
cat ${HZN_FILEPATH}
echo "-----"

echo ""
echo "====="
echo "Input Exchange and Sync Service addresses"
echo "====="
echo ""
sleep 2

echo "Type in Exchange Service address"
echo "  NOTE: Ensure you get protocol, port, and trailing slash correct"
echo "  ex: https://alpha.edge-fabric.com/v1/"
echo "  ex: http://127.0.0.1:8080/v1/"

read -p 'Exchange: ' HZN_EXCHANGE_URL

echo "Type in Sync Service address"
echo "  NOTE: Ensure you get protocol, port, and trailing slash correct"
echo "  ex: https://alpha.edge-fabric.com/css/"
echo "  ex: http://127.0.0.1:8080/css/"

read -p 'Sync: ' HZN_FSS_CSSURL

echo "Type in Device ID"
echo "  ex: 000000002caf51bd"

read -p 'Device ID: ' HZN_DEVICE_ID

echo ""
echo "====="
echo "Unregistering Node and Stopping Horizon"
echo "====="
echo ""
sleep 2

hzn unregister -r -f
${_PREFIX} systemctl stop horizon

echo ""
echo "====="
echo "Writing config files and env vars"
echo "====="
echo ""
sleep 2

# {
#     "HZN_EXCHANGE_URL": "https://alpha.edge-fabric.com/v1/",
#     "HZN_FSS_CSSURL": "https://alpha.edge-fabric.com/css/"
# }

${_PREFIX} chmod a+rw ${HZN_JSON_FILEPATH}
echo "{" > ${HZN_JSON_FILEPATH}
echo "	\"HZN_EXCHANGE_URL\": \"${HZN_EXCHANGE_URL}\"," >> ${HZN_JSON_FILEPATH}
echo "	\"HZN_FSS_CSSURL\": \"${HZN_FSS_CSSURL}\"" >> ${HZN_JSON_FILEPATH}
echo "}" >> ${HZN_JSON_FILEPATH}

# HZN_EXCHANGE_URL=
# HZN_FSS_CSSURL=
# HZN_DEVICE_ID=51a8799835ab89e8a9464b1b3995c592a4755b26

${_PREFIX} chmod a+rw ${HZN_FILEPATH}
echo "HZN_EXCHANGE_URL=${HZN_EXCHANGE_URL}" > ${HZN_FILEPATH}
echo "HZN_FSS_CSSURL=${HZN_FSS_CSSURL}" >> ${HZN_FILEPATH}
echo "HZN_DEVICE_ID=${HZN_DEVICE_ID}" >> ${HZN_FILEPATH}

echo "export HZN_EXCHANGE_URL=${HZN_EXCHANGE_URL}" >> ${BASHRC}
echo "export HZN_FSS_CSSURL=${HZN_FSS_CSSURL}" >> ${BASHRC}


echo ""
echo "====="
echo "Restarting Horizon"
echo "====="
echo ""
sleep 2

${_PREFIX} systemctl start horizon
sleep 1
source ${BASHRC}
hzn version
