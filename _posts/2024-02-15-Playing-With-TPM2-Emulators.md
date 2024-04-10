---
layout: post
title: "Playing with TPM2 Emulators"
---

# 1
## 2
### 3

# Adding a software TPM to Qemu

# Talking to it directly

```bash
#!/bin/sh

RUNDIR="$PWD"

SIM_PORT=${1:-9989}

# control port is always SIM_PORT+1
CTRL_PORT=$((SIM_PORT + 1))

mkdir -p "$RUNDIR/tpm"

echo "Starting swtpm, SIM_PORT=${SIM_PORT}"
echo "Use"
echo "  export TPM2TOOLS_TCTI=\"swtpm:host=127.0.0.1,port=${SIM_PORT}\""
echo "to connect with tpm2-tools."

swtpm socket \
  --tpm2 \
  --tpmstate dir="$RUNDIR/tpm/" \
  --ctrl type=tcp,port="$CTRL_PORT" \
  --server port="$SIM_PORT" \
  --log level=20,file="$RUNDIR/tpm/log" \
  --flags startup-clear
```

## Without a Resource Manager

```
swtpm <-- TCP --> tpm2-tools 
```


```
$ export TPM2TOOLS_TCTI="swtpm:host=127.0.0.1,port=${SIM_PORT}"
```

Then use tpm2-tools commands as usual, for example:
```
# tpm2_pcrread
…
```

## With a Resource Manager

```
  swtpm <-- TCP --> tpm2-abrmd <-- dbus --> tpm2-tools
```

`tpm2-abrmd` is a tpm resource manager.

Launch swtpm as described above.

Then launch `tpm2-abrmd`:
```
$ SIM_PORT=9989
$ tpm2-abrmd \
        --tcti=swtpm:host=127.0.0.1,port="$SIM_PORT" \
        --session \
        --dbus-name="com.intel.tss2.Tabrmd${SIM_PORT}"
```

tpm2-tools then can communicate with it via dbus:
```
$ export TPM2TOOLS_TCTI="tabrmd:bus_type=session,bus_name=com.intel.tss2.Tabrmd${SIM_PORT}"
$ tpm2_pcrread
```

# References and Other Resources
- Helpful example script from the [swtpm test suite](https://github.com/tpm2-software/tpm2-tools/blob/master/test/integration/helpers.sh#L359)
- tpm2-tools man page
- tpm2-abrmd man page
- swtpm man page
- Qemu Manpage
