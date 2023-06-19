curl -fsS https://raw.githubusercontent.com/grafana/loki/master/tools/promtail.sh | \
sh -s 625089 <API Key> logs-prod-011.grafana.net monitoring | \
kubectl apply --namespace=monitoring -f  -
