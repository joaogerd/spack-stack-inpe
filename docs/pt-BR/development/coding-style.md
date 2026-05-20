# Estilo de código

## Scripts shell

- Use `bash` explicitamente quando recursos do Bash forem necessários.
- Use nomes claros de funções.
- Imprima mensagens operacionais com prefixos consistentes como `[INFO]`, `[WARN]` e `[ERROR]`.
- Falhe cedo quando uma variável, comando ou caminho obrigatório estiver ausente.
- Mantenha valores específicos de máquina em arquivos de configuração, não escondidos em lógica genérica.

## Documentação

- Prefira comandos concretos a descrições genéricas.
- Separe fatos confirmados de hipóteses.
- Registre evidências de validação.
- Não copie valores de outra máquina sem verificação.

## YAML

- Mantenha a configuração de site focada na infraestrutura.
- Mantenha dependências de aplicação nas definições de ambiente.
- Use comentários quando um valor for específico do site ou provisório.
