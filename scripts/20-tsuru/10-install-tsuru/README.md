## debugging

```sh
docker-machine -s $HOME/.tsuru/installs/tsuru ssh tsuru-1
sudo -i
docker ps
docker logs ...
```

## default credentials

tsuru dashboard default createndials are `admin@example.com / admin123`
