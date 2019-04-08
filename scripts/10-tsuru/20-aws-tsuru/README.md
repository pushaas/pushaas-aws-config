Criar nessa pasta um arquivo `aws_credentials` com o conteúdo:

```
aws_access_key_id = <my access key>
aws_secret_access_key = <my secret key>
```

Para debug:

```sh
docker-machine -s $HOME/.tsuru/installs/tsuru ssh tsuru-1
sudo -i
docker ps
docker logs ...
```
