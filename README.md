# horizon-examples
Functional and practical services with associated service definition files and registration utility

## Overview

This Makefile is intended to be run with the GNU Make utility. 
The contents are intended to be run on OSX (MacOS) or Ubuntu Linux 18.04.x. 
Pre-populate the following environment variables with your values before running. 
Here are some example values.  Please modify as needed:

``` bash
export HZN_ORG_ID='organization-name'
export HZN_EXCHANGE_USER_AUTH='username:password'
export HZN_DEVICE_ID='my-device-id'
export HZN_DEVICE_TOKEN='i-am-not-a-pw'
export HZN_EXCHANGE_NODE_AUTH=$HZN_DEVICE_ID:$HZN_DEVICE_TOKEN
export HZN_EXCHANGE_URL=http://127.0.0.1:8080/v1/
export HZN_FSS_CSSURL=http://127.0.0.1:8080/css/
```

## Usage

### Current Configuration

To see what your environment variables are set to, 
or to use the defaults for the variables that are not set, run:

``` bash
make
```

### Server Initialization

If you are running the Makefile on an Ubuntu Server 18.04.x, 
the `server-init` parameter will install the pre-requisites for the Horizon Services:

``` bash
make server-init
```

### Client Install Check

To verify that the Anax agent is installed and running, use the following:

``` bash
make check
```

### Client Initialization

If the Anax agent is already installed, 
the following will write the values as shown in `Current Configuration` above and restart the agent:

``` bash
make populate-configs
```
