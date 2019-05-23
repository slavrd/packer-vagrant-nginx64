#/usr/env/bin bash
# Sets the environment variables referenced in the packer template
# Requires packages - jq, vagrant

# usage run.sh <nginx_version> <source_box_name> [source_box_version]
# can pass auto as <nginx_version> to install the current version in apt catalogue

# verify jq install
which jq vagrant >> /dev/null || {
    echo "ERROR: the script requires jq, vagrant to be installed" >&2
    exit 1
}

print_usage() {
    cat << EOF

usage run.sh <nginx_version> <source_box> <source_box_version> [<dst_vc_box> <dsc_vc_box_ver>]

<nginx_version> - version of nginx to install or 'auto'
<source_box_name> - vagrant cloud box 'my-vc-user/my-box'
<source_box_version> - version of the VC box or 'current'
<dst_vc_box> - (optional) the vagrant cloud destination box
<dsc_vc_box_ver> - (required if <dst_vc_box> set) the vagrant cloud destination box version

EOF
}

# input basic sanity

if [ $# -lt 3 ]; then
    print_usage
    exit 1
elif [ $# -eq 4 ]; then
    print_usage
    exit 1
fi

# assign input values

if [ "$1" != "auto" ]; then
    export PKR_NGINX_VER=$1
else
    export PKR_NGINX_VER=""
fi

export VC_BOX_NAME=$2
export VC_BOX_VER=$3

export DST_VC_BOX=$4
export DST_VC_BOX_VER=$5

# get current source box version
if [ "$VC_BOX_VER" == "current" ]; then

    export VC_BOX_VER=$(curl -s https://app.vagrantup.com/api/v1/box/$VC_BOX_NAME | jq -r '.current_version.version')

    if [ "$VC_BOX_VER" == "" ] || [ "$VC_BOX_VER" == "\n" ]; then
        echo "ERROR: could not get current box version. Make sure the box \"$VC_BOX_NAME\" exists and is accessible."
        exit 1
    fi
fi

# check if box is added
vagrant box list | grep -i "$VC_BOX_NAME (virtualbox, $VC_BOX_VER)" >>/dev/null
if [ "$?" != 0 ]; then
    V_SKIP_ADD="false"
else
    echo "Vagrant box already added. Setting packer to skip adding it"
    V_SKIP_ADD="true"
fi

# execute packer
if [ $# -eq 3 ]; then

    packer validate -except vagrant-cloud,shell-local template.json && \
        packer build \
            -var "v_skip_add=$V_SKIP_ADD" \
            -except vagrant-cloud,shell-local \
            template.json

elif [ $# -eq 5 ]; then

    packer validate template.json && \
        packer build \
            -var "v_skip_add=$V_SKIP_ADD" \
            template.json

fi
