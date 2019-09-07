# horizon-examples
Functional and practical services with associated service definition files and registration utility

## Overview

This Makefile is intended to be run with the GNU Make utility. 
The contents are intended to be run on OSX (MacOS) or Ubuntu Linux 18.04.x. 

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
