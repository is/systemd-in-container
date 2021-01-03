DIST=sic/opensuse-tumbleweed-systemd:latest
FROM=opensuse/tumbleweed:latest
MIRROR=aliyun
CN=o


buildah from --name o --pull-never opensuse/tumbleweed:latest
if [ "$MIRROR" = "aliyun" ] ; then
MURL="http://mirrors.aliyun.com/opensuse/tumbleweed"
buildah run $CN zypper mr -da
buildah run $CN zypper ar -f $MURL/repo/oss oss
buildah run $CN zypper ar -f $MURL/repo/non-oss non-oss
buildah run $CN zypper ref
fi

buildah run $CN zypper up

buildah run $CN zypper -n install systemd openssh-server iproute2


if [ "$PKGS_0" != "" ] ; then
buildah run $CN zypper -n install $PKGS
fi

buildah config --cmd '["/usr/lib/systemd/systemd"]' \
  --author 'Yu Xin <scaner@gmail.com>' \
  $CN

buildah commit $CN $DIST
buildah rm $CN
