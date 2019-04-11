
## create on current folder an `aws_credentials` file containing:

```
aws_access_key_id = <my access key>
aws_secret_access_key = <my secret key>
```

## debugging :

```sh
docker-machine -s $HOME/.tsuru/installs/tsuru ssh tsuru-1
sudo -i
docker ps
docker logs ...
```

## default credentials

tsuru dashboard default createndials are `admin@example.com / admin123`
