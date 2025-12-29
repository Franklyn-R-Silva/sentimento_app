import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sentimento_app/backend/tables/entradas_humor.dart';
import 'package:sentimento_app/core/theme.dart';
import 'package:sentimento_app/core/widgets.dart';
import 'package:sentimento_app/core/model.dart';
import 'home.model.dart';

export 'home.model.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  late HomeModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeModel());
    _loadData();
  }

  Future<void> _loadData() async {
    await _model.loadData();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => _buildAddMoodSheet(context),
            );
          },
          backgroundColor: FlutterFlowTheme.of(context).primary,
          elevation: 8,
          child: Icon(
            Icons.add,
            color: FlutterFlowTheme.of(context).info,
            size: 24,
          ),
        ),
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          title: Text(
            'Dashboard',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
              fontFamily: 'Inter Tight',
              color: Colors.white,
              fontSize: 22,
            ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 2,
        ),
        body: SafeArea(
          top: true,
          child: _model.isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0),
                        child: Text(
                          'Humor Semanal',
                          style: FlutterFlowTheme.of(context).titleMedium,
                        ),
                      ),
                      Container(
                        height: 200,
                        padding: EdgeInsets.all(16),
                        child: _buildWeeklyChart(),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0),
                        child: Text(
                          'Média Anual',
                          style: FlutterFlowTheme.of(context).titleMedium,
                        ),
                      ),
                      Container(
                        height: 200,
                        padding: EdgeInsets.all(16),
                        child: _buildAnnualChart(),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(16, 24, 16, 8),
                        child: Text(
                          'Entradas Recentes',
                          style: FlutterFlowTheme.of(context).titleMedium,
                        ),
                      ),
                      ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _model.recentEntries.length,
                        itemBuilder: (context, index) {
                          final entry = _model.recentEntries[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getColorForMood(entry.nota),
                              radius: 16,
                              child: Text(
                                _getEmojiForMood(entry.nota),
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            title: Text(
                              DateFormat(
                                'dd/MM/yyyy HH:mm',
                              ).format(entry.criadoEm),
                              style: FlutterFlowTheme.of(context).bodyMedium,
                            ),
                            subtitle: Text(
                              entry.notaTexto ?? '',
                              style: FlutterFlowTheme.of(context).bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Text(
                              'Nota: ${entry.nota}',
                              style: FlutterFlowTheme.of(context).bodySmall,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildWeeklyChart() {
    if (_model.weeklyEntries.isEmpty) {
      return Center(child: Text('Sem dados nesta semana'));
    }
    // Simple logic: One point per entry. In real app, might aggregate by day.
    // For now, let's just plot them in order.
    // Better: Aggregate by day of week.

    // Create map of 7 days
    Map<int, List<int>> days = {};
    for (int i = 6; i >= 0; i--) {
      days[DateTime.now().subtract(Duration(days: i)).weekday] = [];
    }

    /*
    for (var entry in _model.weeklyEntries) {
        // days[entry.criadoEm.weekday]?.add(entry.nota);
        // Simplification: Just show raw points for now
    }
    */

    List<FlSpot> spots = [];
    for (int i = 0; i < _model.weeklyEntries.length; i++) {
      spots.add(FlSpot(i.toDouble(), _model.weeklyEntries[i].nota.toDouble()));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minY: 1,
        maxY: 5,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: FlutterFlowTheme.of(context).primary,
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnualChart() {
    if (_model.annualEntries.isEmpty) {
      return Center(child: Text('Sem dados anuais'));
    }
    // Aggregate by month (1-12)
    Map<int, List<int>> months = {};
    for (var entry in _model.annualEntries) {
      final m = entry.criadoEm.month;
      if (!months.containsKey(m)) months[m] = [];
      months[m]!.add(entry.nota);
    }

    List<BarChartGroupData> barGroups = [];
    months.forEach((month, values) {
      double avg = values.fold(0, (a, b) => a + b) / values.length;
      barGroups.add(
        BarChartGroupData(
          x: month,
          barRods: [
            BarChartRodData(
              toY: avg,
              color: FlutterFlowTheme.of(context).secondary,
            ),
          ],
        ),
      );
    });

    // Add missing months as 0? FlChart handles X.

    return BarChart(
      BarChartData(
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(value.toInt().toString());
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
        gridData: FlGridData(show: false),
      ),
    );
  }

  Widget _buildAddMoodSheet(BuildContext context) {
    int selectedEmoji = 3;
    final textController = TextEditingController();

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Como você está se sentindo?',
                style: FlutterFlowTheme.of(context).titleMedium,
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (index) {
                  final score = index + 1;
                  return GestureDetector(
                    onTap: () => setState(() => selectedEmoji = score),
                    child: AnimatedScale(
                      scale: selectedEmoji == score ? 1.2 : 1.0,
                      duration: Duration(milliseconds: 200),
                      child: Text(
                        _getEmojiForMood(score),
                        style: TextStyle(fontSize: 32),
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 24),
              TextFormField(
                controller: textController,
                decoration: InputDecoration(
                  labelText: 'Diário (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 24),
              FFButtonWidget(
                onPressed: () async {
                  await _model.addEntry(
                    context,
                    selectedEmoji,
                    textController.text,
                    [],
                  );
                  Navigator.pop(context);
                  _loadData(); // Refresh UI
                },
                text: 'Salvar',
                options: FFButtonOptions(
                  width: double.infinity,
                  height: 50,
                  color: FlutterFlowTheme.of(context).primary,
                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                    fontFamily: 'Inter Tight',
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  padding: EdgeInsets.zero,
                  iconPadding: EdgeInsets.zero,
                ),
              ),
              SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  String _getEmojiForMood(int mood) {
    switch (mood) {
      case 1:
        return '😢';
      case 2:
        return '😟';
      case 3:
        return '😐';
      case 4:
        return '🙂';
      case 5:
        return '😄';
      default:
        return '😐';
    }
  }

  Color _getColorForMood(int mood) {
    switch (mood) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.amber;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
