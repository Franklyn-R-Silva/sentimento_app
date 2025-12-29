// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:sentimento_app/core/theme.dart';

/// Callback para carregar mais dados
typedef LoadMoreCallback<T> = Future<List<T>> Function(int pageKey);

/// Callback para construir um item da lista
typedef ItemBuilder<T> =
    Widget Function(BuildContext context, T item, int index);

/// Opções de configuração do FlutterFlowInfiniteScrollPagination
class FFInfiniteScrollOptions {
  const FFInfiniteScrollOptions({
    this.pageSize = 20,
    this.firstPageKey = 0,
    this.enablePullToRefresh = true,
    this.scrollDirection = Axis.vertical,
    this.padding,
    this.separatorBuilder,
    this.loadingIndicator,
    this.errorIndicator,
    this.noItemsFoundIndicator,
    this.noMoreItemsIndicator,
    this.physics,
    this.shrinkWrap = false,
    this.primary,
    this.reverse = false,
    this.cacheExtent,
    this.semanticChildCount,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
  });

  /// Número de itens por página
  final int pageSize;

  /// Chave da primeira página (geralmente 0 ou 1)
  final int firstPageKey;

  /// Habilita pull-to-refresh
  final bool enablePullToRefresh;

  /// Direção do scroll
  final Axis scrollDirection;

  /// Padding da lista
  final EdgeInsetsGeometry? padding;

  /// Construtor do separador entre itens
  final Widget Function(BuildContext, int)? separatorBuilder;

  /// Indicador de carregamento customizado
  final Widget? loadingIndicator;

  /// Indicador de erro customizado
  final Widget? errorIndicator;

  /// Indicador quando não há itens
  final Widget? noItemsFoundIndicator;

  /// Indicador quando não há mais itens
  final Widget? noMoreItemsIndicator;

  /// Physics do scroll
  final ScrollPhysics? physics;

  /// Se a lista deve encolher para o conteúdo
  final bool shrinkWrap;

  /// Se é o scroll primário
  final bool? primary;

  /// Se a lista está invertida
  final bool reverse;

  /// Cache extent
  final double? cacheExtent;

  /// Contagem semântica de filhos
  final int? semanticChildCount;

  /// Comportamento de dismiss do teclado
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// ID de restauração
  final String? restorationId;

  /// Comportamento de clipping
  final Clip clipBehavior;
}

/// Controller para gerenciar o estado da paginação infinita
class FFInfiniteScrollController<T> extends ChangeNotifier {
  FFInfiniteScrollController({
    required this.pageSize,
    required this.firstPageKey,
    this.initialItems,
  }) : _currentPageKey = firstPageKey {
    if (initialItems != null) {
      _items.addAll(initialItems!);
      _state = FFInfiniteScrollState.loaded;
    }
  }

  final int pageSize;
  final int firstPageKey;
  final List<T>? initialItems;

  final List<T> _items = [];
  FFInfiniteScrollState _state = FFInfiniteScrollState.loading;
  String? _error;
  int _currentPageKey;
  bool _hasMoreItems = true;

  List<T> get items => List.unmodifiable(_items);
  FFInfiniteScrollState get state => _state;
  String? get error => _error;
  bool get hasMoreItems => _hasMoreItems;
  int get currentPageKey => _currentPageKey;
  int get itemCount => _items.length;

  void _setState(final FFInfiniteScrollState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  void _setError(final String? error) {
    _error = error;
    _setState(FFInfiniteScrollState.error);
  }

  /// Adiciona itens à lista
  void appendItems(final List<T> newItems) {
    _items.addAll(newItems);

    if (newItems.length < pageSize) {
      _hasMoreItems = false;
      _setState(FFInfiniteScrollState.noMoreItems);
    } else {
      _currentPageKey++;
      _setState(FFInfiniteScrollState.loaded);
    }
  }

  /// Carrega a próxima página
  Future<void> loadNextPage(final LoadMoreCallback<T> loadMore) async {
    if (_state == FFInfiniteScrollState.loading || !_hasMoreItems) return;

    _setState(FFInfiniteScrollState.loading);

    try {
      final newItems = await loadMore(_currentPageKey);
      appendItems(newItems);
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Recarrega a lista do início
  Future<void> refresh(final LoadMoreCallback<T> loadMore) async {
    _items.clear();
    _currentPageKey = firstPageKey;
    _hasMoreItems = true;
    _error = null;
    _setState(FFInfiniteScrollState.loading);

    try {
      final newItems = await loadMore(_currentPageKey);
      appendItems(newItems);
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Retenta carregar após erro
  Future<void> retry(final LoadMoreCallback<T> loadMore) async {
    if (_state != FFInfiniteScrollState.error) return;

    _error = null;
    await loadNextPage(loadMore);
  }
}

/// Estados possíveis da paginação infinita
enum FFInfiniteScrollState { loading, loaded, error, noMoreItems }

/// Widget principal de paginação infinita
class FlutterFlowInfiniteScrollPagination<T> extends StatefulWidget {
  const FlutterFlowInfiniteScrollPagination({
    required this.loadMore,
    required this.itemBuilder,
    required this.options,
    super.key,
    this.controller,
    this.onRefresh,
    this.onError,
    this.scrollController,
  });

  /// Callback para carregar mais dados
  final LoadMoreCallback<T> loadMore;

  /// Construtor de itens
  final ItemBuilder<T> itemBuilder;

  /// Opções de configuração
  final FFInfiniteScrollOptions options;

  /// Controller opcional (se não fornecido, será criado internamente)
  final FFInfiniteScrollController<T>? controller;

  /// Callback opcional para refresh
  final VoidCallback? onRefresh;

  /// Callback opcional para erros
  final void Function(String error)? onError;

  /// Controller de scroll opcional
  final ScrollController? scrollController;

  @override
  State<FlutterFlowInfiniteScrollPagination<T>> createState() =>
      _FlutterFlowInfiniteScrollPaginationState<T>();
}

class _FlutterFlowInfiniteScrollPaginationState<T>
    extends State<FlutterFlowInfiniteScrollPagination<T>> {
  late FFInfiniteScrollController<T> _controller;
  late ScrollController _scrollController;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();

    _controller =
        widget.controller ??
        FFInfiniteScrollController<T>(
          pageSize: widget.options.pageSize,
          firstPageKey: widget.options.firstPageKey,
        );

    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);

    _controller.addListener(_onControllerChange);

    // Carrega a primeira página se não há itens
    if (_controller.items.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((final _) {
        _controller.loadNextPage(widget.loadMore);
      });
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onControllerChange() {
    if (_controller.state == FFInfiniteScrollState.error &&
        widget.onError != null) {
      widget.onError!(_controller.error ?? 'Erro desconhecido');
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _controller.hasMoreItems &&
        _controller.state != FFInfiniteScrollState.loading) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      await _controller.loadNextPage(widget.loadMore);
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _onRefresh() async {
    await HapticFeedback.mediumImpact();
    widget.onRefresh?.call();
    await _controller.refresh(widget.loadMore);
  }

  Widget _buildLoadingIndicator() {
    return SingleChildScrollView(
      physics:
          const NeverScrollableScrollPhysics(), // Geralmente loading não precisa de scroll mas evita o erro
      child:
          widget.options.loadingIndicator ??
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  FlutterFlowTheme.of(context).primary,
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildErrorIndicator() {
    return widget.options.errorIndicator ??
        LayoutBuilder(
          builder: (final context, final constraints) {
            final minHeight = constraints.hasBoundedHeight
                ? constraints.maxHeight
                : 0.0;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: minHeight),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: FlutterFlowTheme.of(context).error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Erro ao carregar dados',
                        style: FlutterFlowTheme.of(context).bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      if (_controller.error != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _controller.error!,
                          style: FlutterFlowTheme.of(context).bodySmall
                              .copyWith(
                                color: FlutterFlowTheme.of(
                                  context,
                                ).secondaryText,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _controller.retry(widget.loadMore),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FlutterFlowTheme.of(context).primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
  }

  Widget _buildNoItemsIndicator() {
    return SingleChildScrollView(
      child:
          widget.options.noItemsFoundIndicator ??
          LayoutBuilder(
            builder: (final context, final constraints) {
              final minHeight = constraints.hasBoundedHeight
                  ? constraints.maxHeight
                  : 0.0;

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: minHeight),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 48,
                          color: FlutterFlowTheme.of(context).secondaryText,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum item encontrado',
                          style: FlutterFlowTheme.of(context).bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
    );
  }

  Widget _buildNoMoreItemsIndicator() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child:
          widget.options.noMoreItemsIndicator ??
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Não há mais itens',
                style: FlutterFlowTheme.of(context).bodySmall.copyWith(
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
    );
  }

  Widget _buildList() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (final context, final child) {
        final items = _controller.items;
        final state = _controller.state;

        // Lista inicial vazia ou carregando
        if (items.isEmpty) {
          if (state == FFInfiniteScrollState.loading) {
            return _buildLoadingIndicator();
          } else if (state == FFInfiniteScrollState.error) {
            return _buildErrorIndicator();
          } else {
            return _buildNoItemsIndicator();
          }
        }

        // Lista com itens
        return ListView.separated(
          controller: _scrollController,
          scrollDirection: widget.options.scrollDirection,
          padding:
              widget.options.padding ?? const EdgeInsets.symmetric(vertical: 8),
          physics: widget.options.enablePullToRefresh
              ? const AlwaysScrollableScrollPhysics()
              : widget.options.physics,
          shrinkWrap: widget.options.shrinkWrap,
          primary: widget.options.primary,
          reverse: widget.options.reverse,
          cacheExtent: widget.options.cacheExtent,
          keyboardDismissBehavior: widget.options.keyboardDismissBehavior,
          restorationId: widget.options.restorationId,
          clipBehavior: widget.options.clipBehavior,
          itemCount: items.length + 1, // +1 para o indicador no final
          separatorBuilder: (final context, final index) {
            if (index >= items.length) return const SizedBox.shrink();
            return widget.options.separatorBuilder?.call(context, index) ??
                const SizedBox.shrink();
          },
          itemBuilder: (final context, final index) {
            // Item normal da lista
            if (index < items.length) {
              return widget.itemBuilder(context, items[index], index);
            }

            // Indicador no final da lista
            if (state == FFInfiniteScrollState.loading && _isLoadingMore) {
              return _buildLoadingIndicator();
            } else if (state == FFInfiniteScrollState.error) {
              return _buildErrorIndicator();
            } else if (state == FFInfiniteScrollState.noMoreItems) {
              return _buildNoMoreItemsIndicator();
            }

            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  @override
  Widget build(final BuildContext context) {
    if (widget.options.enablePullToRefresh) {
      return RefreshIndicator(
        onRefresh: _onRefresh,
        color: FlutterFlowTheme.of(context).primary,
        child: _buildList(),
      );
    }

    return _buildList();
  }
}

/// Extensão para facilitar o acesso ao tema
extension FlutterFlowInfiniteScrollTheme on BuildContext {
  FlutterFlowTheme get theme => FlutterFlowTheme.of(this);
}
