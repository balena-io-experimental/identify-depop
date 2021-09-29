# identify-depop

I2C script to check depop balenaFin profiles for customers.

This specific example looks for the `pca963x` driver, attempts to set the blue led to 0 brightness and records if it succeeded or failed.

## Requirements

- bash
- curl
- jq
- balena-cli

## Usage

Run the script with the following command:

```bash
./scan.sh $YOUR_BALENA_API_AUTH_TOKEN $FLEET_ID
```

> You can find you `$FLEET_ID` from the url, for example https://dashboard.balena-cloud.com/fleets/1234567, where 1234567 is the `$FLEET_ID`.

