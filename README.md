# Event-driven

Um sistema de processamento de pedidos orientado a eventos construído com AWS Lambda, Terraform, DynamoDB e API Gateway. Atualmente evoluindo de uma arquitetura síncrona para um sistema resiliente orientado a eventos, com SQS/DLQ, idempotência e observabilidade com CloudWatch.

# Arquitetura

---

![phase_3_diagram.drawio.svg](/diagrams/phase_3_diagram.drawio.svg)

# Tecnologias utilizadas

---

- Terraform
- AWS Lambda
- SQS queue
- API Gateway
- DynamoDB
- Python

# Estrutura do Projeto

---

```
event-driven-project/
│
├── diagrams/
│ 
├── infra/
│   │
│   ├── api_gateway.tf      → configuração do API Gateway
│   ├── dynamodb.tf         → criação da tabela DynamoDB
│   ├── iam.tf              → roles e permissões IAM
│   ├── lambda.tf           → definição das funções Lambda
│   ├── outputs.tf
│   ├── provider.tf         → configura o provider da AWS
|   ├── sqs.tf              → configuração do SQS
|   ├── variables.tf        → declaração de variáveis reutilizáveis
|   └── versions.tf         → especificações de versões compativeis do projeto
│
├── lambda/
│   ├── event-driven-create-order/
│   │   └── index.py
│   │
│   └── event-driven-process-order/
|       └── index.py
│
└── README.md
```

## DEVLOG

O projeto será desenvolvido de forma incremental:

- Fase 0 → Fundamentos (arquitetura síncrona)
- Fase 1 → Infraestrutura como código (Terraform)
- Fase 2 → modelo assíncrono (event-driven)
- Fase 3 → Resiliência e tolerância a falhas
- Fase 4 → Observabilidade e maturidade de produção
- Fase 5 → Refinamento e nível portfólio

# Fase 0 - Protótipo (Console / Fundamentos)

---

### Dia 1:

Implementei, utilizando o console, o primeiro protótipo do que será o sistema. Criei uma tabela padrão no DynamoDB para o processamento de pedidos, com a partition key `id`. Optei por essa partition key por ainda não saber como ficará a modelagem final do banco, deixando para utilizar GSI futuramente, conforme a necessidade de buscas.

Além disso, criei a primeira função Lambda, que será responsável por criar pedidos e salvá-los na tabela do DynamoDB mencionada anteriormente.

Optei por usar o prefixo `event-driven` em todos os serviços relacionados a este projeto e `event_driven` em todas as variáveis e no código, além de duas tags (enviroment:dev e project:event-driven), para melhor organização.

### Dia 2:

Criei o código da função Lambda utilizando IA (sem copiar e colar) e a documentação da AWS.

O código consiste, basicamente, na criação de um pedido com os seguintes parâmetros: id (número aleatório), items a serem processados (passados no corpo da requisição), status (para controle do tratamento dos pedidos) e createdAt (para controle e busca pela data de criação dos pedidos).

As seguintes bibliotecas foram utilizadas nesse processo:

- uuid
- json
- boto3
- datetime

### Dia 3:

Criei o API Gateway do tipo HTTP API (optei por ele devido ao menor custo e à menor complexidade) e o integrei à função Lambda criada anteriormente. Usei o stage default e baixei o Postman para testar se a API estava funcionando corretamente. Após o teste bem-sucedido, comecei a me direcionar para a fase 1 (apagar tudo e refazer utilizando Terraform).

#### Configuração do teste realizado no Postman

**Method:** POST

**URL:** https://t2ugcied7f.execute-api.sa-east-1.amazonaws.com/orders

Na aba **Headers**, coloque:

| **Key** | **Value** |
| --- | --- |
| Content-Type | application/json |

**Na aba Body:**

marquei **raw →** selecionei **JSON →** e segui esse modelo para testes:

```json
{
  "items": ["produto-1"]
}
```

# Fase 1 - Infraestrutura como código (Terraform)

---

### Diagrama Fase 1:

![phase_1_diagram.drawio.svg](/diagrams/phase_1_diagram.drawio.svg)

### Dia 3:

Estudei um pouco sobre o Terraform e como ele deve ser utilizado, além de definir a estrutura do meu projeto e a arquitetura das pastas com base na documentação disponível no site:

[https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-create](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-create)

### Dia 4:

Continuei meus estudos que havia começado anteriormente a respeito do Terraform. Entretanto, dessa vez utilizei uma documentação diferente um pouco mais voltada para lançar recursos dentro da AWS, visto que isso é meu atual objetivo no momento, link da documentação:

[https://registry.terraform.io/providers/hashicorp/aws/latest/docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

Após estudar um pouco, resolvi lançar o primeiro recurso do projeto com Terraform. Copiei o exemplo da documentação e, com base no protótipo feito no console, fiz as adaptações necessárias para o meu projeto. Em seguida, parti para o próximo recurso: o Lambda. Criei uma subpasta no diretório principal chamada Lambda, onde pretendo guardar as funções do projeto em subpastas, organizadas com arquivos index.py.

### Dia 5:

Continuei o desenvolvimento da infraestrutura do projeto utilizando Terraform. Durante essa etapa, aprofundei meus conhecimentos em HCL para organização da infraestrutura como código, substituindo abordagens baseadas em JSON tradicional. Também implementei o provisionamento de recursos AWS como IAM Roles, IAM Policies e funções Lambda, além de automatizar etapas do deploy, como o empacotamento do código das funções utilizando recursos nativos do Terraform.

### Dia 6:

Terminei de montar minha função Lambda, as roles e as policies no Terraform e agora vou migrar para o API Gateway. No entanto, como ainda não estou muito familiarizado com a arquitetura do Terraform e tive certa dificuldade, decidi montar o seguinte diagrama mostrando o fluxo de criação do Terraform:

![event_driven_diagram.drawio.svg](/diagrams/event_driven_diagram.drawio.svg)

### Dia 7:

Comecei e finalizei a construção do API Gateway no Terraform. Para isso, tive que adicionar cinco blocos ao projeto: event_driven_api_gateway (a própria API criada pelo Terraform), event_driven_api_integration (responsável por integrar a API ao Lambda), event_driven_api_routes (onde as rotas são criadas), event_driven_api_stage (responsável pela criação do stage da API) e lambda_permission (que concede permissões para que a API chame o Lambda).

Optei por criar o API Gateway com a integração do tipo AWS_PROXY (já que estamos trabalhando com lambda e não EC2) e implementei a rota com o método POST, já que ela é responsável por cadastrar novos pedidos no sistema. Com isso, a Fase 1 do projeto foi concluída, entregando um fluxo serverless funcional entre API Gateway, Lambda e DynamoDB.

# Fase 2 - modelo assíncrono (event-driven)

---

### Diagrama Fase 2:

![phase_2_diagram.drawio.svg](/diagrams/phase_2_diagram.drawio.svg)

### Dia 8:

Como eu havia mencionado no dia 6, estava tendo muita dificuldade para trabalhar no meu projeto em Terraform devido à complexidade que ele vinha atingindo. Então, resolvi dividir meu arquivo main.tf em quatro arquivos menores, para melhorar a organização e facilitar o entendimento de onde está cada recurso do projeto. Para isso, criei os seguintes arquivos, com seus respectivos blocos HCL: lambda.tf, api_gateway.tf, dynamoDB.tf e iam.tf.

Conforme o projeto evoluiu, a complexidade da infraestrutura também aumentou, tornando o arquivo `main.tf` cada vez mais difícil de manter e navegar. Para melhorar a organização e facilitar a manutenção da infraestrutura, a configuração Terraform foi dividida em múltiplos arquivos separados por responsabilidade.

Foram criados os seguintes arquivos:

- `lambda.tf`
- `api_gateway.tf`
- `dynamodb.tf`
- `iam.tf`

Cada arquivo passou a concentrar recursos relacionados ao seu respectivo domínio, melhorando a legibilidade da infraestrutura e tornando futuras evoluções mais simples.

### Dia 9:

Comecei o processo de desacoplamento da arquitetura por meio da adição de uma fila Amazon SQS (atualmente utilizando uma Standard Queue). A escolha inicial pela Standard Queue foi feita visando simplicidade e maior escalabilidade, embora exista a possibilidade futura de migração para FIFO caso surja a necessidade de garantia de ordenação ou deduplicação de mensagens.

Além disso, a função Lambda responsável anteriormente por persistir os dados diretamente no DynamoDB começou a ser transformada em uma Producer Lambda, passando a publicar eventos na fila ao invés de realizar o processamento diretamente.

Como próximo passo, será criada uma Consumer Lambda responsável por consumir as mensagens da fila, processá-las e persisti-las no DynamoDB.

Também foram adicionadas as permissões IAM necessárias para permitir que a Lambda publique mensagens no SQS.

### Dia 10:

Realizei melhorias na documentação do projeto, adicionando novas seções ao README, como arquitetura da solução, tecnologias utilizadas e estrutura de diretórios, com o objetivo de tornar a evolução do sistema mais clara e organizada.

Além disso, finalizei a transição da função principal para o modelo de **Lambda Producer**, desacoplando a persistência no banco do fluxo de entrada da aplicação. Durante esse processo, apliquei o princípio do menor privilégio (*Least Privilege*), removendo da Producer as permissões de escrita no DynamoDB.

Também refatorei os recursos de IAM no Terraform para uma nomenclatura mais explícita e escalável, adicionando o prefixo `lambda_producer` aos componentes relacionados à função Producer.

Por fim, iniciei a construção da função **Consumer**, incluindo sua estrutura inicial de código e a configuração completa do IAM responsável pelas permissões de consumo da fila SQS e persistência no DynamoDB.

### Dia 11:

finalizei o desenvolvimento da função **Consumer**, concluindo oficialmente a **Fase 2** do projeto, focada na introdução da arquitetura **event-driven**.

Além da implementação da função, também aprofundei meus estudos sobre o problema de valores **hardcoded** em infraestrutura como código. Como parte dessa melhoria, iniciei o processo de refatoração dos blocos Terraform, centralizando configurações em um arquivo `variables.tf` para tornar a infraestrutura mais reutilizável, organizada e fácil de manter.

Também será adicionado abaixo um diagrama representando o fluxo completo de criação e consumo de eventos desta fase do projeto.

# Fase 3 - Resiliência e tolerância a falhas

---

### Diagrama Fase 3:

![phase_3_diagram.drawio.svg](/diagrams/phase_3_diagram.drawio.svg)

### Dia 12:

Concluí a refatoração dos módulos Terraform, removendo valores hardcoded e centralizando configurações via variáveis.
Também implementei uma DLQ associada à fila SQS da Fase 2. Agora, mensagens que falharem três vezes consecutivas são encaminhadas para a DLQ para análise futura e possível reprocessamento com uma Lambda dedicada (que futuramente vai ser implementada).

O limite de três tentativas foi definido propositalmente para facilitar testes no contexto de um projeto de portfólio.

### Dia 13:

Como a Fase 3 está praticamente concluída, foi realizada uma etapa de revisão e estabilização da aplicação, com foco na identificação de bugs, remoção de dados hardcoded e refinamento geral da infraestrutura e do código.

Também foram executados testes de resiliência e tolerância a falhas, incluindo falhas simuladas na arquitetura assíncrona, validação do mecanismo de retry, análise de logs no CloudWatch e verificação do fluxo de Dead Letter Queue (DLQ), garantindo que o sistema operasse conforme os objetivos arquiteturais definidos para o projeto.

# Fase 4 - Observabilidade e Idempotência

---

### Dia 14: