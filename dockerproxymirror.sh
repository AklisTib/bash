cat <<EOF > /etc/docker/daemon.json
{
    "registry-mirrors": [
        "https://dockerhub1.beget.com"
        "https://mirror.gcr.io"
        "https://dockerhub.timeweb.cloud"
        "https://daocloud.io",
        "https://c.163.com/",
        "https://registry.docker-cn.com"
    ]
}

EOF

systemctl restart docker
