# Event-driven (readme)

## Planejamento

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

### Dia 8:

Como eu havia mencionado no dia 6, estava tendo muita dificuldade para trabalhar no meu projeto em Terraform devido à complexidade que ele vinha atingindo. Então, resolvi dividir meu arquivo main.tf em quatro arquivos menores, para melhorar a organização e facilitar o entendimento de onde está cada recurso do projeto. Para isso, criei os seguintes arquivos, com seus respectivos blocos HCL: lambda.tf, api_gateway.tf, dynamoDB.tf e iam.tf.

### Dia 9: (SQS)