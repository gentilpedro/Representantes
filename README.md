# Josapar Representantes

> ⚠️ **Este projeto é um protótipo funcional.** Foi construído a partir de telas do
> Visily para validar fluxos e experiência de uso com representantes de vendas da
> Josapar S.A. **Nenhum dado é real** — toda a camada de dados (login, pedidos,
> clientes, agenda, relatórios, sincronização) é servida por repositórios *mock* em
> memória, feitos para simular a futura Web API .NET 10 da empresa. Quando a API real
> existir, basta trocar as implementações em `lib/**/data/repositories/` — as telas não
> precisam mudar.

App em Flutter para representantes comerciais da Josapar, cobrindo:

- Login e dashboard do representante
- Pedidos (lista, novo pedido, catálogo de produtos, carrinho)
- Clientes (lista, favoritos, detalhe financeiro)
- Agenda de visitas com check-in/check-out por GPS
- Relatórios de vendas (gráficos de linha, barra e donut)
- Sincronização automática: pedidos finalizados offline ficam salvos localmente como
  `pending` e são enviados sozinhos assim que a conexão volta (sem precisar tocar em
  "Sincronizar Agora") — rascunhos (`draft`) nunca entram nessa fila
- Persistência local de verdade (Hive): a fila de pedidos offline e o cache de
  produtos/clientes/leads sobrevivem a um restart do app ou refresh da página — veja
  [Persistência local](#persistência-local) abaixo
- Perfil / configurações

Feito para rodar tanto em **mobile (Android e iOS)** quanto em **Web**, a partir do
mesmo código-fonte.

## Login (protótipo)

A autenticação é mock: **aceita qualquer código/e-mail e qualquer senha, desde que não
fiquem em branco.** Não existe validação real de credenciais nesta fase. Sugestão para
testar:

| Campo               | Valor de exemplo         |
|---------------------|---------------------------|
| Código ou e-mail    | `88294` (ou qualquer texto) |
| Senha               | `123456` (ou qualquer texto) |

Após o login, o app sempre retorna o mesmo usuário fixo do protótipo: **Ricardo
Santos**, Representante Comercial Sênior, Região Sul.

## Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (canal stable — testado
  com Flutter 3.44.4 / Dart 3.12.2)
- Para rodar no navegador: Chrome ou Edge instalado
- Para rodar em Android: Android Studio + Android SDK, um emulador configurado ou um
  aparelho físico com depuração USB habilitada
- Para rodar em iOS: um Mac com Xcode instalado (não é possível compilar para iOS a
  partir de Windows/Linux — veja seção específica abaixo)

Verifique se o ambiente está pronto com:

```bash
flutter doctor
```

Instale as dependências do projeto:

```bash
flutter pub get
```

## Rodando na Web

```bash
flutter run -d chrome
# ou
flutter run -d edge
```

Isso abre o app no navegador com hot reload. Para gerar um build de produção estático
(pasta `build/web`, publicável em qualquer servidor de arquivos estáticos):

```bash
flutter build web
```

## Rodando no celular

### Android

1. Conecte um aparelho Android via USB com a **depuração USB** ativada (Configurações
   → Opções do desenvolvedor → Depuração USB), ou inicie um emulador pelo Android
   Studio (Device Manager).
2. Confirme que o Flutter enxerga o dispositivo:
   ```bash
   flutter devices
   ```
3. Rode o app:
   ```bash
   flutter run
   ```
   Se houver mais de um dispositivo conectado (ex.: emulador + celular físico), use
   `flutter run -d <device-id>` (o id aparece na saída de `flutter devices`).

Para gerar um instalável (`.apk`) para compartilhar com outra pessoa testar sem passar
pelo `flutter run`:

```bash
flutter build apk --debug
```

O arquivo fica em `build/app/outputs/flutter-apk/app-debug.apk`.

> **Nota:** se `flutter doctor` acusar problema de licenças do Android SDK, rode
> `flutter doctor --android-licenses` e aceite todas antes de compilar para Android.

### iOS

A compilação para iOS **exige um Mac com Xcode** (é uma limitação da Apple, não do
Flutter). Em um Mac, com um iPhone conectado (ou o Simulator do Xcode aberto):

```bash
flutter devices
flutter run
```

Para instalar num iPhone físico é necessária uma conta de desenvolvedor Apple
configurada no Xcode (`ios/Runner.xcworkspace`) para assinatura do app.

## Persistência local

Diferente do resto da camada de dados (que é toda mock em memória), duas coisas
realmente sobrevivem a um restart do app ou a um refresh da página web, usando
[Hive](https://pub.dev/packages/hive) (banco embutido, sem plugin nativo — funciona em
Android/iOS/Windows/Web sem setup extra):

- **Fila de pedidos offline** (`lib/features/orders/data/local/offline_order_record.dart`):
  todo pedido finalizado com "Finalizar" (não rascunho) é gravado localmente enquanto
  fica `pending`. Feche a aba, dê refresh, reabra o app — o pedido continua na fila.
  Assim que é sincronizado (reconexão automática ou "Sincronizar Agora"), o registro
  local é apagado — rascunhos nunca entram nessa fila.
- **Cache de referência** (produtos, clientes e "clientes em potencial"/leads): na
  primeira execução é semeado com os dados de exemplo do protótipo, simulando "o
  último download do servidor"; dali em diante o app lê sempre do cache local. Sem uma
  Web API real ainda, `refreshCache()` em cada repositório só re-semeia os mesmos
  exemplos — a peça já fica pronta para virar um download semanal de verdade. Leads
  ainda não têm tela própria; a única integração visível hoje é uma parada extra na
  Agenda de Visitas com o chip "Cliente em Potencial".

O resto (histórico de pedidos já enviados, detalhe de cliente, notificações etc.)
continua sendo dado de exemplo fixo, já que ainda não existe uma Web API real para
guardar isso de verdade.

## Rodando os testes automatizados

O projeto tem testes de widget cobrindo o fluxo real de cada tela (não apenas
renderização), incluindo a durabilidade da persistência local entre "restarts". Para
rodar todos:

```bash
flutter test
```

## Estrutura do projeto

```
lib/
  core/                # tema, formatação, storage de sessão/Hive, utilitários compartilhados
  features/
    auth/               # boas-vindas, primeiro acesso, login e sessão
    dashboard/          # tela inicial do representante
    orders/             # pedidos, catálogo, carrinho, fila offline (Hive)
    clients/            # clientes e detalhe financeiro (cache Hive)
    leads/               # clientes em potencial (cache Hive, sem tela própria ainda)
    agenda/             # agenda de visitas com GPS (inclui paradas de leads)
    reports/            # relatórios e gráficos
    sync/                # sincronização offline e notificações
    profile/            # perfil e configurações
test/                  # testes de fluxo (*_flow_test.dart) e de persistência local
```

Cada feature segue o padrão `domain/` (entidades + interface do repositório) →
`data/` (implementação mock do repositório) → `presentation/` (telas + providers
Riverpod). Essa separação é o que permite trocar os mocks por chamadas reais à Web API
.NET 10 no futuro sem tocar nas telas.
