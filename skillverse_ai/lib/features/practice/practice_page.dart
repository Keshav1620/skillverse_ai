import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/gradient_button.dart';

class PracticePage extends StatefulWidget {
  const PracticePage({super.key});

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  int _selectedCameraIndex = 0;
  
  // Telemetry Session State
  bool _isPaused = false;
  int _secondsElapsed = 0;
  Timer? _sessionTimer;
  double _caloriesBurned = 0.0;
  int _practiceScore = 0;
  double _professionalSimilarity = 88.4; 

  // Mode toggles
  bool _isGhostModeEnabled = false;
  bool _isReplayModeEnabled = false;
  
  // Real-time Pose State Simulation variables
  double _elbowAngle = 120.0;
  double _backAngle = 165.0;
  String _currentFeedback = 'Raise your elbow.';
  Color _skeletonStateColor = AppColors.primaryPurple; 
  
  late AnimationController _pulseController;
  
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _initializeCamera();
    _startSession();
    _simulateRealtimePoseTelemetry();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _cameraController?.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _cameraController = CameraController(
          _cameras[_selectedCameraIndex],
          ResolutionPreset.medium,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() => _isCameraInitialized = true);
        }
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  Future<void> _toggleCamera() async {
    HapticFeedback.mediumImpact();
    if (_cameras.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No secondary camera detected on this phone.'), duration: Duration(seconds: 2)),
      );
      return;
    }
    
    setState(() {
      _isCameraInitialized = false;
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    });

    if (_cameraController != null) {
      await _cameraController!.dispose();
    }

    _cameraController = CameraController(
      _cameras[_selectedCameraIndex],
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      debugPrint('Error toggling camera: $e');
    }
  }

  void _startSession() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && !_isReplayModeEnabled) {
        setState(() {
          _secondsElapsed++;
          _caloriesBurned += 0.15; 
          _practiceScore += (5 + math.Random().nextInt(5));
          
          if (_secondsElapsed % 8 == 0) {
            _professionalSimilarity = 90.0 + math.Random().nextDouble() * 8.0;
          }
        });
      }
    });
  }

  void _simulateRealtimePoseTelemetry() {
    Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (!mounted || _isPaused || _isReplayModeEnabled) return;
      
      setState(() {
        final ran = math.Random();
        _elbowAngle = 110 + ran.nextDouble() * 60;
        _backAngle = 150 + ran.nextDouble() * 30;

        if (_elbowAngle > 140 && _backAngle > 170) {
          _skeletonStateColor = AppColors.emeraldGreen; 
          _currentFeedback = 'Excellent stance alignment. Keep going.';
        } else if (_elbowAngle > 120) {
          _skeletonStateColor = AppColors.primaryBlue; 
          _currentFeedback = 'Straighten your lower back.';
        } else {
          _skeletonStateColor = AppColors.primaryPurple; 
          _currentFeedback = 'Raise your dominant elbow.';
        }
      });
    });
  }

  void _togglePause() {
    HapticFeedback.selectionClick();
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _finishSession() {
    HapticFeedback.heavyImpact();
    _sessionTimer?.cancel();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryBlue,
                ),
                child: const Icon(Icons.workspace_premium_rounded, color: Colors.black, size: 40),
              ),
              const SizedBox(height: 16),
              const Text('Trial Complete', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Pose telemetry compiled successfully.', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
              const SizedBox(height: 20),
              Divider(color: AppColors.glassBorder),
              const SizedBox(height: 12),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatSummary('Score', '$_practiceScore XP'),
                  _buildStatSummary('Similarity', '${_professionalSimilarity.toStringAsFixed(1)}%'),
                  _buildStatSummary('Calories', '${_caloriesBurned.toInt()} kcal'),
                ],
              ),
              const SizedBox(height: 24),
              GradientButton(
                text: 'Collect Blessings',
                onPressed: () {
                  Navigator.pop(context); 
                  Navigator.pop(context); 
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatSummary(String label, String val) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  String _formatDuration(int secs) {
    final minutes = (secs / 60).floor();
    final remaining = secs % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remaining.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Camera Live Feed or Simulation Placeholder
          Positioned.fill(
            child: _isCameraInitialized && !_isReplayModeEnabled
                ? CameraPreview(_cameraController!)
                : Container(
                    color: Colors.black,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(
                          child: GridPaper(
                            color: AppColors.primaryBlue.withValues(alpha: 0.05),
                            interval: 40,
                            subdivisions: 1,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.video_camera_back_rounded, color: AppColors.primaryBlue.withValues(alpha: 0.2), size: 64),
                            const SizedBox(height: 12),
                            Text(
                              _isReplayModeEnabled ? 'Replay Analytics Mode' : 'Simulating Pose Telemetry Feed',
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),

          // 2. Custom Pose Overlay (MediaPipe joints + Biomechanical Scanning tags)
          Positioned.fill(
            child: CustomPaint(
              painter: PosePainter(
                elbowAngle: _elbowAngle,
                backAngle: _backAngle,
                skeletonColor: _skeletonStateColor,
                isGhostMode: _isGhostModeEnabled,
                isReplayMode: _isReplayModeEnabled,
                pulseProgress: _pulseController.value,
              ),
            ),
          ),

          // 3. Safety Area Overlay HUD
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    ),
                    const Text('Hercules Arena', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    
                    // Switch camera front/back button
                    IconButton(
                      onPressed: _toggleCamera,
                      icon: const Icon(Icons.flip_camera_ios_rounded, color: AppColors.primaryBlue, size: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(child: _buildHudTile(Icons.timer_outlined, _formatDuration(_secondsElapsed), 'Duration')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildHudTile(Icons.local_fire_department_rounded, '${_caloriesBurned.toStringAsFixed(1)} kcal', 'Calories')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildHudTile(Icons.auto_awesome_rounded, '$_practiceScore XP', 'Score')),
                  ],
                ),
              ],
            ),
          ),

          // 4. Floating Voice/Vocal Cue Overlay Alert
          Positioned(
            left: 20,
            right: 20,
            bottom: 160,
            child: GlassContainer(
              borderColor: _skeletonStateColor.withValues(alpha: 0.4),
              backgroundColor: _skeletonStateColor.withValues(alpha: 0.1),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.record_voice_over_rounded, color: _skeletonStateColor, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('HERCULES VOICE TELEMETRY', style: TextStyle(color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(
                          _currentFeedback,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: _skeletonStateColor),
                  ),
                ],
              ),
            ),
          ),

          // 5. Bottom control panel actions
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFeatureButton('Ghost Stance', Icons.copy_rounded, _isGhostModeEnabled, () {
                      HapticFeedback.selectionClick();
                      setState(() => _isGhostModeEnabled = !_isGhostModeEnabled);
                    }),
                    _buildFeatureButton('Replay Heatmap', Icons.history_rounded, _isReplayModeEnabled, () {
                      HapticFeedback.selectionClick();
                      setState(() => _isReplayModeEnabled = !_isReplayModeEnabled);
                    }),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: GradientButton(
                        text: _isPaused ? 'Resume' : 'Pause',
                        icon: _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                        onPressed: _togglePause,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GradientButton(
                        text: 'Finish Stance',
                        icon: Icons.stop_rounded,
                        onPressed: _finishSession,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHudTile(IconData icon, String val, String subtitle) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primaryBlue, size: 14),
              const SizedBox(width: 4),
              Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildFeatureButton(String label, IconData icon, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryBlue.withValues(alpha: 0.15) : AppColors.surface.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: active ? AppColors.primaryBlue : AppColors.glassBorder),
        ),
        child: Row(
          children: [
            Icon(icon, color: active ? AppColors.primaryBlue : Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: active ? AppColors.primaryBlue : Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class PosePainter extends CustomPainter {
  final double elbowAngle;
  final double backAngle;
  final Color skeletonColor;
  final bool isGhostMode;
  final bool isReplayMode;
  final double pulseProgress;

  PosePainter({
    required this.elbowAngle,
    required this.backAngle,
    required this.skeletonColor,
    required this.isGhostMode,
    required this.isReplayMode,
    required this.pulseProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // User joints coordinate coordinates map
    final head = Offset(center.dx, center.dy - 120);
    final shoulderL = Offset(center.dx - 60, center.dy - 70);
    final shoulderR = Offset(center.dx + 60, center.dy - 70);
    
    final elbowRad = (elbowAngle * math.pi) / 180;
    final elbowL = Offset(shoulderL.dx - 50, shoulderL.dy + 40);
    final wristL = Offset(elbowL.dx - 40 * math.sin(elbowRad), elbowL.dy + 50 * math.cos(elbowRad));

    final elbowR = Offset(shoulderR.dx + 50, shoulderR.dy + 40);
    final wristR = Offset(elbowR.dx + 50, elbowR.dy + 40);

    final hipL = Offset(center.dx - 45, center.dy + 70);
    final hipR = Offset(center.dx + 45, center.dy + 70);
    final kneeL = Offset(hipL.dx - 15, hipL.dy + 90);
    final kneeR = Offset(hipR.dx + 15, hipR.dy + 90);
    final footL = Offset(kneeL.dx - 20, kneeL.dy + 80);
    final footR = Offset(kneeR.dx + 20, kneeR.dy + 80);

    // 1. Draw Professional Ghost Pose
    if (isGhostMode) {
      final ghostPaint = Paint()
        ..color = AppColors.primaryBlue.withValues(alpha: 0.25)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      
      final gElbowL = Offset(shoulderL.dx - 60, shoulderL.dy + 60);
      final gWristL = Offset(gElbowL.dx - 60, gElbowL.dy + 20);
      
      canvas.drawLine(head, shoulderL, ghostPaint);
      canvas.drawLine(head, shoulderR, ghostPaint);
      canvas.drawLine(shoulderL, shoulderR, ghostPaint);
      canvas.drawLine(shoulderL, gElbowL, ghostPaint);
      canvas.drawLine(gElbowL, gWristL, ghostPaint);
      canvas.drawLine(shoulderL, hipL, ghostPaint);
      canvas.drawLine(shoulderR, hipR, ghostPaint);
      canvas.drawLine(hipL, kneeL, ghostPaint);
      canvas.drawLine(kneeL, footL, ghostPaint);
      canvas.drawLine(hipR, kneeR, ghostPaint);
      canvas.drawLine(kneeR, footR, ghostPaint);
    }

    // 2. Draw User Skeleton Lines
    final linePaint = Paint()
      ..color = skeletonColor
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    
    canvas.drawLine(head, shoulderL, linePaint);
    canvas.drawLine(head, shoulderR, linePaint);
    canvas.drawLine(shoulderL, shoulderR, linePaint);
    canvas.drawLine(shoulderL, elbowL, linePaint);
    canvas.drawLine(elbowL, wristL, linePaint);
    canvas.drawLine(shoulderR, elbowR, linePaint);
    canvas.drawLine(elbowR, wristR, linePaint);
    canvas.drawLine(shoulderL, hipL, linePaint);
    canvas.drawLine(shoulderR, hipR, linePaint);
    canvas.drawLine(hipL, hipR, linePaint);
    canvas.drawLine(hipL, kneeL, linePaint);
    canvas.drawLine(kneeL, footL, linePaint);
    canvas.drawLine(hipR, kneeR, linePaint);
    canvas.drawLine(kneeR, footR, linePaint);

    // 3. Draw Joint Nodes
    final nodePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final glowPaint = Paint()
      ..color = skeletonColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final joints = [head, shoulderL, shoulderR, elbowL, wristL, elbowR, wristR, hipL, hipR, kneeL, kneeR, footL, footR];
    for (final j in joints) {
      canvas.drawCircle(j, 10 + (pulseProgress * 4), glowPaint);
      canvas.drawCircle(j, 5, nodePaint);
    }

    // 4. Center of Gravity crosshair
    final cog = Offset(center.dx, center.dy + 40);
    final cogPaint = Paint()
      ..color = AppColors.primaryBlue
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(cog, 8, cogPaint);
    canvas.drawCircle(cog, 16 + (pulseProgress * 8), Paint()..color = AppColors.primaryBlue.withValues(alpha: 0.15)..style = PaintingStyle.stroke..strokeWidth = 2);

    // 5. Draw Biomechanical Posture Scan Quality Tags (Good, Bad, Great) next to body parts
    final tp = TextPainter(textDirection: TextDirection.ltr);

    void drawScanTag(String text, Color color, Offset offset) {
      tp.text = TextSpan(
        text: text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10, background: Paint()..color = Colors.black..style = PaintingStyle.fill),
      );
      tp.layout();
      tp.paint(canvas, offset);
    }

    // Biomechanical scan indicators for joints
    drawScanTag('Great [Head Sync]', AppColors.cyanGlow, Offset(head.dx + 12, head.dy - 6));
    drawScanTag('Good [Shoulders L/R]', AppColors.cyanGlow, Offset(shoulderL.dx - 45, shoulderL.dy - 18));
    
    // Left elbow condition based on angle
    final elbowStatus = elbowAngle > 140 ? 'Great' : (elbowAngle > 120 ? 'Good' : 'Bad (Flex Elbow)');
    final elbowColor = elbowAngle > 140 ? AppColors.emeraldGreen : (elbowAngle > 120 ? AppColors.primaryBlue : AppColors.primaryPurple);
    drawScanTag('$elbowStatus [L-Elbow: ${elbowAngle.toInt()}°]', elbowColor, Offset(elbowL.dx - 60, elbowL.dy - 16));

    // Core alignment
    final backStatus = backAngle > 170 ? 'Great' : 'Bad (Leaning)';
    final backColor = backAngle > 170 ? AppColors.emeraldGreen : AppColors.primaryPurple;
    drawScanTag('$backStatus [Spine: ${backAngle.toInt()}°]', backColor, Offset(cog.dx + 16, cog.dy - 6));

    // Lower limbs
    drawScanTag('Great [Knees Balanced]', AppColors.emeraldGreen, Offset(kneeR.dx + 12, kneeR.dy - 6));
    drawScanTag('Good [Footing]', AppColors.cyanGlow, Offset(footL.dx - 12, footL.dy + 12));

    // 6. Draw Heatmap (Only when Replay Heatmap is enabled)
    if (isReplayMode) {
      final heatmapPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.red.withValues(alpha: 0.6),
            Colors.orange.withValues(alpha: 0.3),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: elbowL, radius: 45))
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(elbowL, 45, heatmapPaint);
      canvas.drawCircle(kneeR, 40, heatmapPaint);
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.elbowAngle != elbowAngle ||
        oldDelegate.backAngle != backAngle ||
        oldDelegate.skeletonColor != skeletonColor ||
        oldDelegate.isGhostMode != isGhostMode ||
        oldDelegate.isReplayMode != isReplayMode ||
        oldDelegate.pulseProgress != pulseProgress;
  }
}
