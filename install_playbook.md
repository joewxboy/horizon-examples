# Curl and CLI commands for the administrator

## Pre-requisites

NOTE: as root user

apt-get -y update
apt-get -y upgrade
apt-get -y install jq curl git make gcc net-tools

export HZN_LISTEN_IP=

NOTE: Install without Agent or registering



## Initial setup

Export the following environment variables:

* HZN_EXCHANGE_URL
* HZN_EXCHANGE_ROOT_USER_AUTH


Check the Hub version:

curl -u ${HZN_EXCHANGE_ROOT_USER_AUTH} ${HZN_EXCHANGE_URL}/admin/version

Check the Hub status:

```shell
curl --silent -u ${HZN_EXCHANGE_ROOT_USER_AUTH} ${HZN_EXCHANGE_URL}/admin/status | jq .
```

List Organizations:

```shell
curl --silent -u ${HZN_EXCHANGE_ROOT_USER_AUTH} ${HZN_EXCHANGE_URL}/orgs | jq .
```

- or by setting `HZN_EXCHANGE_USER_AUTH` to root/root:pw

```shell
hzn exchange org list
```

Add an org named "testorg":

```shell
curl -sSf -X POST -u ${HZN_EXCHANGE_ROOT_USER_AUTH} -H "Content-Type:application/json" -d '{"label": "testorg", "description": "Organization for Testing"}' ${HZN_EXCHANGE_URL}/orgs/testorg | jq .
```

- or by setting `HZN_EXCHANGE_USER_AUTH` to root/root:pw

```shell
hzn exchange org create --org=myorg --description="Organization for Testing" --label=testorg testorg
```

List the users in "testorg":

curl --silent -u ${HZN_EXCHANGE_ROOT_USER_AUTH} ${HZN_EXCHANGE_URL}/orgs/testorg/users | jq .

- or by setting `HZN_EXCHANGE_USER_AUTH` to root/root:pw

```shell
hzn exchange user list -a -o testorg
```

Add a user to "testorg":

```shell
hzn exchange user create -o testorg foo fubarpw foo@bar.com
```

Add `-A` flag if user should be admin

