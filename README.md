В данном репозитории хранится код развертывания облачной инфраструктуры в Yandex cloud, по средствам использования Terraform.

1. Terraform_vm_lb1 - разворачивает VM, сеть, подсеть, load-balancer, DNS запись
2. Terraform_prod_lb2 – разворачивает VM для production, load-balancer, DNS запись 
3. Terraform_monitoring - разворачивает VM для мониторинга и две DNS записи (одна в итоге для Prometheus, вторая для Grafana)
4. Terraform_base_image – создает образ деска с VM prod
5. Terraform_ASG – разворачивает автоматическое масштабирование VM при этом взяв образ диска с VM prod

* все личные данные изменены

