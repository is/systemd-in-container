DIST=sic/opensuse-tumbleweed-systemd:latest
FROM=opensuse/tumbleweed:latest
ROOTPW=a0b1c2d3

IMAGE_ALIAS=os:0

STATIC_SSH_HOST_KEY=1

MIRROR=aliyun
PKGS_0="openssh-server iproute2"

PKGS_1="tcpdump strace lsof"

CN=o


buildah rmi --force $DIST
R="buildah run $CN"

buildah from --name o --pull-never $FROM
if [ "$MIRROR" = "aliyun" ] ; then
echo "+ setup aliyun source"
MURL="http://mirrors.aliyun.com/opensuse/tumbleweed"
$R zypper mr -da
$R zypper ar -f $MURL/repo/oss oss
$R zypper ar -f $MURL/repo/non-oss non-oss
$R zypper ref
fi

$R zypper up
$R zypper -n install systemd $PKGS_0

if [ "$PKGS_1" != "" ] ; then
echo "+ install extra packages"
$R zypper -n install $PKGS_1
fi

buildah config --cmd '["/usr/lib/systemd/systemd"]' \
  --author 'Yu Xin <scaner@gmail.com>' \
  $CN



# Root password and ssh keys
$R usermod --password $(openssl passwd -1 $ROOTPW) root

if [ -f ssh/authorized_keys ] ; then
$R mkdir /root/.ssh
$R chmod 700 /root/.ssh
buildah copy $CN ssh/authorized_keys /root/.ssh
fi


if [ "$STATIC_SSH_HOST_KEY" = 1 ] ; then
buildah copy $CN ssh/host_key /etc/ssh
fi

$R zypper clean
$R rm -fr /var/cache/zypp

buildah commit $CN $DIST
buildah rm $CN

if [ "$IMAGE_ALIAS" != "" ] ; then
buildah tag $DIST $IMAGE_ALIAS
fi
