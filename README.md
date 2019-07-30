ansiform
--------------

This is a learning repo for building infrastructure as code using Docker, Terraform and Ansible

### Setup
1. Update `TF_VAR_aws_secret_key` and `TF_VAR_aws_access_key` in `docker-compose.yaml`
2. Create a ssh key called `MyLearningInstance.pem` and add to `~/Downloads/aws_keys`
3. Install Docker and Docker Compose if needed

### Deployment
```bash
docker-compose build
docker-compose run ansiform init web
docker-compose run ansiform plan web
docker-compose run ansiform apply web
docker-compose run ansiform destroy web
```
