import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  String _userName = "";
  String _userAvatar = "";
  bool _isLoading = true;
  bool _isDarkMode = false; // ✅ Controla o tema

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
  }

  Future<void> _carregarDadosUsuario() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _userName = userDoc.data()?['apelido'] ?? 'Usuário';
            _userAvatar = userDoc.data()?['avatar'] ?? 'assets/avatar1.png';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Erro ao carregar dados do usuário: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fazerLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.white,
        title: Text(
          'Sair',
          style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
        ),
        content: Text(
          'Deseja realmente sair da sua conta?',
          style: TextStyle(
            color: _isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: _isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sair', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) context.go('/options');
    }
  }

  // ✅ Função para alternar o tema
  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  // ✅ Função para obter as cores do tema atual
  Color get _backgroundColor => _isDarkMode ? Colors.black : Colors.white;
  Color get _textColor => _isDarkMode ? Colors.white : Colors.black;
  Color get _textSecondaryColor =>
      _isDarkMode ? Colors.white70 : Colors.black54;
  String get _backgroundImage => _isDarkMode
      ? 'assets/night_background.png'
      : 'assets/morning_background.png';

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: _backgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: const Color(0xFFA9DBF4)),
        ),
      );
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(_backgroundImage), // ✅ Background dinâmico
            fit: BoxFit.cover,
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // ✅ App Bar com logo, botão de tema e avatar
            SliverAppBar(
              floating: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Row(
                children: [Image.asset("assets/logo.png", height: 40)],
              ),
              centerTitle: false,
              actions: [
                // ✅ Botão de Tema (Sol/Lua)
                IconButton(
                  onPressed: _toggleTheme,
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return RotationTransition(
                        turns: animation,
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: Icon(
                      _isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
                      key: ValueKey(_isDarkMode),
                      color: _isDarkMode ? Colors.amber : Colors.orange,
                      size: 28,
                    ),
                  ),
                  tooltip: _isDarkMode ? 'Modo Claro' : 'Modo Escuro',
                ),
                const SizedBox(width: 8),

                // Avatar do usuário
                GestureDetector(
                  onTap: _fazerLogout,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage(_userAvatar),
                    ),
                  ),
                ),
              ],
            ),

            // Conteúdo principal
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mensagem de boas-vindas
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Olá, $_userName!',
                      style: TextStyle(
                        color: _textColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Filme em Destaque
                  _buildFilmeDestaque(),

                  const SizedBox(height: 24),

                  // Seção: Populares
                  _buildSecaoFilmes('Populares no Bluflix', _filmesPopulares),

                  const SizedBox(height: 24),

                  // Seção: Ação
                  _buildSecaoFilmes('Filmes de Ação', _filmesAcao),

                  const SizedBox(height: 24),

                  // Seção: Comédia
                  _buildSecaoFilmes('Comédias', _filmesComedia),

                  const SizedBox(height: 24),

                  // Seção: Drama
                  _buildSecaoFilmes('Dramas', _filmesDrama),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget do filme em destaque (banner grande)
  Widget _buildFilmeDestaque() {
    final filme = _filmesPopulares[0];
    return Container(
      height: 400,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(filme['capa']!),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.7),
              Colors.black,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                filme['titulo']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                filme['descricao']!,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // Ação de assistir
                    },
                    icon: const Icon(Icons.play_arrow, color: Colors.black),
                    label: const Text(
                      'Assistir',
                      style: TextStyle(color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      _mostrarDetalhesFilme(filme);
                    },
                    icon: const Icon(Icons.info_outline, color: Colors.white),
                    label: const Text(
                      'Mais Info',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para seção de filmes (lista horizontal)
  Widget _buildSecaoFilmes(String titulo, List<Map<String, String>> filmes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            titulo,
            style: TextStyle(
              color: _textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: filmes.length,
            itemBuilder: (context, index) {
              return _buildCardFilme(filmes[index]);
            },
          ),
        ),
      ],
    );
  }

  // Widget de card individual do filme
  Widget _buildCardFilme(Map<String, String> filme) {
    return GestureDetector(
      onTap: () {
        _mostrarDetalhesFilme(filme);
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Capa do filme
            Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(filme['capa']!),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mostrar detalhes do filme em um modal
  void _mostrarDetalhesFilme(Map<String, String> filme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.grey[100],
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Indicador de arrastar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Imagem do filme
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        filme['capa']!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Título
                    Text(
                      filme['titulo']!,
                      style: TextStyle(
                        color: _textColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Ano e Duração
                    Row(
                      children: [
                        Text(
                          filme['ano']!,
                          style: TextStyle(
                            color: _textSecondaryColor,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          filme['duracao']!,
                          style: TextStyle(
                            color: _textSecondaryColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Descrição
                    Text(
                      filme['descricao']!,
                      style: TextStyle(
                        color: _textSecondaryColor,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Botões de ação
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.play_arrow,
                              color: Colors.black,
                            ),
                            label: const Text(
                              'Assistir',
                              style: TextStyle(color: Colors.black),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: () {
                            // Adicionar à lista
                          },
                          icon: Icon(Icons.add, color: _textColor),
                          style: IconButton.styleFrom(
                            backgroundColor: _isDarkMode
                                ? Colors.grey[800]
                                : Colors.grey[300],
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Dados mock dos filmes
  final List<Map<String, String>> _filmesPopulares = [
    {
      'titulo': 'Avatar: O Caminho da Água',
      'capa': 'https://image.tmdb.org/t/p/w500/t6HIqrRAclMCA60NsSmeqe9RmNV.jpg',
      'descricao':
          'Jake Sully e Ney\'tiri formaram uma família e estão fazendo de tudo para ficarem juntos.',
      'ano': '2022',
      'duracao': '3h 12min',
    },
    {
      'titulo': 'Pantera Negra: Wakanda Para Sempre',
      'capa': 'https://image.tmdb.org/t/p/w500/sv1xJUazXeYqALyczSZ3O6nkH75.jpg',
      'descricao':
          'A rainha Ramonda, Shuri, M\'Baku, Okoye e as Dora Milaje lutam para proteger sua nação.',
      'ano': '2022',
      'duracao': '2h 41min',
    },
    {
      'titulo': 'Top Gun: Maverick',
      'capa': 'https://image.tmdb.org/t/p/w500/62HCnUTziyWcpDaBO2i1DX17ljH.jpg',
      'descricao':
          'Depois de mais de 30 anos de serviço, Pete "Maverick" Mitchell continua sendo um dos melhores pilotos da Marinha.',
      'ano': '2022',
      'duracao': '2h 11min',
    },
    {
      'titulo': 'Homem-Aranha: Sem Volta Para Casa',
      'capa': 'https://image.tmdb.org/t/p/w500/fVzXp3NwovUxEwnQ3xPGZdDaRQU.jpg',
      'descricao':
          'Peter Parker tem sua identidade secreta revelada e pede ajuda ao Doutor Estranho.',
      'ano': '2021',
      'duracao': '2h 28min',
    },
    {
      'titulo': 'Doutor Estranho no Multiverso da Loucura',
      'capa': 'https://image.tmdb.org/t/p/w500/9Gtg2DzBhmYamXBS1hKAhiwbBKS.jpg',
      'descricao':
          'O Doutor Estranho enfrenta uma ameaça misteriosa relacionada ao Multiverso.',
      'ano': '2022',
      'duracao': '2h 6min',
    },
  ];

  final List<Map<String, String>> _filmesAcao = [
    {
      'titulo': 'Velozes e Furiosos 10',
      'capa': 'https://image.tmdb.org/t/p/w500/fiVW06jE7z9YnO4trhaMEdclSiC.jpg',
      'descricao':
          'Dom Toretto e sua família enfrentam o adversário mais letal.',
      'ano': '2023',
      'duracao': '2h 21min',
    },
    {
      'titulo': 'John Wick 4: Baba Yaga',
      'capa': 'https://image.tmdb.org/t/p/w500/vZloFAK7NmvMGKE7VkF5UHaz0I.jpg',
      'descricao': 'John Wick descobre um caminho para derrotar a Alta Cúpula.',
      'ano': '2023',
      'duracao': '2h 49min',
    },
    {
      'titulo': 'Missão: Impossível - Acerto de Contas',
      'capa': 'https://image.tmdb.org/t/p/w500/NNxYkU70HPurnNCSiCjYAmacwm.jpg',
      'descricao':
          'Ethan Hunt e sua equipe embarcam em sua missão mais perigosa.',
      'ano': '2023',
      'duracao': '2h 43min',
    },
    {
      'titulo': 'Bullet Train',
      'capa': 'https://image.tmdb.org/t/p/w500/j8szC8OgrejDQjjMKSVXyaAjw3V.jpg',
      'descricao':
          'Cinco assassinos se encontram em um trem-bala que vai de Tóquio a Morioka.',
      'ano': '2022',
      'duracao': '2h 7min',
    },
    {
      'titulo': 'Ambulância',
      'capa': 'https://image.tmdb.org/t/p/w500/lRTRMuvZPHNeALmjdN3VWIi2sn4.jpg',
      'descricao':
          'Dois irmãos roubam uma ambulância após um assalto dar errado.',
      'ano': '2022',
      'duracao': '2h 16min',
    },
  ];

  final List<Map<String, String>> _filmesComedia = [
    {
      'titulo': 'Barbie',
      'capa': 'https://image.tmdb.org/t/p/w500/iuFNMS8U5cb6xfzi51Dbkovj7vM.jpg',
      'descricao':
          'Barbie e Ken vivem felizes na colorida Barbieland, mas descobrem o mundo real.',
      'ano': '2023',
      'duracao': '1h 54min',
    },
    {
      'titulo': 'Guardiões da Galáxia Vol. 3',
      'capa': 'https://image.tmdb.org/t/p/w500/r2J02Z2OpNTctfOSN1Ydgii51I3.jpg',
      'descricao':
          'A equipe dos Guardiões embarca em uma missão para proteger um dos seus.',
      'ano': '2023',
      'duracao': '2h 30min',
    },
    {
      'titulo': 'As Branquelas',
      'capa': 'https://image.tmdb.org/t/p/w500/iPEe7b86bKZfLDcVBrhwdINxWxI.jpg',
      'descricao':
          'Dois agentes do FBI se disfarçam de jovens brancas para solucionar um caso.',
      'ano': '2004',
      'duracao': '1h 49min',
    },
    {
      'titulo': 'Deadpool',
      'capa': 'https://image.tmdb.org/t/p/w500/yGSxMiF0cYuAiyuve5DA6bnWEOI.jpg',
      'descricao':
          'Wade Wilson é um mercenário que se torna o anti-herói Deadpool.',
      'ano': '2016',
      'duracao': '1h 48min',
    },
    {
      'titulo': 'Se Beber, Não Case!',
      'capa': 'https://image.tmdb.org/t/p/w500/uRqj4J6HBlvYLDFb3Yrpn8qzZbC.jpg',
      'descricao':
          'Quatro amigos vão para Las Vegas e não lembram de nada do que aconteceu.',
      'ano': '2009',
      'duracao': '1h 40min',
    },
  ];

  final List<Map<String, String>> _filmesDrama = [
    {
      'titulo': 'Oppenheimer',
      'capa': 'https://image.tmdb.org/t/p/w500/8Gxv8gSFCU0XGDykEGv7zR1n2ua.jpg',
      'descricao':
          'A história de J. Robert Oppenheimer e seu papel no desenvolvimento da bomba atômica.',
      'ano': '2023',
      'duracao': '3h 0min',
    },
    {
      'titulo': 'Coringa',
      'capa': 'https://image.tmdb.org/t/p/w500/udDclJoHjfjb8Ekgsd4FDteOkCU.jpg',
      'descricao':
          'Arthur Fleck trabalha como palhaço para uma agência de talentos.',
      'ano': '2019',
      'duracao': '2h 2min',
    },
    {
      'titulo': 'Interestelar',
      'capa': 'https://image.tmdb.org/t/p/w500/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
      'descricao':
          'Exploradores viajam através de um buraco de minhoca para garantir a sobrevivência da humanidade.',
      'ano': '2014',
      'duracao': '2h 49min',
    },
    {
      'titulo': 'Parasita',
      'capa': 'https://image.tmdb.org/t/p/w500/7IiTTgloJzvGI1TAYymCfbfl3vT.jpg',
      'descricao': 'Uma família pobre se infiltra na casa de uma família rica.',
      'ano': '2019',
      'duracao': '2h 12min',
    },
    {
      'titulo': '1917',
      'capa': 'https://image.tmdb.org/t/p/w500/iZf0KyrE25z1sage4SYFLCCrMi9.jpg',
      'descricao':
          'Dois soldados britânicos recebem uma missão aparentemente impossível durante a Primeira Guerra Mundial.',
      'ano': '2019',
      'duracao': '1h 59min',
    },
  ];
}
