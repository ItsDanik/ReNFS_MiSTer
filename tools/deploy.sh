#!/bin/sh
# Package the build and copy it to a MiSTer over ssh, in the layout of the
# hybrid ports. The core is not (re)loaded: load a game of ReNFS from the
# Other menu afterwards. Run Scripts/danik_hybrid_ports.sh on the MiSTer
# once to set up the launcher. A MiSTer that has ReNFS in the old layout
# (games/ReNFS/) gets it moved by the launcher (version 3) once this is
# there.
# usage: MISTER=root@<address> tools/deploy.sh
set -e
cd "$(dirname "$0")/.."
HOST=${MISTER:?set MISTER=root@<address of the MiSTer>}
./package.sh > /dev/null
OUT=dist/ReNFS_$(date +%Y%m%d)
G=/media/fat/games/dnk/ReNFS
ssh "$HOST" "mkdir -p $G /media/fat/_Other/dnk /media/fat/Scripts/.danik_hybrid_ports && rm -f /media/fat/_Other/dnk/dnk-ReNFS_*.rbf"
# a running game keeps its binary busy: copy next to it, then swap
# (scp would copy into a folder of that name, if something left one behind)
ssh "$HOST" "rm -rf $G/ReNFS.new"
scp -q "$OUT/games/dnk/ReNFS/ReNFS" "$HOST:$G/ReNFS.new"
ssh "$HOST" "mv -f $G/ReNFS.new $G/ReNFS"
# everything else of the package (user files on the MiSTer are left alone)
(cd "$OUT/games/dnk/ReNFS" && tar cf - --exclude=./ReNFS .) | ssh "$HOST" "tar xf - --no-same-owner -C $G"
(cd "$OUT/Scripts" && tar cf - .) | ssh "$HOST" "tar xf - --no-same-owner -C /media/fat/Scripts"
(cd "$OUT/_Other" && tar cf - .) | ssh "$HOST" "tar xf - --no-same-owner -C /media/fat/_Other"
ssh "$HOST" "chmod +x $G/ReNFS $G/*.sh /media/fat/Scripts/danik_hybrid_ports.sh; ls -la $G /media/fat/_Other/dnk/dnk-ReNFS_*.rbf /media/fat/_Other/dnk-*.mgl"
