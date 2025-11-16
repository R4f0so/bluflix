<div align="center">

# 🎬 BluFlix

### Plataforma de Streaming Educacional Acessível para Crianças com TEA

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-FFCA28?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-Academic-blue.svg)](LICENSE)
[![Status](https://img.shields.io/badge/Status-MVP-green.svg)]()

</div>

---

BluFlix é um **MVP de aplicativo de streaming** desenvolvido para oferecer uma experiência acessível a pessoas do espectro autista de nível 1. O sistema disponibiliza vídeos curtos em um catálogo interativo, com interface clara e previsível, visando conforto sensorial, facilidade de navegação e controle do usuário sobre a experiência de reprodução.

Como se trata de um MVP, algumas funcionalidades ainda estão em desenvolvimento e o app não está pronto para uso em produção.

---

## 📋 Sumário

- [Sobre o Projeto](#sobre-o-projeto)
- [Perfis de Usuário](#perfis-de-usuário)
- [Funcionalidades](#funcionalidades)
- [Arquitetura e Tecnologias](#arquitetura-e-tecnologias)
- [Instalação e Execução](#instalação-e-execução)
- [Estrutura de Pastas](#estrutura-de-pastas)
- [Principais Endpoints](#principais-endpoints)
- [Modelos de Dados](#modelos-de-dados)
- [Upload de Vídeos](#upload-de-vídeos)
- [Segurança](#segurança)
- [Termos de Uso e Privacidade](#termos-de-uso-e-privacidade)
- [Contribuição](#contribuição)
- [Licença](#licença)
- [Autores](#autores)
- [Referências](#referências)
- [Screenshots](#screenshots)
- [Observações Finais](#observações-finais)

---

## 📖 Sobre o Projeto

O **BluFlix** foi desenvolvido como **Trabalho de Conclusão de Curso (TCC)** para a FATEC Carapicuíba, com o objetivo de criar uma **plataforma MVP** de streaming acessível para pessoas do espectro autista de nível 1 de suporte, disponibilizando vídeos curtos em um catálogo organizado, proporcionando uma experiência de consumo de conteúdo clara, previsível e confortável, respeitando as necessidades sensoriais e de navegação desse público.

Como se trata de um MVP, o sistema ainda está em fase de desenvolvimento, e algumas funcionalidades podem estar incompletas ou em teste.

### 🎯 Objetivos Principais

- ✨ Proporcionar experiência de consumo de conteúdo educativo clara e previsível
- 🧩 Respeitar necessidades sensoriais específicas do público-alvo
- 👨‍👩‍👧 Oferecer controle parental robusto e seguro
- 🔒 Criar ambiente personalizado para cada perfil infantil
- 🎨 Facilitar navegação através de interface minimalista

---

## 👥 Perfis de Usuário

- **Usuário (Criança)**: Pessoa do espectro autista nível 1 que acessa o catálogo de vídeos curtos, reproduz conteúdos e interage com a interface minimalista através de um perfil personalizado protegido por PIN.

- **Responsável (Pai/Mãe)**: Usuário adulto que gerencia até 4 perfis infantis, configura preferências, monitora o uso e controla o acesso através de autenticação por email/senha.

- **Administrador/Gerente do App**: Usuário responsável por adicionar ou atualizar vídeos no catálogo, gerenciar funcionalidades do aplicativo e visualizar estatísticas de uso.

---

## ✨ Funcionalidades

### Implementadas ✅

#### 🔐 Sistema de Autenticação Dual
- **Pais/Responsáveis**: Login via email e senha (Firebase Authentication)
- **Crianças**: Autenticação por PIN de 4 dígitos com hash SHA-256
- Recuperação de senha por email
- Persistência de sessão automática

#### 👤 Sistema Multi-Perfil
- **Até 4 perfis infantis** por conta de responsável
- Personalização completa: nome, avatar, idade
- Seleção de gêneros favoritos educacionais
- **Isolamento completo de dados** entre perfis
- Favoritos e histórico individualizados por perfil

#### 🎥 Catálogo de Vídeos
- Navegação por catálogo de vídeos curtos em grid responsivo
- Reprodução ao clicar no cartaz de um vídeo
- Integração com **YouTube Player** para reprodução
- Filtragem por gênero educacional:
  - 📚 Educação
  - 🎨 Animação
  - 🎵 Música
  - 🌿 Natureza
  - 🎭 Arte
  - 🔬 Ciência
  - ⚽ Esportes
  - 📖 Histórias
- Reprodução em tela cheia
- Analytics automático de visualizações

#### ❤️ Sistema de Favoritos
- Adicionar/remover vídeos favoritos com um toque
- Lista de favoritos personalizada por perfil infantil
- Sincronização em tempo real com Firestore
- Isolamento: favoritos independentes entre perfis

#### 🌓 Interface e Temas
- Alternância suave entre modo claro e escuro
- Interface minimalista e previsível
- Cores otimizadas para conforto visual
- Botões grandes e espaçados (acessibilidade TEA)
- Animações suaves e não agressivas
- Feedback tátil em interações

#### 🛡️ Painel Administrativo
- Adicionar novos vídeos (URL do YouTube + metadados)
- Editar informações de vídeos existentes
- Soft delete (desativar vídeos sem perder dados)
- Visualizar estatísticas de engajamento
- Controle de acesso via flag `isAdmin`

### Em Desenvolvimento 🚧

- Sistema de busca por título e tags
- Histórico completo de visualização
- Recomendações personalizadas baseadas em preferências
- Modo offline (download de vídeos)
- Notificações de novos conteúdos
- Controle parental avançado (tempo de tela, horários)
- Relatórios detalhados para responsáveis

---

## 🛠️ Arquitetura e Tecnologias

### Frontend
- **Flutter 3.x** - Framework multiplataforma (Dart)
- **Material Design 3** - Design system e componentes UI
- **Provider** - Gerenciamento de estado

### Backend
- **Firebase Authentication** - Autenticação de usuários
- **Cloud Firestore** - Banco de dados NoSQL em tempo real
- **Firebase Storage** - (Opcional) Armazenamento de mídia

### Bibliotecas e Pacotes Principais

```yaml
dependencies:
  # Firebase
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
  cloud_firestore: ^4.13.0
  
  # Reprodução de Vídeo
  youtube_player_flutter: ^8.1.2
  
  # UI e UX
  provider: ^6.1.1
  cached_network_image: ^3.3.0
  
  # Segurança
  crypto: ^3.0.3  # Para hash SHA-256 de PINs
  
  # Utilidades
  intl: ^0.18.1
  shared_preferences: ^2.2.2
```

### Arquitetura em Camadas

```
┌─────────────────────────────────────────────┐
│         CAMADA DE APRESENTAÇÃO              │
│   (Screens, Widgets, UI Components)         │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│          CAMADA DE NEGÓCIO                  │
│   (Services, Business Logic, Validators)    │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│           CAMADA DE DADOS                   │
│   (Firebase, Firestore, Authentication)     │
└─────────────────────────────────────────────┘
```

---

## 📥 Instalação e Execução

### Pré-requisitos

- [Flutter SDK](https://flutter.dev/docs/get-started/install) 3.0 ou superior
- [Firebase CLI](https://firebase.google.com/docs/cli) (opcional, mas recomendado)
- Android Studio ou Xcode (para desenvolvimento mobile)
- Conta no [Firebase Console](https://console.firebase.google.com/)
- Git

### Passo a Passo

#### 1️⃣ Clone o Repositório

```bash
git clone https://github.com/R4f0so/bluflix.git
cd bluflix
```

#### 2️⃣ Instale as Dependências

```bash
flutter pub get
```

#### 3️⃣ Configure o Firebase

**Opção A: FlutterFire CLI (Recomendado)**

```bash
# Instalar FlutterFire CLI globalmente
dart pub global activate flutterfire_cli

# Configurar Firebase automaticamente
flutterfire configure
```

**Opção B: Configuração Manual**

**Para Android:**
1. Crie um projeto no [Firebase Console](https://console.firebase.google.com/)
2. Adicione um aplicativo Android
3. Baixe o arquivo `google-services.json`
4. Coloque em `android/app/google-services.json`

**Para iOS:**
1. No Firebase Console, adicione um aplicativo iOS
2. Baixe o arquivo `GoogleService-Info.plist`
3. Coloque em `ios/Runner/GoogleService-Info.plist`

#### 4️⃣ Configure as Regras do Firestore

No Firebase Console, vá em **Firestore Database → Rules** e cole:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Coleção de usuários (responsáveis)
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Coleção de perfis infantis
    match /child_profiles/{profileId} {
      allow read: if request.auth != null && 
                  resource.data.parentUid == request.auth.uid;
      allow create: if request.auth != null && 
                    request.resource.data.parentUid == request.auth.uid;
      allow update, delete: if request.auth != null && 
                            resource.data.parentUid == request.auth.uid;
    }
    
    // Coleção de vídeos
    match /videos/{videoId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                   get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
  }
}
```

#### 5️⃣ Execute o Aplicativo

```bash
# Para Android
flutter run

# Para iOS
flutter run -d ios

# Para Web (opcional)
flutter run -d chrome
```

---

## 📁 Estrutura de Pastas

```
bluflix/
├── lib/
│   ├── main.dart                    # Ponto de entrada da aplicação
│   ├── screens/                     # Telas do aplicativo
│   │   ├── auth/                    # Telas de autenticação
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── home/                    # Tela principal
│   │   │   ├── home_screen.dart
│   │   │   ├── profile_selection_screen.dart
│   │   │   └── video_player_screen.dart
│   │   ├── profile/                 # Gerenciamento de perfis
│   │   │   ├── profile_management_screen.dart
│   │   │   └── create_child_profile_screen.dart
│   │   ├── admin/                   # Painel administrativo
│   │   │   └── admin_panel_screen.dart
│   │   └── settings/                # Configurações
│   │       └── settings_screen.dart
│   ├── models/                      # Modelos de dados
│   │   ├── user_model.dart
│   │   ├── profile_model.dart
│   │   ├── video_model.dart
│   │   └── genre_model.dart
│   ├── services/                    # Serviços de integração
│   │   ├── auth_service.dart
│   │   ├── firestore_service.dart
│   │   └── video_service.dart
│   ├── widgets/                     # Widgets reutilizáveis
│   │   ├── video_card.dart
│   │   ├── profile_avatar.dart
│   │   └── custom_button.dart
│   ├── utils/                       # Utilitários
│   │   ├── constants.dart
│   │   ├── validators.dart
│   │   └── pin_hasher.dart
│   └── theme/                       # Temas e estilos
│       ├── app_theme.dart
│       └── colors.dart
├── assets/                          # Recursos estáticos
│   ├── images/
│   ├── icons/
│   └── fonts/
├── test/                            # Testes unitários
├── integration_test/                # Testes de integração
├── android/                         # Configurações Android
├── ios/                             # Configurações iOS
├── pubspec.yaml                     # Dependências do projeto
└── README.md                        # Este arquivo
```

---

## 🔗 Principais Endpoints

### Firebase Authentication
- `POST /v1/accounts:signUp` - Registro de novo usuário
- `POST /v1/accounts:signInWithPassword` - Login
- `POST /v1/accounts:sendOobCode` - Recuperação de senha

### Cloud Firestore Collections

#### `users/{userId}`
Armazena dados dos responsáveis (pais/mães).

**Campos:**
- `email`: string
- `name`: string
- `createdAt`: timestamp
- `isAdmin`: boolean
- `childProfileIds`: array[string] (máximo 4)

#### `child_profiles/{profileId}`
Armazena perfis das crianças.

**Campos:**
- `parentUid`: string (referência ao responsável)
- `name`: string
- `avatarUrl`: string
- `pinHash`: string (SHA-256)
- `age`: number
- `preferredGenres`: array[string]
- `favoriteVideoIds`: array[string]
- `watchHistory`: map{videoId: count}
- `createdAt`: timestamp

#### `videos/{videoId}`
Catálogo de vídeos disponíveis.

**Campos:**
- `title`: string
- `description`: string
- `youtubeId`: string (ID do vídeo no YouTube)
- `thumbnailUrl`: string
- `genres`: array[string]
- `durationSeconds`: number
- `uploadedAt`: timestamp
- `viewCount`: number
- `isActive`: boolean

---

## 📊 Modelos de Dados

### User Model (Responsável)

```dart
class UserModel {
  final String uid;
  final String email;
  final String name;
  final DateTime createdAt;
  final bool isAdmin;
  final List<String> childProfileIds;
  
  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.createdAt,
    this.isAdmin = false,
    this.childProfileIds = const [],
  });
  
  Map<String, dynamic> toMap() { ... }
  factory UserModel.fromMap(Map<String, dynamic> map) { ... }
}
```

### Child Profile Model

```dart
class ChildProfileModel {
  final String profileId;
  final String parentUid;
  final String name;
  final String avatarUrl;
  final String pinHash;
  final int age;
  final List<String> preferredGenres;
  final List<String> favoriteVideoIds;
  final Map<String, int> watchHistory;
  
  ChildProfileModel({
    required this.profileId,
    required this.parentUid,
    required this.name,
    required this.avatarUrl,
    required this.pinHash,
    required this.age,
    this.preferredGenres = const [],
    this.favoriteVideoIds = const [],
    this.watchHistory = const {},
  });
  
  Map<String, dynamic> toMap() { ... }
  factory ChildProfileModel.fromMap(Map<String, dynamic> map) { ... }
}
```

### Video Model

```dart
class VideoModel {
  final String videoId;
  final String title;
  final String description;
  final String youtubeId;
  final String thumbnailUrl;
  final List<String> genres;
  final int durationSeconds;
  final DateTime uploadedAt;
  final int viewCount;
  final bool isActive;
  
  VideoModel({
    required this.videoId,
    required this.title,
    required this.description,
    required this.youtubeId,
    required this.thumbnailUrl,
    required this.genres,
    required this.durationSeconds,
    required this.uploadedAt,
    this.viewCount = 0,
    this.isActive = true,
  });
  
  Map<String, dynamic> toMap() { ... }
  factory VideoModel.fromMap(Map<String, dynamic> map) { ... }
}
```

---

## 📤 Upload de Vídeos

### Para Administradores

O BluFlix utiliza integração com o YouTube para reprodução de vídeos, evitando custos com armazenamento no Firebase Storage. Para adicionar um novo vídeo:

1. Faça login como administrador
2. Acesse o Painel Administrativo
3. Clique em "Adicionar Novo Vídeo"
4. Preencha os campos:
   - **Título** (obrigatório)
   - **Descrição** (opcional)
   - **URL do YouTube** (formato: `https://www.youtube.com/watch?v=VIDEO_ID`)
   - **Gêneros** (selecione um ou mais)
   - **Duração** (em segundos)
5. Salve o vídeo

O sistema extrairá automaticamente:
- ID do vídeo no YouTube
- Thumbnail padrão do YouTube
- Timestamp de upload

### Gêneros Disponíveis

- 📚 **Educação** - Conteúdo educativo e didático
- 🎨 **Animação** - Desenhos animados e animações
- 🎵 **Música** - Canções infantis e música educativa
- 🌿 **Natureza** - Documentários sobre animais e meio ambiente
- 🎭 **Arte** - Atividades artísticas e criativas
- 🔬 **Ciência** - Experimentos e curiosidades científicas
- ⚽ **Esportes** - Atividades físicas e esportivas
- 📖 **Histórias** - Narrativas e contos infantis

---

## 🔒 Segurança

### Autenticação

#### Responsáveis
- Autenticação via **Firebase Authentication** (email/senha)
- Senha mínima de 6 caracteres
- Validação de email com RegEx
- Recuperação de senha por email

#### Crianças
- Autenticação por **PIN de 4 dígitos**
- Hash SHA-256 do PIN antes de armazenar
- Sem acesso direto ao Firestore (proteção de dados)

```dart
import 'package:crypto/crypto.dart';
import 'dart:convert';

String hashPin(String pin) {
  final bytes = utf8.encode(pin);
  final digest = sha256.convert(bytes);
  return digest.toString();
}
```

### Regras de Firestore

- **Isolamento de dados**: Cada usuário só acessa seus próprios dados
- **Validação de parentesco**: Perfis infantis verificam `parentUid`
- **Controle de admin**: Apenas admins podem gerenciar vídeos
- **Leitura pública de vídeos**: Vídeos são visíveis apenas para usuários autenticados

### Validações

- Email: formato válido obrigatório
- Senha: mínimo 6 caracteres
- PIN: exatamente 4 dígitos numéricos
- Limite: máximo 4 perfis infantis por conta
- Nome de perfil: mínimo 2 caracteres

---

## 📜 Termos de Uso e Privacidade

### Coleta de Dados

O BluFlix coleta e armazena:
- Email e nome do responsável
- Nome, idade e avatar dos perfis infantis
- Histórico de visualizações (anônimo, por perfil)
- Vídeos favoritos
- Preferências de gêneros

### Uso de Dados

Os dados são utilizados exclusivamente para:
- Autenticação e gerenciamento de conta
- Personalização da experiência
- Analytics internos (não compartilhados)
- Melhorias do aplicativo

### Segurança

- Todos os dados são criptografados em trânsito (HTTPS)
- PINs armazenados com hash SHA-256
- Acesso restrito por regras de Firestore
- Nenhum dado é vendido ou compartilhado com terceiros

### Direitos do Usuário

- Acesso aos próprios dados
- Exclusão de conta e dados a qualquer momento
- Modificação de informações pessoais

**Nota**: Este é um projeto acadêmico MVP. Para uso em produção, seria necessário adequação completa à LGPD e outras legislações aplicáveis.

---

## 🤝 Contribuição

Contribuições são bem-vindas! Este é um projeto acadêmico, mas sugestões e melhorias são apreciadas.

### Como Contribuir

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/MinhaFeature`)
3. Commit suas mudanças (`git commit -m 'Adiciona MinhaFeature'`)
4. Push para a branch (`git push origin feature/MinhaFeature`)
5. Abra um Pull Request

### Diretrizes

- Siga as convenções de código do Flutter/Dart
- Adicione testes para novas funcionalidades
- Atualize a documentação quando necessário
- Descreva claramente as mudanças no PR

---

## 📄 Licença

Este projeto foi desenvolvido como **Trabalho de Conclusão de Curso (TCC)** para a FATEC Carapicuíba e é destinado a fins **acadêmicos e educacionais**.

---

## 👨‍💻 Autores

**Rafael (Rafa)**  
Estudante de Ciência da Computação - FATEC Carapicuíba

- GitHub: [@R4f0so](https://github.com/R4f0so)
- LinkedIn: [Seu perfil LinkedIn]
- Email: [seu.email@exemplo.com]

### Orientação Acadêmica
- **Orientador(a)**: [Nome do Professor(a)]
- **Instituição**: FATEC Carapicuíba
- **Curso**: Ciência da Computação
- **Ano**: 2024

---

## 📚 Referências

### Documentação Técnica
- [Documentação Flutter](https://docs.flutter.dev/)
- [Firebase para Flutter](https://firebase.flutter.dev/)
- [Material Design Guidelines](https://material.io/design)
- [YouTube Player Flutter](https://pub.dev/packages/youtube_player_flutter)

### Acessibilidade e TEA
- [Acessibilidade no Flutter](https://docs.flutter.dev/development/accessibility-and-localization/accessibility)
- Diretrizes de design para pessoas com TEA
- Pesquisas sobre UX para espectro autista

### Artigos Acadêmicos
- [Inserir artigos relevantes sobre TEA e tecnologia]
- [Inserir referências sobre streaming educacional]

---

## 📸 Screenshots

### Tela de Login
![Login](assets/screenshots/login.png)

### Seleção de Perfil
![Perfis](assets/screenshots/profiles.png)

### Catálogo de Vídeos
![Catálogo](assets/screenshots/catalog.png)

### Reprodução de Vídeo
![Player](assets/screenshots/player.png)

### Painel Administrativo
![Admin](assets/screenshots/admin.png)

---

## 📝 Observações Finais

O **BluFlix** é um **MVP** (Minimum Viable Product) destinado a validar conceitos de usabilidade e acessibilidade para pessoas do espectro autista nível 1 de suporte.

### Status do Projeto

✅ **Completo no MVP:**
- Sistema de autenticação dual
- Multi-perfil com isolamento de dados
- Catálogo e reprodução de vídeos
- Sistema de favoritos
- Painel administrativo
- Temas claro/escuro

🚧 **Em Desenvolvimento:**
- Sistema de busca avançada
- Recomendações personalizadas
- Controle parental detalhado
- Analytics avançados
- Modo offline

### Próximos Passos

Funcionalidades adicionais e refinamentos estão planejados para futuras versões, incluindo:
- Testes de usabilidade com o público-alvo
- Feedback de terapeutas e especialistas em TEA
- Expansão do catálogo de vídeos educacionais
- Melhorias de performance e otimização
- Publicação nas lojas (Google Play / App Store)

**Nota**: Estas funcionalidades não fazem parte desta entrega acadêmica inicial.

---

## 🙏 Agradecimentos

- **FATEC Carapicuíba** - Pela oportunidade e suporte acadêmico
- **Professores e Orientadores** - Pela orientação durante o desenvolvimento
- **Comunidade Flutter** - Pela documentação e recursos
- **Firebase** - Pela plataforma backend robusta e gratuita para MVPs
- **Famílias com crianças TEA** - Pela inspiração e motivação do projeto

---

## 📞 Suporte e Contato

Encontrou um bug? Tem uma sugestão? Entre em contato:

- 🐛 [Abra uma Issue](https://github.com/R4f0so/bluflix/issues)
- 💬 [Discussões no GitHub](https://github.com/R4f0so/bluflix/discussions)
- 📧 Email: [seu.email@exemplo.com]

---

<div align="center">

**Desenvolvido com ❤️ para tornar o streaming educacional mais acessível**

⭐ Se este projeto foi útil para você ou seu TCC, considere dar uma estrela!

[![GitHub stars](https://img.shields.io/github/stars/R4f0so/bluflix.svg?style=social)](https://github.com/R4f0so/bluflix/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/R4f0so/bluflix.svg?style=social)](https://github.com/R4f0so/bluflix/network)

</div>
