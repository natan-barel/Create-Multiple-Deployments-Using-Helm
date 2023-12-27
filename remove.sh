cd /usercode
helm create multiple-deployments
rm -r  /usercode/multiple-deployments/templates/tests
rm /usercode/multiple-deployments/templates/ingress.yaml /usercode/multiple-deployments/templates/hpa.yaml /usercode/multiple-deployments/templates/serviceaccount.yaml
> /usercode/multiple-deployments/values.yaml
> /usercode/multiple-deployments/templates/deployment.yaml
> /usercode/multiple-deployments/templates/service.yaml
> /usercode/multiple-deployments/templates/NOTES.txt
> /usercode/multiple-deployments/templates/_helpers.tpl
touch /usercode/multiple-deployments/templates/configmap.yaml
cd /usercode/multiple-deployments