# Event-driven (readme)

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

### Dia 3: