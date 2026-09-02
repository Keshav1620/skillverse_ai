import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/skill_biomechanics.dart';
import '../services/biomechanics_engine.dart';

class ARBiomechanicsPainter extends CustomPainter {
  final HumanTrackingPayload payload;
  final BiomechanicsEvaluationFrame evaluation;
  final SkillMovementPhase currentPhase;
  final bool isGhostModeEnabled;
  final bool isReplayModeEnabled;
  final double pulseProgress;

  ARBiomechanicsPainter({
    required this.payload,
    required this.evaluation,
    required this.currentPhase,
    required this.isGhostModeEnabled,
    required this.isReplayModeEnabled,
    required this.pulseProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!payload.humanDetected || payload.joints.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final scaleX = size.width * 0.45;
    final scaleY = size.height * 0.45;

    Offset map3D(Joint3DPoint p) {
      return Offset(center.dx + (p.x * scaleX), center.dy - (p.y * scaleY));
    }

    final joints = payload.joints;
    final head = map3D(joints['head'] ?? const Joint3DPoint(x: 0, y: 0.85, z: 0));
    final neck = map3D(joints['neck'] ?? const Joint3DPoint(x: 0, y: 0.70, z: 0));
    final lShoulder = map3D(joints['leftShoulder'] ?? const Joint3DPoint(x: -0.25, y: 0.50, z: 0));
    final rShoulder = map3D(joints['rightShoulder'] ?? const Joint3DPoint(x: 0.25, y: 0.50, z: 0));
    final lElbow = map3D(joints['leftElbow'] ?? const Joint3DPoint(x: -0.38, y: 0.15, z: 0.05));
    final lWrist = map3D(joints['leftWrist'] ?? const Joint3DPoint(x: -0.42, y: 0.45, z: 0.10));
    final rElbow = map3D(joints['rightElbow'] ?? const Joint3DPoint(x: 0.38, y: 0.15, z: 0.05));
    final rWrist = map3D(joints['rightWrist'] ?? const Joint3DPoint(x: 0.42, y: 0.45, z: 0.10));
    final spine = map3D(joints['spine'] ?? const Joint3DPoint(x: 0, y: 0.20, z: 0));
    final lHip = map3D(joints['leftHip'] ?? const Joint3DPoint(x: -0.15, y: -0.10, z: 0));
    final rHip = map3D(joints['rightHip'] ?? const Joint3DPoint(x: 0.15, y: -0.10, z: 0));
    final lKnee = map3D(joints['leftKnee'] ?? const Joint3DPoint(x: -0.18, y: -0.45, z: -0.05));
    final rKnee = map3D(joints['rightKnee'] ?? const Joint3DPoint(x: 0.18, y: -0.45, z: -0.05));
    final lAnkle = map3D(joints['leftAnkle'] ?? const Joint3DPoint(x: -0.20, y: -0.80, z: 0));
    final rAnkle = map3D(joints['rightAnkle'] ?? const Joint3DPoint(x: 0.20, y: -0.80, z: 0));

    // 1. Cyan Bone Paint (Matching user image: vibrant Cyan #00E5FF, 6px width)
    final cyanBonePaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final redNodePaint = Paint()
      ..color = const Color(0xFFFF2A2A)
      ..style = PaintingStyle.fill;

    // 2. Draw Body Skeleton Bones
    canvas.drawLine(head, neck, cyanBonePaint);
    canvas.drawLine(neck, spine, cyanBonePaint);
    canvas.drawLine(neck, lShoulder, cyanBonePaint);
    canvas.drawLine(neck, rShoulder, cyanBonePaint);

    canvas.drawLine(lShoulder, lElbow, cyanBonePaint);
    canvas.drawLine(lElbow, lWrist, cyanBonePaint);
    canvas.drawLine(rShoulder, rElbow, cyanBonePaint);
    canvas.drawLine(rElbow, rWrist, cyanBonePaint);

    canvas.drawLine(spine, lHip, cyanBonePaint);
    canvas.drawLine(spine, rHip, cyanBonePaint);
    canvas.drawLine(lHip, rHip, cyanBonePaint);

    canvas.drawLine(lHip, lKnee, cyanBonePaint);
    canvas.drawLine(lKnee, lAnkle, cyanBonePaint);
    canvas.drawLine(rHip, rKnee, cyanBonePaint);
    canvas.drawLine(rKnee, rAnkle, cyanBonePaint);

    // 3. Draw 21-Node Hand Finger Skeleton (Left Hand & Right Hand)
    void drawHandMesh(Offset wrist, String prefix) {
      final tMcp = map3D(joints['${prefix}_thumb_mcp'] ?? const Joint3DPoint(x: 0, y: 0, z: 0));
      final tTip = map3D(joints['${prefix}_thumb_tip'] ?? const Joint3DPoint(x: 0, y: 0, z: 0));
      final iMcp = map3D(joints['${prefix}_index_mcp'] ?? const Joint3DPoint(x: 0, y: 0, z: 0));
      final iPip = map3D(joints['${prefix}_index_pip'] ?? const Joint3DPoint(x: 0, y: 0, z: 0));
      final iTip = map3D(joints['${prefix}_index_tip'] ?? const Joint3DPoint(x: 0, y: 0, z: 0));
      final mMcp = map3D(joints['${prefix}_middle_mcp'] ?? const Joint3DPoint(x: 0, y: 0, z: 0));
      final mPip = map3D(joints['${prefix}_middle_pip'] ?? const Joint3DPoint(x: 0, y: 0, z: 0));
      final mTip = map3D(joints['${prefix}_middle_tip'] ?? const Joint3DPoint(x: 0, y: 0, z: 0));
      final rMcp = map3D(joints['${prefix}_ring_mcp'] ?? const Joint3DPoint(x: 0, y: 0, z: 0));
      final rPip = map3D(joints['${prefix}_ring_pip'] ?? const Joint3DPoint(x: 0, y: 0, z: 0));
      final rTip = map3D(joints['${prefix}_ring_tip'] ?? const Joint3DPoint(x: 0, y: 0, z: 0));
      final pMcp = map3D(joints['${prefix}_pinky_mcp'] ?? const Joint3DPoint(x: 0, y: 0, z: 0));
      final pTip = map3D(joints['${prefix}_pinky_tip'] ?? const Joint3DPoint(x: 0, y: 0, z: 0));

      final fingerBonePaint = Paint()
        ..color = const Color(0xFF00E5FF)
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke;

      // Finger rays
      canvas.drawLine(wrist, tMcp, fingerBonePaint);
      canvas.drawLine(tMcp, tTip, fingerBonePaint);

      canvas.drawLine(wrist, iMcp, fingerBonePaint);
      canvas.drawLine(iMcp, iPip, fingerBonePaint);
      canvas.drawLine(iPip, iTip, fingerBonePaint);

      canvas.drawLine(wrist, mMcp, fingerBonePaint);
      canvas.drawLine(mMcp, mPip, fingerBonePaint);
      canvas.drawLine(mPip, mTip, fingerBonePaint);

      canvas.drawLine(wrist, rMcp, fingerBonePaint);
      canvas.drawLine(rMcp, rPip, fingerBonePaint);
      canvas.drawLine(rPip, rTip, fingerBonePaint);

      canvas.drawLine(wrist, pMcp, fingerBonePaint);
      canvas.drawLine(pMcp, pTip, fingerBonePaint);

      // Red finger joint spheres
      final fingerNodes = [tMcp, tTip, iMcp, iPip, iTip, mMcp, mPip, mTip, rMcp, rPip, rTip, pMcp, pTip];
      for (final fn in fingerNodes) {
        canvas.drawCircle(fn, 7, redNodePaint);
        canvas.drawCircle(fn, 8.5, Paint()..color = Colors.redAccent.withValues(alpha: 0.4)..style = PaintingStyle.stroke..strokeWidth = 1.5);
      }
    }

    drawHandMesh(lWrist, 'l');
    drawHandMesh(rWrist, 'r');

    // 4. Draw Face Mesh & Eye Sync Keypoints
    final eyeL = map3D(joints['face_eye_l'] ?? const Joint3DPoint(x: -0.06, y: 0.88, z: 0.05));
    final eyeR = map3D(joints['face_eye_r'] ?? const Joint3DPoint(x: 0.06, y: 0.88, z: 0.05));
    final nose = map3D(joints['face_nose'] ?? const Joint3DPoint(x: 0, y: 0.84, z: 0.08));
    final mouth = map3D(joints['face_mouth'] ?? const Joint3DPoint(x: 0, y: 0.78, z: 0.05));

    // Face Mask Circle (Matching grey head mask from reference photo)
    canvas.drawCircle(head, 36, Paint()..color = const Color(0xFFD6D6E0).withValues(alpha: 0.85)..style = PaintingStyle.fill);

    // Eye Sync Diamonds (Blue & Pink)
    final blueEyePaint = Paint()..color = const Color(0xFF0038FF)..style = PaintingStyle.fill;
    final pinkEyePaint = Paint()..color = const Color(0xFFFF00C7)..style = PaintingStyle.fill;

    canvas.drawCircle(eyeL, 7, blueEyePaint);
    canvas.drawCircle(eyeR, 7, pinkEyePaint);
    canvas.drawCircle(nose, 6, blueEyePaint);
    canvas.drawCircle(mouth, 7, redNodePaint);

    // Eye Contour Nodes (Red facial dots around eyes like in the photo)
    final faceDots = [
      Offset(eyeL.dx - 12, eyeL.dy - 8), Offset(eyeL.dx, eyeL.dy - 12), Offset(eyeL.dx + 12, eyeL.dy - 8),
      Offset(eyeL.dx - 14, eyeL.dy + 4), Offset(eyeL.dx + 14, eyeL.dy + 4),
      Offset(eyeR.dx - 12, eyeR.dy - 8), Offset(eyeR.dx, eyeR.dy - 12), Offset(eyeR.dx + 12, eyeR.dy - 8),
      Offset(eyeR.dx - 14, eyeR.dy + 4), Offset(eyeR.dx + 14, eyeR.dy + 4),
      Offset(mouth.dx - 10, mouth.dy + 6), Offset(mouth.dx + 10, mouth.dy + 6),
    ];
    for (final fd in faceDots) {
      canvas.drawCircle(fd, 4, redNodePaint);
    }

    // 5. Draw Major Red Spherical Joint Nodes
    final bodyJoints = [head, neck, lShoulder, rShoulder, lElbow, lWrist, rElbow, rWrist, spine, lHip, rHip, lKnee, lAnkle, rKnee, rAnkle];
    for (final j in bodyJoints) {
      canvas.drawCircle(j, 12, redNodePaint);
      canvas.drawCircle(j, 15, Paint()..color = Colors.red.withValues(alpha: 0.35)..style = PaintingStyle.stroke..strokeWidth = 2);
    }

    // 6. AR 3D Directional Correction Prompts directly attached to joints
    final tp = TextPainter(textDirection: TextDirection.ltr);

    void drawARCorrectionTag(String text, BiomechanicalErrorSeverity severity, Offset jointPos, Offset offset) {
      Color c;
      switch (severity) {
        case BiomechanicalErrorSeverity.green:
          c = AppColors.emeraldGreen;
          break;
        case BiomechanicalErrorSeverity.yellow:
          c = Colors.amber;
          break;
        case BiomechanicalErrorSeverity.red:
          c = AppColors.roseError;
          break;
      }

      final tagPos = Offset(jointPos.dx + offset.dx, jointPos.dy + offset.dy);

      canvas.drawLine(
        jointPos,
        tagPos,
        Paint()..color = c.withValues(alpha: 0.8)..strokeWidth = 1.5,
      );
      canvas.drawCircle(jointPos, 6, Paint()..color = c..style = PaintingStyle.fill);

      tp.text = TextSpan(
        text: ' $text ',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 10,
          background: Paint()..color = c.withValues(alpha: 0.95)..style = PaintingStyle.fill,
        ),
      );
      tp.layout();
      tp.paint(canvas, tagPos);
    }

    // AR Tags
    final elbowRes = evaluation.jointResults['elbow'];
    if (elbowRes != null) {
      drawARCorrectionTag(
        '${elbowRes.correctionPrompt} [${elbowRes.currentAngle.toInt()}°]',
        elbowRes.severity,
        lElbow,
        const Offset(-130, -20),
      );
    }

    final kneeRes = evaluation.jointResults['knee'];
    if (kneeRes != null) {
      drawARCorrectionTag(
        '${kneeRes.correctionPrompt} [${kneeRes.currentAngle.toInt()}°]',
        kneeRes.severity,
        lKnee,
        const Offset(20, -10),
      );
    }

    final torsoRes = evaluation.jointResults['torso'];
    if (torsoRes != null) {
      drawARCorrectionTag(
        '${torsoRes.correctionPrompt} [Torso: ${evaluation.torsoInclination.toInt()}°]',
        torsoRes.severity,
        spine,
        const Offset(24, 15),
      );
    }
  }

  @override
  bool shouldRepaint(covariant ARBiomechanicsPainter oldDelegate) {
    return oldDelegate.payload.trackingConfidence != payload.trackingConfidence ||
        oldDelegate.evaluation.overallTechniqueScore != evaluation.overallTechniqueScore ||
        oldDelegate.currentPhase.name != currentPhase.name ||
        oldDelegate.isGhostModeEnabled != isGhostModeEnabled ||
        oldDelegate.isReplayModeEnabled != isReplayModeEnabled ||
        oldDelegate.pulseProgress != pulseProgress;
  }
}
