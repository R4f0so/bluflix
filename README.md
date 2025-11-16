# BluFlix 

## 📋 Sumário

1. [Visão Geral do Projeto](#visão-geral-do-projeto)
2. [Arquitetura do Sistema](#arquitetura-do-sistema)
3. [Estrutura do Projeto](#estrutura-do-projeto)
4. [Modelos de Dados](#modelos-de-dados)
5. [Serviços Principais](#serviços-principais)
6. [Rotas e Navegação](#rotas-e-navegação)
7. [Gerenciamento de Estado](#gerenciamento-de-estado)
8. [Firebase e Firestore](#firebase-e-firestore)
9. [Segurança](#segurança)
10. [Analytics e Monitoramento](#analytics-e-monitoramento)

---

## 1. Visão Geral do Projeto

### 1.1 Sobre o BluFlix

O **BluFlix** é um aplicativo MVP de streaming educacional desenvolvido como TCC para a FATEC Carapicuíba, voltado para crianças com TEA nível 1 de suporte.

### 1.2 Tecnologias Utilizadas

#### Frontend
- **Flutter**: ^3.9.2
- **Dart**: SDK
- **go_router**: ^17.0.0 (navegação)
- **provider**: ^6.1.2 (gerenciamento de estado)
- **youtube_player_flutter**: ^9.0.3

#### Backend
- **firebase_core**: ^4.1.1
- **firebase_auth**: ^6.1.0
- **cloud_firestore**: ^6.0.2

#### Segurança
- **crypto**: ^3.0.6 (SHA-256 para PINs)
- **flutter_secure_storage**: ^9.2.4

#### Utilidades
- **shared_preferences**: ^2.2.2
- **audioplayers**: ^6.5.1

---

## 2. Arquitetura do Sistema

### 2.1 Estrutura de Pastas Real

```
bluflix/
├── lib/
│   ├── main.dart                           # Ponto de entrada
│   ├── firebase_options.dart               # Configuração Firebase
│   │
│   ├── core/                               # Núcleo do app
│   │   ├── routes/
│   │   │   └── app_routes.dart            # Rotas do GoRouter
│   │   └── theme/
│   │       └── app_theme.dart             # Gerenciamento de temas
│   │
│   ├── data/                               # Camada de dados
│   │   ├── models/
│   │   │   ├── video_model_youtube.dart
│   │   │   └── video_visualizacao_model.dart
│   │   └── services/
│   │       ├── pin_service.dart
│   │       ├── video_service_youtube.dart
│   │       ├── analytics_service.dart
│   │       └── admin_guard.dart
│   │
│   └── presentation/                       # Camada de apresentação
│       ├── providers/
│       │   └── perfil_provider.dart
│       └── screens/
│           ├── auth/
│           │   ├── splash_screen.dart
│           │   ├── options_screen.dart
│           │   ├── login_screen.dart
│           │   ├── cadastro_screen.dart
│           │   └── esqueci_senha_screen.dart
│           ├── onboarding/
│           │   ├── avatar_screen.dart
│           │   ├── apelido_screen.dart
│           │   ├── criapin_screen.dart
│           │   ├── avatar_filho_screen.dart
│           │   ├── apelido_filho_screen.dart
│           │   └── preferencias_filho_screen.dart
│           ├── catalogo/
│           │   ├── catalogo_screen.dart
│           │   ├── lista_videos_screen_youtube.dart
│           │   ├── video_player_youtube_screen.dart
│           │   └── favoritos_screen.dart
│           ├── perfil/
│           │   ├── adicionar_perfis_screen.dart
│           │   ├── mudar_perfil_screen.dart
│           │   ├── gerenciamento_pais_screen.dart
│           │   ├── mudar_avatar_screen.dart
│           │   └── editar_perfil_filho_screen.dart
│           ├── configuracoes/
│           │   ├── perfil_configs_screen.dart
│           │   ├── perfilpai_configs_screen.dart
│           │   ├── seguranca_config_screen.dart
│           │   └── tema_config_screen.dart
│           ├── admin/
│           │   ├── gerenciamento_admin_screen.dart
│           │   ├── admin_gerenciar_videos_screen.dart
│           │   ├── admin_add_video_screen.dart
│           │   └── admin_listar_videos_screen.dart
│           └── analytics/
│               └── perfil_filho_analytics_screen.dart
│
├── assets/
│   ├── logo.png
│   ├── logo_1024.png
│   ├── morning_background.png
│   ├── night_background.png
│   ├── google.png
│   ├── facebook.png
│   └── avatar1.png até avatar8.png
│
├── firestore.rules                         # Regras de segurança
├── firebase.json                           # Configuração Firebase
└── pubspec.yaml                            # Dependências
```

---

## 3. Modelos de Dados

### 3.1 VideoModelYoutube

```dart
class VideoModelYoutube {
  final String id;
  final String titulo;
  final String descricao;
  final String youtubeId;         // Ex: "dQw4w9WgXcQ"
  final String youtubeUrl;        // URL completa do YouTube
  final List<String> generos;
  final DateTime dataUpload;
  final bool ativo;

  VideoModelYoutube({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.youtubeId,
    required this.youtubeUrl,
    required this.generos,
    required this.dataUpload,
    this.ativo = true,
  });

  // ═══════════════════════════════════════════════════════════════
  // MÉTODOS
  // ═══════════════════════════════════════════════════════════════

  /// Converte de Firestore DocumentSnapshot
  factory VideoModelYoutube.fromFirestore(DocumentSnapshot doc);

  /// Converte para Map (para salvar no Firestore)
  Map<String, dynamic> toMap();

  /// URL da thumbnail do YouTube
  String get thumbnailUrl =>
      'https://img.youtube.com/vi/$youtubeId/hqdefault.jpg';

  /// Extrai ID do YouTube de uma URL
  static String? extractYoutubeId(String url);

  /// Copia o modelo com alterações
  VideoModelYoutube copyWith({...});
}
```

**Firestore**: Collection `videos_youtube/{id}`

**Campos no Firestore:**
```json
{
  "titulo": "string",
  "descricao": "string",
  "youtubeId": "string",
  "youtubeUrl": "string",
  "generos": ["array"],
  "dataUpload": "timestamp",
  "ativo": "boolean"
}
```

### 3.2 VideoVisualizacao (Analytics)

```dart
class VideoVisualizacao {
  final String id;
  final String videoId;
  final String videoTitulo;
  final String videoThumbnail;
  final String genero;
  final String perfilFilhoApelido;
  final DateTime inicioVisualizacao;
  final DateTime? fimVisualizacao;
  final int duracaoAssistidaSegundos;
  final int duracaoTotalSegundos;
  final double percentualAssistido;
  final bool concluido;
  final int vezesReassistido;

  VideoVisualizacao({...});

  Map<String, dynamic> toMap();
  factory VideoVisualizacao.fromMap(String id, Map<String, dynamic> map);
}
```

**Firestore**: `users/{userId}/perfis/{perfilApelido}/analytics/{id}`

### 3.3 SessaoApp (Tempo de Uso)

```dart
class SessaoApp {
  final String id;
  final String perfilFilhoApelido;
  final DateTime inicioSessao;
  final DateTime? fimSessao;
  final int duracaoSegundos;

  SessaoApp({...});

  Map<String, dynamic> toMap();
  factory SessaoApp.fromMap(String id, Map<String, dynamic> map);
}
```

**Firestore**: `users/{userId}/perfis/{perfilApelido}/sessoes/{id}`

---

## 4. Serviços Principais

### 4.1 VideoServiceYoutube

Gerencia todas as operações com vídeos do YouTube no Firestore.

```dart
class VideoServiceYoutube {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ═══════════════════════════════════════════════════════════════
  // BUSCAR VÍDEOS
  // ═══════════════════════════════════════════════════════════════

  /// Busca todos os vídeos ativos
  Future<List<VideoModelYoutube>> buscarTodosVideos() async {...}

  /// Busca vídeos por gênero específico
  Future<List<VideoModelYoutube>> buscarVideosPorGenero(String genero) async {...}

  /// Busca vídeos por múltiplos gêneros
  Future<List<VideoModelYoutube>> buscarVideosPorGeneros(
    List<String> generos,
  ) async {...}

  /// Busca um vídeo específico por ID
  Future<VideoModelYoutube?> buscarVideoPorId(String videoId) async {...}

  // ═══════════════════════════════════════════════════════════════
  // ADMIN - GERENCIAR VÍDEOS
  // ═══════════════════════════════════════════════════════════════

  Future<String?> adicionarVideo({
    required String titulo,
    required String descricao,
    required String youtubeUrl,
    required List<String> generos,
  }) async {...}

  Future<bool> atualizarVideo({
    required String videoId,
    String? titulo,
    String? descricao,
    String? youtubeUrl,
    List<String>? generos,
    bool? ativo,
  }) async {...}

  Future<bool> excluirVideo(String videoId) async {...}

  Future<bool> desativarVideo(String videoId) async {...}

  // ═══════════════════════════════════════════════════════════════
  // ANALYTICS
  // ═══════════════════════════════════════════════════════════════

  Future<void> registrarVisualizacao(String videoId, String userId) async {...}

  Future<int> buscarTotalVisualizacoes(String videoId) async {...}
}
```

### 4.2 PinService

Gerenciamento seguro de PINs com hash SHA-256.

```dart
class PinService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ═══════════════════════════════════════════════════════════════
  // HASH SHA-256
  // ═══════════════════════════════════════════════════════════════

  /// Gera hash SHA-256 do PIN
  /// Exemplo: "1234" → "03ac674216f3e15c761ee1a5e255f067..."
  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // ═══════════════════════════════════════════════════════════════
  // GERENCIAR PIN
  // ═══════════════════════════════════════════════════════════════

  Future<bool> criarPinPerfilPai(String pin) async {...}

  Future<bool> verificarPinPerfilPai(String pin) async {...}

  Future<bool> alterarPinPerfilPai(String pinAntigo, String pinNovo) async {...}

  Future<bool> removerPinPerfilPai(String pin) async {...}

  Future<bool> temPinConfigurado() async {...}

  // ═══════════════════════════════════════════════════════════════
  // VALIDAÇÃO
  // ═══════════════════════════════════════════════════════════════

  /// Valida se o PIN é válido:
  /// - 4 dígitos
  /// - Apenas números
  bool _validarPin(String pin) {...}
}
```

**Estrutura no Firestore:**
```json
{
  "users/{userId}": {
    "pinHash": "string (SHA-256)",
    "pinCriadoEm": "timestamp",
    "pinAlteradoEm": "timestamp"
  }
}
```

### 4.3 AnalyticsService

Sistema completo de analytics e monitoramento.

```dart
class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ═══════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════

  CollectionReference _getAnalyticsRef(String userId, String perfilApelido) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('perfis')
        .doc(perfilApelido)
        .collection('analytics');
  }

  CollectionReference _getSessoesRef(String userId, String perfilApelido) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('perfis')
        .doc(perfilApelido)
        .collection('sessoes');
  }

  // ═══════════════════════════════════════════════════════════════
  // VISUALIZAÇÕES
  // ═══════════════════════════════════════════════════════════════

  Future<String?> iniciarVisualizacao({
    required String videoId,
    required String videoTitulo,
    required String videoThumbnail,
    required String genero,
    required String perfilFilhoApelido,
    required int duracaoTotalSegundos,
  }) async {...}

  Future<void> finalizarVisualizacao({
    required String visualizacaoId,
    required int duracaoAssistidaSegundos,
    String? perfilFilhoApelido,
  }) async {...}

  // ═══════════════════════════════════════════════════════════════
  // SESSÕES
  // ═══════════════════════════════════════════════════════════════

  Future<String?> iniciarSessao(String perfilFilhoApelido) async {...}

  Future<void> finalizarSessao(
    String sessaoId,
    String perfilFilhoApelido,
  ) async {...}

  // ═══════════════════════════════════════════════════════════════
  // ESTATÍSTICAS
  // ═══════════════════════════════════════════════════════════════

  Future<List<VideoVisualizacao>> buscarVisualizacoesPerfil(
    String perfilFilhoApelido, {
    int? limiteDias,
  }) async {...}

  Future<int> calcularTempoTotalTela(
    String perfilFilhoApelido, {
    int? limiteDias,
  }) async {...}

  Future<Map<String, int>> calcularGenerosMaisAssistidos(
    String perfilFilhoApelido, {
    int? limiteDias,
  }) async {...}

  Future<List<VideoVisualizacao>> buscarVideosMaisAssistidos(
    String perfilFilhoApelido, {
    int limite = 10,
  }) async {...}

  Future<double> calcularTaxaConclusao(
    String perfilFilhoApelido, {
    int? limiteDias,
  }) async {...}

  Future<int> calcularDuracaoMediaSessao(
    String perfilFilhoApelido, {
    int? limiteDias,
  }) async {...}

  Future<Map<String, int>> calcularFrequenciaPorDia(
    String perfilFilhoApelido, {
    int? limiteDias,
  }) async {...}
}
```

### 4.4 AdminGuard

Proteção de rotas administrativas.

```dart
class AdminGuard {
  /// Verifica se o usuário é admin
  static Future<bool> isAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final tipoUsuario = userDoc.data()?['tipoUsuario'] ?? '';
    return tipoUsuario == 'admin';
  }

  /// Verifica permissão e redireciona se não autorizado
  static Future<void> checkAdminAccess(BuildContext context) async {...}

  /// Widget que protege rotas
  static Widget protectRoute({
    required Widget child,
    Widget? fallback,
  }) {...}
}
```

---

## 5. Rotas e Navegação (GoRouter)

### 5.1 Configuração

```dart
class AppRoutes {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [...]
  );
}
```

### 5.2 Rotas Principais

#### Autenticação
- `/splash` - SplashScreen
- `/options` - OptionsScreen
- `/login` - LoginScreen
- `/cadastro` - CadastroScreen
- `/esqueci-senha` - EsqueciSenhaScreen

#### Onboarding - Perfil Pai
- `/avatar` - AvatarScreen
- `/apelido` - ApelidoScreen (+ avatar)
- `/criapin` - CriaPinScreen (+ apelido + avatar)

#### Onboarding - Perfil Filho
- `/avatar-filho` - AvatarFilhoScreen
- `/apelido-filho` - ApelidoFilhoScreen (+ avatar)
- `/preferencias-filho` - PreferenciasFilhoScreen (+ apelido + avatar)

#### Gerenciamento de Perfis
- `/gerenciamento-pais` - GerenciamentoPaisScreen
- `/adicionar-perfis` - AdicionarPerfisScreen
- `/mudar-perfil` - MudarPerfilScreen
- `/mudar-avatar` - MudarAvatarScreen
- `/editar-perfil-filho` - EditarPerfilFilhoScreen

#### Configurações
- `/perfil-configs` - PerfilConfigsScreen
- `/perfilpai-configs` - PerfilPaiConfigsScreen
- `/seguranca-config` - SegurancaConfigScreen
- `/tema-config` - TemaConfigScreen

#### Catálogo e Vídeos
- `/catalogo` - CatalogoScreen
- `/videos/:genero` - ListaVideosYoutubeScreen
- `/player` - VideoPlayerYoutubeScreen (recebe VideoModelYoutube)
- `/favoritos` - FavoritosScreen

#### Admin
- `/gerenciamento-admin` - GerenciamentoAdminScreen
- `/admin/gerenciar-videos` - AdminGerenciarVideosScreen
- `/admin/adicionar-video` - AdminAddVideoScreen
- `/admin-videos` - AdminListarVideosScreen

#### Analytics
- `/analytics/:perfilFilhoApelido` - PerfilFilhoAnalyticsScreen

---

## 6. Gerenciamento de Estado

### 6.1 AppTema (Provider)

Gerencia tema claro/escuro com persistência em SharedPreferences e Firestore.

```dart
class AppTema extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;
  String get backgroundImage => _isDarkMode
      ? 'assets/night_background.png'
      : 'assets/morning_background.png';
  Color get textColor => _isDarkMode ? Colors.white : Colors.black;
  Color get textSecondaryColor => _isDarkMode ? Colors.white70 : Colors.black54;
  Color get backgroundColor => _isDarkMode ? Colors.black : Colors.white;
  Color get corSecundaria => _isDarkMode
      ? const Color(0xFF1E88E5)
      : const Color(0xFF1976D2);

  // Carregar do SharedPreferences
  Future<void> loadTheme() async {...}

  // Carregar do Firestore (após login)
  Future<void> loadThemeFromFirestore() async {...}

  // Alternar tema
  Future<void> toggleTheme() async {...}

  // Definir tema específico
  Future<void> setDarkMode(bool value) async {...}

  // Limpar tema
  Future<void> clearTheme() async {...}
}
```

### 6.2 PerfilProvider

Gerencia perfil ativo com SharedPreferences.

```dart
class PerfilProvider extends ChangeNotifier {
  String? _perfilAtivoApelido;
  String? _perfilAtivoAvatar;
  bool _isPerfilPai = true;

  String? get perfilAtivoApelido => _perfilAtivoApelido;
  String? get perfilAtivoAvatar => _perfilAtivoAvatar;
  bool get isPerfilPai => _isPerfilPai;

  // Carregar perfil salvo
  Future<void> loadPerfilAtivo() async {...}

  // Definir perfil ativo
  Future<void> setPerfilAtivo({
    required String apelido,
    required String avatar,
    required bool isPai,
  }) async {...}

  // Limpar perfil (usado no logout)
  Future<void> clearPerfilAtivo() async {...}
}
```

---

## 7. Firebase e Firestore

### 7.1 Inicialização (main.dart)

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const BluFlixApp());
}
```

### 7.2 Estrutura do Firestore

```
firestore/
├── users/
│   └── {userId}/
│       ├── email: string
│       ├── nome: string
│       ├── tipoUsuario: string ("admin" | "usuario")
│       ├── temaDark: boolean
│       ├── pinHash: string (SHA-256)
│       ├── pinCriadoEm: timestamp
│       ├── pinAlteradoEm: timestamp
│       │
│       └── perfis/                    # Subcoleção
│           └── {perfilApelido}/
│               ├── apelido: string
│               ├── avatar: string
│               ├── generosFavoritos: array
│               │
│               ├── analytics/          # Subcoleção
│               │   └── {visualizacaoId}/
│               │       ├── videoId: string
│               │       ├── videoTitulo: string
│               │       ├── genero: string
│               │       ├── inicioVisualizacao: timestamp
│               │       ├── duracaoAssistidaSegundos: number
│               │       └── vezesReassistido: number
│               │
│               └── sessoes/            # Subcoleção
│                   └── {sessaoId}/
│                       ├── inicioSessao: timestamp
│                       ├── fimSessao: timestamp
│                       └── duracaoSegundos: number
│
├── perfis_filhos/
│   └── {perfilId}/
│       ├── userId: string (referência ao pai)
│       ├── apelido: string
│       ├── avatar: string
│       ├── generosFavoritos: array
│       └── criadoEm: timestamp
│
└── videos_youtube/
    └── {videoId}/
        ├── titulo: string
        ├── descricao: string
        ├── youtubeId: string
        ├── youtubeUrl: string
        ├── generos: array
        ├── dataUpload: timestamp
        ├── ativo: boolean
        │
        └── visualizacoes/              # Subcoleção
            └── {visualizacaoId}/
                ├── userId: string
                └── timestamp: timestamp
```

### 7.3 Regras de Segurança (firestore.rules)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Funções auxiliares
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    function isAdmin() {
      return isAuthenticated() 
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
    
    // Usuários
    match /users/{userId} {
      allow read, write: if isAuthenticated() && isOwner(userId);
    }
    
    // Perfis filhos
    match /perfis_filhos/{perfilId} {
      allow read: if isAuthenticated();
      allow create, update, delete: if isAuthenticated() 
        && request.resource.data.userId == request.auth.uid;
    }
    
    // Vídeos (somente admin pode adicionar)
    match /videos/{videoId} {
      allow read: if isAuthenticated();
      allow create, update, delete: if isAdmin();
    }
  }
}
```

---

## 8. Segurança

### 8.1 Hash de PIN (SHA-256)

```dart
import 'dart:convert';
import 'package:crypto/crypto.dart';

String hashPin(String pin) {
  final bytes = utf8.encode(pin);
  final hash = sha256.convert(bytes);
  return hash.toString();
}

// Exemplo:
// Input:  "1234"
// Output: "03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4"
```

### 8.2 Validação de PIN

```dart
bool _validarPin(String pin) {
  // Deve ter exatamente 4 dígitos
  if (pin.length != 4) return false;
  
  // Deve conter apenas números
  if (!RegExp(r'^\d{4}$').hasMatch(pin)) return false;
  
  return true;
}
```

### 8.3 Verificação Admin

```dart
Future<bool> isAdmin() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;

  final userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();

  final tipoUsuario = userDoc.data()?['tipoUsuario'] ?? '';
  return tipoUsuario == 'admin';
}
```

---

## 9. Analytics e Monitoramento

### 9.1 Fluxo de Visualização

```
1. Usuário clica em vídeo
   ↓
2. iniciarVisualizacao()
   - Cria documento em analytics/{id}
   - Registra início
   - Retorna visualizacaoId
   ↓
3. Vídeo é reproduzido
   - YouTube Player
   - Tracking de tempo
   ↓
4. finalizarVisualizacao()
   - Atualiza duracaoAssistidaSegundos
   - Calcula percentualAssistido
   - Marca concluido se ≥90%
```

### 9.2 Métricas Calculadas

#### Tempo Total de Tela
```dart
Future<int> calcularTempoTotalTela(
  String perfilFilhoApelido, {
  int? limiteDias,
}) async {
  final visualizacoes = await buscarVisualizacoesPerfil(...);
  return visualizacoes.fold<int>(
    0,
    (total, v) => total + v.duracaoAssistidaSegundos,
  );
}
```

#### Gêneros Mais Assistidos
```dart
Future<Map<String, int>> calcularGenerosMaisAssistidos(...) async {
  // Retorna: {"Educação": 3600, "Música": 2400, ...}
}
```

#### Taxa de Conclusão
```dart
Future<double> calcularTaxaConclusao(...) async {
  // Retorna percentual médio assistido (0-100)
}
```

#### Frequência por Dia da Semana
```dart
Future<Map<String, int>> calcularFrequenciaPorDia(...) async {
  // Retorna: {"Segunda": 5, "Terça": 3, ...}
}
```

---

## 10. Configuração do Projeto

### 10.1 Configuração Firebase (firebase.json)

```json
{
  "firestore": {
    "rules": "firestore.rules"
  },
  "flutter": {
    "platforms": {
      "android": {
        "default": {
          "projectId": "bluflix-tg",
          "appId": "1:846678971915:android:dd3925f1bb6e571fb4190e",
          "fileOutput": "android/app/google-services.json"
        }
      }
    }
  }
}
```

### 10.2 Ícone do App (pubspec.yaml)

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/logo_1024.png"
  adaptive_icon_background: "#A9DBF4"
  adaptive_icon_foreground: "assets/logo_1024.png"
  remove_alpha_ios: true
  min_sdk_android: 21
  adaptive_icon_foreground_inset: 16
  adaptive_icon_round: "assets/logo_1024.png"
  
  web:
    generate: true
    image_path: "assets/logo_1024.png"
    background_color: "#A9DBF4"
```

### 10.3 Assets

```yaml
assets:
  - assets/logo.png
  - assets/morning_background.png
  - assets/night_background.png
  - assets/google.png
  - assets/facebook.png
  - assets/avatar1.png
  - assets/avatar2.png
  - assets/avatar3.png
  - assets/avatar4.png
  - assets/avatar5.png
  - assets/avatar6.png
  - assets/avatar7.png
  - assets/avatar8.png
```

---

## Apêndices

### A. Exceções Customizadas

```dart
class VideoServiceException implements Exception {
  final String message;
  VideoServiceException(this.message);

  @override
  String toString() => 'VideoServiceException: $message';
}
```

### B. Padrões de Nomenclatura

- **Classes**: PascalCase (ex: `VideoModelYoutube`)
- **Métodos**: camelCase (ex: `buscarTodosVideos`)
- **Variáveis privadas**: _camelCase (ex: `_firestore`)
- **Constantes**: UPPER_SNAKE_CASE ou camelCase

### C. Convenções de Código

- Uso de `final` para variáveis imutáveis
- Comentários com separadores visuais `═══════...`
- Emojis em logs para fácil identificação (✅ ❌ ⚠️ 🔄)
- Try-catch em todas as operações async
- Prints informativos para debug

---

**Última atualização**: Novembro 2024  
**Versão**: 1.0  
**Projeto ID**: bluflix-tg
