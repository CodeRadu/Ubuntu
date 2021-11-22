fsfolder=ubuntu-data
proot &> /dev/null
if [ $? = 127 ]; then
  echo "Please install proot"
  exit 1;
fi
if test -d "$fsfoler"; then
  skdownload=1
  echo "Skipping fs Download"
fi
tarball="ubuntu-fs.tar.xz"
if [ "$first" != 1 ]; then
  if ! test -f $tarball; then
    echo "Download File System. Please wait"
    case `dpkg --print-architecture` in
    aarch64)
      arch="arm64";;
    amd64)
      arch="amd64";;
    *)
      echo "Unsuported Architecture"; exit 1;;
    esac
    wget "https://raw.githubusercontent.com/coderadu/Ubuntu/main/fs/ubuntu-fs-${arch}.tar.xz" -o $tarball
  fi
  current=`pwd`
  mkdir -p "$fsfolder"
  cd "$fsfolder"
  echo "Decompressing..."
  proot tar -xJf ${current}/${tarball}||:
  cd "$current"
fi

mkdir -p binds
bin=start.sh
echo "Creating start script"
cat > $bin <<- EOF
#!/bin/bash
cd $(dirname $0)
## unset LD_PRELOAD in case termux-exec is installed
unset LD_PRELOAD
command="proot"
command+=" -0"
command+=" -r "
command+=" ubuntu-data/"
command+=" -b /dev"
command+=" -b /proc"
## uncomment the following line to have access to the home directory of termux
#command+=" -b /data/data/com.termux/files/home:/root"
## uncomment the following line to mount /sdcard directly to / 
#command+=" -b /sdcard"
command+=" -w /root"
command+=" /usr/bin/env -i"
command+=" HOME=/root"
command+=" PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games"
command+=" LANG=C.UTF-8"
command+=" /bin/bash --login"
com="\$@"
if [ -z "\$1" ];then
  exec \$command
else
  \$command -c "\$com"
fi
EOF
chmod +x $bin
echo "You can start Ubuntu with ./start.sh"