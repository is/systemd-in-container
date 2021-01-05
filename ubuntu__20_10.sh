DIST=sic/ubuntu:20.10
FROM=ubuntu:20.10
ROOTPW=a0b1c2d3

IMAGE_ALIAS=us:20.10

STATIC_SSH_HOST_KEY=1

MIRROR=aliyun
PKGS_0="systemd openssh-server iproute2"
PKGS_1="tcpdump strace lsof"

CN=o


buildah rmi --force $DIST
R="buildah run $CN"
C="buildah copy $CN"

buildah from --name $CN --pull-never $FROM
if [ "$MIRROR" = "aliyun" ] ; then
$C ubuntu/20.10/aliyun-sources.list /etc/apt/sources.list
fi

$R apt update -y
$R apt upgrade -y
$R apt install -y $PKGS_0

if [ "$PKGS_1" != "" ] ; then
echo "+ install extra packages"
$R apt install -y $PKGS_1
fi

buildah config --cmd '["/usr/lib/systemd/systemd"]' \
  --author 'Yu Xin <scaner@gmail.com>' \
  $CN

# Root password and ssh keys
$R usermod --password $(openssl passwd -1 $ROOTPW) root

if [ -f ssh/authorized_keys ] ; then
$R mkdir /root/.ssh
$R chmod 700 /root/.ssh
$C ssh/authorized_keys /root/.ssh
fi


if [ "$STATIC_SSH_HOST_KEY" = 1 ] ; then
$C ssh/host_key /etc/ssh
fi

$R systemctl set-default multi-user.target 
for s in getty@tty1 networkd-dispatcher ; do
$R systemctl disable ${s}.service
done
$R systemctl mask console-getty.service

buildah commit $CN $DIST
buildah rm $CN

if [ "$IMAGE_ALIAS" != "" ] ; then
buildah rmi $IMAGE_ALIAS > /dev/null 2>&1
buildah tag $DIST $IMAGE_ALIAS
fi
