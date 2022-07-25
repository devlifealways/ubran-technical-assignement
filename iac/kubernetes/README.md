## Traefik

I have choosed to use Traefik ingress controller for this techincal assignement
you can install it like this

```shell
$ helm repo add traefik https://helm.traefik.io/traefik && helm repo update
$ helm upgrade --install traefik traefik/traefik --namespace ingress-controller --create-namespace --values traefik_values.yaml
```

and then it's just a matter of applying the `deploy_all.yaml` manifest:

```shell
# you chan use create but running it over and over
# will be a bad idea
$ kubectl apply -f deploy_all.yaml
```

Hope it helps, enjoy
