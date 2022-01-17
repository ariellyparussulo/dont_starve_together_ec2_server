# Servidor EC2 de Don't Starve Together
Este projeto Terraform foi criado para gerar um servidor EC2 básico de Don't Starve Together.
Você pode personalizar esse servidor abrindo o arquivo [init.sh.tpl](./_resources/init.sh.tpl). Ele possui o script de inicialização deste servidor e você poderá colocar todos os arquivos de configuração que quiser.

## 1. Pre-Setup
1. Crie uma conta na [AWS](https://aws.amazon.com/pt/account/).
2. Crie um [usuário](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html) administrador no IAM em sua conta.
3. Crie um [access key](https://docs.aws.amazon.com/powershell/latest/userguide/pstools-appendix-sign-up.html) para seu usuário.
4. Instale o [terraform](https://www.terraform.io/).

## 2. Gerando um token para o Don't Starve Together
1. Siga o tutorial **Server Tokens** [desse link](https://dontstarve.fandom.com/wiki/Guides/Don’t_Starve_Together_Dedicated_Servers).
2. Crie um [Parâmetro SSM](https://console.aws.amazon.com/systems-manager/parameters?region=us-east-1) do tipo **SecretString** como o nome **/cluster/dont_starve_together/token** com o valor gerado no passo anterior.

## 3. Rodando o terraform
1. Defina seu AWS_PROFILE usando `export AWS_PROFILE=<seu profile>`.
2. Rode `terraform init` para iniciar o projeto.
3. Rode `terraform approve -auto-approve` para rodar o projeto.
4. Espere o script terminar.

## (Opcional) Destruindo esse projeto
Rode `terraform destroy -auto-approve`.

## 4. Armazenando seu tfstate.
Caso queira compartilhar esse projeto com outras pessoas é recomendado criar um S3 Bucket e salvar o tfstate nele. Assim, todo mundo que usar esse projeto - e tiver acesso a sua conta - poderá aplicar alterações nesse projeto. Para criar um backend, olhe [este link](https://www.terraform.io/language/settings/backends/s3).

## 5. Mudando as configurações do seu servidor
Abra o [arquivo principal do terraform](./main.tf). Nele você poderá mudar as seguintes configurações do seu servidor:

- **cluster_name**: nome do seu servidor.
- **cluster_description**: descrição do seu servidor.
- **cluster_intention**: modo do jogo ([Neste link](https://tokphobia.com/setting-up-a-dedicated-dont-starve-together-server-in-aws.html) há todas as opções disponíveis).
- **cluster_password**: senha do servidor.
- **max_players**: quantidade máxima de jogares