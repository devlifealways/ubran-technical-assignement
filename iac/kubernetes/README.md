## Traefik Helm chart

I have choosed to use Traefik ingress controller for this techincal assignement
you can install it like this

```shell
$ helm repo add traefik https://helm.traefik.io/traefik && helm repo update
$ helm upgrade --install traefik traefik/traefik --namespace ingress-controller --create-namespace --values traefik_values.yaml
```

and then it's just a matter of applying urban's helm chart

## Urban Helm chart

```shell
# make sure you're in the folder kubernetes/
$ helm install ubran urban --create-namespace -n urban
```

If you wish to tweak deployment behavior, then please try to do so using your values files

```shell
# generate default values and change it to your liking
$ helm show values urban > urban_values.yaml
$ helm install ubran urban --create-namespace -n urban -f urban_values.yaml
```

Hope it helps, enjoy
