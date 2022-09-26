#!/bin/sh
# Using env -i unsets all incoming variables, ensuring no unwanted and potentially hazardous
# environment variables from the host system leak into the build environment.
# ch 4.4
exec env -i HOME="$HOME" TERM="$TERM" PS1='\u:\w\$ ' /bin/bash
