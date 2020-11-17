#!/bin/bash

#immediately exit if any command has a non-zero exit status
set -euxo pipefail
#enable debugging
set -x

################################################################################################
#OS (e.g. Ubuntu/Debian)
#Series (e.g. 4.1)
#Version (e.g. 4.1.0)
#Release (e.g. 1)
#Flavor(e.g. Ubuntu - xenial/bionic/eoan/focal/groovy, Debian - buster/stretch/bullseye)

# to run use: 'bash -x generic_package.sh debian stretch 6 4.1.0 1'

#Key generation: https://help.ubuntu.com/community/GnuPrivacyGuardHowto#Generating_an_OpenPGP_Key
#Addditional info: sending of pubkey to a keyserv is been done using the MIT keyserv
#################################################################################################
os=$1
flavor=$2
series=$3
version=$4
release=$5
latest_series=$6
latest_version=$7

#Keys required in debian builds
declare -a debuild_keys
debuild_keys="F9C958A3AEE0D2184FAD1CBD43607F0DC2F8238C"

declare -a pbuild_keys
pbuild_keys="BF11C87C"

# Check for OS(Ubuntu or Debian)
if [ "$os" == "ubuntu" ]; then
        mirror="http://ubuntu.osuosl.org/ubuntu/"
	debuild_key=4F5B5CA5
elif [ "$os" == "debian" ]; then
        mirror="http://ftp.us.debian.org/debian/"
        if [ "$flavor" == "stretch" ]; then
             debuild_key=${pbuild_keys}
        else
             debuild_key=${debuild_keys}
        fi
        pbuild_key=${pbuild_keys}
else
	echo "Exiting: OS should be debian or ubuntu. Please provide the right one"
	exit
fi

mkdir ${os}-${flavor}-Glusterfs-${version}

cd ${os}-${flavor}-Glusterfs-${version}

mkdir build packages

echo "Building glusterfs-${version}-${release} for ${flavor}"

cd build

TGZS=(`ls ~/glusterfs-${version}-?-*/build/glusterfs-${version}.tar.gz`)
echo ${TGZS[0]}

if [ -z ${TGZS[0]} ]; then
        echo "wget https://download.gluster.org/pub/gluster/glusterfs/${series}/${version}/glusterfs-${version}.tar.gz"
        wget https://download.gluster.org/pub/gluster/glusterfs/${series}/${version}/glusterfs-${version}.tar.gz
else
        echo "found ${TGZS[0]}, using it..."
        cp ${TGZS[0]} .
fi

echo "Creating link file.."
ln -s glusterfs-${version}.tar.gz glusterfs_${version}.orig.tar.gz

echo "Untaring.."
tar xpf glusterfs-${version}.tar.gz

# Changelogs needed for building are maintained in a separate repo.
# the repo has to be clone and updated properly so we can copy the changelogs so far.

echo "Cloning the glusterfs-debian repo"
git clone http://github.com/gluster/glusterfs-debian.git

cd glusterfs-debian/

git checkout -b ${flavor}-${series}-local origin/${flavor}-glusterfs-${series}

if [ "$os" == "ubuntu" ]; then
        dch --distribution ${flavor} -u medium -v ${version}-${os}1~${flavor}1 "GlusterFS ${version} GA"
elif [ "$os" == "debian" ]; then
        dch --distribution ${flavor} -u low -v (${version}-1 ${flavor}) "GlusterFS ${version} GA"
fi

git commit -a -m "Glusterfs ${version} G.A (${flavor})"

echo "Copying Changelog to source"
cp -a debian ../glusterfs-${version}/

echo "Building source package.."
cd ../glusterfs-${version}
debuild -S -sa -k${debuild_key}

echo "Uploading the packages.."
if [ "$os" == "ubuntu" ]; then
        cd ..
        dput ppa:gluster/glusterfs-${series} glusterfs_${version}-${os}1~${flavor}1_source.changes

    echo "Done"
    exit
fi

# we are using the same builder machine to build so we are running the "pbuilder
# create" everytime to create the chroot according to the os and flavor we want to build.
echo "creating chroot for ${os} ${flavor}"
sudo pbuilder create --distribution ${flavor} --mirror ${mirror} --debootstrapopts --keyring=/usr/share/keyrings/${os}-archive-keyring.gpg

echo "Building glusterfs-${version} for ${os} ${flavor} using the chroot and .dsc we created"

# have to use the .dsc file inside the ${os}${flavor} folder
sudo pbuilder build ~/${os}-${flavor}-Glusterfs-${version}/build/glusterfs_${version}-${release}.dsc | tee build.log

#move the packages to packages directory.
cp /var/cache/pbuilder/result/glusterfs*${version}-${release}*.deb ~/${os}-${flavor}-Glusterfs-${version}/packages/
rm -rf /var/cache/pbuilder/result/glusterfs*${version}-${release}*.deb

if [ "$flavor" != "stretch" ]; then
     mv /var/cache/pbuilder/result/libg*${version}-${release}*.deb ~/${os}-${flavor}-Glusterfs-${version}/packages/
fi
/usr/share/debdelta/dpkg-sig -v -k ${pbuild_key} --sign builder ~/${os}-${flavor}-Glusterfs-${version}/packages/glusterfs-*${version}-${release}*.deb

cd /var/www/repos/apt/debian/

rm -rf pool/* dists/* db/*

cp ~/conf.distributions/${series} conf/distributions

# distribute Debian packages using apt
for i in ~/${os}-${flavor}-Glusterfs-${version}/packages/glusterfs-*${version}-${release}*; do reprepro includedeb $flavor $i; done
if [ "$flavor" != "stretch" ]; then
     for i in ~/${os}-${flavor}-Glusterfs-${version}/packages/libg*${version}-${release}*.deb; do reprepro includedeb $flavor $i; done
fi
reprepro includedsc ${flavor} ~/${os}-${flavor}-Glusterfs-${version}/build/glusterfs_${version}-${release}.dsc

tar czf ~/${os}-${flavor}-Glusterfs-${version}/${flavor}-apt-amd64-${version}.tgz pool/ dists/

echo "Pushing Changelog changes.."
git push origin ${flavor}-${series}-local:${flavor}-glusterfs-${series}

cd ~/${os}-${flavor}-Glusterfs-${version}

#copy the tar.gz file produced by the build to download.rht.gluster.org:/var/www/scratch
scp $flavor-apt-amd64-$version.tgz gluster_ant@download.rht.gluster.org:/var/www/scratch

ssh gluster_ant@download.rht.gluster.org /var/www/html/pub/gluster/unpacking-script.sh series version os flavor latest_version latest_series

cd ..
function finish {
  # cleanup code
  echo "removing the chroot"
  sudo rm -rf /var/cache/pbuilder/base.tgz

  #removing folders created while packaging
  rm -rf ${os}-${flavor}-Glusterfs-${version}
}
trap finish EXIT
trap finish SIGQUIT

echo "Done."
